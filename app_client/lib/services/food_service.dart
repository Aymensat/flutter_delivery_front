import 'package:flutter/foundation.dart';
import 'api_service.dart';
import '../models/food.dart';

class FoodService {
  final ApiService _apiService = ApiService();

  Future<Food> fetchFoodById(String foodId) async {
    try {
      final response = await _apiService.get('/foods/$foodId');
      return Food.fromJson(response);
    } catch (e) {
      debugPrint('Failed to fetch food $foodId: $e');
      throw Exception('Failed to load food details.');
    }
  }
}
