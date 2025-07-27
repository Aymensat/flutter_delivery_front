// lib/providers/auth_provider.dart

import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_public_profile.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserPublicProfile? _user;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  UserPublicProfile? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  bool get isAuthenticated => _user != null && _token != null;

  AuthProvider() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserAndToken();
    });
  }

  Future<void> _loadUserAndToken() async {
    _token = await _authService.getToken();
    if (_token != null) {
      try {
        _user = await _authService.fetchCurrentUser();
      } catch (e) {
        _errorMessage = "Failed to load user data: ${e.toString()}";
        _user = null;
        _token = null;
        await _authService.deleteToken();
        await _authService.deleteCurrentUser();
      }
    } else {
      _user = null;
      await _authService.deleteCurrentUser();
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _authService.login(email, password);
      if (success) {
        await _loadUserAndToken();
        return true;
      } else {
        _errorMessage = 'Login failed. Please check your credentials.';
        return false;
      }
    } catch (e) {
      _errorMessage = 'An error occurred during login: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
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
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final success = await _authService.register(
        username: username,
        firstName: firstName,
        name: name,
        email: email,
        password: password,
        phone: phone,
        role: role,
      );
      if (success) {
        await _loadUserAndToken();
        return true;
      } else {
        _errorMessage = 'Registration failed. Please try again.';
        return false;
      }
    } catch (e) {
      _errorMessage = 'An error occurred during registration: ${e.toString()}';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void logout() async {
    _isLoading = true;
    notifyListeners();
    await _authService.deleteToken();
    await _authService.deleteCurrentUser();
    _user = null;
    _token = null;
    _isLoading = false;
    notifyListeners();
  }

  // Method to update user profile (text data only)
  Future<bool> updateUser(Map<String, dynamic> data) async {
    if (_user == null) {
      _errorMessage = "No user to update.";
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedUser = await _authService.updateUser(_user!.id, data);
      _user = updatedUser; // Update the local user object
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // NEW: Method to update user profile with an image
  Future<bool> updateUserWithProfileImage({
    required Map<String, String> data,
    required String imagePath,
  }) async {
    if (_user == null) {
      _errorMessage = "No user to update.";
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final updatedUser = await _authService.updateUserWithProfileImage(
        userId: _user!.id,
        data: data,
        imagePath: imagePath,
      );
      _user = updatedUser; // Update the local user object with the new data
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }
}
