import 'package:app_client/models/cart.dart';
import 'package:app_client/models/user.dart';

enum OrderStatus {
  pending,
  confirmed,
  preparing,
  ready,
  picked_up,
  delivering,
  delivered,
  cancelled,
}

class Order {
  final String id;
  final String user;
  final List<OrderItem> items;
  final double totalAmount;
  final OrderStatus status;
  final String? deliveryAddress;
  final String? specialInstructions;
  final String? assignedDriver;
  final DateTime? estimatedDeliveryTime;
  final DateTime createdAt;
  final DateTime updatedAt;
  final String? paymentId;
  final bool isPaid;
  final User? userDetails;
  final User? driverDetails;

  Order({
    required this.id,
    required this.user,
    required this.items,
    required this.totalAmount,
    required this.status,
    this.deliveryAddress,
    this.specialInstructions,
    this.assignedDriver,
    this.estimatedDeliveryTime,
    required this.createdAt,
    required this.updatedAt,
    this.paymentId,
    this.isPaid = false,
    this.userDetails,
    this.driverDetails,
  });

  // Calculate subtotal from items
  double get subtotal {
    return items.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  // Get total items count
  int get totalItems {
    return items.fold(0, (sum, item) => sum + item.quantity);
  }

  // Get estimated delivery time as formatted string
  String get estimatedDeliveryTimeFormatted {
    if (estimatedDeliveryTime == null) return 'TBD';
    final difference = estimatedDeliveryTime!.difference(DateTime.now());
    if (difference.inMinutes <= 0) return 'Now';
    if (difference.inMinutes < 60) return '${difference.inMinutes} min';
    return '${difference.inHours}h ${difference.inMinutes % 60}m';
  }

  // Get order status as display string
  String get statusDisplay {
    switch (status) {
      case OrderStatus.pending:
        return 'Pending';
      case OrderStatus.confirmed:
        return 'Confirmed';
      case OrderStatus.preparing:
        return 'Preparing';
      case OrderStatus.ready:
        return 'Ready for Pickup';
      case OrderStatus.picked_up:
        return 'Picked Up';
      case OrderStatus.delivering:
        return 'On the Way';
      case OrderStatus.delivered:
        return 'Delivered';
      case OrderStatus.cancelled:
        return 'Cancelled';
    }
  }

  // Get status color for UI
  String get statusColor {
    switch (status) {
      case OrderStatus.pending:
        return '#FFA500'; // Orange
      case OrderStatus.confirmed:
      case OrderStatus.preparing:
        return '#2196F3'; // Blue
      case OrderStatus.ready:
      case OrderStatus.picked_up:
      case OrderStatus.delivering:
        return '#FF9800'; // Amber
      case OrderStatus.delivered:
        return '#4CAF50'; // Green
      case OrderStatus.cancelled:
        return '#F44336'; // Red
    }
  }

  // Check if order can be cancelled
  bool get canBeCancelled {
    return status == OrderStatus.pending || status == OrderStatus.confirmed;
  }

  // Check if order is active (not delivered or cancelled)
  bool get isActive {
    return status != OrderStatus.delivered && status != OrderStatus.cancelled;
  }

  // Get restaurants involved in this order
  List<String> get restaurantIds {
    return items.map((item) => item.restaurantId).toSet().toList();
  }

  // Get restaurant names
  List<String> get restaurantNames {
    return items.map((item) => item.restaurantName).toSet().toList();
  }

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['_id'] ?? '',
      user: json['user'] ?? '',
      items:
          (json['items'] as List<dynamic>?)
              ?.map((item) => OrderItem.fromJson(item))
              .toList() ??
          [],
      totalAmount: (json['totalAmount'] ?? 0).toDouble(),
      status: _parseOrderStatus(json['status']),
      deliveryAddress: json['deliveryAddress'],
      specialInstructions: json['specialInstructions'],
      assignedDriver: json['assignedDriver'],
      estimatedDeliveryTime: json['estimatedDeliveryTime'] != null
          ? DateTime.parse(json['estimatedDeliveryTime'])
          : null,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
      paymentId: json['paymentId'],
      isPaid: json['isPaid'] ?? false,
      userDetails: json['userDetails'] != null
          ? User.fromJson(json['userDetails'])
          : null,
      driverDetails: json['driverDetails'] != null
          ? User.fromJson(json['driverDetails'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': user,
      'items': items.map((item) => item.toJson()).toList(),
      'totalAmount': totalAmount,
      'status': status.name,
      'deliveryAddress': deliveryAddress,
      'specialInstructions': specialInstructions,
      'assignedDriver': assignedDriver,
      'estimatedDeliveryTime': estimatedDeliveryTime?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'paymentId': paymentId,
      'isPaid': isPaid,
      if (userDetails != null) 'userDetails': userDetails!.toJson(),
      if (driverDetails != null) 'driverDetails': driverDetails!.toJson(),
    };
  }

  // Create order for API request
  Map<String, dynamic> toCreateJson() {
    return {
      'items': items.map((item) => item.toCreateJson()).toList(),
      'totalAmount': totalAmount,
      'deliveryAddress': deliveryAddress,
      'specialInstructions': specialInstructions,
    };
  }

  Order copyWith({
    String? id,
    String? user,
    List<OrderItem>? items,
    double? totalAmount,
    OrderStatus? status,
    String? deliveryAddress,
    String? specialInstructions,
    String? assignedDriver,
    DateTime? estimatedDeliveryTime,
    DateTime? createdAt,
    DateTime? updatedAt,
    String? paymentId,
    bool? isPaid,
    User? userDetails,
    User? driverDetails,
  }) {
    return Order(
      id: id ?? this.id,
      user: user ?? this.user,
      items: items ?? this.items,
      totalAmount: totalAmount ?? this.totalAmount,
      status: status ?? this.status,
      deliveryAddress: deliveryAddress ?? this.deliveryAddress,
      specialInstructions: specialInstructions ?? this.specialInstructions,
      assignedDriver: assignedDriver ?? this.assignedDriver,
      estimatedDeliveryTime:
          estimatedDeliveryTime ?? this.estimatedDeliveryTime,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      paymentId: paymentId ?? this.paymentId,
      isPaid: isPaid ?? this.isPaid,
      userDetails: userDetails ?? this.userDetails,
      driverDetails: driverDetails ?? this.driverDetails,
    );
  }

  @override
  String toString() {
    return 'Order(id: $id, status: $statusDisplay, total: ${totalAmount.toStringAsFixed(2)})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Order && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;

  static OrderStatus _parseOrderStatus(String? status) {
    switch (status?.toLowerCase()) {
      case 'pending':
        return OrderStatus.pending;
      case 'confirmed':
        return OrderStatus.confirmed;
      case 'preparing':
        return OrderStatus.preparing;
      case 'ready':
        return OrderStatus.ready;
      case 'picked_up':
        return OrderStatus.picked_up;
      case 'delivering':
        return OrderStatus.delivering;
      case 'delivered':
        return OrderStatus.delivered;
      case 'cancelled':
        return OrderStatus.cancelled;
      default:
        return OrderStatus.pending;
    }
  }
}

class OrderItem {
  final String foodId;
  final String foodName;
  final int quantity;
  final double unitPrice;
  final String restaurantId;
  final String restaurantName;
  final String? foodImageUrl;
  final List<String>? specialRequests;

  OrderItem({
    required this.foodId,
    required this.foodName,
    required this.quantity,
    required this.unitPrice,
    required this.restaurantId,
    required this.restaurantName,
    this.foodImageUrl,
    this.specialRequests,
  });

  double get totalPrice => unitPrice * quantity;

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      foodId: json['foodId'] ?? '',
      foodName: json['foodName'] ?? '',
      quantity: json['quantity'] ?? 1,
      unitPrice: (json['unitPrice'] ?? 0).toDouble(),
      restaurantId: json['restaurantId'] ?? '',
      restaurantName: json['restaurantName'] ?? '',
      foodImageUrl: json['foodImageUrl'],
      specialRequests: json['specialRequests'] != null
          ? List<String>.from(json['specialRequests'])
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'foodId': foodId,
      'foodName': foodName,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'restaurantId': restaurantId,
      'restaurantName': restaurantName,
      'foodImageUrl': foodImageUrl,
      'specialRequests': specialRequests,
    };
  }

  Map<String, dynamic> toCreateJson() {
    return {
      'foodId': foodId,
      'quantity': quantity,
      'unitPrice': unitPrice,
      'specialRequests': specialRequests,
    };
  }

  // Create from Cart item
  factory OrderItem.fromCart(Cart cartItem) {
    return OrderItem(
      foodId: cartItem.food,
      foodName: cartItem.foodName,
      quantity: cartItem.quantity,
      unitPrice: cartItem.unitPrice ?? cartItem.foodDetails?.price ?? 0.0,
      restaurantId: cartItem.foodDetails?.restaurant ?? '',
      restaurantName: cartItem.restaurantName,
      foodImageUrl: cartItem.foodImageUrl,
    );
  }

  OrderItem copyWith({
    String? foodId,
    String? foodName,
    int? quantity,
    double? unitPrice,
    String? restaurantId,
    String? restaurantName,
    String? foodImageUrl,
    List<String>? specialRequests,
  }) {
    return OrderItem(
      foodId: foodId ?? this.foodId,
      foodName: foodName ?? this.foodName,
      quantity: quantity ?? this.quantity,
      unitPrice: unitPrice ?? this.unitPrice,
      restaurantId: restaurantId ?? this.restaurantId,
      restaurantName: restaurantName ?? this.restaurantName,
      foodImageUrl: foodImageUrl ?? this.foodImageUrl,
      specialRequests: specialRequests ?? this.specialRequests,
    );
  }

  @override
  String toString() {
    return 'OrderItem(food: $foodName, quantity: $quantity, total: ${totalPrice.toStringAsFixed(2)})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is OrderItem && other.foodId == foodId;
  }

  @override
  int get hashCode => foodId.hashCode;
}

// Import User model - you'll need to add this import at the top of the file
// import 'user.dart';
// import 'cart.dart';
