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
  Future<void> addToCart(String foodId, BuildContext context) async {
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
        updatedItem = await _cartService.updateCartItemQuantity(
          existingCartItem.id,
          existingCartItem.quantity + 1,
        );
        _cartItems[existingCartItemIndex] = updatedItem;
      } else {
        debugPrint(
          'CartProvider: addToCart: Item not in cart, adding new item.',
        );
        // Item does not exist, add new
        // Create a minimal Food object for the Cart constructor's placeholder
        // This Food object will be replaced by the fully populated one from the backend response.
        // The minimalFood object is not actually used in the addItemToCart call,
        // it was part of a previous approach for the orElse clause.
        // It's safe to remove this minimalFood creation if it's not used elsewhere.
        // For clarity, I'm keeping it commented out but it's not strictly necessary for the current logic.
        /*
        final Food minimalFood = Food(
          id: foodId,
          name: '', // Placeholder
          description: '', // Placeholder
          category: '', // Placeholder
          ingredients: [], // Placeholder
          price: 0.0, // Placeholder
          restaurant: '', // Placeholder
          restaurantDetails:
              RestaurantDetails(name: '', address: '', contact: ''), // Placeholder
          ratings: [], // Placeholder
          createdAt: DateTime.now(), // Placeholder
          updatedAt: DateTime.now(), // Placeholder
        );
        */

        updatedItem = await _cartService.addItemToCart(
          foodId: foodId,
          quantity: 1,
          userId: currentUser.id, // Pass userId string
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

  Future<void> updateCartItemQuantity(String cartItemId, int quantity) async {
    debugPrint(
      'CartProvider: updateCartItemQuantity called for $cartItemId to $quantity',
    );
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      if (quantity <= 0) {
        debugPrint(
          'CartProvider: updateCartItemQuantity: Quantity is 0 or less, removing item.',
        );
        await removeFromCart(cartItemId);
        return;
      }
      final updatedItem = await _cartService.updateCartItemQuantity(
        cartItemId,
        quantity,
      );
      int index = _cartItems.indexWhere((item) => item.id == cartItemId);
      if (index != -1) {
        _cartItems[index] = updatedItem;
        debugPrint(
          'CartProvider: updateCartItemQuantity: Item updated in list.',
        );
      }
    } catch (e) {
      _errorMessage = e.toString();
      debugPrint(
        'CartProvider: updateCartItemQuantity: Error updating quantity: $_errorMessage',
      );
    } finally {
      _isLoading = false;
      notifyListeners();
      debugPrint('CartProvider: updateCartItemQuantity: Finished processing.');
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
