import 'package:flutter/material.dart';

/// Brand mark: `assets/icons/app_icon.png` (same source as native launcher icons).
class SfttvLogo extends StatelessWidget {
  const SfttvLogo({super.key, this.size = 120});

  static const String assetPath = 'assets/icons/app_icon.png';

  final double size;

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(size * 0.223);
    return SizedBox(
      width: size,
      height: size,
      child: ClipRRect(
        borderRadius: radius,
        child: Image.asset(
          assetPath,
          width: size,
          height: size,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          gaplessPlayback: true,
        ),
      ),
    );
  }
}
