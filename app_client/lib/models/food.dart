class Food {
  final String id;
  final String name;
  final String description;
  final String category;
  final double? calories;
  final List<String> ingredients;
  final double price;
  final String restaurant;
  final RestaurantDetails restaurantDetails;
  final String? imageUrl;
  final bool isAvailable;
  final List<FoodRating> ratings;
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
    this.isAvailable = true,
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
      id: json['_id'] ?? '',
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      category: json['category'] ?? '',
      calories: json['calories']?.toDouble(),
      ingredients: List<String>.from(json['ingredients'] ?? []),
      price: (json['price'] ?? 0).toDouble(),
      restaurant: json['restaurant'] ?? '',
      restaurantDetails: RestaurantDetails.fromJson(
        json['restaurantDetails'] ?? {},
      ),
      imageUrl: json['imageUrl'],
      isAvailable: json['isAvailable'] ?? true,
      ratings:
          (json['ratings'] as List<dynamic>?)
              ?.map((rating) => FoodRating.fromJson(rating))
              .toList() ??
          [],
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
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
      'ratings': ratings.map((rating) => rating.toJson()).toList(),
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
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      contact: json['contact'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {'name': name, 'address': address, 'contact': contact};
  }
}

class FoodRating {
  final String clientId;
  final double rating;

  FoodRating({required this.clientId, required this.rating});

  factory FoodRating.fromJson(Map<String, dynamic> json) {
    return FoodRating(
      clientId: json['clientId'] ?? '',
      rating: (json['rating'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {'clientId': clientId, 'rating': rating};
  }
}
