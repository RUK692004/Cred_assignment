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

  /// Circular "%" and settings buttons sitting beside the summary pill.
  static const Color controlSurface = Color(0xF2FFFFFF);
  static const Color controlBorder = Color(0x1A141414);
  static const Color controlShadow = Color(0x14141414);

  /// Red dot marking a pill option that needs attention.
  static const Color badge = Color(0xFFE5484D);

  /// Cashback banner at the bottom of the upper section.
  static const Color cashbackSurface = Color(0xFFFFFFFF);
  static const Color cashbackBorder = Color(0x1A8A1247);
  static const Color cashbackIconSurface = Color(0x148A1247);

  /// Decorative marks painted into the upper background. The alphas are kept
  /// deliberately low so the artwork can never hurt readability.
  static const Color decorInk = Color(0x12141414);
  static const Color decorAccent = Color(0x148A1247);
  static const Color decorCool = Color(0x0F2F5BFF);

  /// Credit-card chrome: chip, "Pay now" pill and the card hairline.
  static const Color chipGold = Color(0xFFE8D2A2);
  static const Color chipGoldDeep = Color(0xFFB3924F);
  static const Color chipLine = Color(0x33000000);
  static const Color payNowSurface = Color(0xFFFFFFFF);
  static const Color onPayNowSurface = Color(0xFF141414);
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

/// Fixed sizes shared by more than one widget, so no widget has to hardcode
/// them.
abstract final class AppSizes {
  /// Width-to-height ratio of a payment card (ISO/IEC 7810 ID-1).
  static const double cardAspectRatio = 1.586;

  /// Side of the circular "%" and settings buttons.
  static const double control = 40;

  /// Slightly rounded square used by the cashback icon.
  static const double bannerIcon = 28;
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

  /// Glyph shown inside the circular "%" button.
  static const TextStyle controlGlyph = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w800,
    height: 1.1,
    color: AppColors.textPrimary,
  );

  /// Promotional sentence of the cashback banner.
  static const TextStyle cashback = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    height: 1.25,
    color: AppColors.accent,
  );

  /// Emphasised part of the cashback sentence, e.g. the amount.
  static const TextStyle cashbackAmount = TextStyle(
    fontSize: 13,
    fontWeight: FontWeight.w800,
    height: 1.25,
    color: AppColors.accent,
  );

  /// Masked card number. The colour is overridden per card.
  static const TextStyle cardNumber = TextStyle(
    fontSize: 13.5,
    fontWeight: FontWeight.w600,
    letterSpacing: 1.8,
    height: 1.1,
    color: AppColors.cardTextPrimary,
  );

  /// Card holder name printed at the bottom of a card.
  static const TextStyle cardHolder = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.1,
    height: 1.15,
    color: AppColors.cardTextPrimary,
  );

  /// Outstanding amount shown on a card.
  static const TextStyle cardDueAmount = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.2,
    height: 1.1,
    color: AppColors.cardTextPrimary,
    fontFeatures: <FontFeature>[FontFeature.tabularFigures()],
  );

  /// Due date line under [cardDueAmount].
  static const TextStyle cardDueDate = TextStyle(
    fontSize: 9.5,
    fontWeight: FontWeight.w700,
    letterSpacing: 1.2,
    height: 1.2,
    color: AppColors.cardTextSecondary,
  );

  /// Label of the white "Pay now" pill drawn on a card.
  static const TextStyle payNow = TextStyle(
    fontSize: 12.5,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.2,
    height: 1.1,
    color: AppColors.onPayNowSurface,
  );

  /// Fallback wordmark used when a card has no dedicated logo artwork.
  static const TextStyle cardWordmark = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w800,
    letterSpacing: 1.4,
    height: 1.15,
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

  /// Wash behind the upper section.
  ///
  /// Off-white at the top, cooling into a light grey and finally fading to
  /// transparent, so the section blends seamlessly into the screen gradient
  /// that paints the card area below it.
  static const LinearGradient upperSection = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: <Color>[Color(0xFFFFFFFF), Color(0xFFF4F4F6), Color(0x00F4F4F6)],
    stops: <double>[0, 0.7, 1],
  );

  /// Golden sheen of the card chip.
  static const LinearGradient chip = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: <Color>[AppColors.chipGold, AppColors.chipGoldDeep],
  );
}

/// Material theme of the app.
abstract final class AppTheme {
  /// Light theme configuration.
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

  /// Dark theme configuration.
  static ThemeData get dark {
    final ThemeData base = ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: const Color(0xFF121212),
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.accent,
        brightness: Brightness.dark,
      ),
    );

    return base.copyWith(
      textTheme: base.textTheme.apply(
        bodyColor: const Color(0xFFF2F2F7),
        displayColor: const Color(0xFFF2F2F7),
      ),
      colorScheme: base.colorScheme.copyWith(
        primary: AppColors.accent,
        onPrimary: Colors.white,
        secondary: AppColors.accentDeep,
        surface: const Color(0xFF1C1C1E),
        onSurface: const Color(0xFFF2F2F7),
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
