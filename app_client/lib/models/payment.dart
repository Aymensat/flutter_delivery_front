class Payment {
  final String id;
  final String userId;
  final String orderId;
  final String cardName;
  final String cardNumber;
  final String expiry;
  final String cvc;
  final double amount;
  final PaymentStatus status;
  final bool saveCard;
  final bool isDefault;
  final DateTime createdAt;
  final String? maskedCardNumber;

  Payment({
    required this.id,
    required this.userId,
    required this.orderId,
    required this.cardName,
    required this.cardNumber,
    required this.expiry,
    required this.cvc,
    required this.amount,
    required this.status,
    this.saveCard = false,
    this.isDefault = false,
    required this.createdAt,
    this.maskedCardNumber,
  });

  // Factory constructor from JSON
  factory Payment.fromJson(Map<String, dynamic> json) {
    return Payment(
      id: json['_id'] ?? '',
      userId: json['user'] ?? '',
      orderId: json['order'] ?? '',
      cardName: json['cardName'] ?? '',
      cardNumber: json['cardNumber'] ?? '',
      expiry: json['expiry'] ?? '',
      cvc: json['cvc'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      status: PaymentStatus.values.firstWhere(
        (e) => e.name == json['status'],
        orElse: () => PaymentStatus.pending,
      ),
      saveCard: json['saveCard'] ?? false,
      isDefault: json['isDefault'] ?? false,
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      maskedCardNumber: json['maskedCardNumber'],
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'user': userId,
      'order': orderId,
      'cardName': cardName,
      'cardNumber': cardNumber,
      'expiry': expiry,
      'cvc': cvc,
      'amount': amount,
      'status': status.name,
      'saveCard': saveCard,
      'isDefault': isDefault,
      'createdAt': createdAt.toIso8601String(),
      if (maskedCardNumber != null) 'maskedCardNumber': maskedCardNumber,
    };
  }

  // Create a copy with updated values
  Payment copyWith({
    String? id,
    String? userId,
    String? orderId,
    String? cardName,
    String? cardNumber,
    String? expiry,
    String? cvc,
    double? amount,
    PaymentStatus? status,
    bool? saveCard,
    bool? isDefault,
    DateTime? createdAt,
    String? maskedCardNumber,
  }) {
    return Payment(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      orderId: orderId ?? this.orderId,
      cardName: cardName ?? this.cardName,
      cardNumber: cardNumber ?? this.cardNumber,
      expiry: expiry ?? this.expiry,
      cvc: cvc ?? this.cvc,
      amount: amount ?? this.amount,
      status: status ?? this.status,
      saveCard: saveCard ?? this.saveCard,
      isDefault: isDefault ?? this.isDefault,
      createdAt: createdAt ?? this.createdAt,
      maskedCardNumber: maskedCardNumber ?? this.maskedCardNumber,
    );
  }

  // Get masked card number for display
  String get displayCardNumber {
    if (maskedCardNumber != null) {
      return maskedCardNumber!;
    }
    if (cardNumber.length >= 4) {
      return '**** **** **** ${cardNumber.substring(cardNumber.length - 4)}';
    }
    return cardNumber;
  }

  // Check if card is expired
  bool get isExpired {
    try {
      final parts = expiry.split('/');
      if (parts.length != 2) return false;

      final month = int.parse(parts[0]);
      final year = int.parse('20${parts[1]}');
      final expiryDate = DateTime(
        year,
        month + 1,
        0,
      ); // Last day of expiry month

      return DateTime.now().isAfter(expiryDate);
    } catch (e) {
      return false;
    }
  }

  // Get card type from card number
  String get cardType {
    if (cardNumber.isEmpty) return 'Unknown';

    // Remove spaces and non-digits
    final cleanNumber = cardNumber.replaceAll(RegExp(r'\D'), '');

    if (cleanNumber.startsWith('4')) {
      return 'Visa';
    } else if (cleanNumber.startsWith('5') || cleanNumber.startsWith('2')) {
      return 'Mastercard';
    } else if (cleanNumber.startsWith('3')) {
      return 'American Express';
    } else if (cleanNumber.startsWith('6')) {
      return 'Discover';
    }

    return 'Unknown';
  }

  @override
  String toString() {
    return 'Payment(id: $id, amount: $amount, status: $status, cardType: $cardType)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Payment && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

enum PaymentStatus { pending, paid, failed }

// Extension for PaymentStatus
extension PaymentStatusExtension on PaymentStatus {
  String get displayName {
    switch (this) {
      case PaymentStatus.pending:
        return 'Pending';
      case PaymentStatus.paid:
        return 'Paid';
      case PaymentStatus.failed:
        return 'Failed';
    }
  }

  bool get isCompleted => this == PaymentStatus.paid;
  bool get isFailed => this == PaymentStatus.failed;
  bool get isPending => this == PaymentStatus.pending;
}
