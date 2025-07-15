import 'package:app_client/models/food.dart';

class Cart {
  final String id;
  final String user;
  final String food;
  final int quantity;
  final Food? foodDetails; // Populated food details
  final double? unitPrice; // Cached price for calculation

  Cart({
    required this.id,
    required this.user,
    required this.food,
    required this.quantity,
    this.foodDetails,
    this.unitPrice,
  });

  // Calculate total price for this cart item
  double get totalPrice {
    if (unitPrice != null) {
      return unitPrice! * quantity;
    }
    if (foodDetails != null) {
      return foodDetails!.price * quantity;
    }
    return 0.0;
  }

  // Get food name (from populated details or fallback)
  String get foodName {
    return foodDetails?.name ?? 'Unknown Food';
  }

  // Get food image URL
  String? get foodImageUrl {
    return foodDetails?.imageUrl;
  }

  // Get restaurant name
  String get restaurantName {
    return foodDetails?.restaurantDetails.name ?? 'Unknown Restaurant';
  }

  factory Cart.fromJson(Map<String, dynamic> json) {
    return Cart(
      id: json['_id'] ?? '',
      user: json['user'] ?? '',
      food: json['food'] ?? '',
      quantity: json['quantity'] ?? 1,
      foodDetails: json['foodDetails'] != null
          ? Food.fromJson(json['foodDetails'])
          : null,
      unitPrice: json['unitPrice']?.toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': user,
      'food': food,
      'quantity': quantity,
      if (foodDetails != null) 'foodDetails': foodDetails!.toJson(),
      if (unitPrice != null) 'unitPrice': unitPrice,
    };
  }

  // Create cart item for API request
  Map<String, dynamic> toCreateJson() {
    return {'food': food, 'quantity': quantity};
  }

  Cart copyWith({
    String? id,
    String? user,
    String? food,
    int? quantity,
    Food? foodDetails,
    double? unitPrice,
  }) {
    return Cart(
      id: id ?? this.id,
      user: user ?? this.user,
      food: food ?? this.food,
      quantity: quantity ?? this.quantity,
      foodDetails: foodDetails ?? this.foodDetails,
      unitPrice: unitPrice ?? this.unitPrice,
    );
  }

  @override
  String toString() {
    return 'Cart(id: $id, food: $foodName, quantity: $quantity, total: ${totalPrice.toStringAsFixed(2)})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Cart && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

// Cart summary for checkout
class CartSummary {
  final List<Cart> items;
  final double subtotal;
  final double deliveryFee;
  final double serviceFee;
  final double tax;
  final double total;
  final int totalItems;

  CartSummary({
    required this.items,
    required this.subtotal,
    this.deliveryFee = 5.0,
    this.serviceFee = 2.0,
    this.tax = 0.0,
    required this.totalItems,
  }) : total = subtotal + deliveryFee + serviceFee + tax;

  // Calculate subtotal from items
  static double calculateSubtotal(List<Cart> items) {
    return items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  // Calculate total items count
  static int calculateTotalItems(List<Cart> items) {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  // Create summary from cart items
  factory CartSummary.fromItems(List<Cart> items) {
    final subtotal = calculateSubtotal(items);
    final totalItems = calculateTotalItems(items);
    final tax = subtotal * 0.1; // 10% tax rate

    return CartSummary(
      items: items,
      subtotal: subtotal,
      tax: tax,
      totalItems: totalItems,
    );
  }

  // Group items by restaurant
  Map<String, List<Cart>> get itemsByRestaurant {
    final Map<String, List<Cart>> grouped = {};

    for (final item in items) {
      final restaurantName = item.restaurantName;
      if (!grouped.containsKey(restaurantName)) {
        grouped[restaurantName] = [];
      }
      grouped[restaurantName]!.add(item);
    }

    return grouped;
  }

  // Check if cart has items from multiple restaurants
  bool get hasMultipleRestaurants {
    return itemsByRestaurant.keys.length > 1;
  }

  Map<String, dynamic> toJson() {
    return {
      'items': items.map((item) => item.toJson()).toList(),
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'serviceFee': serviceFee,
      'tax': tax,
      'total': total,
      'totalItems': totalItems,
    };
  }

  @override
  String toString() {
    return 'CartSummary(items: ${items.length}, total: ${total.toStringAsFixed(2)})';
  }
}
