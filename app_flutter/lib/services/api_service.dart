import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:ngirit_app/config/constants.dart';
import 'storage_service.dart';

class ApiService {
  final StorageService _storage = StorageService();

  // POST request
  Future<Map<String, dynamic>> post(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = false,
  }) async {
    final url = Uri.parse(ApiConstants.getUrl(endpoint));

    Map<String, String> headers = {'Content-Type': 'application/json'};

    // Add auth token if required
    if (requiresAuth) {
      final token = await _storage.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    try {
      final response = await http.post(
        url,
        headers: headers,
        body: json.encode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // GET request
  Future<dynamic> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    bool requiresAuth = false,
  }) async {
    final url = Uri.parse(
      ApiConstants.getUrl(endpoint),
    ).replace(queryParameters: queryParams);

    Map<String, String> headers = {'Content-Type': 'application/json'};

    if (requiresAuth) {
      final token = await _storage.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    try {
      debugPrint("🌍 GET $url");

      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 10));

      return _handleResponse(response);
    } catch (e, st) {
      debugPrint("❌ GET FAILED $e");
      debugPrintStack(stackTrace: st);
      rethrow;
    }
  }

  // get public api

  Future<dynamic> getPublic(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    bool requiresAuth = false,
  }) async {
    final url = Uri.parse(endpoint).replace(queryParameters: queryParams);

    Map<String, String> headers = {'Content-Type': 'application/json'};

    if (requiresAuth) {
      final token = await _storage.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    try {
      debugPrint("🌍 GET Public $url");

      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 10));

      return _handleResponse(response);
    } catch (e, st) {
      debugPrint("❌ GET FAILED $e");
      debugPrintStack(stackTrace: st);
      rethrow;
    }
  }

  // PATCH request
  Future<Map<String, dynamic>> patch(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = false,
  }) async {
    final url = Uri.parse(ApiConstants.getUrl(endpoint));

    Map<String, String> headers = {'Content-Type': 'application/json'};

    // Add auth token if required
    if (requiresAuth) {
      final token = await _storage.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    try {
      final response = await http.patch(
        url,
        headers: headers,
        body: json.encode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // PUT request
  Future<Map<String, dynamic>> put(
    String endpoint,
    Map<String, dynamic> body, {
    bool requiresAuth = false,
  }) async {
    final url = Uri.parse(ApiConstants.getUrl(endpoint));

    Map<String, String> headers = {'Content-Type': 'application/json'};

    // Add auth token if required
    if (requiresAuth) {
      final token = await _storage.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    try {
      final response = await http.put(
        url,
        headers: headers,
        body: json.encode(body),
      );

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  Future<Map<String, dynamic>> delete(
    String endpoint, {
    bool reqiresAuth = false,
  }) async {
    final url = Uri.parse(ApiConstants.getUrl(endpoint));
    Map<String, String> headers = {"Content-Type": "application/json"};

    if (reqiresAuth) {
      final token = await _storage.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    try {
      final response = await http.delete(url, headers: headers);
      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
    }
  }

  // Handle API response
  dynamic _handleResponse(http.Response response) {
    debugPrint('📡 Response status: ${response.statusCode}');
    debugPrint('📡 Response body: ${response.body}');

    // ✅ SUCCESS
    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) return null;
      return json.decode(response.body);
    }

    // ✅ EXPECTED: resource not found
    if (response.statusCode == 404) {
      return null;
    }

    if (response.statusCode == 401) {
      if (response.body.isEmpty) return null;
      return json.decode(response.body);
    }

    // ❌ REAL errors
    try {
      final errorData = json.decode(response.body);
      if (errorData is Map<String, dynamic>) {
        throw Exception(
          errorData['error'] ?? errorData['message'] ?? 'Request failed',
        );
      }
    } catch (_) {}

    throw Exception('Request failed: ${response.statusCode}');
  }
}
