import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ThemeProvider extends ChangeNotifier {
  ThemeMode _themeMode = ThemeMode.system;
  static const _key = 'theme_mode';

  ThemeProvider() {
    _loadTheme();
  }

  ThemeMode get themeMode => _themeMode;
  bool get isDark => _themeMode == ThemeMode.dark;

  Future<void> _loadTheme() async {
    final prefs = await SharedPreferences.getInstance();
    final stored = prefs.getString(_key);
    if (stored == 'dark') {
      _themeMode = ThemeMode.dark;
    } else if (stored == 'light') {
      _themeMode = ThemeMode.light;
    } else {
      _themeMode = ThemeMode.system;
    }
    notifyListeners();
  }

  Future<void> toggleTheme() async {
    _themeMode = _themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_key, _themeMode == ThemeMode.dark ? 'dark' : 'light');
  }
}