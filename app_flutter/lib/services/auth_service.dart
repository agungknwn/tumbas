import '../config/constants.dart';
import '../models/user.dart';
import 'api_service.dart';
import 'storage_service.dart';

class AuthService {
  final ApiService _api = ApiService();
  final StorageService _storage = StorageService();

  // Register - calls POST /auth/register
  Future<User> register({
    required String email,
    required String password,
    required String username,
    required String name,
  }) async {
    final response = await _api.post(
      ApiConstants.register, // This is '/auth/register'
      {
        'email': email,
        'password': password,
        'username': username,
        'name': name,
      },
    );

    // Assuming your Go backend returns:
    // {
    //   "success": true,
    //   "message": "User created",
    //   "user": {...}
    // }

    if (response['userId'] != null) {
      return User.fromJson(response);
    } else {
      throw Exception(response['error'] ?? 'Registration failed');
    }
  }

  // Login - calls POST /auth/login
  Future<User?> login({
    required String identifier,
    required String password,
    bool staySignedIn = false,
  }) async {
    final response = await _api.post(
      ApiConstants.login, // This is '/auth/login'
      {'identifier': identifier, 'password': password},
    );

    // Assuming your Go backend returns:
    // {
    //   "success": true,
    //   "access_token": "...",
    //   "refresh_token": "...",
    //   "user": {...}
    // }

    if (response != null && response['userId'] != null) {
      // Save tokens if stay signed in
      if (staySignedIn) {
        await _storage.saveToken(response['access_token']);
        await _storage.saveRefreshToken(response['refresh_token']);
      }

      return User.fromJson(response);
    } else {
      // return response['error'] ?? 'Login Failed';
      return null;
      // throw Exception(response['error'] ?? 'Login failed');
    }
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _storage.getToken();
    return token != null && token.isNotEmpty;
  }

  // Logout
  Future<void> logout() async {
    await _storage.clearAll();
  }
}
