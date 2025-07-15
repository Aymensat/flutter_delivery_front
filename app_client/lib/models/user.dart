// lib/models/user.dart
import 'dart:convert';

class User {
  final String id;
  final String username;
  final String firstName;
  final String name;
  final String email;
  final String? image;
  final bool verified;
  final String phone;
  final Location? location;
  final String role;
  final String? vehicleType;
  final List<String>? vehicleDocuments;
  final String status;
  final bool isOnline;
  final DateTime? lastActive;
  final List<Rating>? ratings;
  final Map<String, dynamic>? vehicle;
  final LivreurStats? livreurStats;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  User({
    required this.id,
    required this.username,
    required this.firstName,
    required this.name,
    required this.email,
    this.image,
    this.verified = false,
    required this.phone,
    this.location,
    this.role = 'client',
    this.vehicleType,
    this.vehicleDocuments,
    this.status = 'available',
    this.isOnline = false,
    this.lastActive,
    this.ratings,
    this.vehicle,
    this.livreurStats,
    this.createdAt,
    this.updatedAt,
  });

  // Convert from JSON string
  factory User.fromJson(String jsonString) {
    final Map<String, dynamic> json = jsonDecode(jsonString);
    return User.fromMap(json);
  }

  // Convert from Map
  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      id: map['_id'] ?? map['id'] ?? '',
      username: map['username'] ?? '',
      firstName: map['firstName'] ?? '',
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      image: map['image'],
      verified: map['verified'] ?? false,
      phone: map['phone'] ?? '',
      location: map['location'] != null
          ? Location.fromMap(map['location'])
          : null,
      role: map['role'] ?? 'client',
      vehicleType: map['vehiculetype'] ?? map['vehicleType'],
      vehicleDocuments: map['vehicleDocuments'] != null
          ? List<String>.from(map['vehicleDocuments'])
          : null,
      status: map['status'] ?? 'available',
      isOnline: map['isOnline'] ?? false,
      lastActive: map['lastActive'] != null
          ? DateTime.tryParse(map['lastActive'])
          : null,
      ratings: map['ratings'] != null
          ? (map['ratings'] as List).map((r) => Rating.fromMap(r)).toList()
          : null,
      vehicle: map['vehicle'],
      livreurStats: map['livreurStats'] != null
          ? LivreurStats.fromMap(map['livreurStats'])
          : null,
      createdAt: map['createdAt'] != null
          ? DateTime.tryParse(map['createdAt'])
          : null,
      updatedAt: map['updatedAt'] != null
          ? DateTime.tryParse(map['updatedAt'])
          : null,
    );
  }

  // Convert to JSON string
  String toJson() {
    return jsonEncode(toMap());
  }

  // Convert to Map
  Map<String, dynamic> toMap() {
    return {
      '_id': id,
      'username': username,
      'firstName': firstName,
      'name': name,
      'email': email,
      'image': image,
      'verified': verified,
      'phone': phone,
      'location': location?.toMap(),
      'role': role,
      'vehiculetype': vehicleType,
      'vehicleDocuments': vehicleDocuments,
      'status': status,
      'isOnline': isOnline,
      'lastActive': lastActive?.toIso8601String(),
      'ratings': ratings?.map((r) => r.toMap()).toList(),
      'vehicle': vehicle,
      'livreurStats': livreurStats?.toMap(),
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }

  // Create copy with updated fields
  User copyWith({
    String? id,
    String? username,
    String? firstName,
    String? name,
    String? email,
    String? image,
    bool? verified,
    String? phone,
    Location? location,
    String? role,
    String? vehicleType,
    List<String>? vehicleDocuments,
    String? status,
    bool? isOnline,
    DateTime? lastActive,
    List<Rating>? ratings,
    Map<String, dynamic>? vehicle,
    LivreurStats? livreurStats,
  }) {
    return User(
      id: id ?? this.id,
      username: username ?? this.username,
      firstName: firstName ?? this.firstName,
      name: name ?? this.name,
      email: email ?? this.email,
      image: image ?? this.image,
      verified: verified ?? this.verified,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      role: role ?? this.role,
      vehicleType: vehicleType ?? this.vehicleType,
      vehicleDocuments: vehicleDocuments ?? this.vehicleDocuments,
      status: status ?? this.status,
      isOnline: isOnline ?? this.isOnline,
      lastActive: lastActive ?? this.lastActive,
      ratings: ratings ?? this.ratings,
      vehicle: vehicle ?? this.vehicle,
      livreurStats: livreurStats ?? this.livreurStats,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
    );
  }
}

class Location {
  final double latitude;
  final double longitude;

  Location({required this.latitude, required this.longitude});

  factory Location.fromMap(Map<String, dynamic> map) {
    return Location(
      latitude: (map['latitude'] ?? 0.0).toDouble(),
      longitude: (map['longitude'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {'latitude': latitude, 'longitude': longitude};
  }
}

class Rating {
  final String clientId;
  final int rating;

  Rating({required this.clientId, required this.rating});

  factory Rating.fromMap(Map<String, dynamic> map) {
    return Rating(clientId: map['clientId'] ?? '', rating: map['rating'] ?? 0);
  }

  Map<String, dynamic> toMap() {
    return {'clientId': clientId, 'rating': rating};
  }
}

class LivreurStats {
  final int deliveriesCompleted;
  final int deliveriesThisMonth;
  final String averageTime;
  final String monthlyEarnings;
  final String successRate;
  final double rating;

  LivreurStats({
    required this.deliveriesCompleted,
    required this.deliveriesThisMonth,
    required this.averageTime,
    required this.monthlyEarnings,
    required this.successRate,
    required this.rating,
  });

  factory LivreurStats.fromMap(Map<String, dynamic> map) {
    return LivreurStats(
      deliveriesCompleted: map['deliveriesCompleted'] ?? 0,
      deliveriesThisMonth: map['deliveriesThisMonth'] ?? 0,
      averageTime: map['averageTime'] ?? '',
      monthlyEarnings: map['monthlyEarnings'] ?? '',
      successRate: map['successRate'] ?? '',
      rating: (map['rating'] ?? 0.0).toDouble(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'deliveriesCompleted': deliveriesCompleted,
      'deliveriesThisMonth': deliveriesThisMonth,
      'averageTime': averageTime,
      'monthlyEarnings': monthlyEarnings,
      'successRate': successRate,
      'rating': rating,
    };
  }
}
