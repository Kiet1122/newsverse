import 'package:flutter/foundation.dart';

class AppProvider with ChangeNotifier {
  String _currentTheme = 'light';
  String _language = 'en';

  String get currentTheme => _currentTheme;
  String get language => _language;

  void setTheme(String theme) {
    _currentTheme = theme;
    notifyListeners();
  }

  void setLanguage(String lang) {
    _language = lang;
    notifyListeners();
  }
}