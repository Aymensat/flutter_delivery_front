class Feedback {
  final String id;
  final String orderId;
  final String userId;
  final String? deliveryId;
  final String? restaurantId;
  final int rating;
  final String comment;
  final FeedbackType type;
  final DateTime createdAt;
  final DateTime updatedAt;

  Feedback({
    required this.id,
    required this.orderId,
    required this.userId,
    this.deliveryId,
    this.restaurantId,
    required this.rating,
    required this.comment,
    required this.type,
    required this.createdAt,
    required this.updatedAt,
  });

  // Factory constructor from JSON
  factory Feedback.fromJson(Map<String, dynamic> json) {
    return Feedback(
      id: json['_id'] ?? '',
      orderId: json['order'] ?? '',
      userId: json['user'] ?? '',
      deliveryId: json['delivery'],
      restaurantId: json['restaurant'],
      rating: json['rating'] ?? 0,
      comment: json['comment'] ?? '',
      type: FeedbackType.values.firstWhere(
        (e) => e.name == json['type'],
        orElse: () => FeedbackType.restaurant,
      ),
      createdAt: DateTime.parse(
        json['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
      updatedAt: DateTime.parse(
        json['updatedAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'order': orderId,
      'user': userId,
      if (deliveryId != null) 'delivery': deliveryId,
      if (restaurantId != null) 'restaurant': restaurantId,
      'rating': rating,
      'comment': comment,
      'type': type.name,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
    };
  }

  // Create a copy with updated values
  Feedback copyWith({
    String? id,
    String? orderId,
    String? userId,
    String? deliveryId,
    String? restaurantId,
    int? rating,
    String? comment,
    FeedbackType? type,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return Feedback(
      id: id ?? this.id,
      orderId: orderId ?? this.orderId,
      userId: userId ?? this.userId,
      deliveryId: deliveryId ?? this.deliveryId,
      restaurantId: restaurantId ?? this.restaurantId,
      rating: rating ?? this.rating,
      comment: comment ?? this.comment,
      type: type ?? this.type,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  // Check if feedback is positive (4-5 stars)
  bool get isPositive => rating >= 4;

  // Check if feedback is negative (1-2 stars)
  bool get isNegative => rating <= 2;

  // Check if feedback is neutral (3 stars)
  bool get isNeutral => rating == 3;

  // Get rating as percentage
  double get ratingPercentage => (rating / 5.0) * 100;

  // Get formatted time ago
  String get timeAgo {
    final now = DateTime.now();
    final difference = now.difference(createdAt);

    if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  // Get star display string
  String get starDisplay {
    return '★' * rating + '☆' * (5 - rating);
  }

  @override
  String toString() {
    return 'Feedback(id: $id, type: $type, rating: $rating, comment: ${comment.length > 50 ? '${comment.substring(0, 50)}...' : comment})';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Feedback && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

enum FeedbackType { restaurant, delivery, food }

// Extension for FeedbackType
extension FeedbackTypeExtension on FeedbackType {
  String get displayName {
    switch (this) {
      case FeedbackType.restaurant:
        return 'Restaurant';
      case FeedbackType.delivery:
        return 'Delivery';
      case FeedbackType.food:
        return 'Food';
    }
  }

  String get description {
    switch (this) {
      case FeedbackType.restaurant:
        return 'Rate the restaurant service and quality';
      case FeedbackType.delivery:
        return 'Rate the delivery service and speed';
      case FeedbackType.food:
        return 'Rate the food quality and taste';
    }
  }

  String get icon {
    switch (this) {
      case FeedbackType.restaurant:
        return '🏪';
      case FeedbackType.delivery:
        return '🚚';
      case FeedbackType.food:
        return '🍕';
    }
  }
}

// Helper class for feedback statistics
class FeedbackStats {
  final double averageRating;
  final int totalReviews;
  final Map<int, int> ratingDistribution;

  FeedbackStats({
    required this.averageRating,
    required this.totalReviews,
    required this.ratingDistribution,
  });

  factory FeedbackStats.fromFeedbackList(List<Feedback> feedbacks) {
    if (feedbacks.isEmpty) {
      return FeedbackStats(
        averageRating: 0.0,
        totalReviews: 0,
        ratingDistribution: {},
      );
    }

    final distribution = <int, int>{};
    int totalRating = 0;

    for (final feedback in feedbacks) {
      totalRating += feedback.rating;
      distribution[feedback.rating] = (distribution[feedback.rating] ?? 0) + 1;
    }

    return FeedbackStats(
      averageRating: totalRating / feedbacks.length,
      totalReviews: feedbacks.length,
      ratingDistribution: distribution,
    );
  }

  // Get percentage for specific rating
  double getPercentageForRating(int rating) {
    if (totalReviews == 0) return 0.0;
    final count = ratingDistribution[rating] ?? 0;
    return (count / totalReviews) * 100;
  }

  // Get formatted average rating
  String get formattedAverageRating {
    return averageRating.toStringAsFixed(1);
  }

  // Get star display for average rating
  String get averageStarDisplay {
    final fullStars = averageRating.floor();
    final hasHalfStar = (averageRating - fullStars) >= 0.5;
    final emptyStars = 5 - fullStars - (hasHalfStar ? 1 : 0);

    return '★' * fullStars + (hasHalfStar ? '☆' : '') + '☆' * emptyStars;
  }
}
