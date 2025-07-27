// lib/models/user_public_profile.dart
// Represents the safe, public data for a user returned by most endpoints.

class UserPublicProfile {
  final String id;
  final String username;
  final String firstName;
  final String name;
  final String email;
  final String? image;
  final String phone; // NEW: Added phone number
  final String role;
  final bool isOnline;

  UserPublicProfile({
    required this.id,
    required this.username,
    required this.firstName,
    required this.name,
    required this.email,
    this.image,
    required this.phone, // NEW: Added to constructor
    required this.role,
    required this.isOnline,
  });

  factory UserPublicProfile.fromMap(Map<String, dynamic> map) {
    return UserPublicProfile(
      id: map['_id'] ?? '',
      username: map['username'] ?? '',
      firstName: map['firstName'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      image: map['image'],
      phone: map['phone'] ?? '', // NEW: Parsing from map
      role: map['role'] ?? 'client',
      isOnline: map['isOnline'] ?? false,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'username': username,
      'firstName': firstName,
      'name': name,
      'email': email,
      'image': image,
      'phone': phone, // NEW: Added to map
      'role': role,
      'isOnline': isOnline,
    };
  }
}
