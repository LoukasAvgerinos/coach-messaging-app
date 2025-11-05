import 'package:flutter/material.dart';
import 'theme.dart';

class ThemeProvider extends ChangeNotifier {
  // Start with light mode by default
  ThemeData _themeData = lightModeTheme;

  ThemeData get themeData => _themeData;

  bool get isDarkMode => _themeData == darkModeTheme;

  set themeData(ThemeData themeData) {
    _themeData = themeData;
    notifyListeners();
  }

  void toggleTheme() {
    if (_themeData == lightModeTheme) {
      _themeData = darkModeTheme;
    } else {
      _themeData = lightModeTheme;
    }
    notifyListeners();
  }
}
