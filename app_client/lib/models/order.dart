// Enum to represent the available payment methods.
enum PaymentMethod {
  creditCard,
  paypal,
  cash, // Added for cash on delivery
}

// Extension to provide string conversion for the PaymentMethod enum.
extension PaymentMethodExtension on PaymentMethod {
  // Converts the enum value to its corresponding string representation for the API.
  String get value {
    switch (this) {
      case PaymentMethod.creditCard:
        return 'credit-card';
      case PaymentMethod.paypal:
        return 'paypal';
      case PaymentMethod.cash:
        return 'cash'; // The backend will handle this as a special case.
      // default:
      //   return 'credit-card';
    }
  }

  // Converts a string from the API to the corresponding enum value.
  static PaymentMethod fromString(String? value) {
    switch (value) {
      case 'credit-card':
        return PaymentMethod.creditCard;
      case 'paypal':
        return PaymentMethod.paypal;
      case 'cash':
        return PaymentMethod.cash;
      default:
        // Default to creditCard if the value is unknown or null.
        return PaymentMethod.creditCard;
    }
  }
}

class Order {
  final String id;
  final String user;
  final String restaurant;
  final String? restaurantName;
  final double? restaurantLatitude;
  final double? restaurantLongitude;
  final List<OrderItem> items;
  final double totalPrice;
  final double subtotal;
  final double deliveryFee;
  final String status;
  final String paymentStatus;
  final String serviceMethod;
  final PaymentMethod
  paymentMethod; // Changed from String to PaymentMethod enum
  final int reference;
  final String phone;
  final double latitude;
  final double longitude;
  final int cookingTime;
  final String? livreur;
  final DateTime createdAt;
  final DateTime? updatedAt;

  Order({
    required this.id,
    required this.user,
    required this.restaurant,
    this.restaurantName,
    this.restaurantLatitude,
    this.restaurantLongitude,
    required this.items,
    required this.totalPrice,
    required this.subtotal,
    required this.deliveryFee,
    required this.status,
    required this.paymentStatus,
    required this.serviceMethod,
    required this.paymentMethod,
    required this.reference,
    required this.phone,
    required this.latitude,
    required this.longitude,
    required this.cookingTime,
    this.livreur,
    required this.createdAt,
    this.updatedAt,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    // Helper to extract ID from a populated field (Map) or use it directly if it's a String
    String extractId(dynamic field) {
      if (field is String) {
        return field;
      }
      if (field is Map<String, dynamic>) {
        return field['_id'] ?? '';
      }
      return '';
    }

    return Order(
      id: json['_id'] ?? '',
      user: extractId(json['user']),
      restaurant: extractId(json['restaurant']),
      restaurantName: json['restaurantName'],
      restaurantLatitude: (json['restaurantLatitude'] as num?)?.toDouble(),
      restaurantLongitude: (json['restaurantLongitude'] as num?)?.toDouble(),
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => OrderItem.fromJson(item as Map<String, dynamic>))
          .toList(),
      totalPrice: (json['totalPrice'] as num?)?.toDouble() ?? 0.0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      deliveryFee: (json['deliveryFee'] as num?)?.toDouble() ?? 3.0,
      status: json['status'] ?? 'pending',
      paymentStatus: json['paymentStatus'] ?? 'pending',
      serviceMethod: json['serviceMethod'] ?? 'delivery',
      paymentMethod: PaymentMethodExtension.fromString(
        json['paymentMethod'],
      ), // Use the extension to parse the string
      reference: json['reference'] ?? 0,
      phone: json['phone'] ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      cookingTime: json['cookingTime'] ?? 0,
      livreur: json['livreur'],
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': user,
      'restaurant': restaurant,
      'restaurantName': restaurantName,
      'restaurantLatitude': restaurantLatitude,
      'restaurantLongitude': restaurantLongitude,
      'items': items.map((item) => item.toJson()).toList(),
      'totalPrice': totalPrice,
      'subtotal': subtotal,
      'deliveryFee': deliveryFee,
      'status': status,
      'paymentStatus': paymentStatus,
      'serviceMethod': serviceMethod,
      'paymentMethod':
          paymentMethod.value, // Use the extension to get the string value
      'reference': reference,
      'phone': phone,
      'latitude': latitude,
      'longitude': longitude,
      'cookingTime': cookingTime,
      'livreur': livreur,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
    };
  }
}

class OrderItem {
  final String food;
  final int quantity;
  final List<String> excludedIngredients;

  OrderItem({
    required this.food,
    required this.quantity,
    this.excludedIngredients = const [],
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    String foodId;
    // Handle cases where 'food' can be a String (ID) or a Map (populated object)
    if (json['food'] is String) {
      foodId = json['food'];
    } else if (json['food'] is Map<String, dynamic>) {
      foodId = json['food']['_id'] ?? '';
    } else {
      foodId = '';
    }

    return OrderItem(
      food: foodId,
      quantity: json['quantity'] ?? 1,
      excludedIngredients: json['excludedIngredients'] != null
          ? List<String>.from(json['excludedIngredients'])
          : [],
    );
  }

  Map<String, dynamic> toJson() {
    // The backend expects the 'food' field to be the ID string directly.
    return {
      'food': food,
      'quantity': quantity,
      'excludedIngredients': excludedIngredients,
    };
  }
}
