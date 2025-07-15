import 'package:flutter/foundation.dart';
import '../models/restaurant.dart';
import '../models/food.dart';
import '../services/api_service.dart';

class RestaurantProvider with ChangeNotifier {
  final ApiService _apiService = ApiService();

  List<Restaurant> _restaurants = [];
  List<Restaurant> _filteredRestaurants = [];
  List<Food> _foods = [];
  Restaurant? _selectedRestaurant;
  bool _isLoading = false;
  String? _error;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  // Getters
  List<Restaurant> get restaurants => _restaurants;
  List<Restaurant> get filteredRestaurants => _filteredRestaurants;
  List<Food> get foods => _foods;
  Restaurant? get selectedRestaurant => _selectedRestaurant;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  // Load restaurants
  Future<void> loadRestaurants({double? lat, double? lon}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _restaurants = await _apiService.getRestaurants(lat: lat, lon: lon);
      _filteredRestaurants = _restaurants;
      _applyFilters();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load restaurant by ID
  Future<void> loadRestaurantById(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _selectedRestaurant = await _apiService.getRestaurantById(id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Load foods
  Future<void> loadFoods() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _foods = await _apiService.getFoods();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Search restaurants
  void searchRestaurants(String query) {
    _searchQuery = query;
    _applyFilters();
    notifyListeners();
  }

  // Filter by category
  void filterByCategory(String category) {
    _selectedCategory = category;
    _applyFilters();
    notifyListeners();
  }

  // Apply filters
  void _applyFilters() {
    _filteredRestaurants = _restaurants.where((restaurant) {
      // Search filter
      bool matchesSearch =
          _searchQuery.isEmpty ||
          restaurant.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          restaurant.cuisine.toLowerCase().contains(_searchQuery.toLowerCase());

      // Category filter
      bool matchesCategory =
          _selectedCategory == 'All' ||
          restaurant.cuisine.toLowerCase() == _selectedCategory.toLowerCase();

      return matchesSearch && matchesCategory;
    }).toList();
  }

  // Get restaurant categories
  List<String> getCategories() {
    Set<String> categories = {'All'};
    for (var restaurant in _restaurants) {
      categories.add(restaurant.cuisine);
    }
    return categories.toList();
  }

  // Clear filters
  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = 'All';
    _filteredRestaurants = _restaurants;
    notifyListeners();
  }

  // Clear error
  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Refresh data
  Future<void> refresh({double? lat, double? lon}) async {
    await loadRestaurants(lat: lat, lon: lon);
  }
}
