// lib/services/auth_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart'; // Import for debugPrint
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';

class AuthService {
  final String _baseUrl = AppConfig.baseUrl;
  static const String _tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  Future<String?> getToken() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getString(_tokenKey);
    } catch (e) {
      debugPrint('Error getting token: $e');
      return null;
    }
  }

  Future<String?> getUserId() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJsonString = prefs.getString(userKey);
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

  // Add the logout method here if it's missing (referencing Line 115 in auth_provider.dart)
  Future<void> logout() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_tokenKey);
      await prefs.remove(userKey);
      // You might also want to clear current user state in AuthProvider
      debugPrint('User logged out, data cleared from storage.');
    } catch (e) {
      debugPrint('Error during logout: $e');
    }
  }

  // Removed _saveToken and _saveUserData as they were unused and AuthProvider handles persistence directly.

  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        // Assuming your backend returns token and user data upon successful login
        return {'success': true, 'token': data['token'], 'user': data['user']};
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Login failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // CRITICAL FIX: Added register method based on OpenAPI spec and AuthProvider's call
  Future<Map<String, dynamic>> register({
    required String username,
    required String firstName,
    required String name, // Corresponds to lastName in AuthProvider
    required String email,
    required String password,
    required String phone,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/register'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'firstName': firstName,
          'name': name, // 'name' in backend typically refers to lastName
          'email': email,
          'password': password,
          'phone': phone,
          'role': role,
        }),
      );

      if (response.statusCode == 201) {
        // Assuming 201 Created for successful registration
        final data = jsonDecode(response.body);
        return {
          'success': true,
          'message': data['message'] ?? 'Registration successful',
        };
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Registration failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  // Placeholder for updateProfile method
  Future<Map<String, dynamic>> updateProfile(
    String userId,
    Map<String, dynamic> userData,
  ) async {
    debugPrint('AuthService.updateProfile not implemented yet.');
    return {'success': false, 'message': 'Profile update not implemented'};
  }

  // Placeholder for changePassword method
  Future<Map<String, dynamic>> changePassword(
    String oldPassword,
    String newPassword,
  ) async {
    debugPrint('AuthService.changePassword not implemented yet.');
    return {'success': false, 'message': 'Change password not implemented'};
  }

  // Placeholder for resetPassword method
  Future<Map<String, dynamic>> resetPassword(String email) async {
    debugPrint('AuthService.resetPassword not implemented yet.');
    return {'success': false, 'message': 'Password reset not implemented'};
  }

  // Placeholder for getCurrentUser method
  Future<Map<String, dynamic>> getCurrentUser(String token) async {
    debugPrint(
      'AuthService.getCurrentUser not fully implemented yet. Returning dummy data.',
    );
    try {
      final response = await http.get(
        Uri.parse('$_baseUrl/users/me'), // Assuming /users/me endpoint
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'user': data};
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Failed to fetch current user',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }

  Future<Map<String, dynamic>> verifyEmail(String token) async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/auth/verify-email'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'token': token}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return {'success': true, 'message': data['message']};
      } else {
        final errorData = jsonDecode(response.body);
        return {
          'success': false,
          'message': errorData['message'] ?? 'Email verification failed',
        };
      }
    } catch (e) {
      return {'success': false, 'message': 'Network error: ${e.toString()}'};
    }
  }
}
