import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

enum AppThemeMode { light, dark, amoled }

class AppTheme {
  static ThemeData light(AccentColor accent, ColorScheme? dynamicScheme) {
    final scheme = dynamicScheme ??
        ColorScheme.fromSeed(seedColor: accent.seed, brightness: Brightness.light);
    return _build(scheme);
  }

  static ThemeData dark(AccentColor accent, ColorScheme? dynamicScheme) {
    final scheme = dynamicScheme ??
        ColorScheme.fromSeed(seedColor: accent.seed, brightness: Brightness.dark);
    return _build(scheme);
  }

  static ThemeData amoled(AccentColor accent, ColorScheme? dynamicScheme) {
    final base = dynamicScheme ??
        ColorScheme.fromSeed(seedColor: accent.seed, brightness: Brightness.dark);
    final scheme = base.copyWith(
      surface: amoledBlack,
      surfaceContainerLowest: amoledBlack,
      surfaceContainerLow: const Color(0xFF050505),
      surfaceContainer: const Color(0xFF0A0A0A),
      surfaceContainerHigh: const Color(0xFF101010),
      surfaceContainerHighest: const Color(0xFF161616),
    );
    return _build(scheme).copyWith(
      scaffoldBackgroundColor: amoledBlack,
    );
  }

  static ThemeData _build(ColorScheme scheme) {
    final textTheme = GoogleFonts.poppinsTextTheme(
      ThemeData(brightness: scheme.brightness).textTheme,
    );
    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: scheme.surface,
      textTheme: textTheme,
      appBarTheme: AppBarTheme(
        backgroundColor: scheme.surface,
        foregroundColor: scheme.onSurface,
        elevation: 0,
        scrolledUnderElevation: 1,
        centerTitle: false,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surfaceContainer,
        indicatorColor: scheme.primaryContainer,
        elevation: 0,
      ),
      cardTheme: CardThemeData(
        color: scheme.surfaceContainerLow,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        selectedColor: scheme.primaryContainer,
        labelStyle: textTheme.labelLarge,
        shape: StadiumBorder(),
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: scheme.primary,
        inactiveTrackColor: scheme.surfaceContainerHighest,
        thumbColor: scheme.primary,
        trackHeight: 4,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurfaceVariant,
      ),
    );
  }
}
