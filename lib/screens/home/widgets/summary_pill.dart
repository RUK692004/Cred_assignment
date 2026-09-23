import 'package:flutter/material.dart';

import '../../../app/theme.dart';

/// Labels of the summary pill, left to right.
///
/// Phase 1 ships exactly two tabs; the widget itself is written so that more
/// can be added later without touching the animation math.
const List<String> kSummaryPillLabels = <String>['Total Due', 'Recent Spends'];

/// Index of the "Total Due" tab - the primary state of the screen.
const int kTotalDueTab = 0;

/// Index of the "Recent Spends" tab - a placeholder state in Phase 1.
const int kRecentSpendsTab = 1;

/// Height of the selectable row inside the pill.
const double _segmentHeight = 46;

/// Thickness of the grey track around the sliding indicator.
const double _trackPadding = 5;

/// Segmented control used to switch between "Total Due" and "Recent Spends".
///
/// The widget is stateless: the parent owns the selected index and is notified
/// through [onSelected], which keeps the animation a pure function of the
/// selected index (no animation controller bookkeeping needed).
class SummaryPill extends StatelessWidget {
  const SummaryPill({
    super.key,
    required this.selectedIndex,
    required this.onSelected,
    this.labels = kSummaryPillLabels,
    this.badgeTabs = const <int>{},
  });

  final int selectedIndex;
  final ValueChanged<int> onSelected;
  final List<String> labels;

  /// Indexes of [labels] that show the red notification dot to their right.
  final Set<int> badgeTabs;

  /// Where the indicator sits for [index], distributed evenly across the track.
  Alignment _indicatorAlignment(int index) {
    if (labels.length < 2) {
      return Alignment.center;
    }
    final double step = 2 / (labels.length - 1);
    return Alignment(-1 + step * index, 0);
  }

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.pillTrack,
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Padding(
        padding: const EdgeInsets.all(_trackPadding),
        child: LayoutBuilder(
          builder: (BuildContext context, BoxConstraints constraints) {
            final double segmentWidth = constraints.maxWidth / labels.length;

            return Stack(
              children: <Widget>[
                // The sliding selection indicator.
                SizedBox(
                  height: _segmentHeight,
                  child: AnimatedAlign(
                    alignment: _indicatorAlignment(selectedIndex),
                    duration: AppDurations.pill,
                    curve: AppDurations.curve,
                    child: Container(
                      width: segmentWidth,
                      height: _segmentHeight,
                      decoration: BoxDecoration(
                        color: AppColors.pillIndicator,
                        borderRadius: BorderRadius.circular(AppRadius.pill),
                        boxShadow: const <BoxShadow>[
                          BoxShadow(
                            color: AppColors.pillShadow,
                            blurRadius: 8,
                            offset: Offset(0, 2),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  height: _segmentHeight,
                  child: Row(
                    children: <Widget>[
                      for (int index = 0; index < labels.length; index++)
                        Expanded(
                          child: _PillTab(
                            label: labels[index],
                            selected: index == selectedIndex,
                            showBadge: badgeTabs.contains(index),
                            onTap: () => onSelected(index),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PillTab extends StatelessWidget {
  const _PillTab({
    required this.label,
    required this.selected,
    required this.showBadge,
    required this.onTap,
  });

  final String label;
  final bool selected;

  /// Whether the red notification dot is drawn next to [label].
  final bool showBadge;

  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    // Inherit the app font from the theme instead of hardcoding a family.
    final TextStyle baseStyle =
        Theme.of(context).textTheme.labelLarge ?? const TextStyle();

    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        child: Center(
          child: AnimatedDefaultTextStyle(
            duration: AppDurations.pill,
            curve: AppDurations.curve,
            style: baseStyle.copyWith(
              fontSize: 11.5,
              fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
              letterSpacing: 1.05,
              color: selected
                  ? AppColors.textPrimary
                  : AppColors.pillLabelUnselected,
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Flexible(
                  child: Text(
                    label.toUpperCase(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
                if (showBadge) ...<Widget>[
                  const SizedBox(width: 5),
                  const NotificationDot(),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Small red dot marking a pill option that needs the user's attention.
class NotificationDot extends StatelessWidget {
  const NotificationDot({super.key, this.size = 7});

  final double size;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: 'new',
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.badge,
          border: Border.all(color: AppColors.pillIndicator, width: 1),
        ),
      ),
    );
  }
}
