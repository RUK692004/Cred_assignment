import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../models/credit_card.dart';

/// Bank logos and card-face artwork.
///
/// [BankLogo] draws the bank wordmark and [BankCardPattern] paints the card
/// background. Both switch on [CreditCard.artwork], so adding a bank means
/// adding one case here - [CreditCardWidget] itself never changes.
class BankLogo extends StatelessWidget {
  const BankLogo({super.key, required this.card, this.scale = 1});

  final CreditCard card;

  /// Multiplier applied to the logo metrics, so the logo follows the card size
  /// instead of being pinned to fixed pixels.
  final double scale;

  @override
  Widget build(BuildContext context) {
    final String? asset = card.logoAsset;
    if (asset != null) {
      return Image.asset(asset, height: 34 * scale, fit: BoxFit.contain);
    }

    return switch (card.artwork) {
      BankArtwork.sbi => _SbiWordmark(card: card, scale: scale),
      BankArtwork.idfcFirst => _IdfcWordmark(card: card, scale: scale),
      BankArtwork.hdfc => _HdfcWordmark(card: card, scale: scale),
      BankArtwork.yesBank => _YesWordmark(card: card, scale: scale),
      BankArtwork.axis => _AxisWordmark(card: card, scale: scale),
    };
  }
}

/// Same colour at a given opacity, used by every pattern painter.
Color _tint(Color color, double opacity) => color.withValues(alpha: opacity);

/// `SBI Card` wordmark: the round keyhole mark followed by the name.
class _SbiWordmark extends StatelessWidget {
  const _SbiWordmark({required this.card, required this.scale});

  final CreditCard card;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          width: 25 * scale,
          height: 25 * scale,
          child: CustomPaint(
            painter: _SbiMarkPainter(
              color: card.foreground,
              slot: card.backgroundColors.last,
            ),
          ),
        ),
        SizedBox(width: 8 * scale),
        Text(
          'SBI',
          style: TextStyle(
            color: card.foreground,
            fontSize: 18 * scale,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.2,
            height: 1.1,
          ),
        ),
        SizedBox(width: 5 * scale),
        Text(
          'Card',
          style: TextStyle(
            color: card.foreground.withValues(alpha: 0.92),
            fontSize: 14 * scale,
            fontWeight: FontWeight.w500,
            letterSpacing: 2.2,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}

/// IDFC FIRST Bank logo block: white type on the bank's red square.
class _IdfcWordmark extends StatelessWidget {
  const _IdfcWordmark({required this.card, required this.scale});

  final CreditCard card;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Container(
      color: card.accent,
      padding: EdgeInsets.symmetric(horizontal: 7 * scale, vertical: 4 * scale),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            'IDFC',
            style: TextStyle(
              color: card.foreground,
              fontSize: 15 * scale,
              fontWeight: FontWeight.w900,
              letterSpacing: 0.4,
              height: 1,
            ),
          ),
          SizedBox(height: 2 * scale),
          Text(
            'FIRST Bank',
            style: TextStyle(
              color: card.foreground,
              fontSize: 8 * scale,
              fontWeight: FontWeight.w600,
              letterSpacing: 0.6,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

/// HDFC Bank wordmark: the red monogram tile plus the bank name.
class _HdfcWordmark extends StatelessWidget {
  const _HdfcWordmark({required this.card, required this.scale});

  final CreditCard card;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Container(
          width: 22 * scale,
          height: 22 * scale,
          color: card.accent,
          alignment: Alignment.center,
          child: Text(
            'H',
            style: TextStyle(
              color: card.foreground,
              fontSize: 14 * scale,
              fontWeight: FontWeight.w900,
              height: 1,
            ),
          ),
        ),
        SizedBox(width: 8 * scale),
        Text(
          'HDFC Bank',
          style: TextStyle(
            color: card.foreground,
            fontSize: 15 * scale,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.2,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}

/// YES BANK wordmark.
class _YesWordmark extends StatelessWidget {
  const _YesWordmark({required this.card, required this.scale});

  final CreditCard card;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        Text(
          'YES',
          style: TextStyle(
            color: card.foreground,
            fontSize: 17 * scale,
            fontWeight: FontWeight.w900,
            letterSpacing: 0.5,
            height: 1.1,
          ),
        ),
        SizedBox(width: 5 * scale),
        Text(
          'BANK',
          style: TextStyle(
            color: card.foreground.withValues(alpha: 0.9),
            fontSize: 13 * scale,
            fontWeight: FontWeight.w500,
            letterSpacing: 3,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}

/// AXIS BANK wordmark with the triangular bank mark.
class _AxisWordmark extends StatelessWidget {
  const _AxisWordmark({required this.card, required this.scale});

  final CreditCard card;
  final double scale;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: <Widget>[
        SizedBox(
          width: 20 * scale,
          height: 20 * scale,
          child: CustomPaint(painter: _AxisMarkPainter(card.foreground)),
        ),
        SizedBox(width: 8 * scale),
        Text(
          'AXIS BANK',
          style: TextStyle(
            color: card.foreground,
            fontSize: 14 * scale,
            fontWeight: FontWeight.w700,
            letterSpacing: 2.2,
            height: 1.1,
          ),
        ),
      ],
    );
  }
}

/// The round SBI mark: a disc with the vertical keyhole slot cut out.
class _SbiMarkPainter extends CustomPainter {
  const _SbiMarkPainter({required this.color, required this.slot});

  final Color color;

  /// Colour of the card face showing through the slot.
  final Color slot;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = size.center(Offset.zero);
    final double radius = size.shortestSide / 2;

    canvas.drawCircle(center, radius, Paint()..color = color);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        Rect.fromCenter(
          center: Offset(center.dx, center.dy - radius * 0.06),
          width: radius * 0.42,
          height: radius * 1.06,
        ),
        Radius.circular(radius * 0.21),
      ),
      Paint()..color = slot,
    );
  }

  @override
  bool shouldRepaint(covariant _SbiMarkPainter oldDelegate) =>
      oldDelegate.color != color || oldDelegate.slot != slot;
}

/// The Axis mark: an outlined triangle with a crossbar.
class _AxisMarkPainter extends CustomPainter {
  const _AxisMarkPainter(this.color);

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final double width = size.width;
    final double height = size.height;

    final Paint stroke = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = height * 0.14
      ..strokeJoin = StrokeJoin.round;

    canvas.drawPath(
      Path()
        ..moveTo(width * 0.5, height * 0.1)
        ..lineTo(width * 0.92, height * 0.92)
        ..lineTo(width * 0.08, height * 0.92)
        ..close(),
      stroke,
    );
    canvas.drawLine(
      Offset(width * 0.28, height * 0.68),
      Offset(width * 0.72, height * 0.68),
      stroke,
    );
  }

  @override
  bool shouldRepaint(covariant _AxisMarkPainter oldDelegate) =>
      oldDelegate.color != color;
}

/// Card face of a bank: its gradient plus the bank's own pattern.
///
/// When [CreditCard.backgroundAsset] is set the asset wins, which keeps the
/// door open for a design that is too intricate to paint.
class BankCardPattern extends StatelessWidget {
  const BankCardPattern({super.key, required this.card});

  final CreditCard card;

  @override
  Widget build(BuildContext context) {
    final String? asset = card.backgroundAsset;
    if (asset != null) {
      return Image.asset(
        asset,
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
      );
    }

    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: card.backgroundColors,
        ),
      ),
      child: CustomPaint(painter: patternFor(card)),
    );
  }

  /// The painted pattern of [card], chosen by its [CreditCard.artwork].
  static CustomPainter patternFor(CreditCard card) => switch (card.artwork) {
    BankArtwork.sbi => _SbiPatternPainter(card.accent),
    BankArtwork.idfcFirst => const _IdfcPatternPainter(),
    BankArtwork.hdfc => const _HdfcPatternPainter(),
    BankArtwork.yesBank => _YesPatternPainter(card.accent),
    BankArtwork.axis => _AxisPatternPainter(card.accent),
  };
}

/// SBI: a woven diagonal ribbon background with a dotted grid and the arc
/// sweep of the reference card.
class _SbiPatternPainter extends CustomPainter {
  const _SbiPatternPainter(this.accent);

  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);

    final Paint ribbon = Paint()
      ..color = _tint(Colors.white, 0.05)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.height * 0.13;

    final double step = size.width * 0.185;
    for (double x = -size.height; x < size.width + size.height; x += step) {
      canvas.drawLine(Offset(x, size.height), Offset(x + size.height, 0), ribbon);
    }

    final Paint dot = Paint()..color = _tint(accent, 0.3);
    for (int row = 0; row < 4; row++) {
      for (int column = 0; column < 6; column++) {
        canvas.drawCircle(
          Offset(
            size.width * (0.07 + column * 0.03),
            size.height * (0.62 + row * 0.06),
          ),
          size.height * 0.007,
          dot,
        );
      }
    }

    final Paint arc = Paint()
      ..color = _tint(Colors.white, 0.08)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.height * 0.012;
    for (int ring = 0; ring < 4; ring++) {
      canvas.drawCircle(
        Offset(size.width * 0.97, size.height * 0.14),
        size.height * (0.36 + ring * 0.24),
        arc,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SbiPatternPainter oldDelegate) =>
      oldDelegate.accent != accent;
}

/// IDFC FIRST: fine diagonal grid, a circle outline and a tilted square.
class _IdfcPatternPainter extends CustomPainter {
  const _IdfcPatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);

    final Paint grid = Paint()
      ..color = _tint(Colors.white, 0.05)
      ..strokeWidth = size.height * 0.005;
    final double step = size.width * 0.055;
    for (double x = -size.height; x < size.width + size.height; x += step) {
      canvas.drawLine(Offset(x, size.height), Offset(x + size.height, 0), grid);
    }

    final Paint outline = Paint()
      ..color = _tint(Colors.white, 0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.height * 0.01;
    canvas.drawCircle(
      Offset(size.width * 0.88, size.height * 0.18),
      size.height * 0.44,
      outline,
    );

    canvas.save();
    canvas.translate(size.width * 0.13, size.height * 0.86);
    canvas.rotate(math.pi / 4);
    canvas.drawRect(
      Rect.fromCenter(
        center: Offset.zero,
        width: size.height * 0.32,
        height: size.height * 0.32,
      ),
      outline,
    );
    canvas.restore();
  }

  @override
  bool shouldRepaint(covariant _IdfcPatternPainter oldDelegate) => false;
}

/// HDFC: a faint grid overlaid by the globe wireframe of the reference card.
class _HdfcPatternPainter extends CustomPainter {
  const _HdfcPatternPainter();

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);

    final Paint grid = Paint()
      ..color = _tint(Colors.white, 0.035)
      ..strokeWidth = size.height * 0.004;
    for (double x = 0; x <= size.width; x += size.width * 0.08) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), grid);
    }
    for (double y = 0; y <= size.height; y += size.height * 0.14) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), grid);
    }

    final Offset center = Offset(size.width * 0.84, size.height * 0.44);
    final double radius = size.height * 0.52;
    final Paint globe = Paint()
      ..color = _tint(Colors.white, 0.09)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.height * 0.008;

    for (final double width in <double>[
      radius * 2,
      radius * 1.35,
      radius * 0.62,
    ]) {
      canvas.drawOval(
        Rect.fromCenter(center: center, width: width, height: radius * 2),
        globe,
      );
    }
    for (final double height in <double>[
      radius * 2,
      radius * 1.4,
      radius * 0.7,
    ]) {
      canvas.drawOval(
        Rect.fromCenter(center: center, width: radius * 2, height: height),
        globe,
      );
    }
  }

  @override
  bool shouldRepaint(covariant _HdfcPatternPainter oldDelegate) => false;
}

/// YES BANK: a light wash plus the mandala fanning out of the bottom edge.
class _YesPatternPainter extends CustomPainter {
  const _YesPatternPainter(this.accent);

  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);

    final Rect topLeft = Rect.fromCircle(
      center: Offset(size.width * 0.08, 0),
      radius: size.width * 0.85,
    );
    canvas.drawRect(
      Offset.zero & size,
      Paint()
        ..shader = RadialGradient(
          colors: <Color>[_tint(Colors.white, 0.16), _tint(Colors.white, 0)],
        ).createShader(topLeft),
    );

    final Offset center = Offset(size.width * 0.5, size.height * 1.18);
    final Paint petal = Paint()
      ..color = _tint(accent, 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.height * 0.006;

    for (int ring = 0; ring < 3; ring++) {
      canvas.drawCircle(center, size.height * (0.5 + ring * 0.26), petal);
    }

    for (int index = 0; index < 15; index++) {
      canvas.save();
      canvas.translate(center.dx, center.dy);
      canvas.rotate(index * (math.pi * 2 / 15) + math.pi / 15);
      canvas.drawRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(0, -size.height * 0.72),
            width: size.height * 0.11,
            height: size.height * 0.56,
          ),
          Radius.circular(size.height * 0.06),
        ),
        petal,
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(covariant _YesPatternPainter oldDelegate) =>
      oldDelegate.accent != accent;
}

/// AXIS: geometric diagonal bands with the chevrons of the reference card.
class _AxisPatternPainter extends CustomPainter {
  const _AxisPatternPainter(this.accent);

  final Color accent;

  @override
  void paint(Canvas canvas, Size size) {
    canvas.clipRect(Offset.zero & size);

    final Paint band = Paint()..color = _tint(Colors.white, 0.05);
    canvas.save();
    canvas.translate(size.width * 0.55, size.height * 0.5);
    canvas.rotate(-0.6);
    for (int index = -2; index <= 3; index++) {
      canvas.drawRect(
        Rect.fromLTWH(
          -size.width * 0.8,
          index * size.height * 0.2,
          size.width * 1.6,
          size.height * 0.075,
        ),
        band,
      );
    }
    canvas.restore();

    final Paint chevron = Paint()
      ..color = _tint(accent, 0.28)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.height * 0.012
      ..strokeJoin = StrokeJoin.round;
    for (int index = 0; index < 3; index++) {
      final double x = size.width * (0.68 + index * 0.07);
      canvas.drawPath(
        Path()
          ..moveTo(x, size.height * 0.76)
          ..lineTo(x + size.width * 0.05, size.height * 0.86)
          ..lineTo(x + size.width * 0.1, size.height * 0.76),
        chevron,
      );
    }

    final Paint outline = Paint()
      ..color = _tint(Colors.white, 0.07)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.height * 0.008;
    canvas.drawRect(
      Rect.fromLTWH(
        size.width * 0.04,
        size.height * 0.08,
        size.width * 0.2,
        size.height * 0.2,
      ),
      outline,
    );
  }

  @override
  bool shouldRepaint(covariant _AxisPatternPainter oldDelegate) =>
      oldDelegate.accent != accent;
}



