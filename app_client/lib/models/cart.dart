// lib/models/cart.dart (REVISED)
import 'package:app_client/models/food.dart';
import 'package:app_client/models/user_public_profile.dart';

// This model directly matches the `Cart` schema in `openapi -v2.3.yaml`
class Cart {
  final String id;
  final UserPublicProfile user; // CHANGED from String to UserPublicProfile
  final Food food; // CHANGED from String to Food
  final int quantity;

  Cart({
    required this.id,
    required this.user,
    required this.food,
    required this.quantity,
  });

  double get totalPrice => food.price * quantity;
  String get foodName => food.name;
  String? get foodImageUrl => food.imageUrl;

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['_id'],
      // The API now returns the full objects, so we parse them directly
      user: UserPublicProfile.fromMap(json['user']),
      food: Food.fromJson(json['food']),
      quantity: json['quantity'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': user.toMap(),
      'food': food.toJson(),
      'quantity': quantity,
    };
  }
}
