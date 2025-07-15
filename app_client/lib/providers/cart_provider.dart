import 'package:flutter/foundation.dart';
import '../models/cart.dart';
import '../models/food.dart';
import '../services/cart_service.dart';

class CartProvider with ChangeNotifier {
  final CartService _cartService = CartService();
  List<Cart> _cartItems = [];
  bool _isLoading = false;
  String? _error;

  List<Cart> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get totalItems => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  double get totalAmount => _cartItems.fold(
    0.0,
    (sum, item) => sum + item.totalPrice, // Use totalPrice from Cart model
  );

  Future<void> loadCart() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _cartItems = await _cartService.getCartItems();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(Food food, {int quantity = 1}) async {
    try {
      // Check if item already exists in cart
      final existingItemIndex = _cartItems.indexWhere(
        (item) => item.food == food.id, // Compare with food ID string
      );

      if (existingItemIndex >= 0) {
        // Update quantity of existing item
        final existingItem = _cartItems[existingItemIndex];
        final newQuantity = existingItem.quantity + quantity;
        await updateCartItem(existingItem.id, newQuantity);
      } else {
        // Add new item to cart
        final cartItem = await _cartService.addToCart(food.id, quantity);
        _cartItems.add(cartItem);
        notifyListeners();
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> updateCartItem(String cartItemId, int quantity) async {
    try {
      if (quantity <= 0) {
        await removeFromCart(cartItemId);
        return;
      }

      final index = _cartItems.indexWhere((item) => item.id == cartItemId);
      if (index >= 0) {
        _cartItems[index] = _cartItems[index].copyWith(quantity: quantity);
        notifyListeners();

        // Update on server
        await _cartService.updateCartItem(cartItemId, quantity);
      }
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    try {
      await _cartService.removeFromCart(cartItemId);
      _cartItems.removeWhere((item) => item.id == cartItemId);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    try {
      for (final item in _cartItems) {
        await _cartService.removeFromCart(item.id);
      }
      _cartItems.clear();
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  Cart? getCartItem(String foodId) {
    try {
      return _cartItems.firstWhere(
        (item) => item.food == foodId,
      ); // Compare with food ID string
    } catch (e) {
      return null;
    }
  }

  int getItemQuantity(String foodId) {
    final item = getCartItem(foodId);
    return item?.quantity ?? 0;
  }

  // Helper method to get cart summary
  CartSummary get cartSummary => CartSummary.fromItems(_cartItems);

  // Helper method to check if cart is empty
  bool get isEmpty => _cartItems.isEmpty;

  // Helper method to check if cart has items from multiple restaurants
  bool get hasMultipleRestaurants => cartSummary.hasMultipleRestaurants;
}
