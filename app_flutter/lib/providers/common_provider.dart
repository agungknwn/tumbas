import 'package:flutter/material.dart';

class CommonProvider extends ChangeNotifier {
  // Initialize with a default value to avoid 'LateInitializationError'
  String _selectedCurrency = 'IDR';

  String get selectedCurrency => _selectedCurrency;

  set selectedCurrency(String value) {
    if (_selectedCurrency != value) {
      _selectedCurrency = value;
      notifyListeners(); // 📢 This is the "trigger" you are missing!
    }
  }

  // Or a method version
  void updateCurrency(String newCurrency) {
    _selectedCurrency = newCurrency;
    notifyListeners();
  }
}
