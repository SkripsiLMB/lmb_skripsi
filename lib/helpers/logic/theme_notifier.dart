import 'package:flutter/material.dart';
import 'package:lmb_skripsi/helpers/logic/shared_preferences.dart';

class ThemeNotifier extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;

  ThemeMode get themeMode => _themeMode;

  ThemeNotifier() {
    _loadThemeMode();
  }

  void setThemeMode(ThemeMode mode) async {
    _themeMode = mode;
    await LmbLocalStorage.setValue<String>("theme_mode", mode.name);
    notifyListeners();
  }

  void _loadThemeMode() async {
    final modeName = await LmbLocalStorage.getValue<String>("theme_mode");

    _themeMode = ThemeMode.values.firstWhere(
      (e) => e.name == modeName,
      orElse: () => ThemeMode.system,
    );

    notifyListeners();
  }
}