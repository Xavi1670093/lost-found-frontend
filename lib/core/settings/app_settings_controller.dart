import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AppSettingsController extends ChangeNotifier {
  static const _themeKey = 'is_dark_mode';
  static const _localeKey = 'selected_locale';

  bool _isDarkMode = false;
  Locale _locale = const Locale('es');

  bool get isDarkMode => _isDarkMode;
  Locale get locale => _locale;

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    _isDarkMode = prefs.getBool(_themeKey) ?? false;

    final savedLocale = prefs.getString(_localeKey) ?? 'es';
    _locale = Locale(savedLocale);

    notifyListeners();
  }

  Future<void> setDarkMode(bool value) async {
    _isDarkMode = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_themeKey, value);
  }

  Future<void> setLocale(Locale value) async {
    _locale = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, value.languageCode);
  }
}