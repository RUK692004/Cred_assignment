import 'package:cred/app/app.dart';
import 'package:cred/app/theme.dart';
import 'package:cred/data/credit_cards.dart';
import 'package:cred/models/credit_card.dart';
import 'package:cred/screens/home/widgets/cashback_banner.dart';
import 'package:cred/screens/home/widgets/credit_card_widget.dart';
import 'package:cred/screens/home/widgets/lower_section.dart';
import 'package:cred/screens/home/widgets/pay_bill_button.dart';
import 'package:cred/screens/home/widgets/stacked_card_list.dart';
import 'package:cred/screens/home/widgets/summary_content.dart';
import 'package:cred/screens/home/widgets/summary_pill.dart';
import 'package:cred/screens/home/widgets/top_controls.dart';
import 'package:cred/screens/home/widgets/upper_background.dart';
import 'package:cred/screens/home/widgets/upper_section.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// The statement amount the header shows, derived from the card data.
const String _statementTotal = '₹50,000.00';

/// The cards the deck paints, front card first.
List<CreditCard> get _visibleCards =>
    kCreditCards.take(StackedCardConfig.maxVisibleCards).toList();

/// Key the deck gives the card at [index] of [kCreditCards].
ValueKey<String> _cardKey(int index) =>
    ValueKey<String>(kCreditCards[index].id);

/// Finder of the card at [index] of the deck, the front card first.
Finder _cardFinder(int index) => find.byKey(_cardKey(index));

/// Finder of the deepest card the hand shows at rest.
Finder get _backCard => _cardFinder(StackedCardConfig.maxVisibleCards - 1);

/// Height of a card as the deck lays it out.
double _cardHeightOf(WidgetTester tester) =>
    tester.getSize(_cardFinder(0)).height;

/// Vertical reveal of every card behind the front one, i.e. the band of it that
/// stays visible: a fraction of the card height, as resolved by the deck.
double _revealOf(WidgetTester tester) =>
    _cardHeightOf(tester) * StackedCardConfig.stackOffsetRatio;

/// Scroll distance that moves the hand by one card.
double _transitionDistanceOf(WidgetTester tester) =>
    (_cardHeightOf(tester) * StackedCardConfig.transitionRatio).clamp(
      StackedCardConfig.minTransitionDistance,
      StackedCardConfig.maxTransitionDistance,
    );

/// Pumps the app on a viewport tall enough to lay the deck out at its natural
/// size, so card positions can be compared without the scale-down guard of
/// [StackedCardList] coming into play.
Future<void> pumpTallApp(WidgetTester tester) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.reset);

  await tester.pumpWidget(const CredApp());
  await tester.pumpAndSettle();
}

void main() {
  group('HomeScreen', () {
    testWidgets('shows the Total Due state by default', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const CredApp());

      expect(find.byType(SummaryPill), findsOneWidget);
      expect(find.text('TOTAL DUE'), findsOneWidget);
      expect(find.text('RECENT SPENDS'), findsOneWidget);
      expect(find.text('STATEMENT DUE FOR 1 CARD'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(SummaryContent),
          matching: find.text(_statementTotal),
        ),
        findsOneWidget,
      );
      expect(find.widgetWithText(PayBillButton, 'Pay bill'), findsOneWidget);
    });

    testWidgets('renders the Phase 2 upper section shell', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const CredApp());

      // Decorative background, "%" button, pill, settings button, banner.
      expect(find.byType(UpperBackground), findsOneWidget);
      expect(find.byType(TopControls), findsOneWidget);
      expect(find.text('%'), findsOneWidget);
      expect(find.byIcon(Icons.settings_outlined), findsOneWidget);
      expect(find.byType(CashbackBanner), findsOneWidget);
      expect(
        find.textContaining('cashback on full bill payments'),
        findsOneWidget,
      );

      // The red notification badge sits on the Total Due option.
      expect(
        find.descendant(
          of: find.byType(SummaryPill),
          matching: find.byType(NotificationDot),
        ),
        findsOneWidget,
      );
    });

    testWidgets('shows the SBI card first in the lower section', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const CredApp());

      expect(find.byType(LowerSection), findsOneWidget);
      expect(find.byType(CreditCardWidget), findsWidgets);
      expect(
        find.byKey(ValueKey<String>(kCreditCards.first.id)),
        findsOneWidget,
      );
      expect(find.text(kCreditCards.first.maskedNumber), findsOneWidget);
    });

    testWidgets('stacks the cards behind the front card without shrinking them', (
      WidgetTester tester,
    ) async {
      await pumpTallApp(tester);

      expect(find.byType(StackedCardList), findsOneWidget);

      // The whole hand is painted, so no card is ever cut off at the edge of
      // the deck ...
      expect(
        kCreditCards.length,
        greaterThan(StackedCardConfig.maxVisibleCards),
      );
      expect(find.byType(CreditCardWidget), findsNWidgets(kCreditCards.length));

      // The front card is the first card of the data ...
      final Rect front = tester.getRect(_cardFinder(0));
      final double reveal = _revealOf(tester);

      // ... and every card behind it keeps the card size: the hand is built
      // from position, never from scale.
      for (int index = 0; index < StackedCardConfig.maxVisibleCards; index++) {
        final Rect card = tester.getRect(_cardFinder(index));

        expect(card.size.width, closeTo(front.size.width, 0.01));
        expect(card.size.height, closeTo(front.size.height, 0.01));
        expect(card.left, closeTo(front.left, 0.01));
        // Each card sits one reveal further down, so a band of it stays visible
        // below the card in front of it.
        expect(
          card.top - front.top,
          closeTo(index * reveal, 0.5),
          reason: _visibleCards[index].bankName,
        );
      }

      // The cards past the visible depth wait exactly behind the deepest
      // card of the hand, hidden until the hand moves on.
      final Rect deepest = tester.getRect(
        _cardFinder(StackedCardConfig.maxVisibleCards - 1),
      );
      for (int index = StackedCardConfig.maxVisibleCards;
          index < kCreditCards.length;
          index++) {
        expect(
          tester.getTopLeft(_cardFinder(index)).dy,
          closeTo(deepest.top, 0.01),
          reason: kCreditCards[index].bankName,
        );
      }

      // The cards really overlap, and the overlap leaves the front card
      // dominant: the card right behind it starts well above the bottom of the
      // front card.
      expect(front.bottom, greaterThan(deepest.top));
      expect(reveal, lessThan(front.height / 2));
    });

    testWidgets('paints the back of the hand before the front card', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const CredApp());
      await tester.pumpAndSettle();

      final List<Key?> painted = tester
          .widgetList<CreditCardWidget>(find.byType(CreditCardWidget))
          .map((CreditCardWidget widget) => widget.key)
          .toList();

      // A Stack paints its children in order, so the deepest card is inserted
      // first and the front card last, which puts it on top of the others.
      expect(painted.first, ValueKey<String>(kCreditCards.last.id));
      expect(painted.last, _cardKey(0));
      expect(painted.length, kCreditCards.length);
    });

    testWidgets('keeps the stack inside the card area', (
      WidgetTester tester,
    ) async {
      await pumpTallApp(tester);

      // The deck owns a ScrollController for drag interaction.
      expect(
        find.descendant(
          of: find.byType(LowerSection),
          matching: find.byType(Scrollable),
        ),
        findsOneWidget,
      );

      final Rect area = tester.getRect(find.byType(LowerSection));
      // The stack starts below the upper section instead of overlapping the
      // pill, the settings button or the summary.
      expect(
        area.top,
        greaterThanOrEqualTo(
          tester.getBottomLeft(find.byType(UpperSection)).dy,
        ),
      );

      for (int index = 0; index < StackedCardConfig.maxVisibleCards; index++) {
        final Rect card = tester.getRect(_cardFinder(index));
        expect(card.top, greaterThanOrEqualTo(area.top));
        expect(card.left, greaterThanOrEqualTo(area.left));
        expect(card.right, lessThanOrEqualTo(area.right));
        expect(
          card.bottom,
          lessThanOrEqualTo(area.bottom),
          reason: _visibleCards[index].bankName,
        );
      }
    });

    testWidgets('switches to the Recent Spends placeholder', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const CredApp());

      await tester.tap(find.text('RECENT SPENDS'));
      await tester.pumpAndSettle();

      // "RECENT SPENDS" is now shown both in the pill and as the state label.
      expect(find.text('RECENT SPENDS'), findsNWidgets(2));
      expect(find.text('₹4,280'), findsOneWidget);
      expect(find.text('Total spent recently'), findsOneWidget);
      expect(
        find.descendant(
          of: find.byType(SummaryContent),
          matching: find.text(_statementTotal),
        ),
        findsNothing,
      );
      expect(find.byType(PayBillButton), findsNothing);

      // Switching tabs only swaps the summary: the cards stay in place.
      expect(find.byKey(ValueKey<String>(kCreditCards.first.id)), findsOneWidget);
    });

    testWidgets('switches back to Total Due', (WidgetTester tester) async {
      await tester.pumpWidget(const CredApp());

      await tester.tap(find.text('RECENT SPENDS'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('TOTAL DUE'));
      await tester.pumpAndSettle();

      expect(
        find.descendant(
          of: find.byType(SummaryContent),
          matching: find.text(_statementTotal),
        ),
        findsOneWidget,
      );
      expect(find.byType(PayBillButton), findsOneWidget);
    });

    testWidgets('Pay bill is tappable but performs no payment', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const CredApp());

      await tester.tap(find.byType(PayBillButton));
      await tester.pumpAndSettle();

      // The phase stays on the same screen: no navigation, no payment.
      expect(find.byType(UpperSection), findsOneWidget);
      expect(find.byType(LowerSection), findsOneWidget);
      expect(find.byType(PayBillButton), findsOneWidget);
    });

    testWidgets('lays out on a small phone without overflow', (
      WidgetTester tester,
    ) async {
      // 320x480 is the smallest phone the dashboard has to support.
      tester.view.physicalSize = const Size(320, 480);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const CredApp());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      expect(find.byType(CreditCardWidget), findsNWidgets(kCreditCards.length));
      // The deck is scaled down rather than cut off, so the whole hand stays
      // inside the card area even when the viewport is very short.
      final Rect area = tester.getRect(find.byType(LowerSection));
      expect(tester.getRect(_backCard).bottom, lessThanOrEqualTo(area.bottom));
    });

    testWidgets('lays out on a wide window without overflow', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(1440, 900);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      await tester.pumpWidget(const CredApp());
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
      // The content column keeps its phone-like width instead of stretching.
      expect(tester.getSize(find.byType(CreditCardWidget).first).width, 440);
    });

    testWidgets('keeps the credit-card aspect ratio on every card', (
      WidgetTester tester,
    ) async {
      await tester.pumpWidget(const CredApp());

      final Size size = tester.getSize(find.byType(CreditCardWidget).first);
      expect(size.width / size.height, closeTo(1.586, 0.01));
    });
  });

  group('StackedCardList', () {
    /// Geometry of the deck on a phone-sized card area.
    StackedCardGeometry phoneGeometry({double height = 462}) =>
        StackedCardGeometry.resolve(
          available: Size(350, height),
          cardCount: kCreditCards.length,
        );

    test('lays every card of the hand one reveal below the previous one', () {
      final StackedCardGeometry geometry = phoneGeometry();

      expect(geometry.cardWidth, 350);
      expect(geometry.cardHeight, closeTo(350 / AppSizes.cardAspectRatio, 0.01));
      // The reveal follows the card size, so the hand keeps its proportions.
      expect(
        geometry.stackOffset,
        closeTo(
          geometry.cardHeight * StackedCardConfig.stackOffsetRatio,
          0.01,
        ),
      );
      // Every card behind the front one is fully visible in the deck: the stack
      // is as tall as the front card plus the reveal of the cards behind it.
      expect(
        geometry.stackHeight,
        closeTo(
          geometry.cardHeight +
              3 * geometry.stackOffset +
              StackedCardConfig.deckBottomPadding,
          0.01,
        ),
      );
      // The hand travels one reveal per card, and can reach the last card.
      expect(
        geometry.maxScrollExtent,
        closeTo(
          (kCreditCards.length - 1) * geometry.transitionDistance,
          0.01,
        ),
      );
    });

    test('tightens the reveal instead of shrinking the cards on a short area', () {
      final StackedCardGeometry tall = phoneGeometry();
      final StackedCardGeometry short = phoneGeometry(height: 320);

      // The cards keep their size ...
      expect(short.cardHeight, tall.cardHeight);
      // ... and the overlap absorbs the missing space.
      expect(short.stackOffset, lessThan(tall.stackOffset));
      expect(short.stackHeight, lessThan(tall.stackHeight));

      // An area too short even for the smallest reveal keeps the cards whole and
      // lets the deck scale down as a whole instead.
      final StackedCardGeometry tiny = phoneGeometry(height: 120);
      expect(tiny.stackOffset, StackedCardConfig.minStackOffset);
      expect(tiny.cardHeight, tall.cardHeight);
    });

    test('keeps the cards past the visible depth behind the deepest one', () {
      final StackedCardGeometry geometry = phoneGeometry();

      expect(geometry.maxDepth, StackedCardConfig.maxVisibleCards - 1);

      // While a card is deeper than the hand, it waits exactly in the deepest
      // slot, hidden behind the card sitting there ...
      final double deepestSlot = geometry.maxDepth * geometry.stackOffset;
      for (final double progress in <double>[0, 0.37, 0.5, 1]) {
        expect(geometry.yOf(4, progress), closeTo(deepestSlot, 0.01));
      }

      // ... and it rises out of the back of the stack as soon as the hand moves
      // on, one reveal per card of scroll.
      expect(geometry.yOf(4, 1.5), lessThan(deepestSlot));
      expect(
        geometry.yOf(4, 1.5),
        closeTo(deepestSlot - geometry.stackOffset / 2, 0.01),
      );

      // The limit is visual only: the underlying data keeps every card.
      expect(kCreditCards.length, 5);
    });

    test('calculates relative position based on card index and scroll progress', () {
      expect(calculateRelativePosition(0, 0.0), 0.0);
      expect(calculateRelativePosition(1, 0.5), 0.5);
      expect(calculateRelativePosition(1, 1.0), 0.0);
      expect(calculateRelativePosition(2, 1.5), 0.5);
    });

    test('keeps the cards of the hand in place and slides the front one out', () {
      double yOf(int index, double progress) => calculateCardY(
            index,
            progress,
            stackOffset: 60,
            exitTravel: 240,
            maxDepth: 3,
          );

      // At rest: the front card is at the top of the deck and every card behind
      // it waits one reveal further down.
      expect(yOf(0, 0), 0);
      expect(yOf(1, 0), 60);
      expect(yOf(2, 0), 120);
      expect(yOf(3, 0), 180);
      // Cards deeper than the hand wait behind the deepest painted card.
      expect(yOf(4, 0), 180);

      // Halfway: the front card is halfway out of the deck while the next card
      // has come half a reveal closer to the front position.
      expect(yOf(0, 0.5), -120);
      expect(yOf(1, 0.5), 30);
      expect(yOf(2, 0.5), 90);

      // The cards waiting behind the front one move up as one: scrolling by a
      // whole card moves each of them up by exactly one reveal.
      for (int index = 1; index < StackedCardConfig.maxVisibleCards; index++) {
        expect(yOf(index, 1.0), closeTo(yOf(index, 0.0) - 60, 0.01));
      }
      // ... while the card that was in front travels its own height, so it never
      // lingers over the card taking its place.
      expect(yOf(0, 1.0), lessThan(yOf(0, 0.0) - 60));
    });

    test('clears the deck completely while a card slides out', () {
      final StackedCardGeometry geometry = phoneGeometry();

      // At the moment the next card takes over, the card that left the front
      // position is above the deck - height and shadow included.
      expect(
        geometry.yOf(0, 1) + geometry.cardHeight,
        lessThanOrEqualTo(0),
      );
    });

    test('keeps the cards of the hand one reveal apart at any scroll position', () {
      double yOf(int index, double progress) => calculateCardY(
            index,
            progress,
            stackOffset: 60,
            exitTravel: 240,
            maxDepth: 3,
          );

      // Whatever the scroll position, the cards waiting behind the front one
      // stay exactly one reveal apart: the hand keeps its shape and moves as a
      // whole instead of being rebuilt card by card.
      for (final double progress in <double>[0, 0.37, 0.5, 0.62, 0.99]) {
        for (int index = 2; index < StackedCardConfig.maxVisibleCards; index++) {
          expect(
            yOf(index, progress) - yOf(index - 1, progress),
            closeTo(60, 0.01),
            reason: 'progress $progress, card $index',
          );
        }
      }
    });

    testWidgets('moves the hand continuously while dragging, and back', (
      WidgetTester tester,
    ) async {
      await pumpTallApp(tester);

      final Rect deck = tester.getRect(find.byType(StackedCardList));
      final List<double> restTops = <double>[
        for (int index = 0; index < StackedCardConfig.maxVisibleCards; index++)
          tester.getTopLeft(_cardFinder(index)).dy,
      ];
      final double reveal = _revealOf(tester);

      // Half a card of travel: a continuous position, not a swap of cards.
      final TestGesture gesture = await tester.startGesture(
        tester.getCenter(find.byType(LowerSection)),
      );
      await gesture.moveBy(Offset(0, -_transitionDistanceOf(tester) / 2));
      await tester.pump();

      // The front card is on its way out of the deck: it left its position but
      // is still on screen.
      final double frontTop = tester.getTopLeft(_cardFinder(0)).dy;
      expect(frontTop, lessThan(restTops[0]));
      expect(frontTop, greaterThan(deck.top - tester.getSize(_cardFinder(0)).height));

      // The cards behind it followed continuously, so they sit between their
      // rest position and the front position ...
      for (int index = 1; index < StackedCardConfig.maxVisibleCards; index++) {
        final double top = tester.getTopLeft(_cardFinder(index)).dy;
        expect(top, lessThan(restTops[index]));
        expect(top, greaterThan(restTops[index] - reveal));
      }
      // ... and still exactly one reveal apart, wherever the drag stopped.
      for (int index = 2; index < StackedCardConfig.maxVisibleCards; index++) {
        expect(
          tester.getTopLeft(_cardFinder(index)).dy -
              tester.getTopLeft(_cardFinder(index - 1)).dy,
          closeTo(reveal, 0.5),
        );
      }

      // Scrolling back returns the hand exactly where it was.
      await gesture.moveBy(Offset(0, _transitionDistanceOf(tester) / 2));
      await tester.pump();
      for (int index = 0; index < StackedCardConfig.maxVisibleCards; index++) {
        expect(
          tester.getTopLeft(_cardFinder(index)).dy,
          closeTo(restTops[index], 0.5),
        );
      }
      await gesture.up();
      await tester.pumpAndSettle();

      expect(tester.takeException(), isNull);
    });

    testWidgets('settles on the next card after a swipe', (
      WidgetTester tester,
    ) async {
      await pumpTallApp(tester);

      final Rect deck = tester.getRect(find.byType(StackedCardList));
      final double restTop = tester.getTopLeft(_cardFinder(0)).dy;
      final double reveal = _revealOf(tester);

      await tester.drag(
        find.byType(LowerSection),
        Offset(0, -1.4 * _transitionDistanceOf(tester)),
      );
      await tester.pumpAndSettle();

      // The second card of the data now sits in the front position ...
      expect(
        tester.getTopLeft(_cardFinder(1)).dy,
        closeTo(restTop, 0.5),
      );
      // ... every card behind it is one reveal further down ...
      expect(
        tester.getTopLeft(_cardFinder(2)).dy - tester.getTopLeft(_cardFinder(1)).dy,
        closeTo(reveal, 0.5),
      );
      // ... and the card that left the deck is gone: it is still painted, but
      // entirely above the clip of the card area.
      expect(
        tester.getRect(_cardFinder(0)).bottom,
        lessThanOrEqualTo(deck.top),
      );
    });

    testWidgets('reaches the last card of the data and stops there', (
      WidgetTester tester,
    ) async {
      await pumpTallApp(tester);

      final Rect front = tester.getRect(_cardFinder(0));

      await tester.drag(find.byType(LowerSection), const Offset(0, -4000));
      await tester.pumpAndSettle();

      // The deck stops on its last card instead of scrolling past it, and that
      // card takes the position and the size of the front card.
      final Finder last = find.byKey(ValueKey<String>(kCreditCards.last.id));
      expect(last, findsOneWidget);
      expect(tester.getTopLeft(last).dy, closeTo(front.top, 0.5));
      expect(tester.getTopLeft(last).dx, closeTo(front.left, 0.01));
      expect(tester.getSize(last).width, closeTo(front.width, 0.01));
      expect(tester.getSize(last).height, closeTo(front.height, 0.01));
    });

    testWidgets('reports the Pay now pill of the card facing the user', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      final List<CreditCard> tapped = <CreditCard>[];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: 350,
                child: StackedCardList(
                  cards: kCreditCards,
                  onPayNow: (CreditCard card) => tapped.add(card),
                ),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // The action sits in the header of a card, so only the card facing the
      // user can be paid: the pills of the cards behind it stay covered.
      await tester.tap(
        find.descendant(
          of: find.byKey(ValueKey<String>(kCreditCards[2].id)),
          matching: find.byType(PayNowButton),
        ),
        // The tap lands on the card covering the pill, which is the point here.
        warnIfMissed: false,
      );
      await tester.pumpAndSettle();
      expect(tapped, isEmpty);

      // Once the hand has moved on, the next card faces the user and its pill
      // pays exactly that card.
      await tester.drag(
        find.byType(StackedCardList),
        Offset(0, -_transitionDistanceOf(tester) - 20),
      );
      await tester.pumpAndSettle();

      final Finder front = find.byKey(ValueKey<String>(kCreditCards[1].id));
      expect(
        tester.getTopLeft(front).dy,
        closeTo(tester.getRect(find.byType(StackedCardList)).top, 0.5),
      );
      await tester.tap(
        find.descendant(of: front, matching: find.byType(PayNowButton)),
      );
      await tester.pumpAndSettle();

      expect(tapped, <CreditCard>[kCreditCards[1]]);
    });

    testWidgets('still reports the tapped card through onPayNow', (
      WidgetTester tester,
    ) async {
      tester.view.physicalSize = const Size(390, 844);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.reset);

      // The IDFC card is the first card of the data that shows "Pay now".
      final CreditCard card = kCreditCards[1];
      CreditCard? tapped;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Align(
              alignment: Alignment.topCenter,
              child: SizedBox(
                width: 350,
                child: StackedCardList(
                  cards: <CreditCard>[card],
                  onPayNow: (CreditCard value) => tapped = value,
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(PayNowButton));
      await tester.pumpAndSettle();

      expect(tapped, card);
    });
  });
}
