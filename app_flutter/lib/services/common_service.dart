import 'api_service.dart';
import 'package:flutter/material.dart';

class CommonService {
  final ApiService _api = ApiService();
  final frankfurterApi = 'https://api.frankfurter.dev/v2';
  Future<bool> checkHealth() async {
    try {
      final response = await _api
          .get("/health")
          .timeout(const Duration(seconds: 5));

      debugPrint("Response: $response");
      // debugPrint("Response Status: ${response.status}");
      return response['status'] == "ok";
    } catch (err) {
      return false;
    }
  }

  Future<List<String>> getFrankfurterCurrencies() async {
    try {
      final response = await _api.getPublic('$frankfurterApi/currencies');
      // debugPrint("Response frankfurter: $response");
      if (response == null) return [];
      // response is List of objects, extract iso_code from each
      return (response as List<dynamic>)
          .map((currency) => currency['iso_code'] as String)
          .toList();
    } catch (e) {
      throw Exception(e);
    }
  }

  Future<double> getFrankfurterExchangeRate({
    required String baseCurrency,
    required String targetCurrency,
  }) async {
    try {
      final exchangeRateUrl =
          '$frankfurterApi/rates?base=$baseCurrency&quotes=$targetCurrency';

      final response = await _api.getPublic(exchangeRateUrl);

      if (response == null) return 1.0;

      final data = response as List<dynamic>;

      if (data.isEmpty) return 1.0;

      final rate = data[0]['rate'];

      return (rate as num).toDouble();
    } catch (e) {
      throw Exception('Failed to fetch exchange rate: $e');
    }
  }
}
