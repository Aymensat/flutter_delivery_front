// lib/screens/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart'; // Import AuthProvider
import '../../models/cart.dart'; // Ensure this is imported
import 'checkout_screen.dart'; // Import CheckoutScreen

class CartScreen extends StatefulWidget {
  const CartScreen({super.key});

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  // Define the base server URL for images.
  // This should match your backend server's address.
  // For Android Emulator, 'http://10.0.2.2:3000' is typically used.
  // For iOS Simulator/Desktop, 'http://localhost:3000' is common.
  // For a physical device, use your computer's local IP address (e.g., 'http://192.168.1.5:3000').
  static const String baseServerUrl = 'http://10.0.2.2:3000';

  @override
  void initState() {
    super.initState();
    debugPrint('CartScreen: initState called.');
    WidgetsBinding.instance.addPostFrameCallback((_) {
      debugPrint('CartScreen: initState: addPostFrameCallback triggered.');
      // Pass context to loadCart
      Provider.of<CartProvider>(context, listen: false).loadCart(context);
    });
  }

  @override
  Widget build(BuildContext context) {
    debugPrint('CartScreen: build method called.');
    print('CartScreen: baseServerUrl: $baseServerUrl');
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        actions: [
          IconButton(
            icon: const Icon(Icons.home),
            onPressed: () {
              // Navigate back to home screen
              Navigator.of(context).popUntil((route) => route.isFirst);
            },
          ),
          Consumer<CartProvider>(
            builder: (context, cartProvider, child) {
              if (cartProvider.cartItems.isEmpty) return const SizedBox();
              return TextButton(
                onPressed: () => _showClearCartDialog(context),
                child: const Text('Clear All'),
              );
            },
          ),
        ],
      ),
      body: Consumer<CartProvider>(
        builder: (context, cartProvider, child) {
          if (cartProvider.isLoading) {
            debugPrint('CartScreen: Building with loading state.');
            return const Center(child: CircularProgressIndicator());
          }

          if (cartProvider.errorMessage != null) {
            debugPrint(
              'CartScreen: Building with error state: ${cartProvider.errorMessage}',
            );
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${cartProvider.errorMessage}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        cartProvider
                            .clearErrorMessage(); // Use the correct method name
                        cartProvider.loadCart(context); // Pass context
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (cartProvider.cartItems.isEmpty) {
            debugPrint('CartScreen: Building with empty cart state.');
            return const Center(
              child: Text(
                'Your cart is empty. Start adding some delicious food!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }
          debugPrint(
            'CartScreen: Building with cart items: ${cartProvider.cartItems.length}',
          );
          return Column(
            children: [
              Expanded(
                child: ListView.builder(
                  padding: const EdgeInsets.all(16),
                  itemCount: cartProvider.cartItems.length,
                  itemBuilder: (context, index) {
                    final cartItem = cartProvider.cartItems[index];
                    return CartItemCard(
                      cartItem: cartItem,
                      onQuantityChanged: (newQuantity) {
                        Provider.of<CartProvider>(
                          context,
                          listen: false,
                        ).updateCartItem(cartItem.id, newQuantity, cartItem.excludedIngredients);
                      },
                      onRemove: () {
                        Provider.of<CartProvider>(
                          context,
                          listen: false,
                        ).removeFromCart(cartItem.id);
                      },
                      baseServerUrl: baseServerUrl,
                    );
                  },
                ),
              ),
              _buildCartSummary(context, cartProvider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildCartSummary(BuildContext context, CartProvider cartProvider) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            spreadRadius: 1,
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _buildSummaryRow(
            'Subtotal:',
            '\$${cartProvider.totalAmount.toStringAsFixed(2)}',
          ),
          _buildSummaryRow(
            'Delivery Fee:',
            '\$5.00',
          ), // Example fixed delivery fee
          const Divider(),
          _buildSummaryRow(
            'Total:',
            '\$${(cartProvider.totalAmount + 5.00).toStringAsFixed(2)}',
            isTotal: true,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: cartProvider.cartItems.isEmpty
                ? null
                : () {
                    // Navigate to CheckoutScreen
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const CheckoutScreen(),
                      ),
                    );
                  },
            style: ElevatedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text(
              'Proceed to Checkout',
              style: TextStyle(fontSize: 18),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isTotal = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Theme.of(context).primaryColor : Colors.black87,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isTotal ? 18 : 16,
              fontWeight: isTotal ? FontWeight.bold : FontWeight.normal,
              color: isTotal ? Theme.of(context).primaryColor : Colors.black87,
            ),
          ),
        ],
      ),
    );
  }

  void _showClearCartDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Clear Cart?'),
        content: const Text(
          'Are you sure you want to remove all items from your cart?',
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(ctx).pop();
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Provider.of<CartProvider>(context, listen: false).clearCart();
              Navigator.of(ctx).pop();
            },
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }
}

class CartItemCard extends StatelessWidget {
  final Cart cartItem;
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;
  final String baseServerUrl; // New: Pass baseServerUrl to CartItemCard

  const CartItemCard({
    super.key,
    required this.cartItem,
    required this.onQuantityChanged,
    required this.onRemove,
    required this.baseServerUrl, // New: Require baseServerUrl
  });

  @override
  Widget build(BuildContext context) {
    // Construct the full image URL for the cart item's food image.
    final cartImageUrl = cartItem.food.imageUrl;
    String? fullFoodImageUrl;
    if (cartImageUrl != null && cartImageUrl.isNotEmpty) {
      if (cartImageUrl.startsWith('http')) {
        // It's already a full URL
        fullFoodImageUrl = cartImageUrl;
      } else {
        // It's a relative path, so prepend the base server URL
        fullFoodImageUrl = '$baseServerUrl$cartImageUrl';
      }
    } else {
      fullFoodImageUrl = null;
    }
    print('CartItemCard: fullFoodImageUrl: $fullFoodImageUrl');

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            // Food Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: fullFoodImageUrl != null
                  ? Image.network(
                      fullFoodImageUrl,
                      width: 70,
                      height: 70,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        width: 70,
                        height: 70,
                        color: Colors.grey[200],
                        child: Center(
                          child: Icon(
                            Icons.broken_image,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                    )
                  : Container(
                      width: 70,
                      height: 70,
                      color: Colors.grey[200],
                      child: Center(
                        child: Icon(Icons.fastfood, color: Colors.grey[400]),
                      ),
                    ),
            ),
            const SizedBox(width: 12),
            // Item Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    cartItem.food.name, // Access food name directly
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cartItem.food.restaurantDetails?.name ??
                        'Unknown Restaurant', // Access restaurant name
                    style: TextStyle(color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  if (cartItem.excludedIngredients.isNotEmpty)
                    Text(
                      'Excluding: ${cartItem.excludedIngredients.join(', ')}',
                      style: TextStyle(color: Colors.grey[600], fontStyle: FontStyle.italic),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${(cartItem.food.price).toStringAsFixed(2)}', // Access price directly
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: cartItem.quantity > 1
                                ? () => onQuantityChanged(cartItem.quantity - 1)
                                : null,
                            icon: const Icon(Icons.remove),
                            iconSize: 20,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: Theme.of(
                                context,
                              ).primaryColor.withOpacity(0.1),
                              foregroundColor: Theme.of(context).primaryColor,
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            child: Text(
                              '${cartItem.quantity}',
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          IconButton(
                            onPressed: () =>
                                onQuantityChanged(cartItem.quantity + 1),
                            icon: const Icon(Icons.add),
                            iconSize: 20,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            style: IconButton.styleFrom(
                              backgroundColor: Theme.of(context).primaryColor,
                              foregroundColor: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            IconButton(
              onPressed: onRemove,
              icon: const Icon(Icons.delete_outline),
              color: Colors.red,
            ),
          ],
        ),
      ),
    );
  }
}
