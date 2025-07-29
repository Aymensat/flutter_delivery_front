// lib/providers/review_provider.dart

import 'package:flutter/material.dart';
import '../models/feedback.dart' as feedback_model;
import '../services/review_service.dart';

class ReviewProvider with ChangeNotifier {
  final ReviewService _reviewService = ReviewService();
  Map<String, List<feedback_model.Feedback>> _reviews = {};
  bool _isLoading = false;
  String? _errorMessage;

  Map<String, List<feedback_model.Feedback>> get reviews => _reviews;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchReviewsForRestaurant(String restaurantId) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _reviews[restaurantId] = await _reviewService.getReviewsForRestaurant(
        restaurantId,
      );
    } catch (e) {
      _errorMessage = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // TODO: This function needs to be updated to accept an orderId instead of a restaurantId.
  // The backend requires an orderId to create a review.
  // The review submission UI should be moved to the OrderDetailScreen.
  Future<bool> submitReview({
    required String restaurantId,
    required int rating,
    required String comment,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final reviewData = {
        'restaurant': restaurantId,
        'rating': rating,
        'comment': comment,
        'type': 'restaurant',
      };
      final newReview = await _reviewService.submitReview(reviewData);
      _reviews[restaurantId]?.add(newReview);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
  }
}
