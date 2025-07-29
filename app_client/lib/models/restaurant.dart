// lib/models/restaurant.dart
import 'package:flutter/foundation.dart'; // For @required if needed
import 'food.dart'; // Import the Food model

class Restaurant {
  final String id;
  final String name;
  final List<String> images;
  final String description;
  final String address;
  final String contact;
  final String workingHours;
  final String cuisine;
  final double latitude;
  final double longitude;
  final double rating;
  final String? imageUrl; // Nullable as per schema
  final OpeningHours? openingHours; // Nullable as per schema
  final bool isActive;
  final DateTime createdAt;
  final DateTime updatedAt;
  List<Food>? foods; // Add this property to hold associated food items

  Restaurant({
    required this.id,
    required this.name,
    required this.images,
    required this.description,
    required this.address,
    required this.contact,
    required this.workingHours,
    required this.cuisine,
    required this.latitude,
    required this.longitude,
    required this.rating,
    this.imageUrl,
    this.openingHours,
    required this.isActive,
    required this.createdAt,
    required this.updatedAt,
    this.foods, // Initialize the foods property in the constructor
  });

  factory Restaurant.fromJson(Map<String, dynamic> json) {
    // Safely parse imageUrl:
    // If json['imageUrl'] is a String, use it directly.
    // If it's a Map, try to extract a 'url' key from it.
    // Otherwise, it's null.
    String? parsedImageUrl;
    if (json['imageUrl'] is String) {
      parsedImageUrl = json['imageUrl'] as String;
    } else if (json['imageUrl'] is Map) {
      parsedImageUrl =
          (json['imageUrl'] as Map<String, dynamic>)['url'] as String?;
    }

    return Restaurant(
      id: json['_id'] as String? ?? '', // Robust null handling
      name: json['name'] as String? ?? '',
      images: List<String>.from(
        json['images'] ?? [],
      ), // Ensure list of strings, handle null
      description: json['description'] as String? ?? '',
      address: json['address'] as String? ?? '',
      contact: json['contact'] as String? ?? '',
      workingHours: json['workingHours'] as String? ?? '',
      cuisine: json['cuisine'] as String? ?? '',
      latitude:
          (json['latitude'] as num?)?.toDouble() ??
          0.0, // Handle null and convert
      longitude:
          (json['longitude'] as num?)?.toDouble() ??
          0.0, // Handle null and convert
      rating:
          (json['rating'] as num?)?.toDouble() ??
          0.0, // Handle null and convert
      imageUrl: parsedImageUrl, // Use the safely parsed imageUrl
      openingHours: json['openingHours'] != null
          ? OpeningHours.fromJson(json['openingHours'] as Map<String, dynamic>)
          : null, // Conditionally parse OpeningHours
      isActive:
          json['isActive'] as bool? ?? true, // Default to true if not provided
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(), // Safe parsing
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(), // Safe parsing
      // foods property is not parsed from JSON here, it's populated by RestaurantProvider
      foods: null, // Initialize as null, will be populated by provider
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'images': images,
      'description': description,
      'address': address,
      'contact': contact,
      'workingHours': workingHours,
      'cuisine': cuisine,
      'latitude': latitude,
      'longitude': longitude,
      'rating': rating,
      'imageUrl': imageUrl,
      'openingHours': openingHours?.toJson(),
      'isActive': isActive,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      // foods is not part of the JSON serialization as it's a derived property
    };
  }
}

class OpeningHours {
  final String open;
  final String close;

  OpeningHours({required this.open, required this.close});

  factory OpeningHours.fromJson(Map<String, dynamic> json) {
    return OpeningHours(
      open: json['open'] as String? ?? '', // Robust null handling
      close: json['close'] as String? ?? '', // Robust null handling
    );
  }

  Map<String, dynamic> toJson() {
    return {'open': open, 'close': close};
  }
}
