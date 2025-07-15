class Order {
  final String id;
  final String userId;
  final String restaurantId;
  final String? restaurantName;
  final List<OrderItem> items;
  final double totalAmount;
  final double deliveryFee;
  final double tax;
  final double grandTotal;
  final OrderStatus status;
  final String? deliveryAddress;
  final String? specialInstructions;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deliveredAt;
  final String? paymentMethod;
  final String? paymentId;
  final String? deliveryDriverId;
  final String? deliveryDriverName;
  final String? deliveryDriverPhone;
  final int? estimatedDeliveryTime;
  final String? trackingNumber;

  Order({
    required this.id,
    required this.userId,
    required this.restaurantId,
    this.restaurantName,
    required this.items,
    required this.totalAmount,
    required this.deliveryFee,
    required this.tax,
    required this.grandTotal,
    required this.status,
    this.deliveryAddress,
    this.specialInstructions,
    required this.createdAt,
    this.updatedAt,
    this.deliveredAt,
    this.paymentMethod,
    this.paymentId,
    this.deliveryDriverId,
    this.deliveryDriverName,
    this.deliveryDriverPhone,
    this.estimatedDeliveryTime,
    this.trackingNumber,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'] ?? json['id'] ?? '',
      userId: json['userId'] ?? json['user'] ?? '',
      restaurantId: json['restaurantId'] ?? json['restaurant'] ?? '',
      restaurantName: json['restaurantName'],
      items: (json['items'] as List<dynamic>? ?? [])
          .map((item) => OrderItem.fromJson(item))
          .toList(),
      totalAmount: (json['totalAmount'] ?? 0.0).toDouble(),
      deliveryFee: (json['deliveryFee'] ?? 0.0).toDouble(),
      tax: (json['tax'] ?? 0.0).toDouble(),
      grandTotal: (json['grandTotal'] ?? 0.0).toDouble(),
      status: OrderStatus.values.firstWhere(
        (e) =>
            e.name.toLowerCase() == (json['status'] ?? 'pending').toLowerCase(),
        orElse: () => OrderStatus.pending,
      ),
      deliveryAddress: json['deliveryAddress'],
      specialInstructions: json['specialInstructions'],
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : null,
      deliveredAt: json['deliveredAt'] != null
          ? DateTime.parse(json['deliveredAt'])
          : null,
      paymentMethod: json['paymentMethod'],
      paymentId: json['paymentId'],
      deliveryDriverId: json['deliveryDriverId'],
      deliveryDriverName: json['deliveryDriverName'],
      deliveryDriverPhone: json['deliveryDriverPhone'],
      estimatedDeliveryTime: json['estimatedDeliveryTime'],
      trackingNumber: json['trackingNumber'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userId': userId,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'deliveryFee': deliveryFee,
      'tax': tax,
      'grandTotal': grandTotal,
      'status': status.name,
      'deliveryAddress': deliveryAddress,
      'specialInstructions': specialInstructions,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'deliveredAt': deliveredAt?.toIso8601String(),
      'paymentMethod': paymentMethod,
      'paymentId': paymentId,
      'deliveryDriverId': deliveryDriverId,
      'deliveryDriverName': deliveryDriverName,
      'deliveryDriverPhone': deliveryDriverPhone,
      'estimatedDeliveryTime': estimatedDeliveryTime,
      'trackingNumber': trackingNumber,
    };
  }

  Order copyWith({
    String? id,
    String? userId,
    String? restaurantId,
    String? restaurantName,
    List<OrderItem>? items,
    double? totalAmount,
    double? deliveryFee,
    double? tax,
    double? grandTotal,
    OrderStatus? status,
    String? deliveryAddress,
    String? specialInstructions,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deliveredAt,
    String? paymentMethod,
    String? paymentId,
    String? deliveryDriverId,
    String? deliveryDriverName,
    String? deliveryDriverPhone,
    int? estimatedDeliveryTime,
    String? trackingNumber,
  }) {
    return Order(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      deliveryFee: deliveryFee ?? this.deliveryFee,
      tax: tax ?? this.tax,
      grandTotal: grandTotal ?? this.grandTotal,
      status: status ?? this.status,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deliveredAt: deliveredAt ?? this.deliveredAt,
      paymentMethod: paymentMethod ?? this.paymentMethod,
      paymentId: paymentId ?? this.paymentId,
      deliveryDriverId: deliveryDriverId ?? this.deliveryDriverId,
      deliveryDriverName: deliveryDriverName ?? this.deliveryDriverName,
      deliveryDriverPhone: deliveryDriverPhone ?? this.deliveryDriverPhone,
      estimatedDeliveryTime:
          estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      trackingNumber: trackingNumber ?? this.trackingNumber,
    );
  }

  // Helper methods
  bool get isDelivered => status == OrderStatus.delivered;
  bool get isCancelled => status == OrderStatus.cancelled;
  bool get isPending => status == OrderStatus.pending;
  bool get isInProgress =>
      status == OrderStatus.confirmed || status == OrderStatus.preparing;

  String get statusDisplay {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.pickedUp:
        return 'Picked Up';
      case OrderStatus.delivering:
        return 'Delivering';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  @override
  String toString() {
    return 'Order(id: $id, status: $status, totalAmount: $totalAmount, items: ${items.length})';
  }
}

// Fixed enum name (was picked_up, now pickedUp)
enum OrderStatus {
  pending,
  confirmed,
  preparing,
  pickedUp, // Fixed: was picked_up
  delivering,
  delivered,
  cancelled,
}

class OrderItem {
  final String id;
  final String foodId;
  final String foodName;
  final String? foodImage;
  final double price;
  final int quantity;
  final double totalPrice;
  final List<String>? specialInstructions;

  OrderItem({
    required this.id,
    required this.foodId,
    required this.foodName,
    this.foodImage,
    required this.price,
    required this.quantity,
    required this.totalPrice,
    this.specialInstructions,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      id: json['_id'] ?? json['id'] ?? '',
      foodId: json['foodId'] ?? json['food'] ?? '',
      foodName: json['foodName'] ?? json['name'] ?? '',
      foodImage: json['foodImage'] ?? json['imageUrl'],
      price: (json['price'] ?? 0.0).toDouble(),
      quantity: json['quantity'] ?? 1,
      totalPrice: (json['totalPrice'] ?? 0.0).toDouble(),
      specialInstructions: json['specialInstructions'] != null
          ? List<String>.from(json['specialInstructions'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'foodId': foodId,
      'foodName': foodName,
      'foodImage': foodImage,
      'price': price,
      'quantity': quantity,
      'totalPrice': totalPrice,
      'specialInstructions': specialInstructions,
    };
  }

  OrderItem copyWith({
    String? id,
    String? foodId,
    String? foodName,
    String? foodImage,
    double? price,
    int? quantity,
    double? totalPrice,
    List<String>? specialInstructions,
  }) {
    return OrderItem(
      id: id ?? this.id,
      foodId: foodId ?? this.foodId,
      foodName: foodName ?? this.foodName,
      foodImage: foodImage ?? this.foodImage,
      price: price ?? this.price,
      quantity: quantity ?? this.quantity,
      totalPrice: totalPrice ?? this.totalPrice,
      specialInstructions: specialInstructions ?? this.specialInstructions,
    );
  }

  @override
  String toString() {
    return 'OrderItem(foodName: $foodName, quantity: $quantity, totalPrice: $totalPrice)';
  }
}
