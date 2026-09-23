import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../app/theme.dart';

/// Decorative backdrop of the upper section.
///
/// The layer reproduces the light, premium look of the Phase 2 reference: an
/// off-white wash that fades into the screen background, plus a handful of
/// barely visible bank-card motifs - card silhouettes, a chip, a masked number
/// and paper-like confetti marks around the edges.
///
/// Everything is painted with Flutter primitives, so there is no raster asset
/// to ship and the artwork stays crisp at any density. It is decorative only:
/// the widget ignores pointers and every mark is transparent enough to leave
/// the summary text fully readable.
class UpperBackground extends StatelessWidget {
  const UpperBackground({super.key});

  @override
  Widget build(BuildContext context) {
    return const IgnorePointer(
      child: DecoratedBox(
        decoration: BoxDecoration(gradient: AppGradients.upperSection),
        child: ClipRect(child: CustomPaint(painter: _UpperBackgroundPainter())),
      ),
    );
  }
}

/// A single confetti / ribbon mark, positioned as a fraction of the section.
@immutable
class _ConfettiMark {
  const _ConfettiMark({
    required this.dx,
    required this.dy,
    required this.length,
    required this.angle,
    required this.tint,
    this.opacity = 1,
  });

  /// Horizontal position, 0 (left edge) to 1 (right edge).
  final double dx;

  /// Vertical position, 0 (top edge) to 1 (bottom edge).
  final double dy;

  /// Length of the mark in percent of the section width.
  final double length;

  /// Rotation in radians.
  final double angle;

  /// `0` ink, `1` brand accent, `2` cool blue.
  final int tint;

  /// Relative strength, `0` to `1`.
  final double opacity;
}

/// Marks scattered around the edges of the section, as in the reference.
const List<_ConfettiMark> _confetti = <_ConfettiMark>[
  _ConfettiMark(dx: 0.05, dy: 0.13, length: 11, angle: -0.6, tint: 0),
  _ConfettiMark(dx: 0.14, dy: 0.06, length: 7, angle: 0.9, tint: 1, opacity: 0.8),
  _ConfettiMark(dx: 0.29, dy: 0.02, length: 9, angle: -0.25, tint: 2, opacity: 0.7),
  _ConfettiMark(dx: 0.45, dy: 0.07, length: 6, angle: 1.2, tint: 0, opacity: 0.6),
  _ConfettiMark(dx: 0.78, dy: 0.04, length: 10, angle: -0.8, tint: 1, opacity: 0.75),
  _ConfettiMark(dx: 0.93, dy: 0.12, length: 8, angle: 0.4, tint: 0, opacity: 0.8),
  _ConfettiMark(dx: 0.97, dy: 0.29, length: 12, angle: 1.05, tint: 2, opacity: 0.7),
  _ConfettiMark(dx: 0.03, dy: 0.41, length: 9, angle: 0.2, tint: 0, opacity: 0.6),
  _ConfettiMark(dx: 0.09, dy: 0.62, length: 7, angle: -0.9, tint: 1, opacity: 0.5),
  _ConfettiMark(dx: 0.88, dy: 0.55, length: 10, angle: 0.75, tint: 0, opacity: 0.45),
];


/// Paints the whole decorative layer in one pass.
class _UpperBackgroundPainter extends CustomPainter {
  const _UpperBackgroundPainter();

  /// Dampens the alpha of a decorative colour, e.g. `0.5` for half strength.
  static Color _fade(Color color, double factor) =>
      color.withValues(alpha: color.a * factor);

  /// Marks towards the bottom of the section fade out, so the artwork never
  /// collides with the card list underneath.
  static double _fadeAt(double y, double height) =>
      1 - ((y - height * 0.55) / (height * 0.45)).clamp(0.0, 1.0);

  @override
  void paint(Canvas canvas, Size size) {
    if (size.isEmpty) {
      return;
    }
    canvas.clipRect(Offset.zero & size);

    _paintHalos(canvas, size);
    _paintCardSilhouettes(canvas, size);
    _paintChipAndNumber(canvas, size);
    _paintConfetti(canvas, size);
    _paintArcs(canvas, size);
  }

  /// Two very soft colour washes that keep the flat background from looking
  /// empty.
  void _paintHalos(Canvas canvas, Size size) {
    _paintHalo(
      canvas,
      center: Offset(size.width * 0.1, size.height * 0.08),
      radius: size.width * 0.6,
      color: AppColors.decorCool,
    );
    _paintHalo(
      canvas,
      center: Offset(size.width * 0.92, size.height * 0.12),
      radius: size.width * 0.42,
      color: AppColors.decorAccent,
    );
  }

  void _paintHalo(
    Canvas canvas, {
    required Offset center,
    required double radius,
    required Color color,
  }) {
    final Rect bounds = Rect.fromCircle(center: center, radius: radius);
    canvas.drawCircle(
      center,
      radius,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[_fade(color, 0.9), _fade(color, 0)],
        ).createShader(bounds),
    );
  }

  /// Outlines of two credit cards, tucked into the corners.
  void _paintCardSilhouettes(Canvas canvas, Size size) {
    _paintCardOutline(
      canvas,
      center: Offset(size.width * 0.94, size.height * 0.2),
      width: size.width * 0.42,
      angle: -0.45,
      color: _fade(AppColors.decorInk, _fadeAt(size.height * 0.2, size.height)),
    );
    _paintCardOutline(
      canvas,
      center: Offset(size.width * 0.06, size.height * 0.82),
      width: size.width * 0.36,
      angle: 0.5,
      color: _fade(
        AppColors.decorInk,
        0.6 * _fadeAt(size.height * 0.82, size.height),
      ),
    );
  }

  void _paintCardOutline(
    Canvas canvas, {
    required Offset center,
    required double width,
    required double angle,
    required Color color,
  }) {
    final double height = width / AppSizes.cardAspectRatio;

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(angle);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(center: Offset.zero, width: width, height: height),
        Radius.circular(width * 0.09),
      ),
      Paint()
        ..color = color
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.1,
    );
    canvas.restore();
  }

  /// A chip outline plus a masked card number, the two most recognisable card
  /// details.
  void _paintChipAndNumber(Canvas canvas, Size size) {
    final double fade = _fadeAt(size.height * 0.34, size.height);
    if (fade <= 0) {
      return;
    }

    final Paint outline = Paint()
      ..color = _fade(AppColors.decorInk, fade)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.05;

    final Rect chip = Rect.fromLTWH(
      size.width * 0.07,
      size.height * 0.29,
      size.width * 0.11,
      size.width * 0.085,
    );
    final RRect chipBody = RRect.fromRectAndRadius(
      chip,
      Radius.circular(chip.height * 0.22),
    );
    canvas.drawRRect(chipBody, outline);

    canvas.save();
    canvas.clipRRect(chipBody);
    final double third = chip.width / 3;
    canvas.drawLine(
      Offset(chip.left + third, chip.top),
      Offset(chip.left + third, chip.bottom),
      outline,
    );
    canvas.drawLine(
      Offset(chip.left + third * 2, chip.top),
      Offset(chip.left + third * 2, chip.bottom),
      outline,
    );
    canvas.drawLine(
      Offset(chip.left, chip.center.dy),
      Offset(chip.right, chip.center.dy),
      outline,
    );
    canvas.restore();

    // Masked number: four short bars sitting under the chip.
    final Paint fill = Paint()..color = _fade(AppColors.decorInk, fade * 1.1);
    for (int group = 0; group < 4; group++) {
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromLTWH(
            chip.left + group * size.width * 0.082,
            chip.bottom + size.height * 0.045,
            size.width * 0.062,
            2.4,
          ),
          const Radius.circular(2),
        ),
        fill,
      );
    }
  }

  /// Paper-like confetti marks around the edges.
  void _paintConfetti(Canvas canvas, Size size) {
    for (final _ConfettiMark mark in _confetti) {
      final double y = size.height * mark.dy;
      final double fade = _fadeAt(y, size.height) * mark.opacity;
      if (fade <= 0) {
        continue;
      }

      final Color color = switch (mark.tint) {
        1 => AppColors.decorAccent,
        2 => AppColors.decorCool,
        _ => AppColors.decorInk,
      };

      // The marks scale with the section width so the density stays constant.
      final double length = size.width * mark.length / 100;

      canvas.save();
      canvas.translate(size.width * mark.dx, y);
      canvas.rotate(mark.angle);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset.zero,
            width: length,
            height: length * 0.24,
          ),
          Radius.circular(length * 0.12),
        ),
        Paint()..color = _fade(color, fade),
      );
      canvas.restore();
    }
  }

  /// Two card-like arcs in the bottom-left corner.
  void _paintArcs(Canvas canvas, Size size) {
    final double fade = _fadeAt(size.height * 0.9, size.height);
    if (fade <= 0) {
      return;
    }

    final Paint arc = Paint()
      ..color = _fade(AppColors.decorInk, fade * 0.9)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.1;

    for (int ring = 0; ring < 2; ring++) {
      canvas.drawArc(
        Rect.fromCircle(
          center: Offset(-size.width * 0.04, size.height * 1.16),
          radius: size.width * (0.42 + ring * 0.14),
        ),
        -math.pi * 0.42,
        math.pi * 0.84,
        false,
        arc,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _UpperBackgroundPainter oldDelegate) => false;
}
