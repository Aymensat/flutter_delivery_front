import 'package:app_client/services/location_service.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order.dart';
import '../orders/orders_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final LocationService _locationService = LocationService();
  Position? _currentPosition;
  String? _currentAddress;

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  void _getCurrentLocation() async {
    try {
      final position = await _locationService.getCurrentPosition();
      // TODO: Implement reverse geocoding to get the address from the position
      setState(() {
        _currentPosition = position;
        _currentAddress = '${position.latitude}, ${position.longitude}';
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error getting location: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cartProvider = Provider.of<CartProvider>(context);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(title: const Text('Checkout')),
      body: cartProvider.isLoading
          ? const Center(child: CircularProgressIndicator())
          : cartProvider.errorMessage != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Error loading cart for checkout: ${cartProvider.errorMessage}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.red, fontSize: 16),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        cartProvider.clearErrorMessage();
                        cartProvider.loadCart(context); // Reload cart
                      },
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              ),
            )
          : Column(
              children: [
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Order Summary',
                          style: Theme.of(context).textTheme.headlineSmall
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 16),
                        // List of items in the cart
                        ListView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: cartProvider.cartItems.length,
                          itemBuilder: (context, index) {
                            final item = cartProvider.cartItems[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                vertical: 4.0,
                              ),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Text(
                                      '${item.quantity} x ${item.food.name}',
                                      style: const TextStyle(fontSize: 16),
                                    ),
                                  ),
                                  Text(
                                    '\$${(item.quantity * item.food.price).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                        const Divider(height: 32),
                        _buildSummaryRow(
                          context, // Pass context here
                          'Subtotal:',
                          '\$${cartProvider.totalAmount.toStringAsFixed(2)}',
                        ),
                        _buildSummaryRow(
                          context, // Pass context here
                          'Delivery Fee:',
                          '\$5.00', // Example fixed delivery fee
                        ),
                        const Divider(),
                        _buildSummaryRow(
                          context, // Pass context here
                          'Total:',
                          '\$${(cartProvider.totalAmount + 5.00).toStringAsFixed(2)}',
                          isTotal: true,
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Delivery Address',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        // Placeholder for delivery address
                        Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _currentAddress ?? 'Loading address...',
                                  style: const TextStyle(fontSize: 16),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Text(
                          'Payment Method',
                          style: Theme.of(context).textTheme.titleLarge
                              ?.copyWith(fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 8),
                        // Placeholder for payment method
                        Card(
                          elevation: 1,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Row(
                              children: [
                                const Icon(Icons.money, size: 30),
                                const SizedBox(width: 12),
                                Text(
                                  'Cash on Delivery',
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Place Order Button (fixed at the bottom)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Theme.of(context).cardColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha((255 * 0.1).round()),
                        spreadRadius: 1,
                        blurRadius: 10,
                        offset: const Offset(0, -2),
                      ),
                    ],
                    borderRadius: const BorderRadius.vertical(
                      top: Radius.circular(16),
                    ),
                  ),
                  child: ElevatedButton(
                    onPressed:
                        cartProvider.cartItems.isEmpty ||
                            _currentPosition == null
                        ? null
                        : () async {
                            final authProvider = Provider.of<AuthProvider>(
                              context,
                              listen: false,
                            );
                            final user = authProvider.user;

                            if (user == null) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'You must be logged in to place an order.',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }

                            final orderItems = cartProvider.cartItems.map((
                              cartItem,
                            ) {
                              return OrderItem(
                                food: cartItem.food.id,
                                quantity: cartItem.quantity,
                                excludedIngredients:
                                    cartItem.excludedIngredients,
                              );
                            }).toList();

                            final order = Order(
                              id: '', // The backend will generate the ID
                              user: user.id,
                              restaurant:
                                  cartProvider.cartItems.first.food.restaurant,
                              items: orderItems,
                              totalPrice:
                                  cartProvider.totalAmount +
                                  5.00, // Total with delivery fee
                              subtotal: cartProvider.totalAmount,
                              deliveryFee: 5.00,
                              status: 'pending',
                              paymentStatus: 'pending',
                              serviceMethod: 'delivery',
                              paymentMethod: PaymentMethod.creditCard,
                              reference: DateTime.now()
                                  .millisecondsSinceEpoch, // A unique reference
                              phone: user.phone,
                              latitude: _currentPosition!.latitude,
                              longitude: _currentPosition!.longitude,
                              cookingTime:
                                  30, // Placeholder cooking time in minutes
                              createdAt: DateTime.now(),
                            );

                            final success = await orderProvider.placeOrder(
                              order,
                            );

                            if (success) {
                              cartProvider.clearCart();
                              Navigator.of(context).pushAndRemoveUntil(
                                MaterialPageRoute(
                                  builder: (context) => const OrdersScreen(),
                                ),
                                (route) => route.isFirst,
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    orderProvider.errorMessage ??
                                        'Failed to place order.',
                                  ),
                                  backgroundColor: Colors.red,
                                ),
                              );
                            }
                          },
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      minimumSize: const Size(
                        double.infinity,
                        50,
                      ), // Make button full width
                    ),
                    child: const Text(
                      'Place Order',
                      style: TextStyle(fontSize: 18),
                    ),
                  ),
                ),
              ],
            ),
    );
  }

  Widget _buildSummaryRow(
    BuildContext context,
    String label,
    String value, {
    bool isTotal = false,
  }) {
    // Add BuildContext parameter
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
}
