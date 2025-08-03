// lib/models/food.dart

class Food {
  final String id;
  final String name;
  final String description;
  final String category;
  final double? calories; // Nullable as per schema, or can be 0
  final List<String> ingredients;
  final double price;
  final String restaurant; // ID of the restaurant
  final RestaurantDetails restaurantDetails; // Nested object
  final String? imageUrl; // Nullable as images might not always be present
  final bool isAvailable;
  final List<FoodRating> ratings; // List of ratings
  final DateTime createdAt;
  final DateTime updatedAt;

  Food({
    required this.id,
    required this.name,
    required this.description,
    required this.category,
    this.calories,
    required this.ingredients,
    required this.price,
    required this.restaurant,
    required this.restaurantDetails,
    this.imageUrl,
    this.isAvailable = true, // Default value for isAvailable
    required this.ratings,
    required this.createdAt,
    required this.updatedAt,
  });

  // Calculate average rating
  double get averageRating {
    if (ratings.isEmpty) return 0.0;
    double total = ratings.fold(0.0, (sum, rating) => sum + rating.rating);
    return total / ratings.length;
  }

  // Get rating count
  int get ratingCount => ratings.length;

  // Check if food is vegetarian based on ingredients
  bool get isVegetarian {
    const nonVegKeywords = [
      'chicken',
      'beef',
      'meat',
      'fish',
      'seafood',
      'lamb',
      'pork',
    ];
    return !ingredients.any(
      (ingredient) => nonVegKeywords.any(
        (keyword) => ingredient.toLowerCase().contains(keyword),
      ),
    );
  }

  factory Food.fromJson(Map<String, dynamic> json) {
    return Food(
      id:
          json['_id'] as String? ??
          '', // Use null-aware ?? for default empty string
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      category: json['category'] as String? ?? '',
      calories: (json['calories'] as num?)
          ?.toDouble(), // Handle null and convert to double
      ingredients: List<String>.from(
        json['ingredients'] ?? [],
      ), // Ensure it's a list of strings
      price:
          (json['price'] as num?)?.toDouble() ??
          0.0, // Handle null and convert to double, default 0.0
      restaurant: json['restaurant'] as String? ?? '',
      restaurantDetails: RestaurantDetails.fromJson(
        json['restaurantDetails'] as Map<String, dynamic>? ??
            {}, // Handle null map
      ),
      imageUrl: json['imageUrl'] as String?, // Directly cast to String?
      isAvailable:
          json['isAvailable'] as bool? ??
          true, // Default to true if not provided
      ratings:
          (json['ratings'] as List<dynamic>?)
              ?.map((e) => FoodRating.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [], // Handle null list and map each item
      createdAt:
          DateTime.tryParse(json['createdAt'] as String? ?? '') ??
          DateTime.now(), // Use tryParse and default to now
      updatedAt:
          DateTime.tryParse(json['updatedAt'] as String? ?? '') ??
          DateTime.now(), // Use tryParse and default to now
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'name': name,
      'description': description,
      'category': category,
      'calories': calories,
      'ingredients': ingredients,
      'price': price,
      'restaurant': restaurant,
      'restaurantDetails': restaurantDetails.toJson(),
      'imageUrl': imageUrl,
      'isAvailable': isAvailable,
      'ratings': ratings.map((r) => r.toJson()).toList(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  Food copyWith({
    String? id,
    String? name,
    String? description,
    String? category,
    double? calories,
    List<String>? ingredients,
    double? price,
    String? restaurant,
    RestaurantDetails? restaurantDetails,
    String? imageUrl,
    bool? isAvailable,
    List<FoodRating>? ratings,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Food(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      category: category ?? this.category,
      calories: calories ?? this.calories,
      ingredients: ingredients ?? this.ingredients,
      price: price ?? this.price,
      restaurant: restaurant ?? this.restaurant,
      restaurantDetails: restaurantDetails ?? this.restaurantDetails,
      imageUrl: imageUrl ?? this.imageUrl,
      isAvailable: isAvailable ?? this.isAvailable,
      ratings: ratings ?? this.ratings,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'Food(id: $id, name: $name, price: $price, restaurant: ${restaurantDetails.name})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Food && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Nested class for restaurant details within the Food model
// Renamed from FoodRestaurantDetails to RestaurantDetails for consistency with your original file
class RestaurantDetails {
  final String name;
  final String address;
  final String contact;

  RestaurantDetails({
    required this.name,
    required this.address,
    required this.contact,
  });

  factory RestaurantDetails.fromJson(Map<String, dynamic> json) {
    return RestaurantDetails(
      name:
          json['name'] as String? ??
          '', // Use null-aware ?? for default empty string
      address: json['address'] as String? ?? '',
      contact: json['contact'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'address': address, 'contact': contact};
  }
}

// Nested class for food ratings
class FoodRating {
  final String clientId;
  final double rating;

  FoodRating({required this.clientId, required this.rating});

  factory FoodRating.fromJson(Map<String, dynamic> json) {
    return FoodRating(
      clientId:
          json['clientId'] as String? ??
          '', // Use null-aware ?? for default empty string
      rating:
          (json['rating'] as num?)?.toDouble() ??
          0.0, // Handle null and convert to double, default 0.0
    );
  }

  Map<String, dynamic> toJson() {
    return {'clientId': clientId, 'rating': rating};
  }
}
