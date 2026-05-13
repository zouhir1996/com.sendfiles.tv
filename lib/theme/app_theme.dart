import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';

ThemeData buildAppTheme() {
  const scheme = ColorScheme.dark(
    surface: AppColors.screenBackground,
    primary: AppColors.accentCyan,
    onPrimary: Color(0xFF0A0C18),
    onSurface: Colors.white,
    secondary: AppColors.accentCyanAlt,
    onSecondary: Color(0xFF0A0C18),
  );

  return ThemeData(
    useMaterial3: true,
    colorScheme: scheme,
    scaffoldBackgroundColor: AppColors.screenBackground,
    appBarTheme: const AppBarTheme(
      centerTitle: true,
      backgroundColor: AppColors.screenBackground,
      foregroundColor: Colors.white,
      elevation: 0,
      systemOverlayStyle: SystemUiOverlayStyle.light,
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFF252842),
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: const Color(0xFF15172A),
      indicatorColor: AppColors.accentCyan.withValues(alpha: 0.2),
      labelTextStyle: WidgetStateProperty.all(
        const TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
      ),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return const IconThemeData(color: AppColors.accentCyan);
        }
        return IconThemeData(color: Colors.white.withValues(alpha: 0.55));
      }),
    ),
    textTheme: Typography.whiteCupertino,
    dividerColor: Colors.white12,
  );
}
