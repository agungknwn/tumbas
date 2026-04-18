import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:ngirit_app/models/user.dart';
import 'package:ngirit_app/providers/common_provider.dart';
import 'package:ngirit_app/services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _apiService = AuthService();
  final FlutterSecureStorage _secureStorage = const FlutterSecureStorage();
  final CommonProvider commonProvider;

  AuthProvider(this.commonProvider);

  static const _keyIdentifier = "saved_identifier";
  static const _keyPassword = "saved_password";

  bool _isLoading = false;
  bool registerStatus = false;
  String? _error;
  User? _user;

  bool get isLoading => _isLoading;
  String? get error => _error;

  // get user Id from "user" response
  String? get userId => _user?.username;
  // Login example
  Future<void> login(String identifier, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _apiService.login(
        identifier: identifier,
        password: password,
      );

      _user = response;
      debugPrint("_user: $_user");

      // save cred on succesful login
      if (_user != null) {
        await _saveCredentials(identifier, password);
      }
    } catch (e) {
      // commonProvider.checkHealth();
      commonProvider.setServerReachable(false);
      _error = e.toString();
      debugPrint("login error: $_error");
      _user = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> register(
    String email,
    String username,
    String name,
    String password,
  ) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _apiService.register(
        email: email,
        password: password,
        username: username,
        name: name,
      );
    } catch (e) {
      commonProvider.setServerReachable(false);
      debugPrint(e.toString());
    } finally {
      registerStatus = true;
      _isLoading = false;
      notifyListeners();
    }
  }

  void userLogout() {
    _user = null;
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Biometric cred helper
  Future<void> _saveCredentials(String identifier, String password) async {
    debugPrint("save cred start");
    await _secureStorage.write(key: _keyIdentifier, value: identifier);
    await _secureStorage.write(key: _keyPassword, value: password);
    debugPrint("save cred done");
  }

  Future<void> clearCredentials() async {
    await _secureStorage.delete(key: _keyIdentifier);
    await _secureStorage.delete(key: _keyPassword);
    debugPrint("biometric cred deleted");
  }

  Future<String?> getSavedIdentity() async {
    return await _secureStorage.read(key: _keyIdentifier);
  }

  Future<String?> getSavedPassword() async {
    return await _secureStorage.read(key: _keyPassword);
  }

  Future<bool> hasSavedCredentials() async {
    final identity = await _secureStorage.read(key: _keyIdentifier);
    return identity != null;
  }

  // Future<void> _clearCredentials() async {
  //   await _secureStorage.delete(key: _keyIdentifier);
  //   await _secureStorage.delete(key: _keyPassword);
  // }
}
