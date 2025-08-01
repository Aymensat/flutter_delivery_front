// lib/models/cart.dart (REVISED)
import 'package:app_client/models/food.dart';
import 'package:app_client/models/user_public_profile.dart';

// This model directly matches the `Cart` schema in `openapi-v4.yaml`
class Cart {
  final String id;
  final UserPublicProfile user;
  final Food food;
  final int quantity;
  final List<String> excludedIngredients; // NEW

  Cart({
    required this.id,
    required this.user,
    required this.food,
    required this.quantity,
    this.excludedIngredients = const [], // NEW
  });

  double get totalPrice => food.price * quantity;
  String get foodName => food.name;
  String? get foodImageUrl => food.imageUrl;

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['_id'],
      user: UserPublicProfile.fromMap(json['user']),
      food: Food.fromJson(json['food']),
      quantity: json['quantity'],
      // NEW: Handle optional excludedIngredients
      excludedIngredients: json['excludedIngredients'] != null
          ? List<String>.from(json['excludedIngredients'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': user.toMap(),
      'food': food.toJson(),
      'quantity': quantity,
      'excludedIngredients': excludedIngredients, // NEW
    };
  }
}
