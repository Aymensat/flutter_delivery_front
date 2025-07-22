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
    // MODIFIED: Call _loadUserAndToken in a post-frame callback
    // This ensures that the state update happens after the initial build,
    // preventing setState during build issues when the provider is first instantiated.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadUserAndToken();
    });
  }

  Future<void> _loadUserAndToken() async {
    // MODIFIED: Removed the first notifyListeners() here.
    // The initial loading state will be reflected once this async operation completes.
    // _isLoading = true; // State is set, but no immediate notification.

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
    notifyListeners(); // Keep this one to update UI after loading is complete
  }

  Future<bool> login(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners(); // Keep this to show loading state immediately

    try {
      final success = await _authService.login(email, password);
      if (success) {
        // _authService.login now handles saving token/user.
        // Reload the current user data into AuthProvider's state.
        // _loadUserAndToken() will trigger its own notifyListeners() at the end.
        await _loadUserAndToken();
        // MODIFIED: Removed redundant notifyListeners() call here
        // notifyListeners(); // REMOVE THIS LINE
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
      notifyListeners(); // Keep this one to update UI (e.g., hide loading)
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
    notifyListeners(); // Notify to show loading state

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
        // Registration also implies successful authentication and token/user saving.
        // Reload user and token into AuthProvider's state.
        // _loadUserAndToken() will trigger its own notifyListeners() at its end.
        await _loadUserAndToken();
        // MODIFIED: Removed redundant notifyListeners() call here
        // notifyListeners(); // REMOVE THIS LINE
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
      notifyListeners(); // Notify to hide loading state
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

  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }
}
