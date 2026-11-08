import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'auth_service.dart';

enum AppLanguage { en, fil }

class SettingsService extends ChangeNotifier {
  SettingsService._();
  static final SettingsService instance = SettingsService._();
  factory SettingsService() => instance;

  static const _defaultTheme = ThemeMode.light;
  static const _defaultLanguage = AppLanguage.en;

  ThemeMode themeMode = _defaultTheme;
  AppLanguage language = _defaultLanguage;
  bool ttsEnabled = false;

  String _key(String user, String name) => 'settings.$user.$name';

  /// Kept so main.dart's existing call still works. If a session is
  /// already active it loads that user's settings, otherwise defaults.
  Future<void> load() => loadForUser();

  /// Call right after a successful login.
  Future<void> loadForUser() async {
    final user = AuthService().currentUsername;
    if (user == null) {
      resetToDefaults();
      return;
    }
    try {
      final p = await SharedPreferences.getInstance();
      themeMode = ThemeMode.values.firstWhere(
          (m) => m.name == p.getString(_key(user, 'theme')),
          orElse: () => _defaultTheme);
      language = AppLanguage.values.firstWhere(
          (l) => l.name == p.getString(_key(user, 'language')),
          orElse: () => _defaultLanguage);
      ttsEnabled = p.getBool(_key(user, 'tts')) ?? false;
    } catch (_) {
      themeMode = _defaultTheme;
      language = _defaultLanguage;
      ttsEnabled = false;
    }
    notifyListeners();
  }

  /// Call on logout. Does not save, so the user's choices stay stored.
  void resetToDefaults() {
    themeMode = _defaultTheme;
    language = _defaultLanguage;
    ttsEnabled = false;
    notifyListeners();
  }

  Future<void> _save(String? user) async {
    if (user == null) return; // nobody logged in: never persist
    try {
      final p = await SharedPreferences.getInstance();
      await p.setString(_key(user, 'theme'), themeMode.name);
      await p.setString(_key(user, 'language'), language.name);
      await p.setBool(_key(user, 'tts'), ttsEnabled);
    } catch (_) {}
  }

  void setTheme(ThemeMode m) {
    themeMode = m;
    notifyListeners();
    _save(AuthService().currentUsername);
  }

  void setLanguage(AppLanguage l) {
    language = l;
    notifyListeners();
    _save(AuthService().currentUsername);
  }

  void setTts(bool v) {
    ttsEnabled = v;
    notifyListeners();
    _save(AuthService().currentUsername);
  }
}