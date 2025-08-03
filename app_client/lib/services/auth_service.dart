// lib/services/auth_service.dart

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/user_public_profile.dart'; // For UserPublicProfile
import 'api_service.dart'; // Import ApiService

class AuthService {
  final String _baseUrl = AppConfig.baseUrl;
  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  // FIXED: Use lazy initialization to avoid circular dependency
  ApiService? _apiService;
  ApiService get apiService => _apiService ??= ApiService();

  static String get userKey => _userKey;

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> deleteToken() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
  }

  Future<UserPublicProfile?> getCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(_userKey);
    if (userJson != null) {
      try {
        final Map<String, dynamic> userDataMap = jsonDecode(userJson);
        return UserPublicProfile.fromMap(userDataMap);
      } catch (e) {
        debugPrint('Error decoding stored user data in getCurrentUser: $e');
        await deleteCurrentUser(); // Clear corrupted data if parsing fails
        return null;
      }
    }
    return null;
  }

  Future<void> saveCurrentUser(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_userKey, jsonEncode(userData));
  }

  Future<void> deleteCurrentUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_userKey);
  }

  // Login method (REVISED based on Postman response)
  Future<bool> login(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse(
          '$_baseUrl/users/login',
        ), // Corrected endpoint as per your feedback
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        final String? token = responseData['token'];

        // Construct the user profile map by excluding the 'token' field
        Map<String, dynamic> userProfileMap = {};
        responseData.forEach((key, value) {
          if (key != 'token') {
            userProfileMap[key] = value;
          }
        });

        // Now, check if the token is present and the userProfileMap is valid
        if (token != null && userProfileMap.isNotEmpty) {
          await saveToken(token);
          await saveCurrentUser(
            userProfileMap,
          ); // Save the extracted user profile data
          debugPrint('Login successful. Token and user data saved.');
          return true;
        } else {
          debugPrint('Login response missing token or user profile data.');
          return false;
        }
      } else {
        final errorData = response.body.isNotEmpty
            ? jsonDecode(response.body)
            : {'message': 'Unknown error'};
        debugPrint(
          'Login failed: ${errorData['message'] ?? response.statusCode}',
        );
        throw Exception(errorData['message'] ?? 'Failed to login');
      }
    } catch (e) {
      debugPrint('An error occurred during login in AuthService: $e');
      rethrow; // Re-throw to allow AuthProvider to catch and set error message
    }
  }

  // Register method (Also needs adjustment as it likely returns the same structure)
  Future<bool> register({
    required String username,
    required String firstName,
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(
          '$_baseUrl/users/register',
        ), // Assuming /users/register endpoint
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'username': username,
          'firstName': firstName,
          'name': name,
          'email': email,
          'password': password,
          'phone': phone,
          'role': role,
        }),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        // 201 Created or 200 OK
        final Map<String, dynamic> responseData = jsonDecode(response.body);

        final String? token = responseData['token'];

        Map<String, dynamic> userProfileMap = {};
        responseData.forEach((key, value) {
          if (key != 'token') {
            userProfileMap[key] = value;
          }
        });

        if (token != null && userProfileMap.isNotEmpty) {
          await saveToken(token);
          await saveCurrentUser(userProfileMap);
          debugPrint('Registration successful. Token and user data saved.');
          return true;
        } else {
          debugPrint(
            'Registration response missing token or user profile data.',
          );
          return false;
        }
      } else {
        final errorData = response.body.isNotEmpty
            ? jsonDecode(response.body)
            : {'message': 'Unknown error'};
        debugPrint(
          'Registration failed: ${errorData['message'] ?? response.statusCode}',
        );
        throw Exception(errorData['message'] ?? 'Failed to register');
      }
    } catch (e) {
      debugPrint('An error occurred during registration in AuthService: $e');
      rethrow;
    }
  }

  // Fetches the current user's public profile
  Future<UserPublicProfile> fetchCurrentUser() async {
    final token = await getToken();
    if (token == null) throw Exception('Authentication token not found.');

    final response = await http.get(
      Uri.parse('$_baseUrl/users/me'), // Assuming /users/me endpoint
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      // If /users/me returns just the user profile (no token),
      // then 'data' directly is the map for UserPublicProfile.
      if (data is Map<String, dynamic>) {
        return UserPublicProfile.fromMap(data);
      } else {
        throw Exception(
          'Failed to parse user profile: Response is not a valid map.',
        );
      }
    } else {
      final errorData = response.body.isNotEmpty
          ? jsonDecode(response.body)
          : {'message': 'Unknown error'};
      debugPrint('Failed to fetch current user: ${errorData['message']}');
      throw Exception(errorData['message'] ?? 'Failed to fetch user profile');
    }
  }

  // Method to update user profile with only text data
  Future<UserPublicProfile> updateUser(
    String userId,
    Map<String, dynamic> data,
  ) async {
    try {
      final response = await apiService.put('/users/$userId', data);
      final updatedUser = UserPublicProfile.fromMap(response);
      await saveCurrentUser(response);
      return updatedUser;
    } catch (e) {
      debugPrint('Error updating user in AuthService: $e');
      rethrow;
    }
  }

  // NEW: Method to update user profile with an image
  Future<UserPublicProfile> updateUserWithProfileImage({
    required String userId,
    required Map<String, String> data,
    required String imagePath,
  }) async {
    try {
      // Use the multipartRequest method from ApiService
      final response = await apiService.multipartRequest(
        'PUT', // HTTP method
        '/users/$userId', // Endpoint
        data, // Text fields
        imagePath, // File path
        'image', // File field name in the form
      );

      // The API returns the updated user object
      final updatedUser = UserPublicProfile.fromMap(response);

      // Save the updated user data locally
      await saveCurrentUser(response);

      return updatedUser;
    } catch (e) {
      debugPrint('Error updating user with image in AuthService: $e');
      rethrow;
    }
  }

  // NEW: Method to fetch a user's public profile by their ID
  Future<UserPublicProfile> getUserProfileById(String userId) async {
    try {
      final response = await apiService.get('/users/$userId');
      return UserPublicProfile.fromMap(response);
    } catch (e) {
      debugPrint('Failed to fetch user profile for ID $userId: $e');
      throw Exception('Failed to load user profile.');
    }
  }
}
