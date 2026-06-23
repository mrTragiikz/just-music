import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_theme.dart';

class SettingsProvider extends ChangeNotifier {
  static const _keyThemeMode = 'theme_mode';
  static const _keyAccentColor = 'accent_color';
  static const _keyFontScale = 'font_scale';
  static const _keyAutoScan = 'auto_scan';
  static const _keyExcludedFolders = 'excluded_folders';

  AppThemeMode _themeMode = AppThemeMode.dark;
  AccentColor _accentColor = AccentColor.blue;
  double _fontScale = 1.0;
  bool _autoScan = true;
  List<String> _excludedFolders = [];

  AppThemeMode get themeMode => _themeMode;
  AccentColor get accentColor => _accentColor;
  double get fontScale => _fontScale;
  bool get autoScan => _autoScan;
  List<String> get excludedFolders => _excludedFolders;

  late SharedPreferences _prefs;

  Future<void> load() async {
    _prefs = await SharedPreferences.getInstance();
    final modeIndex = _prefs.getInt(_keyThemeMode);
    if (modeIndex != null && modeIndex < AppThemeMode.values.length) {
      _themeMode = AppThemeMode.values[modeIndex];
    }
    final accentIndex = _prefs.getInt(_keyAccentColor);
    if (accentIndex != null && accentIndex < AccentColor.values.length) {
      _accentColor = AccentColor.values[accentIndex];
    }
    _fontScale = _prefs.getDouble(_keyFontScale) ?? 1.0;
    _autoScan = _prefs.getBool(_keyAutoScan) ?? true;
    _excludedFolders = _prefs.getStringList(_keyExcludedFolders) ?? [];
    notifyListeners();
  }

  Future<void> setThemeMode(AppThemeMode mode) async {
    _themeMode = mode;
    await _prefs.setInt(_keyThemeMode, mode.index);
    notifyListeners();
  }

  Future<void> setAccentColor(AccentColor color) async {
    _accentColor = color;
    await _prefs.setInt(_keyAccentColor, color.index);
    notifyListeners();
  }

  Future<void> setFontScale(double scale) async {
    _fontScale = scale;
    await _prefs.setDouble(_keyFontScale, scale);
    notifyListeners();
  }

  Future<void> setAutoScan(bool value) async {
    _autoScan = value;
    await _prefs.setBool(_keyAutoScan, value);
    notifyListeners();
  }

  Future<void> setExcludedFolders(List<String> folders) async {
    _excludedFolders = folders;
    await _prefs.setStringList(_keyExcludedFolders, folders);
    notifyListeners();
  }

  ThemeData buildTheme(Brightness platformBrightness) {
    switch (_themeMode) {
      case AppThemeMode.light:
        return AppTheme.light(_accentColor, null);
      case AppThemeMode.dark:
        return AppTheme.dark(_accentColor, null);
      case AppThemeMode.amoled:
        return AppTheme.amoled(_accentColor, null);
    }
  }

  ThemeMode get materialThemeMode {
    switch (_themeMode) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
      case AppThemeMode.amoled:
        return ThemeMode.dark;
    }
  }
}
