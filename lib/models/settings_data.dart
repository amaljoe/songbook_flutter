import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsData extends ChangeNotifier {
  static const _keyThemeMode = 'themeMode';
  static const _keyTextSize = 'textSizeFactor';

  ThemeMode themeMode = ThemeMode.system;
  double textSizeFactor = 1.0;

  Future<void> load() async {
    final prefs = await SharedPreferences.getInstance();
    themeMode = switch (prefs.getString(_keyThemeMode)) {
      'light' => ThemeMode.light,
      'dark' => ThemeMode.dark,
      _ => ThemeMode.system,
    };
    textSizeFactor = prefs.getDouble(_keyTextSize) ?? 1.0;
    notifyListeners();
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    themeMode = mode;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyThemeMode, mode.name);
    notifyListeners();
  }

  Future<void> setTextSizeFactor(double factor) async {
    textSizeFactor = factor;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setDouble(_keyTextSize, factor);
    notifyListeners();
  }
}
