import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

const String requiredLegalVersion = "1.0.0";

class AppSettingsController extends ChangeNotifier {
  static const _themeKey = 'is_dark_mode';
  static const _themeModeKey = 'theme_mode';
  static const _localeKey = 'selected_locale';
  static const _pushKey = 'push_notifications_enabled';

  ThemeMode _themeMode = ThemeMode.system;
  Locale _locale = const Locale('es');
  bool _pushNotificationsEnabled = true;
  StreamSubscription<DatabaseEvent>? _settingsSubscription;

  ThemeMode get themeMode => _themeMode;
  bool get isDarkMode => _themeMode == ThemeMode.dark;
  Locale get locale => _locale;
  bool get pushNotificationsEnabled => _pushNotificationsEnabled;

  AppSettingsController() {
    FirebaseAuth.instance.authStateChanges().listen((user) {
      try {
        _settingsSubscription?.cancel();
        if (user != null) {
          _settingsSubscription = FirebaseDatabase.instance
              .ref('users/${user.uid}/settings')
              .onValue
              .listen((event) {
            if (event.snapshot.exists) {
              final data = Map<dynamic, dynamic>.from(event.snapshot.value as Map);
              bool changed = false;

              if (data['themeMode'] != null) {
                final String dbThemeMode = data['themeMode'].toString();
                ThemeMode? matchedMode;
                if (dbThemeMode == 'light') matchedMode = ThemeMode.light;
                if (dbThemeMode == 'dark') matchedMode = ThemeMode.dark;
                if (dbThemeMode == 'system') matchedMode = ThemeMode.system;
                if (matchedMode != null && _themeMode != matchedMode) {
                  _themeMode = matchedMode;
                  changed = true;
                  SharedPreferences.getInstance().then((prefs) {
                    prefs.setString(_themeModeKey, dbThemeMode);
                    prefs.setBool(_themeKey, dbThemeMode == 'dark');
                  });
                }
              } else if (data['isDarkMode'] != null) {
                final dbVal = data['isDarkMode'] == true;
                final expectedMode = dbVal ? ThemeMode.dark : ThemeMode.light;
                if (_themeMode != expectedMode) {
                  _themeMode = expectedMode;
                  changed = true;
                  SharedPreferences.getInstance().then((prefs) {
                    prefs.setString(_themeModeKey, expectedMode.name);
                    prefs.setBool(_themeKey, dbVal);
                  });
                }
              }

              if (data['language'] != null) {
                final dbLang = data['language'].toString();
                if (_locale.languageCode != dbLang) {
                  _locale = Locale(dbLang);
                  changed = true;
                  SharedPreferences.getInstance().then((prefs) => prefs.setString(_localeKey, dbLang));
                }
              }

              if (data['pushNotificationsEnabled'] != null) {
                final dbPush = data['pushNotificationsEnabled'] == true;
                if (_pushNotificationsEnabled != dbPush) {
                  _pushNotificationsEnabled = dbPush;
                  changed = true;
                  SharedPreferences.getInstance().then((prefs) => prefs.setBool(_pushKey, dbPush));
                }
              }

              if (changed) {
                notifyListeners();
              }
            } else {
              _uploadSettingsToFirebase(user.uid);
            }
          }, onError: (e) {
            debugPrint('ULF_DEBUG: Error listening to settings changes: $e');
          });
        }
      } catch (e) {
        debugPrint('ULF_DEBUG: Error in authStateChanges listener: $e');
      }
    });
  }

  Future<void> _uploadSettingsToFirebase(String userId) async {
    try {
      await FirebaseDatabase.instance.ref('users/$userId/settings').set({
        'themeMode': _themeMode.name,
        'isDarkMode': _themeMode == ThemeMode.dark,
        'language': _locale.languageCode,
        'pushNotificationsEnabled': _pushNotificationsEnabled,
      });
      await FirebaseDatabase.instance.ref('users/$userId').update({
        'preferredLanguage': _locale.languageCode,
      });
    } catch (e) {
      debugPrint('ULF_DEBUG: Error uploading settings to Firebase: $e');
    }
  }

  Future<void> loadSettings() async {
    final prefs = await SharedPreferences.getInstance();

    final savedThemeMode = prefs.getString(_themeModeKey);
    if (savedThemeMode != null) {
      if (savedThemeMode == 'light') _themeMode = ThemeMode.light;
      if (savedThemeMode == 'dark') _themeMode = ThemeMode.dark;
      if (savedThemeMode == 'system') _themeMode = ThemeMode.system;
    } else {
      final hasOldTheme = prefs.containsKey(_themeKey);
      if (hasOldTheme) {
        final oldVal = prefs.getBool(_themeKey) ?? false;
        _themeMode = oldVal ? ThemeMode.dark : ThemeMode.light;
      } else {
        _themeMode = ThemeMode.system;
      }
    }

    final savedLocale = prefs.getString(_localeKey) ?? 'es';
    _locale = Locale(savedLocale);

    _pushNotificationsEnabled = prefs.getBool(_pushKey) ?? true;

    notifyListeners();

    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final snap = await FirebaseDatabase.instance.ref('users/${user.uid}/settings').get();
        if (snap.exists) {
          final data = Map<dynamic, dynamic>.from(snap.value as Map);
          bool changed = false;

          if (data['themeMode'] != null) {
            final String dbThemeMode = data['themeMode'].toString();
            ThemeMode? matchedMode;
            if (dbThemeMode == 'light') matchedMode = ThemeMode.light;
            if (dbThemeMode == 'dark') matchedMode = ThemeMode.dark;
            if (dbThemeMode == 'system') matchedMode = ThemeMode.system;
            if (matchedMode != null && _themeMode != matchedMode) {
              _themeMode = matchedMode;
              changed = true;
              await prefs.setString(_themeModeKey, dbThemeMode);
              await prefs.setBool(_themeKey, dbThemeMode == 'dark');
            }
          } else if (data['isDarkMode'] != null) {
            final dbVal = data['isDarkMode'] == true;
            final expectedMode = dbVal ? ThemeMode.dark : ThemeMode.light;
            if (_themeMode != expectedMode) {
              _themeMode = expectedMode;
              changed = true;
              await prefs.setString(_themeModeKey, expectedMode.name);
              await prefs.setBool(_themeKey, dbVal);
            }
          }

          if (data['language'] != null) {
            final dbLang = data['language'].toString();
            if (_locale.languageCode != dbLang) {
              _locale = Locale(dbLang);
              changed = true;
              await prefs.setString(_localeKey, dbLang);
            }
          }

          if (data['pushNotificationsEnabled'] != null) {
            final dbPush = data['pushNotificationsEnabled'] == true;
            if (_pushNotificationsEnabled != dbPush) {
              _pushNotificationsEnabled = dbPush;
              changed = true;
              await prefs.setBool(_pushKey, dbPush);
            }
          }

          if (changed) {
            notifyListeners();
          }
        } else {
          await _uploadSettingsToFirebase(user.uid);
        }
      } catch (e) {
        debugPrint('ULF_DEBUG: Error during loadSettings firebase sync: $e');
      }
    }
  }

  Future<void> setThemeMode(ThemeMode value) async {
    _themeMode = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeModeKey, value.name);
    await prefs.setBool(_themeKey, value == ThemeMode.dark);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseDatabase.instance
            .ref('users/${user.uid}/settings')
            .update({
              'themeMode': value.name,
              'isDarkMode': value == ThemeMode.dark,
            });
      }
    } catch (e) {
      debugPrint('ULF_DEBUG: Error updating themeMode in Firebase: $e');
    }
  }

  Future<void> setDarkMode(bool value) async {
    await setThemeMode(value ? ThemeMode.dark : ThemeMode.light);
  }

  Future<void> setLocale(Locale value) async {
    _locale = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_localeKey, value.languageCode);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseDatabase.instance
            .ref('users/${user.uid}/settings')
            .update({'language': value.languageCode});
        await FirebaseDatabase.instance
            .ref('users/${user.uid}')
            .update({'preferredLanguage': value.languageCode});
      }
    } catch (e) {
      debugPrint('ULF_DEBUG: Error updating preferredLanguage in controller: $e');
    }
  }

  Future<void> setPushNotifications(bool value) async {
    _pushNotificationsEnabled = value;
    notifyListeners();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_pushKey, value);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        await FirebaseDatabase.instance
            .ref('users/${user.uid}/settings')
            .update({'pushNotificationsEnabled': value});
      }
    } catch (e) {
      debugPrint('ULF_DEBUG: Error updating pushNotificationsEnabled in Firebase: $e');
    }
  }

  @override
  void dispose() {
    _settingsSubscription?.cancel();
    super.dispose();
  }
}