import 'package:flutter/material.dart';
import 'package:ngirit_app/services/common_service.dart';
import 'dart:async';

class CommonProvider extends ChangeNotifier {
  // Initialize with a default value to avoid 'LateInitializationError'
  String _selectedCurrency = 'IDR';
  bool _serverReachable = true;
  List<String> _currencies = [];
  double _exchangeRate = 1.0;
  Timer? _healthTimer;
  bool _isLoading = false;

  // getter
  bool get serverReachable => _serverReachable;
  String get selectedCurrency => _selectedCurrency;
  List<String> get currencyList => _currencies;
  double get exchangeRate => _exchangeRate;
  bool get isLoading => _isLoading;

  // # service
  // ## selected currency
  set selectedCurrency(String value) {
    if (_selectedCurrency != value) {
      _selectedCurrency = value;
      notifyListeners(); // 📢 This is the "trigger" you are missing!
    }
  }

  set currencyList(List<String> values) {
    if (_currencies != values) {
      _currencies = values;
      notifyListeners();
    }
  }

  set exchangeRate(double val) {
    if (_exchangeRate != val) {
      _exchangeRate = val;
      notifyListeners();
    }
  }

  set isLoading(bool val) {
    _isLoading = val;
    notifyListeners();
  }

  // Or a method version
  void updateCurrency(String newCurrency) {
    _selectedCurrency = newCurrency;
    notifyListeners();
  }

  // ## check health
  void setServerReachable(bool value) {
    if (_serverReachable != value) {
      _serverReachable = value;
      notifyListeners();
    }
  }

  void startHealthCheck() {
    _healthTimer?.cancel();
    _healthTimer = Timer.periodic(
      const Duration(seconds: 10),
      (_) => checkHealth(),
    );
  }

  @override
  void dispose() {
    _healthTimer?.cancel();
    super.dispose();
  }

  Future<void> checkHealth() async {
    final ok = await CommonService().checkHealth();
    setServerReachable(ok);
  }

  // Currency Handler
  Future<void> getFrankfurterCurrencies() async {
    currencyList = await CommonService().getFrankfurterCurrencies();
    // currencyList = resp;
    // currencyList(resp);
    // debugPrint("Currencies: $resp");
  }

  Future<double> getExchangeRate(
    String baseCurrency,
    String targetCurrency,
  ) async {
    try {
      _isLoading = true;
      notifyListeners();

      final rate = await CommonService().getFrankfurterExchangeRate(
        baseCurrency: baseCurrency,
        targetCurrency: targetCurrency,
      );
      return rate;
    } catch (e) {
      throw Exception('Failed to get exchange rate: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
    // debugPrint("rate: $exchangeRate");
  }

  Future<void> setExchangeRate(
    String baseCurrency,
    String targetCurrency,
  ) async {
    exchangeRate = await CommonService().getFrankfurterExchangeRate(
      baseCurrency: baseCurrency,
      targetCurrency: targetCurrency,
    );
    debugPrint("rate: $exchangeRate");
  }
}
