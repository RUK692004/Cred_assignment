import 'package:flutter/material.dart';

import '../../../app/theme.dart';
import 'summary_pill.dart';

/// Controls sitting at the very top of the upper section.
///
/// A circular "%" button, the sliding [SummaryPill] and the settings button,
/// laid out in one row. The pill takes all the space that is left, so the row
/// adapts to any width without hardcoded positions.
class TopControls extends StatelessWidget {
  const TopControls({
    super.key,
    required this.selectedTab,
    required this.onTabSelected,
    required this.onRewards,
    required this.onSettings,
    this.badgeTabs = const <int>{kTotalDueTab},
  });

  /// Index of the selected pill option, see [kTotalDueTab].
  final int selectedTab;

  final ValueChanged<int> onTabSelected;

  /// Opens the rewards / offers view.
  final VoidCallback onRewards;

  /// Opens the settings view.
  final VoidCallback onSettings;

  /// Pill options that carry the red notification badge.
  final Set<int> badgeTabs;

  @override
  Widget build(BuildContext context) {
    final double scale = appScale(context);

    return Row(
      children: <Widget>[
        _CircleButton(
          semanticLabel: 'Rewards',
          onPressed: onRewards,
          child: const Text('%', style: AppTextStyles.controlGlyph),
        ),
        SizedBox(width: AppSpacing.md * scale),
        Expanded(
          child: SummaryPill(
            selectedIndex: selectedTab,
            onSelected: onTabSelected,
            badgeTabs: badgeTabs,
          ),
        ),
        SizedBox(width: AppSpacing.md * scale),
        _CircleButton(
          semanticLabel: 'Settings',
          onPressed: onSettings,
          child: Icon(
            Icons.settings_outlined,
            size: 19 * scale,
            color: AppColors.textPrimary,
          ),
        ),
      ],
    );
  }
}

/// Small circular button used on both sides of the summary pill.
class _CircleButton extends StatelessWidget {
  const _CircleButton({
    required this.semanticLabel,
    required this.onPressed,
    required this.child,
  });

  final String semanticLabel;
  final VoidCallback onPressed;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final double size = AppSizes.control * appScale(context);

    return Semantics(
      button: true,
      label: semanticLabel,
      child: SizedBox(
        width: size,
        height: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.controlSurface,
            border: Border.all(color: AppColors.controlBorder),
            boxShadow: const <BoxShadow>[
              BoxShadow(
                color: AppColors.controlShadow,
                blurRadius: 10,
                offset: Offset(0, 4),
              ),
            ],
          ),
          child: Material(
            type: MaterialType.transparency,
            child: InkWell(
              onTap: onPressed,
              customBorder: const CircleBorder(),
              child: Center(child: child),
            ),
          ),
        ),
      ),
    );
  }
}
