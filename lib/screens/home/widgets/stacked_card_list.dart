import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import '../../../models/credit_card.dart';
import 'credit_card_widget.dart';

/// Tuning values of the stacked deck.
///
/// Every distance is a fraction of the card, so the hand keeps its proportions
/// on any screen: [StackedCardGeometry] resolves the ratios against the real
/// card size of the current layout. These are starting values - change them
/// here and the deck follows.
abstract final class StackedCardConfig {
  /// How much of a card stays visible behind the next one, as a fraction of the
  /// card height.
  ///
  /// This reveal is what makes the hand read as a physical stack of cards
  /// instead of a list: every card behind the front one is offset downwards by
  /// this much, so a band of it stays exposed.
  static const double stackOffsetRatio = 0.22;

  /// Bounds of the reveal, in logical pixels.
  static const double minStackOffset = 48;
  static const double maxStackOffset = 64;

  /// Cards the deck shows at once: the front card plus the cards behind it.
  static const int maxVisibleCards = 4;

  /// How far the finger travels to move the hand by one card, as a fraction of
  /// the card height.
  static const double transitionRatio = 0.55;
  static const double minTransitionDistance = 96;
  static const double maxTransitionDistance = 150;

  /// Space kept below the deepest card so its shadow is not clipped.
  static const double deckBottomPadding = 24;

  /// Distance past the top of the deck, on top of its own height, that a card
  /// travels while sliding out, so it is completely gone - shadow included - by
  /// the time the next card has taken its place.
  static const double exitGap = 32;
}

/// Relative position of the card at [index] for the deck's [scrollProgress].
///
/// `0` is the position facing the user, values above `0` are the cards waiting
/// behind it and values below `0` are the cards sliding out of the deck.
double calculateRelativePosition(int index, double scrollProgress) {
  return index - scrollProgress;
}

/// Vertical position of the card at [index] inside the deck, in logical pixels.
///
/// Three regimes, all driven by the continuous [scrollProgress]:
///  * sliding out (`relativePosition < 0`): one [exitTravel] per card step, so
///    the card clears the top edge of the deck and disappears completely;
///  * waiting behind the front card (`0 <= relativePosition <= maxDepth`): one
///    [stackOffset] per step of depth, which is the overlap of the hand;
///  * deeper than the [maxDepth] cards the deck shows: it waits exactly behind
///    the deepest one instead of sticking out of the bottom of the deck.
double calculateCardY(
  int index,
  double scrollProgress, {
  required double stackOffset,
  required double exitTravel,
  required int maxDepth,
}) {
  final double relative = calculateRelativePosition(index, scrollProgress);
  if (relative < 0) {
    return relative * exitTravel;
  }
  return math.min(relative, maxDepth.toDouble()) * stackOffset;
}

/// Shape of the deck for one layout pass.
///
/// Resolving the geometry once per layout keeps the card size, the overlap and
/// the travel distances consistent with each other and with the space the card
/// area actually offers - and keeps the mathematics out of the widget tree.
@immutable
class StackedCardGeometry {
  const StackedCardGeometry({
    required this.cardWidth,
    required this.cardHeight,
    required this.stackOffset,
    required this.transitionDistance,
    required this.cardCount,
  });

  /// Resolves the deck inside the [available] space of the card area.
  ///
  /// The cards keep their natural size: the reveal is what adapts when the card
  /// area is short.
  factory StackedCardGeometry.resolve({
    required Size available,
    required int cardCount,
  }) {
    final double cardWidth = available.width;
    final double cardHeight = cardWidth / AppSizes.cardAspectRatio;
    final int depth = math.max(
      math.min(StackedCardConfig.maxVisibleCards, cardCount) - 1,
      0,
    );

    // Reveal asked for by the card size ...
    final double wanted = (cardHeight * StackedCardConfig.stackOffsetRatio)
        .clamp(StackedCardConfig.minStackOffset, StackedCardConfig.maxStackOffset);

    // ... trimmed when the card area cannot hold the whole hand, so a short
    // screen tightens the overlap instead of shrinking the cards.
    double stackOffset = wanted;
    if (depth > 0 && available.height.isFinite) {
      final double room =
          available.height - cardHeight - StackedCardConfig.deckBottomPadding;
      stackOffset = math.min(
        wanted,
        math.max(room / depth, StackedCardConfig.minStackOffset),
      );
    }

    final double transitionDistance =
        (cardHeight * StackedCardConfig.transitionRatio).clamp(
      StackedCardConfig.minTransitionDistance,
      StackedCardConfig.maxTransitionDistance,
    );

    return StackedCardGeometry(
      cardWidth: cardWidth,
      cardHeight: cardHeight,
      stackOffset: stackOffset,
      transitionDistance: transitionDistance,
      cardCount: cardCount,
    );
  }

  /// Width of a card, i.e. the width of the card area.
  final double cardWidth;

  /// Natural height of a card, derived from its aspect ratio.
  final double cardHeight;

  /// Vertical distance between two neighbouring cards of the hand.
  final double stackOffset;

  /// Scroll distance that moves the hand by one card.
  final double transitionDistance;

  /// Cards available to the deck.
  final int cardCount;

  /// Depth of the deepest card the deck shows, i.e. how many cards are stacked
  /// behind the front one.
  ///
  /// Cards deeper than that wait exactly behind the deepest one, so the back of
  /// the stack always looks complete and a new card grows out of it as the hand
  /// moves on instead of appearing all at once.
  int get maxDepth =>
      math.max(math.min(StackedCardConfig.maxVisibleCards, cardCount) - 1, 0);

  /// Height of the stack itself: the front card, the visible reveal of every
  /// card behind it and the room the shadow of the deepest card needs.
  double get stackHeight =>
      cardHeight + maxDepth * stackOffset + StackedCardConfig.deckBottomPadding;

  /// Distance a card covers while sliding out of the deck.
  double get exitTravel => cardHeight + StackedCardConfig.exitGap;

  /// Scroll extent of the hand: one [transitionDistance] per card.
  double get maxScrollExtent => math.max(cardCount - 1, 0) * transitionDistance;

  /// Height of the scrollable area: the stack plus the distance the cards
  /// travel, so a drag anywhere on the hand moves the whole hand.
  double get contentHeight => stackHeight + maxScrollExtent;

  /// Continuous position of the hand, in cards, for a [scrollOffset].
  double progressOf(double scrollOffset) => scrollOffset / transitionDistance;

  /// Vertical position of the card at [index] for [scrollProgress].
  double yOf(int index, double scrollProgress) => calculateCardY(
        index,
        scrollProgress,
        stackOffset: stackOffset,
        exitTravel: exitTravel,
        maxDepth: maxDepth,
      );
}

/// Custom scroll physics that snaps the card stack to integer card positions
/// on scroll release while preserving continuous drag movement.
class StackedCardScrollPhysics extends ScrollPhysics {
  const StackedCardScrollPhysics({
    required this.itemDimension,
    super.parent,
  });

  /// The scroll distance corresponding to one card step.
  final double itemDimension;

  @override
  StackedCardScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return StackedCardScrollPhysics(
      itemDimension: itemDimension,
      parent: buildParent(ancestor),
    );
  }

  double _getTargetPixels(
      ScrollMetrics position, Tolerance tolerance, double velocity) {
    double page = position.pixels / itemDimension;
    if (velocity < -tolerance.velocity) {
      page = page.floorToDouble();
    } else if (velocity > tolerance.velocity) {
      page = page.ceilToDouble();
    } else {
      page = page.roundToDouble();
    }
    return page * itemDimension;
  }

  @override
  Simulation? createBallisticSimulation(
      ScrollMetrics position, double velocity) {
    if ((velocity <= 0.0 && position.pixels <= position.minScrollExtent) ||
        (velocity >= 0.0 && position.pixels >= position.maxScrollExtent)) {
      return super.createBallisticSimulation(position, velocity);
    }
    final Tolerance tolerance = toleranceFor(position);
    final double target = _getTargetPixels(position, tolerance, velocity);
    if (target != position.pixels) {
      return ScrollSpringSimulation(
        spring,
        position.pixels,
        target,
        velocity,
        tolerance: tolerance,
      );
    }
    return null;
  }
}

/// The bank cards of the dashboard, layered into one hand of cards.
///
/// The deck behaves like a physical stack:
///  * the card facing the user sits in a fixed position and keeps its size, and
///    the cards behind it are offset downwards, so a band of each one stays
///    visible - they are never shrunk to make room;
///  * dragging the hand upwards moves every card continuously: the front card
///    slides out through the top of the deck while the next one rises into the
///    front position;
///  * releasing the drag settles the hand on the nearest card.
///
/// Only this widget listens to the scroll position, so the rest of the screen
/// is not rebuilt while the hand moves.
class StackedCardList extends StatefulWidget {
  const StackedCardList({super.key, required this.cards, this.onPayNow});

  /// Cards to stack, the front card first.
  final List<CreditCard> cards;

  /// Called with the card whose "Pay now" pill was tapped.
  final ValueChanged<CreditCard>? onPayNow;

  @override
  State<StackedCardList> createState() => _StackedCardListState();
}

class _StackedCardListState extends State<StackedCardList> {
  /// Drives the hand: its offset is the continuous position of the deck.
  late final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.cards.isEmpty) {
      return const SizedBox.shrink();
    }

    return LayoutBuilder(
      builder: (BuildContext context, BoxConstraints constraints) {
        final StackedCardGeometry geometry = StackedCardGeometry.resolve(
          available: Size(constraints.maxWidth, constraints.maxHeight),
          cardCount: widget.cards.length,
        );

        // The hand is laid out at its natural size. The box only steps in on a
        // viewport too short to hold it, so the cards are never shrunk on a
        // normal phone; there, the viewport is the stack itself, which is what
        // clips the card sliding out through the top of the deck.
        return FittedBox(
          fit: BoxFit.scaleDown,
          alignment: Alignment.topCenter,
          child: SizedBox(
            width: geometry.cardWidth,
            height: geometry.stackHeight,
            child: SingleChildScrollView(
              controller: _scrollController,
              physics: StackedCardScrollPhysics(
                itemDimension: geometry.transitionDistance,
                parent: const ClampingScrollPhysics(),
              ),
              child: SizedBox(
                width: geometry.cardWidth,
                height: geometry.contentHeight,
                child: AnimatedBuilder(
                  animation: _scrollController,
                  builder: (BuildContext context, Widget? child) =>
                      _hand(geometry),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// The cards of the hand, deepest first, so the front card paints on top.
  ///
  /// Every card of [StackedCardList.cards] is painted: a card waiting deeper
  /// than the visible stack hides exactly behind the deepest card, and the one
  /// sliding out is clipped by the viewport above the deck. That way the hand
  /// has no cut-off entries and no card ever pops in or out.
  ///
  /// The scroll view moves its content up while every card is moved down by the
  /// same amount, which pins the hand to the viewport: only the positions of
  /// [geometry] decide where a card really is.
  Widget _hand(StackedCardGeometry geometry) {
    final double scrollOffset =
        _scrollController.hasClients ? _scrollController.offset : 0;
    final double scrollProgress = geometry.progressOf(scrollOffset);

    return Stack(
      clipBehavior: Clip.none,
      children: <Widget>[
        for (int index = widget.cards.length - 1; index >= 0; index--)
          _card(
            geometry,
            index,
            scrollOffset + geometry.yOf(index, scrollProgress),
          ),
      ],
    );
  }

  /// One card of the hand, positioned [top] logical pixels inside the
  /// scrollable area.
  Widget _card(StackedCardGeometry geometry, int index, double top) {
    final CreditCard card = widget.cards[index];

    return Positioned(
      top: top,
      left: 0,
      child: SizedBox(
        width: geometry.cardWidth,
        height: geometry.cardHeight,
        child: CreditCardWidget(
          key: ValueKey<String>(card.id),
          card: card,
          onPayNow:
              widget.onPayNow == null ? null : () => widget.onPayNow!(card),
        ),
      ),
    );
  }
}


