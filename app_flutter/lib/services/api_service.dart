import 'dart:convert';
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

    // Add auth token if required
    if (requiresAuth) {
      final token = await _storage.getToken();
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }
    }

    try {
      final response = await http.get(url, headers: headers);

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Network error: $e');
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

  // Handle API response
  dynamic _handleResponse(http.Response response) {
    print('📡 Response status: ${response.statusCode}');
    print('📡 Response body: ${response.body}');

    if (response.statusCode >= 200 && response.statusCode < 300) {
      if (response.body.isEmpty) {
        return null;
      }

      // Decode without casting - let it be List or Map
      final data = json.decode(response.body);
      print('📡 Decoded type: ${data.runtimeType}');

      return data; // Could be List<dynamic> or Map<String, dynamic>
    } else {
      // For error responses, try to parse as Map
      try {
        final errorData = json.decode(response.body);
        if (errorData is Map<String, dynamic>) {
          throw Exception(errorData['message'] ?? 'Request failed');
        }
      } catch (e) {
        // If parsing fails, throw generic error
      }
      throw Exception('Request failed: ${response.statusCode}');
    }
  }

  // Map<String, dynamic> _handleResponse(http.Response response) {
  //   final data = json.decode(response.body) as Map<String, dynamic>;
  //
  //   if (response.statusCode >= 200 && response.statusCode < 300) {
  //     return data;
  //   } else {
  //     // Handle error from Go backend
  //     throw Exception(data['message'] ?? 'Request failed');
  //   }
  // }
}
