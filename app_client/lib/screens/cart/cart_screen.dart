// lib/screens/cart_screen.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/cart_provider.dart';
// import '../../providers/auth_provider.dart'; // FIX: Remove unused import
import '../../models/cart.dart'; // Ensure this is imported

class CartScreen extends StatefulWidget {
  const CartScreen({Key? key}) : super(key: key); // FIX: Add key parameter

  @override
  State<CartScreen> createState() => _CartScreenState();
}

class _CartScreenState extends State<CartScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<CartProvider>(context, listen: false).loadCart();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('My Cart'),
        actions: [
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
            return const Center(child: CircularProgressIndicator());
          }

          if (cartProvider.error != null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error: ${cartProvider.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        cartProvider.clearError();
                        cartProvider.loadCart();
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            );
          }

          if (cartProvider.cartItems.isEmpty) {
            return const Center(
              child: Text(
                'Your cart is empty. Start adding some delicious food!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

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
                        ).updateCartItemQuantity(
                          cartItem.id,
                          newQuantity,
                        ); // FIX: Correct method call
                      },
                      onRemove: () {
                        Provider.of<CartProvider>(
                          context,
                          listen: false,
                        ).removeFromCart(cartItem.id);
                      },
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
            color: Colors.black.withOpacity(0.1), // FIX: Use withOpacity
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
                    // Handle checkout logic
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Proceeding to checkout!')),
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

// FIX: Update CartItemCard to CartCard to reflect the model change
class CartItemCard extends StatelessWidget {
  final Cart cartItem; // FIX: Changed type to Cart
  final ValueChanged<int> onQuantityChanged;
  final VoidCallback onRemove;

  const CartItemCard({
    Key? key, // FIX: Add key parameter
    required this.cartItem,
    required this.onQuantityChanged,
    required this.onRemove,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
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
              child: Image.network(
                cartItem.foodDetails?.imageUrl ??
                    'https://via.placeholder.com/70', // FIX: Access imageUrl via foodDetails
                width: 70,
                height: 70,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  width: 70,
                  height: 70,
                  color: Colors.grey[200],
                  child: const Icon(Icons.fastfood, color: Colors.grey),
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
                    cartItem.foodDetails?.name ??
                        'Unknown Food', // FIX: Access name via foodDetails
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    cartItem.foodDetails?.restaurantDetails.name ??
                        'Unknown Restaurant', // FIX: Access restaurantDetails via foodDetails
                    style: TextStyle(color: Colors.grey[600]),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '\$${(cartItem.foodDetails?.price ?? 0.0).toStringAsFixed(2)}', // FIX: Access price via foodDetails
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
                              backgroundColor: Theme.of(context).primaryColor
                                  .withOpacity(0.1), // FIX: Use withOpacity
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
