import 'package:flutter/material.dart';

import '../theme/app_colors.dart';

/// TV, phone, and laptop connected with dotted lines (onboarding art).
class LocalNetworkIllustration extends StatelessWidget {
  const LocalNetworkIllustration({super.key, this.height = 220});

  final double height;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: height,
      child: CustomPaint(painter: _NetworkIllustrationPainter()),
    );
  }
}

class _NetworkIllustrationPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppColors.accentCyan
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round;

    final w = size.width;
    final h = size.height;
    final tv = Rect.fromCenter(
      center: Offset(w * 0.5, h * 0.22),
      width: w * 0.42,
      height: h * 0.22,
    );
    _drawTv(canvas, tv, paint);

    final phone = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w * 0.26, h * 0.72),
        width: w * 0.14,
        height: h * 0.28,
      ),
      const Radius.circular(10),
    );
    _drawPhone(canvas, phone, paint);

    final laptop = RRect.fromRectAndRadius(
      Rect.fromCenter(
        center: Offset(w * 0.74, h * 0.7),
        width: w * 0.34,
        height: h * 0.2,
      ),
      const Radius.circular(8),
    );
    _drawLaptop(canvas, laptop, paint);

    final phoneRect = phone.outerRect;
    final laptopRect = laptop.outerRect;
    _dottedLine(
      canvas,
      tv.bottomCenter.translate(-tv.width * 0.12, 0),
      phoneRect.center.translate(0, -phoneRect.height * 0.35),
      paint,
    );
    _dottedLine(
      canvas,
      tv.bottomCenter.translate(tv.width * 0.12, 0),
      laptopRect.center.translate(0, -laptopRect.height * 0.35),
      paint,
    );
  }

  void _drawTv(Canvas canvas, Rect tv, Paint stroke) {
    final rr = RRect.fromRectAndRadius(tv, const Radius.circular(10));
    canvas.drawRRect(rr, stroke);
    final inner = tv.deflate(8);
    canvas.drawRRect(
      RRect.fromRectAndRadius(inner, const Radius.circular(6)),
      stroke,
    );
    final wifiCenter = inner.center;
    final arcBase = inner.width * 0.22;
    final arcPaint = Paint()
      ..color = stroke.color
      ..style = PaintingStyle.stroke
      ..strokeWidth = stroke.strokeWidth
      ..strokeCap = StrokeCap.round;
    for (var i = 0; i < 3; i++) {
      final sweep = 75 * (3.141592653589793 / 180);
      canvas.drawArc(
        Rect.fromCircle(center: wifiCenter, radius: arcBase * (0.35 + i * 0.28)),
        -2.4,
        sweep,
        false,
        arcPaint,
      );
    }
  }

  void _drawPhone(Canvas canvas, RRect r, Paint stroke) {
    canvas.drawRRect(r, stroke);
    final icon = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(Icons.swap_vert.codePoint),
        style: TextStyle(
          fontSize: r.outerRect.height * 0.35,
          fontFamily: Icons.swap_vert.fontFamily,
          package: Icons.swap_vert.fontPackage,
          color: AppColors.accentCyan,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final oc = r.outerRect.center;
    icon.paint(canvas, oc - Offset(icon.width / 2, icon.height / 2));
  }

  void _drawLaptop(Canvas canvas, RRect r, Paint stroke) {
    canvas.drawRRect(r, stroke);
    final base = Rect.fromCenter(
      center: Offset(r.outerRect.center.dx, r.outerRect.bottom + 5),
      width: r.outerRect.width * 1.08,
      height: r.outerRect.height * 0.12,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(base, const Radius.circular(4)),
      stroke,
    );
    final icon = TextPainter(
      text: TextSpan(
        text: String.fromCharCode(Icons.swap_vert.codePoint),
        style: TextStyle(
          fontSize: r.outerRect.height * 0.38,
          fontFamily: Icons.swap_vert.fontFamily,
          package: Icons.swap_vert.fontPackage,
          color: AppColors.accentCyan,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    final oc = r.outerRect.center;
    icon.paint(canvas, oc - Offset(icon.width / 2, icon.height / 2));
  }

  void _dottedLine(Canvas canvas, Offset a, Offset b, Paint base) {
    final dotted = Paint()
      ..color = base.color
      ..strokeWidth = base.strokeWidth
      ..strokeCap = StrokeCap.round;
    const dash = 5.0;
    const gap = 5.0;
    final dir = (b - a);
    final len = dir.distance;
    if (len == 0) return;
    final unit = dir / len;
    var t = 0.0;
    while (t < len) {
      final p1 = a + unit * t;
      final p2 = a + unit * (t + dash).clamp(0.0, len);
      canvas.drawLine(p1, p2, dotted);
      t += dash + gap;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
