// lib/providers/cart_provider.dart
import 'package:flutter/foundation.dart';
import '../models/cart.dart'; // Ensure this is imported and correctly defines `Cart`
import '../models/food.dart'; // Ensure this is imported
import '../services/cart_service.dart';
import '../services/auth_service.dart';

class CartProvider with ChangeNotifier {
  final CartService _cartService = CartService();
  final AuthService _authService = AuthService();
  List<Cart> _cartItems = []; // FIX: Changed to List<Cart>
  bool _isLoading = false;
  String? _error;

  List<Cart> get cartItems => _cartItems; // FIX: Changed to List<Cart>
  bool get isLoading => _isLoading;
  String? get error => _error;

  int get totalItems => _cartItems.fold(
    0,
    (sum, item) => sum + item.quantity,
  ); // FIX: quantity on Cart
  double get totalAmount => _cartItems.fold(
    0.0,
    (sum, item) => sum + item.totalPrice, // FIX: totalPrice on Cart
  );

  Future<void> loadCart() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final token = await _authService.getToken();
      if (token == null) {
        _error = 'Authentication token not found. Please log in.';
        _isLoading = false;
        notifyListeners();
        return;
      }
      // FIX: getCartItems now returns List<Cart>
      _cartItems = await _cartService.getCartItems();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(Food food, {int quantity = 1}) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _authService.getToken();
      final userId = await _authService
          .getUserId(); // FIX: Now getUserId exists

      if (token == null || userId == null) {
        _error = 'Authentication token or User ID not found. Please log in.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      // Check if item already exists in cart locally
      final existingItemIndex = _cartItems.indexWhere(
        (item) =>
            item.foodDetails?.id ==
            food.id, // FIX: Compare food.id with item.foodDetails.id
      );

      if (existingItemIndex != -1) {
        // If item exists, update its quantity in the backend and then locally
        final existingCart =
            _cartItems[existingItemIndex]; // FIX: Renamed to existingCart
        final newQuantity = existingCart.quantity + quantity;
        await _cartService.updateCartItemQuantity(
          userId: userId,
          cartItemId: existingCart.id, // FIX: Pass existing Cart's ID
          quantity: newQuantity,
          token: token,
        );
        // FIX: If Cart class has an updateQuantity method, use it. Otherwise, reload or recreate the object.
        // Assuming updateQuantity exists in Cart model for simplicity. If not, recreate Cart object.
        // For now, let's just reload the cart to ensure consistency.
        await loadCart();
      } else {
        // If item does not exist, add it to the backend and then locally
        await _cartService.addItemToCart(
          userId: userId,
          foodId: food.id,
          quantity: quantity,
          token: token,
        );
        // After successfully adding to backend, re-fetch the cart or manually add (manual preferred for responsiveness)
        await loadCart(); // FIX: Reload cart to get the newly added item with its Cart ID
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // FIX: Changed cartItemId parameter to match the Cart object's ID
  Future<void> updateCartItemQuantity(String cartItemId, int quantity) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _authService.getToken();
      final userId = await _authService.getUserId();

      if (token == null || userId == null) {
        _error = 'Authentication token or User ID not found. Please log in.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      if (quantity <= 0) {
        // If quantity is 0 or less, remove the item
        await _cartService.removeCartItem(
          userId: userId,
          cartItemId: cartItemId,
          token: token,
        );
        _cartItems.removeWhere((item) => item.id == cartItemId);
      } else {
        // Otherwise, update the quantity
        await _cartService.updateCartItemQuantity(
          userId: userId,
          cartItemId: cartItemId,
          quantity: quantity,
          token: token,
        );
        // Update local list
        final itemIndex = _cartItems.indexWhere(
          (item) => item.id == cartItemId,
        );
        if (itemIndex != -1) {
          // Assuming Cart class has a copyWith or similar method, or re-fetch.
          // For now, let's assume Cart can be updated directly or reload.
          // To be simple and ensure consistency after backend update:
          await loadCart(); // FIX: Reload cart
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    _isLoading = true;
    notifyListeners();

    try {
      final token = await _authService.getToken();
      final userId = await _authService.getUserId();

      if (token == null || userId == null) {
        _error = 'Authentication token or User ID not found. Please log in.';
        _isLoading = false;
        notifyListeners();
        return;
      }

      await _cartService.removeCartItem(
        userId: userId,
        cartItemId: cartItemId,
        token: token,
      );
      _cartItems.removeWhere((item) => item.id == cartItemId); // FIX: item.id
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    _isLoading = true;
    notifyListeners();
    try {
      final token = await _authService.getToken();
      final userId = await _authService.getUserId();

      if (token == null || userId == null) {
        _error = 'Authentication token or User ID not found. Please log in.';
        _isLoading = false;
        notifyListeners();
        return;
      }
      // FIX: _cartService.clearCart expects userId and token
      await _cartService.clearCart(userId, token);
      _cartItems.clear();
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // FIX: Change return type to Cart?, use item.food (ID string) for comparison
  Cart? getCartItem(String foodId) {
    try {
      return _cartItems.firstWhere(
        (item) => item.food == foodId, // FIX: Compare food ID string
      );
    } catch (e) {
      return null;
    }
  }

  int getItemQuantity(String foodId) {
    final item = getCartItem(foodId);
    return item?.quantity ?? 0;
  }
}
