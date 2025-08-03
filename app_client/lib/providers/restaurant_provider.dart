import 'package:flutter/material.dart'; // Import for WidgetsBinding
import '../models/restaurant.dart';
import '../models/food.dart';
import '../services/api_service.dart';

class RestaurantProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Restaurant> _restaurants = [];
  List<Restaurant> _filteredRestaurants = [];
  List<Food> _allFoods = []; // To store all food items for searching
  List<Food> _restaurantSpecificFoods =
      []; // Holds foods for a single restaurant detail view
  Restaurant? _selectedRestaurant;
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  // Getters
  List<Restaurant> get restaurants => _restaurants;
  List<Restaurant> get filteredRestaurants => _filteredRestaurants;
  List<Food> get foods => _restaurantSpecificFoods;
  Restaurant? get selectedRestaurant => _selectedRestaurant;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  void setSearchQuery(String query) {
    _searchQuery = query;
    _applyFilters();
    // No need to call notifyListeners() here as _applyFilters does it.
  }

  Future<void> loadRestaurants({double? lat, double? lon}) async {
    _isLoading = true;
    _error = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (hasListeners) {
        notifyListeners();
      }
    });

    try {
      final results = await Future.wait([
        _apiService.getRestaurants(lat: lat, lon: lon).catchError((e, s) {
          _error = 'Could not load restaurants. Please try again later.';
          return <Restaurant>[];
        }),
        _apiService.getFoods().catchError((e, s) {
          debugPrint('--- WARNING: Failed to fetch food data for search ---');
          debugPrint(
            'The app will function, but food search will be disabled due to this error.',
          );
          debugPrint(e.toString());
          debugPrint(s.toString());
          debugPrint('-------------------------------------------------------');
          return <Food>[];
        }),
      ]);

      _restaurants = results[0] as List<Restaurant>;
      _allFoods = results[1] as List<Food>;
    } catch (e, s) {
      _error = "An unexpected error occurred while loading data.";
      debugPrint('--- UNEXPECTED FALLBACK ERROR in loadRestaurants ---');
      debugPrint(e.toString());
      debugPrint(s.toString());
      debugPrint('----------------------------------------------------');
      _restaurants = [];
      _allFoods = [];
    } finally {
      _filteredRestaurants = _restaurants;
      _applyFilters();
      _isLoading = false;
      if (hasListeners) {
        notifyListeners();
      }
    }
  }

  // FIX: Wrapped initial notifyListeners in addPostFrameCallback to prevent build errors.
  Future<List<Food>> fetchFoodsForRestaurant(String restaurantId) async {
    _isLoading = true;
    _error = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (hasListeners) notifyListeners();
    });

    try {
      _restaurantSpecificFoods = await _apiService.getFoodsByRestaurantId(
        restaurantId,
      );
      return _restaurantSpecificFoods;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      if (hasListeners) notifyListeners();
    }
  }

  // FIX: Wrapped initial notifyListeners in addPostFrameCallback to prevent build errors.
  Future<void> loadRestaurantById(String id) async {
    _isLoading = true;
    _error = null;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (hasListeners) notifyListeners();
    });

    try {
      _selectedRestaurant = await _apiService.getRestaurantById(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      if (hasListeners) notifyListeners();
    }
  }

  void searchRestaurants(String query) {
    _searchQuery = query;
    _applyFilters();
  }

  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
  }

  void _applyFilters() {
    List<Restaurant> tempRestaurants = _restaurants;

    if (_selectedCategory != 'All') {
      tempRestaurants = tempRestaurants.where((restaurant) {
        return restaurant.cuisine.toLowerCase() ==
            _selectedCategory.toLowerCase();
      }).toList();
    }

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      tempRestaurants = tempRestaurants.where((restaurant) {
        try {
          final bool matchesRestaurantInfo =
              restaurant.name.toLowerCase().contains(query) ||
              restaurant.cuisine.toLowerCase().contains(query);

          // This will only work if the _allFoods list was successfully loaded.
          final bool matchesFood = _allFoods.any(
            (food) =>
                food.restaurant == restaurant.id &&
                food.name.toLowerCase().contains(query),
          );

          return matchesRestaurantInfo || matchesFood;
        } catch (e, s) {
          debugPrint('--- FILTERING ERROR ---');
          debugPrint(
            'Error processing restaurant "${restaurant.name}" (ID: ${restaurant.id}): $e',
          );
          debugPrint('Stack trace: $s');
          debugPrint('-----------------------');
          return false;
        }
      }).toList();
    }

    _filteredRestaurants = tempRestaurants;
    // Notify listeners after filters are applied.
    if (hasListeners) notifyListeners();
  }

  List<String> getCategories() {
    Set<String> categories = {'All'};
    for (var restaurant in _restaurants) {
      categories.add(restaurant.cuisine);
    }
    return categories.toList();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = 'All';
    _applyFilters();
  }

  void clearError() {
    _error = null;
    if (hasListeners) notifyListeners();
  }

  Future<void> refresh({double? lat, double? lon}) async {
    await loadRestaurants(lat: lat, lon: lon);
  }
}
