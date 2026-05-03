import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

/// Theme Provider
/// Manages app theme state (dark/light mode) and language preference
/// Persists settings to Hive and notifies listeners for reactive updates
class ThemeProvider extends ChangeNotifier {
  static const String _isDarkModeKey = 'isDarkMode';
  static const String _listLanguageKey = 'listLanguage';
  static const String _settingsBox = 'settings';

  bool _isDarkMode = false;
  String _listLanguage = 'English';

  bool get isDarkMode => _isDarkMode;
  String get listLanguage => _listLanguage;

  // Available languages
  static const List<String> availableLanguages = [
    'English',
    'Hindi',
    'Spanish',
    'French',
    'German',
    'Japanese',
    'Portuguese',
    'Arabic',
    'Chinese (Simplified)',
  ];

  ThemeProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final box = await Hive.openBox(_settingsBox);
      _isDarkMode = box.get(_isDarkModeKey, defaultValue: false) ?? false;
      _listLanguage = box.get(_listLanguageKey, defaultValue: 'English') ?? 'English';
      notifyListeners();
    } catch (e) {
      // Use defaults if loading fails
      _isDarkMode = false;
      _listLanguage = 'English';
      notifyListeners();
    }
  }

  Future<void> toggleDarkMode(bool value) async {
    _isDarkMode = value;
    notifyListeners();

    try {
      final box = await Hive.openBox(_settingsBox);
      await box.put(_isDarkModeKey, value);
    } catch (e) {
      // Silently fail if save fails
      debugPrint('Failed to save dark mode preference: $e');
    }
  }

  Future<void> setListLanguage(String language) async {
    _listLanguage = language;
    notifyListeners();

    try {
      final box = await Hive.openBox(_settingsBox);
      await box.put(_listLanguageKey, language);
    } catch (e) {
      debugPrint('Failed to save language preference: $e');
    }
  }

  /// Get the current language setting for AI service
  static Future<String> getCurrentLanguage() async {
    try {
      final box = await Hive.openBox(_settingsBox);
      return box.get(_listLanguageKey, defaultValue: 'English') ?? 'English';
    } catch (e) {
      return 'English';
    }
  }
}