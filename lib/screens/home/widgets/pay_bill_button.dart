import 'package:flutter/material.dart';

import '../../../app/theme.dart';

/// Primary call to action of the upper section.
///
/// Phase 1 only needs the visual: [onPressed] is a placeholder callback and no
/// payment, navigation or network work happens here.
class PayBillButton extends StatelessWidget {
  const PayBillButton({
    super.key,
    required this.onPressed,
    this.label = 'Pay bill',
  });

  final VoidCallback onPressed;
  final String label;

  @override
  Widget build(BuildContext context) {
    // Inherit the app font from the theme instead of hardcoding a family.
    final TextStyle labelStyle =
        (Theme.of(context).textTheme.labelLarge ?? const TextStyle()).copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.2,
        );

    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.buttonPrimary,
        foregroundColor: AppColors.onButtonPrimary,
        disabledBackgroundColor: AppColors.buttonPrimary,
        elevation: 0,
        minimumSize: const Size(0, 48),
        padding: const EdgeInsets.symmetric(horizontal: 34, vertical: 14),
        splashFactory: InkRipple.splashFactory,
        shape: const StadiumBorder(),
        textStyle: labelStyle,
      ),
      child: Text(label, maxLines: 1, overflow: TextOverflow.ellipsis),
    );
  }
}
