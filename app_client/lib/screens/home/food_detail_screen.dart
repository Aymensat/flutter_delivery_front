import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/food.dart'; // Make sure this path is correct for your Food model
import '../../providers/cart_provider.dart'; // Import CartProvider
import '../../providers/auth_provider.dart'; // Import AuthProvider
import '../cart/cart_screen.dart'; // Import CartScreen

class FoodDetailScreen extends StatefulWidget {
  final Food food;

  const FoodDetailScreen({super.key, required this.food});

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  List<String> _excludedIngredients = [];

  @override
  Widget build(BuildContext context) {
    debugPrint('FoodDetailScreen: Building for food: ${widget.food.name}');
    // Define the base server URL for images.
    // This should match your backend server's address.
    // For Android Emulator, 'http://10.0.2.2:3000' is typically used.
    // For iOS Simulator/Desktop, 'http://localhost:3000' is common.
    // For a physical device, use your computer's local IP address (e.g., 'http://192.168.1.5:3000').
    const String baseServerUrl = 'http://10.0.2.2:3000';

    // Construct the full image URL.
    // Check if widget.food.imageUrl is not null and not empty before constructing.
    // MODIFIED: Check if imageUrl is already a full URL before prepending baseServerUrl.
    final String? fullImageUrl =
        (widget.food.imageUrl != null && widget.food.imageUrl!.isNotEmpty)
        ? (widget.food.imageUrl!.startsWith('http://') ||
                  widget.food.imageUrl!.startsWith('https://'))
              ? widget.food.imageUrl! // It's already a full URL, use as is
              : '$baseServerUrl${widget.food.imageUrl!}' // It's a relative path, prepend base URL
        : null;

    return Scaffold(
      appBar: AppBar(title: Text(widget.food.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Food Image
            if (fullImageUrl != null)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.network(
                    fullImageUrl,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      height: 250,
                      width: double.infinity,
                      color: Colors.grey[300],
                      child: Icon(
                        Icons.broken_image,
                        size: 50,
                        color: Colors.grey[600],
                      ),
                      alignment: Alignment.center,
                    ),
                  ),
                ),
              )
            else
              Center(
                child: Container(
                  height: 250,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: Icon(
                    Icons.image_not_supported,
                    size: 50,
                    color: Colors.grey[600],
                  ),
                  alignment: Alignment.center,
                ),
              ),
            const SizedBox(height: 16),
            // Food Name and Price
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.food.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${widget.food.price.toStringAsFixed(2)} TND', // Display price in TND
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).primaryColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            // Food Category
            Text(
              widget.food.category,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            // Food Description
            Text(
              widget.food.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            // Calories (if available)
            if (widget.food.calories != null && widget.food.calories! > 0)
              Padding(
                padding: const EdgeInsets.only(bottom: 8.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      color: Colors.orange[700],
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${widget.food.calories!.toStringAsFixed(0)} kcal',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            // Ingredients
            Text(
              'Exclude Ingredients:',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: widget.food.ingredients.length,
              itemBuilder: (context, index) {
                final ingredient = widget.food.ingredients[index];
                return CheckboxListTile(
                  title: Text(ingredient),
                  value: _excludedIngredients.contains(ingredient),
                  onChanged: (bool? value) {
                    setState(() {
                      if (value == true) {
                        _excludedIngredients.add(ingredient);
                      } else {
                        _excludedIngredients.remove(ingredient);
                      }
                    });
                  },
                );
              },
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.center,
              child: Consumer2<CartProvider, AuthProvider>(
                builder: (context, cartProvider, authProvider, child) {
                  // Check if the item is already in the cart to show current quantity
                  final existingCartItem = cartProvider.getCartItem(widget.food.id);
                  final int currentQuantity = existingCartItem?.quantity ?? 0;

                  // Disable button if not authenticated or loading
                  final bool isDisabled =
                      !authProvider.isAuthenticated || cartProvider.isLoading;

                  debugPrint(
                    'FoodDetailScreen: Add to Cart button state - isAuthenticated: ${authProvider.isAuthenticated}, userId: ${authProvider.user?.id}, isLoading: ${cartProvider.isLoading}',
                  );

                  return ElevatedButton.icon(
                    onPressed: isDisabled
                        ? null
                        : () async {
                            debugPrint(
                              'FoodDetailScreen: Add to Cart button pressed.',
                            );
                            if (authProvider.user?.id == null) {
                              debugPrint(
                                'FoodDetailScreen: User ID is null, showing login snackbar.',
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please log in to add items to your cart.',
                                  ),
                                  backgroundColor: Colors.orange,
                                  duration: Duration(seconds: 3),
                                ),
                              );
                              return;
                            }
                            await cartProvider.addToCart(
                              widget.food.id,
                              context,
                              excludedIngredients: _excludedIngredients,
                            ); // Pass context
                            if (cartProvider.errorMessage == null) {
                              debugPrint(
                                'FoodDetailScreen: Add to Cart successful, showing snackbar.',
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    '${widget.food.name} added to cart! Quantity: ${currentQuantity + 1}',
                                  ),
                                  duration: const Duration(seconds: 2),
                                ),
                              );

                              // Navigate to cart screen after successfully adding item
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => const CartScreen(),
                                ),
                              );
                            } else {
                              debugPrint(
                                'FoodDetailScreen: Add to Cart failed, showing error snackbar: ${cartProvider.errorMessage}',
                              );
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text(
                                    'Failed to add ${widget.food.name} to cart: ${cartProvider.errorMessage}',
                                  ),
                                  backgroundColor: Colors.red,
                                  duration: const Duration(seconds: 3),
                                ),
                              );
                            }
                          },
                    icon: cartProvider.isLoading
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.add_shopping_cart),
                    label: Text(
                      currentQuantity > 0
                          ? 'Add More (Current: $currentQuantity)'
                          : 'Add to Cart',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Theme.of(context).primaryColor,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
