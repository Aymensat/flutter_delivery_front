// lib/services/auth_service.dart
import 'dart:convert';
import 'package:flutter/foundation.dart'; // For debugPrint
import 'package:http/http.dart' as http; // Now actually used
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import '../models/user.dart'; // For the User model used in registration
import '../models/user_public_profile.dart'; // For UserPublicProfile

class AuthService {
  final String _baseUrl = AppConfig.baseUrl; // Now used in API calls
  static const String _tokenKey = 'auth_token';
  static const String _userKey =
      'user_data'; // Renamed from _userKey to userKey to be public for AuthProvider to access

  // Expose _userKey as a static getter for external classes to access
  static String get userKey => _userKey;

  // Initialize service, typically to load initial user data/token
  Future<void> init() async {
    // This method can be used to load user data/token on app start
    // For now, getToken() and getCurrentUser() handle this on demand.
    // If you need proactive loading, implement it here.
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_tokenKey);
  }

  Future<void> saveToken(String token) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_tokenKey, token);
  }

  Future<void> saveUser(UserPublicProfile user) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _userKey,
      jsonEncode(user.toMap()),
    ); // Assuming UserPublicProfile has a toMap()
  }

  UserPublicProfile? getCurrentUser() {
    // This method should return the currently logged-in user's public profile
    // It should load from SharedPreferences if not already in memory
    // For now, AuthProvider will manage the in-memory _user.
    // If you want AuthService to manage it, this method needs logic to read from SharedPreferences.
    return null; // AuthProvider will handle the in-memory user
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_tokenKey);
    await prefs.remove(_userKey);
    debugPrint('User logged out and local data cleared.'); // Replaced print
  }

  // Login now points to /users/login
  Future<Map<String, dynamic>> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/users/login'), // UPDATED PATH
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({'email': email, 'password': password}),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      await saveToken(data['token']); // Save the token
      // Assuming 'user' data is returned in the login response
      if (data['user'] != null) {
        final userProfile = UserPublicProfile.fromMap(data['user']);
        await saveUser(userProfile); // Save user data
      }
      return {'success': true, 'token': data['token'], 'user': data['user']};
    } else {
      final errorData = jsonDecode(response.body);
      debugPrint('Login failed: ${errorData['message']}'); // Replaced print
      throw Exception(errorData['message'] ?? 'Login failed');
    }
  }

  // Register a new user
  Future<bool> register({
    required String username,
    required String firstName,
    required String name,
    required String email,
    required String password,
    required String phone,
    required String role,
  }) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/users/register'), // Ensure this is the correct path
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

    if (response.statusCode == 201) {
      final data = jsonDecode(response.body);
      await saveToken(
        data['token'],
      ); // Save the token upon successful registration
      if (data['user'] != null) {
        final userProfile = UserPublicProfile.fromMap(data['user']);
        await saveUser(userProfile); // Save user data
      }
      debugPrint('Registration successful: ${response.body}'); // Replaced print
      return true;
    } else {
      final errorData = jsonDecode(response.body);
      debugPrint(
        'Registration failed: ${errorData['message']}',
      ); // Replaced print
      throw Exception(errorData['message'] ?? 'Registration failed');
    }
  }

  // Method for uploading registration image
  Future<bool> uploadRegistrationImage(
    String userId,
    String imagePath,
    String token,
  ) async {
    var request = http.MultipartRequest(
      'POST',
      Uri.parse('$_baseUrl/users/register/image?userId=$userId'),
    );
    request.headers['Authorization'] = 'Bearer $token';
    request.files.add(await http.MultipartFile.fromPath('image', imagePath));
    var response = await request.send();
    return response.statusCode == 201;
  }

  // NEW method for changing password
  Future<bool> changePassword(String oldPassword, String newPassword) async {
    final token = await getToken();
    if (token == null) throw Exception('Authentication token not found.');

    final response = await http.post(
      Uri.parse('$_baseUrl/users/change-password'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'oldPassword': oldPassword,
        'newPassword': newPassword,
      }),
    );
    if (response.statusCode == 200) {
      debugPrint('Password changed successfully.'); // Replaced print
      return true;
    } else {
      final errorData = jsonDecode(response.body);
      debugPrint(
        'Password change failed: ${errorData['message']}',
      ); // Replaced print
      throw Exception(errorData['message'] ?? 'Failed to change password');
    }
  }

  // Fetches the current user's public profile
  Future<UserPublicProfile> fetchCurrentUser() async {
    final token = await getToken();
    if (token == null) throw Exception('Authentication token not found.');

    final response = await http.get(
      Uri.parse('$_baseUrl/users/me'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      return UserPublicProfile.fromMap(
        data,
      ); // Assuming the response body is the UserPublicProfile map
    } else {
      final errorData = jsonDecode(response.body);
      debugPrint(
        'Failed to fetch current user: ${errorData['message']}',
      ); // Replaced print
      throw Exception(errorData['message'] ?? 'Failed to fetch user data');
    }
  }
}
