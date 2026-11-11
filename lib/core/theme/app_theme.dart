import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

/// Central tokens for the entire application.
/// Uses the installed system Arabic font: no runtime font downloads.
class AppTheme {
  static const accent = Color(0xFF7764B7);
  static const lightBackground = Color(0xFFF7F6F3);
  static const darkBackground = Color(0xFF17171D);
  static const darkCard = Color(0xFF25252D);

  static ThemeData build(Brightness brightness) {
    final dark = brightness == Brightness.dark;
    final scheme = ColorScheme.fromSeed(
      seedColor: accent,
      brightness: brightness,
      surface: dark ? darkBackground : lightBackground,
    );
    final text = ThemeData(brightness: brightness).textTheme;
    return ThemeData(
      useMaterial3: true,
      // Keep optional haptics in HapticService; tooltips otherwise vibrate on
      // long press independently of the persisted haptics setting.
      tooltipTheme: const TooltipThemeData(enableFeedback: false),
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      splashFactory: InkRipple.splashFactory,
      visualDensity: VisualDensity.standard,
      appBarTheme: const AppBarTheme(
        centerTitle: false,
        backgroundColor: Colors.transparent,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: dark ? darkCard : Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      textTheme: text.copyWith(
        displaySmall: text.displaySmall?.copyWith(
          fontSize: 36,
          fontWeight: FontWeight.w800,
          height: 1.32,
        ),
        headlineLarge: text.headlineLarge?.copyWith(
          fontSize: 34,
          fontWeight: FontWeight.w800,
          height: 1.36,
        ),
        headlineMedium: text.headlineMedium?.copyWith(
          fontSize: 27,
          fontWeight: FontWeight.w800,
          height: 1.52,
        ),
        titleLarge: text.titleLarge?.copyWith(
          fontSize: 21,
          fontWeight: FontWeight.w800,
          height: 1.4,
        ),
        titleMedium: text.titleMedium?.copyWith(
          fontSize: 17,
          fontWeight: FontWeight.w700,
          height: 1.4,
        ),
        bodyLarge: text.bodyLarge?.copyWith(fontSize: 16, height: 1.5),
        bodyMedium: text.bodyMedium?.copyWith(fontSize: 14, height: 1.5),
        labelLarge: text.labelLarge?.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w700,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(0, 56),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(0, 52),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: dark ? darkCard : Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 17,
          vertical: 16,
        ),
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: ZoomPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
    );
  }
}
