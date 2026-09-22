import 'package:flutter/material.dart';

/// Colour palette adapted from the reference design.
abstract final class AppColors {
  static const Color background = Color(0xFFFFFFFF);
  static const Color backgroundWarm = Color(0xFFF7F0EB);
  static const Color surface = Color(0xFFFFFFFF);

  static const Color textPrimary = Color(0xFF141414);
  static const Color textSecondary = Color(0xFF6E6E73);

  /// Track of the summary pill plus the sliding indicator on top of it.
  static const Color pillTrack = Color(0xFFEFEFEE);
  static const Color pillIndicator = Color(0xFFFFFFFF);
  static const Color pillLabelUnselected = Color(0xFF7A7A80);
  static const Color pillShadow = Color(0x1A000000);

  /// Bill card palette.
  static const Color accent = Color(0xFF8A1247);
  static const Color accentDeep = Color(0xFF63092F);
  static const Color cardTextPrimary = Color(0xFFFFFFFF);
  static const Color cardTextSecondary = Color(0xB3FFFFFF);
  static const Color cardChip = Color(0x29FFFFFF);
  static const Color cardHairline = Color(0x1FFFFFFF);
  static const Color cardShadow = Color(0x333A0618);
  static const Color cardDecoration = Color(0x14FFFFFF);
  static const Color cardDecorationSoft = Color(0x0FFFFFFF);

  /// Warm halo painted behind the bill card.
  static const Color cardGlow = Color(0x1FD98A6A);
  static const Color cardGlowFade = Color(0x00D98A6A);

  static const Color buttonPrimary = Color(0xFF141414);
  static const Color onButtonPrimary = Color(0xFFFFFFFF);
}

/// Corner radii, kept together so the shapes stay consistent.
abstract final class AppRadius {
  static const double button = 12;
  static const double card = 22;

  /// Large enough to always render as a fully rounded (pill) shape.
  static const double pill = 999;
}

/// Spacing scale used across the screen.
abstract final class AppSpacing {
  static const double screen = 20;
  static const double sm = 8;
  static const double md = 12;
  static const double lg = 16;
  static const double xl = 24;
  static const double xxl = 32;
}

/// Timings for the Phase 1 micro-interactions.
abstract final class AppDurations {
  /// Sliding indicator of the summary pill.
  static const Duration pill = Duration(milliseconds: 240);

  /// Content swap between the summary tabs.
  static const Duration content = Duration(milliseconds: 260);

  /// Shared easing for both.
  static const Curve curve = Curves.easeOut;
}

/// Text styles shared by more than one widget.
abstract final class AppTextStyles {
  /// Small uppercase label sitting above an amount.
  static const TextStyle eyebrow = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.6,
    height: 1.2,
    color: AppColors.textSecondary,
  );

  /// Hero amount, e.g. the statement due.
  static const TextStyle heroAmount = TextStyle(
    fontSize: 40,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.8,
    height: 1.05,
    color: AppColors.textPrimary,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
  );

  /// Supporting sentence under an amount.
  static const TextStyle caption = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w500,
    height: 1.3,
    color: AppColors.textSecondary,
  );

  static const TextStyle cardTitle = TextStyle(
    fontSize: 19,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.3,
    height: 1.2,
    color: AppColors.cardTextPrimary,
  );

  static const TextStyle cardProvider = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.2,
    height: 1.35,
    color: AppColors.cardTextSecondary,
  );

  static const TextStyle cardAmount = TextStyle(
    fontSize: 27,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.4,
    height: 1.1,
    color: AppColors.cardTextPrimary,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
  );

  static const TextStyle cardChip = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w700,
    letterSpacing: 1,
    height: 1.1,
    color: AppColors.cardTextPrimary,
  );
}

/// Background paintings used by the screen and the bill card.
abstract final class AppGradients {
  /// Soft white-to-warm wash behind the whole screen.
  static const LinearGradient screen = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[
      AppColors.background,
      Color(0xFFFDFBFB),
      AppColors.backgroundWarm,
    ],
    stops: <double>[0, 0.55, 1],
  );

  static const LinearGradient card = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[AppColors.accent, AppColors.accentDeep],
  );

  static const RadialGradient cardGlow = RadialGradient(
    center: Alignment(0, -0.25),
    radius: 0.95,
    colors: <Color>[AppColors.cardGlow, AppColors.cardGlowFade],
  );
}

/// Material theme of the app.
///
/// Phase 1 targets the light design from the reference only.
abstract final class AppTheme {
  static ThemeData get light {
    final ThemeData base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: ColorScheme.fromSeed(seedColor: AppColors.accent),
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: AppColors.textPrimary,
        displayColor: AppColors.textPrimary,
      ),
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.buttonPrimary,
        onPrimary: AppColors.onButtonPrimary,
        secondary: AppColors.accent,
        surface: AppColors.surface,
        onSurface: AppColors.textPrimary,
      ),
      splashFactory: InkRipple.splashFactory,
    );
  }
}

/// Vertical rhythm scale derived from the viewport height.
///
/// Spacing (and the hero amount) are multiplied by this factor so the screen
/// keeps comfortable proportions on short and tall phones alike.
double appScale(BuildContext context) {
  final double height = MediaQuery.sizeOf(context).height;
  return (height / 800).clamp(0.82, 1.18).toDouble();
}
