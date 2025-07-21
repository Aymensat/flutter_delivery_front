// lib/providers/auth_provider.dart
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import '../models/user_public_profile.dart'; // Make sure this import is correct and UserPublicProfile is defined.

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserPublicProfile? _user;
  String? _token; // Added to store the token internally
  bool _isLoading = false;
  String? _errorMessage;

  UserPublicProfile? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  // Corrected isAuthenticated getter
  bool get isAuthenticated => _user != null && _token != null;

  AuthProvider() {
    _loadUserAndToken(); // Renamed from _loadUser to indicate token loading as well
  }

  // Changed to load both user and token
  Future<void> _loadUserAndToken() async {
    _isLoading = true;
    notifyListeners();
    // Fetch token first
    _token = await _authService.getToken();
    if (_token != null) {
      // If token exists, try to fetch the user profile
      try {
        _user = await _authService.fetchCurrentUser(); // Use fetchCurrentUser
      } catch (e) {
        // If fetching user fails, perhaps the token is invalid/expired
        _errorMessage = "Failed to load user data: ${e.toString()}";
        _user = null;
        _token = null; // Clear token if user data can't be fetched
        await _authService.logout(); // Clear stored token
      }
    }
    _isLoading = false;
    notifyListeners();
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final Map<String, dynamic> loginResponse = await _authService.login(
        email,
        password,
      );
      if (loginResponse['success'] == true) {
        _token = loginResponse['token'];
        // Assuming loginResponse['user'] contains the UserPublicProfile map
        _user = UserPublicProfile.fromMap(loginResponse['user']);
        notifyListeners();
        return true;
      } else {
        _errorMessage =
            loginResponse['message'] ??
            'Login failed. Please check your credentials.';
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

  Future<void> logout() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await _authService.logout();
      _user = null;
      _token = null;
      notifyListeners();
    } catch (e) {
      _errorMessage = 'Logout failed: ${e.toString()}';
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
        // After successful registration, _authService.register should have saved token and user
        // We need to re-load them into AuthProvider's state
        await _loadUserAndToken(); // This will fetch the newly saved token and user
        notifyListeners();
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

  Future<bool> changePassword(
    String currentPassword,
    String newPassword,
  ) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // AuthService.changePassword no longer needs token as an argument, it gets it internally
      final success = await _authService.changePassword(
        currentPassword,
        newPassword,
      );
      if (success) {
        _errorMessage = 'Password changed successfully.';
        return true;
      } else {
        _errorMessage =
            'Failed to change password. Please check your current password.';
        return false;
      }
    } catch (e) {
      _errorMessage = 'An error occurred: ${e.toString()}';
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
