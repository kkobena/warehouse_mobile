import 'package:flutter/material.dart';
import 'package:warehouse_mobile/src/utils/app_theme.dart';

enum AppThemes  {
  vert, // Corresponds to AppTheme.themeDataVert
  bleu, // Corresponds to AppTheme.themeBleu

}
class ThemeProfiver with ChangeNotifier{
  ThemeData _currentTheme = AppTheme.themeBleu; // Default theme
  AppThemes _currentThemeKey = AppThemes.bleu;

  ThemeData get currentTheme => _currentTheme;
  AppThemes get currentThemeKey => _currentThemeKey;
  void setTheme(AppThemes themeKey) {
    if(themeKey == _currentThemeKey){
      return;
    }
    switch (themeKey) {

      case AppThemes.vert:
        _currentTheme = AppTheme.themeDataVert;
        break;
      case AppThemes.bleu:
        _currentTheme = AppTheme.themeBleu;
        break;
    // Add cases for other themes
    }
    _currentThemeKey = themeKey;
    print("current ${currentTheme}");
    notifyListeners(); // Notify listeners that the theme has changed
  }
}