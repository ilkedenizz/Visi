import 'package:flutter/material.dart';

/// Minimal & Elegant Vişi Cherry Brand Symbol
///
/// Crafted specifically to feel like a boutique lifestyle brand icon
/// rather than a cartoon cherry. Supports size and color customization.
class VisiCherryLogo extends StatelessWidget {
  final double size;
  final Color? color;

  const VisiCherryLogo({
    super.key,
    this.size = 28.0,
    this.color,
  });

  @override
  Widget build(BuildContext meContext) {
    final effectiveColor = color ?? Theme.of(meContext).colorScheme.primary;

    return CustomPaint(
      size: Size(size, size),
      painter: _CherryPainter(color: effectiveColor),
    );
  }
}

class _CherryPainter extends CustomPainter {
  final Color color;

  _CherryPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final fillPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill
      ..isAntiAlias = true;

    final strokePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.08
      ..strokeCap = StrokeCap.round
      ..isAntiAlias = true;

    final w = size.width;
    final h = size.height;

    // Stem joining point (top rightish)
    final topPoint = Offset(w * 0.58, h * 0.12);

    // Left Cherry body
    final leftCenter = Offset(w * 0.32, h * 0.72);
    final leftRadius = w * 0.22;

    // Right Cherry body
    final rightCenter = Offset(w * 0.72, h * 0.76);
    final rightRadius = w * 0.20;

    // Draw Stems (Smooth Quadratic Curves)
    final leftStemPath = Path()
      ..moveTo(topPoint.dx, topPoint.dy)
      ..quadraticBezierTo(w * 0.25, h * 0.32, leftCenter.dx, leftCenter.dy - leftRadius * 0.6);

    final rightStemPath = Path()
      ..moveTo(topPoint.dx, topPoint.dy)
      ..quadraticBezierTo(w * 0.78, h * 0.40, rightCenter.dx, rightCenter.dy - rightRadius * 0.6);

    canvas.drawPath(leftStemPath, strokePaint);
    canvas.drawPath(rightStemPath, strokePaint);

    // Draw Minimal Leaf
    final leafPath = Path()
      ..moveTo(topPoint.dx, topPoint.dy)
      ..quadraticBezierTo(w * 0.25, h * 0.05, w * 0.20, h * 0.18)
      ..quadraticBezierTo(w * 0.40, h * 0.22, topPoint.dx, topPoint.dy);
    canvas.drawPath(leafPath, fillPaint);

    // Draw Left & Right Cherries
    canvas.drawCircle(leftCenter, leftRadius, fillPaint);
    canvas.drawCircle(rightCenter, rightRadius, fillPaint);
  }

  @override
  bool shouldRepaint(covariant _CherryPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}
