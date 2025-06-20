import 'package:flutter/material.dart';
import 'package:warehouse_mobile/src/data/services/utils/api_client.dart';
import 'package:warehouse_mobile/src/utils/app_theme.dart';

enum AppThemes {
  vert, // Corresponds to AppTheme.themeDataVert
  bleu, // Corresponds to AppTheme.themeBleu
}

class ThemeProfiver with ChangeNotifier {
  ThemeData _currentTheme = AppTheme.themeBleu; // Default theme
  AppThemes _currentThemeKey = ApiClient().theme;

  ThemeData get currentTheme => _currentTheme;

  AppThemes get currentThemeKey => _currentThemeKey;

  Future<void> setTheme(AppThemes themeKey) async {
    if (themeKey == _currentThemeKey) {
      return;
    }
    switch (themeKey) {
      case AppThemes.vert:
        _currentTheme = AppTheme.themeDataVert;
        break;
      case AppThemes.bleu:
        _currentTheme = AppTheme.themeBleu;
        break;
    }
    _currentThemeKey = themeKey;
    await ApiClient().updateTheme(themeKey);
    notifyListeners(); // Notify listeners that the theme has changed
  }
}
