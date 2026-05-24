import 'package:flutter/material.dart';

/// Onager "O" mark — drawn with canvas for crisp rendering at any size.
class OnagerMark extends StatelessWidget {
  final double size;
  final Color? color;

  const OnagerMark({super.key, this.size = 32, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.onSurface;
    return CustomPaint(
      size: Size(size, size),
      painter: _OnagerMarkPainter(c),
    );
  }
}

class _OnagerMarkPainter extends CustomPainter {
  final Color color;
  _OnagerMarkPainter(this.color);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.06
      ..strokeCap = StrokeCap.butt;

    final center = Offset(size.width / 2, size.height / 2);
    final radius = size.width / 2 - paint.strokeWidth / 2;

    // Outer circle
    canvas.drawCircle(center, radius, paint);

    // Inner horizontal lines (stylised O)
    final gap = size.width * 0.22;
    paint.strokeWidth = size.width * 0.055;
    canvas.drawLine(
      Offset(center.dx - gap, center.dy - size.height * 0.14),
      Offset(center.dx + gap, center.dy - size.height * 0.14),
      paint,
    );
    canvas.drawLine(
      Offset(center.dx - gap, center.dy + size.height * 0.14),
      Offset(center.dx + gap, center.dy + size.height * 0.14),
      paint,
    );
  }

  @override
  bool shouldRepaint(_OnagerMarkPainter old) => old.color != color;
}

/// "ONAGER" wordmark
class OnagerWordmark extends StatelessWidget {
  final double size;
  final Color? color;

  const OnagerWordmark({super.key, this.size = 18, this.color});

  @override
  Widget build(BuildContext context) {
    final c = color ?? Theme.of(context).colorScheme.onSurface;
    return Text(
      'ONAGER',
      style: TextStyle(
        fontFamily: 'serif',
        fontSize: size,
        fontWeight: FontWeight.w300,
        color: c,
        letterSpacing: size * 0.28,
      ),
    );
  }
}
