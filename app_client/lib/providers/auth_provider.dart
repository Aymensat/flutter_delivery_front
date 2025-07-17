// lib/providers/auth_provider.dart
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;
  String? _token;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null && _token != null;

  AuthProvider() {
    _loadStoredAuth();
  }
  Future<String?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJsonString = prefs.getString(AuthService.userKey);
      if (userJsonString != null) {
        final userData = jsonDecode(userJsonString);
        // Assuming your User model has an 'id' or '_id' field
        return userData['_id'] ?? userData['id'] as String?;
      }
      return null;
    } catch (e) {
      debugPrint('Error getting user ID from SharedPreferences: $e');
      return null;
    }
  }

  Future<void> _loadStoredAuth() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('auth_token');
      final userJson = prefs.getString('user_data');

      if (_token != null && userJson != null) {
        _user = User.fromJson(userJson);
        notifyListeners();
      }
    } catch (e) {
      debugPrint('Error loading stored auth: $e');
    }
  }

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.login(email, password);

      if (response['success'] == true) {
        _token = response['token'];
        _user = User.fromMap(response['user']);
        await _saveAuthData();
        notifyListeners();
        return true;
      } else {
        _setError(response['message'] ?? 'Login failed');
        return false;
      }
    } catch (e) {
      _setError('Network error: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> register({
    required String username,
    required String firstName,
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      final response = await _authService.register(
        username: username,
        firstName: firstName,
        name: name,
        email: email,
        password: password,
        phone: phone,
        role: role,
      );

      if (response['success'] == true) {
        // Optionally log in the user directly after successful registration
        // For simplicity, we might just navigate them to the login screen
        // You can uncomment the following lines if you want auto-login
        /*
        _token = response['token'];
        _user = User.fromMap(response['user']);
        await _saveAuthData();
        */
        notifyListeners();
        return true;
      } else {
        _setError(response['message'] ?? 'Registration failed');
        return false;
      }
    } catch (e) {
      _setError('Network error: ${e.toString()}');
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    _clearError();
    try {
      await _authService.logout();
      _token = null;
      _user = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('auth_token');
      await prefs.remove('user_data');
      notifyListeners();
    } catch (e) {
      debugPrint('Error logging out: $e');
      _setError('Logout failed: ${e.toString()}');
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> refreshUser() async {
    if (_token == null) return false;

    try {
      final response = await _authService.getCurrentUser(_token!);

      if (response['success'] == true) {
        _user = User.fromMap(response['user']);
        await _saveAuthData();
        notifyListeners();
        return true;
      }
      return false;
    } catch (e) {
      debugPrint('Error refreshing user: $e');
      return false;
    }
  }

  Future<void> _saveAuthData() async {
    final prefs = await SharedPreferences.getInstance();
    if (_token != null) {
      await prefs.setString('auth_token', _token!);
    }
    if (_user != null) {
      await prefs.setString(AuthService.userKey, _user!.toJson());
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  void clearError() {
    _clearError();
  }

  // Helper method to check if token is valid
  bool isTokenValid() {
    // Add token validation logic here
    // For now, just check if token exists
    return _token != null;
  }
}
