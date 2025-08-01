// lib/providers/cart_provider.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Import Provider
import '../models/cart.dart';
import '../services/cart_service.dart';
import '../providers/auth_provider.dart'; // Import AuthProvider
import '../models/food.dart'; // NEW: Import Food model to access Food and RestaurantDetails classes
import '../models/user_public_profile.dart'; // NEW: Import UserPublicProfile for Cart constructor

class CartProvider with ChangeNotifier {
  final CartService _cartService = CartService();

  List<Cart> _cartItems = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<Cart> get cartItems => _cartItems;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  double get totalAmount {
    return _cartItems.fold(0.0, (sum, item) => sum + item.totalPrice);
  }

  int get totalItems => _cartItems.fold(0, (sum, item) => sum + item.quantity);

  CartProvider() {
    debugPrint('CartProvider instantiated.');
  }

  // Modified: Pass BuildContext to loadCart to access AuthProvider
  Future<void> loadCart(BuildContext context) async {
    debugPrint('CartProvider: loadCart called.');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      // Ensure user is authenticated before loading cart
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      debugPrint(
        'CartProvider: loadCart: authProvider.isAuthenticated: ${authProvider.isAuthenticated}',
      );
      debugPrint(
        'CartProvider: loadCart: authProvider.user?.id: ${authProvider.user?.id}',
      );

      if (!authProvider.isAuthenticated || authProvider.user?.id == null) {
        _errorMessage =
            'User not authenticated. Please log in to view your cart.';
        _cartItems = []; // Clear cart if not authenticated
        debugPrint(
          'CartProvider: loadCart: User not authenticated, clearing cart and returning.',
        );
        return;
      }
      _cartItems = await _cartService.fetchCart();
      debugPrint(
        'CartProvider: loadCart: Cart fetched successfully. Items: ${_cartItems.length}',
      );
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint('CartProvider: loadCart: Error fetching cart: $_errorMessage');
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('CartProvider: loadCart: Finished loading.');
    }
  }

  // Modified: Pass BuildContext to get user ID
  Future<void> addToCart(String foodId, BuildContext context, {List<String> excludedIngredients = const []}) async {
    debugPrint('CartProvider: addToCart called for foodId: $foodId');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final UserPublicProfile? currentUser = authProvider.user;

      debugPrint('CartProvider: addToCart: currentUser: $currentUser');
      debugPrint('CartProvider: addToCart: currentUser.id: ${currentUser?.id}');

      if (currentUser == null || currentUser.id.isEmpty) {
        throw Exception('User ID not available. Please log in.');
      }

      // Find existing item or create a placeholder for a new one
      final existingCartItemIndex = _cartItems.indexWhere(
        (item) => item.food.id == foodId,
      );

      Cart updatedItem;
      if (existingCartItemIndex != -1) {
        debugPrint(
          'CartProvider: addToCart: Item already in cart, updating quantity.',
        );
        // Item exists, update quantity
        final existingCartItem = _cartItems[existingCartItemIndex];
        updatedItem = await _cartService.updateCartItem(
          existingCartItem.id,
          existingCartItem.quantity + 1,
          existingCartItem.excludedIngredients,
        );
        _cartItems[existingCartItemIndex] = updatedItem;
      } else {
        debugPrint(
          'CartProvider: addToCart: Item not in cart, adding new item.',
        );
        
        updatedItem = await _cartService.addItemToCart(
          foodId: foodId,
          quantity: 1,
          userId: currentUser.id, // Pass userId string
          excludedIngredients: excludedIngredients,
        );
        _cartItems.add(updatedItem);
      }
      debugPrint('CartProvider: addToCart: Item added/updated successfully.');
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint(
        'CartProvider: addToCart: Error adding to cart: $_errorMessage',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('CartProvider: addToCart: Finished processing.');
    }
  }

  Future<void> updateCartItem(String cartItemId, int quantity, List<String> excludedIngredients) async {
    debugPrint(
      'CartProvider: updateCartItem called for $cartItemId to $quantity',
    );
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (quantity <= 0) {
        debugPrint(
          'CartProvider: updateCartItem: Quantity is 0 or less, removing item.',
        );
        await removeFromCart(cartItemId);
        return;
      }
      final updatedItem = await _cartService.updateCartItem(
        cartItemId,
        quantity,
        excludedIngredients,
      );
      int index = _cartItems.indexWhere((item) => item.id == cartItemId);
      if (index != -1) {
        _cartItems[index] = updatedItem;
        debugPrint(
          'CartProvider: updateCartItem: Item updated in list.',
        );
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint(
        'CartProvider: updateCartItem: Error updating quantity: $_errorMessage',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('CartProvider: updateCartItem: Finished processing.');
    }
  }

  Future<void> removeFromCart(String cartItemId) async {
    debugPrint('CartProvider: removeFromCart called for $cartItemId');
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _cartService.removeCartItem(cartItemId);
      _cartItems.removeWhere((item) => item.id == cartItemId);
      debugPrint('CartProvider: removeFromCart: Item removed from list.');
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint(
        'CartProvider: removeFromCart: Error removing item: $_errorMessage',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('CartProvider: removeFromCart: Finished processing.');
    }
  }

  Future<void> clearCart() async {
    debugPrint('CartProvider: clearCart called.');
    _isLoading = true;
    notifyListeners();
    try {
      await _cartService.clearCart();
      _cartItems.clear();
      debugPrint('CartProvider: clearCart: Cart cleared from list.');
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint(
        'CartProvider: clearCart: Error clearing cart: $_errorMessage',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('CartProvider: clearCart: Finished processing.');
    }
  }

  // Helper to get a cart item by food ID
  Cart? getCartItem(String foodId) {
    try {
      return _cartItems.firstWhere((item) => item.food.id == foodId);
    } catch (e) {
      return null;
    }
  }

  void clearErrorMessage() {
    _errorMessage = null;
    notifyListeners();
    debugPrint('CartProvider: Error message cleared.');
  }
}
