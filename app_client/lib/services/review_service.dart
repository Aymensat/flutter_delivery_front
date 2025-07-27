
// lib/services/review_service.dart

import '../models/feedback.dart';
import 'api_service.dart';

class ReviewService {
  final ApiService _apiService = ApiService();

  Future<List<Feedback>> getReviewsForRestaurant(String restaurantId) async {
    final response = await _apiService.get('/feedback/restaurant/$restaurantId');
    return (response as List).map((json) => Feedback.fromJson(json)).toList();
  }

  Future<Feedback> submitReview(Map<String, dynamic> reviewData) async {
    final response = await _apiService.post('/feedback', reviewData);
    return Feedback.fromJson(response);
  }
}
