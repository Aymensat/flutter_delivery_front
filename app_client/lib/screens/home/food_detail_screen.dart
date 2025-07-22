import 'package:flutter/material.dart';
import '../../models/food.dart'; // Make sure this path is correct for your Food model

class FoodDetailScreen extends StatelessWidget {
  final Food food;

  const FoodDetailScreen({super.key, required this.food});

  @override
  Widget build(BuildContext context) {
    // Define the base server URL for images.
    // This should match your backend server's address.
    // For Android Emulator, 'http://10.0.2.2:3000' is typically used.
    // For iOS Simulator/Desktop, 'http://localhost:3000' is common.
    // For a physical device, use your computer's local IP address (e.g., 'http://192.168.1.5:3000').
    const String baseServerUrl = 'http://10.0.2.2:3000';

    // Construct the full image URL.
    // Check if food.imageUrl is not null and not empty before constructing.
    final String? fullImageUrl =
        (food.imageUrl != null && food.imageUrl!.isNotEmpty)
        ? '$baseServerUrl${food.imageUrl!}'
        : null;

    return Scaffold(
      appBar: AppBar(title: Text(food.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Food Image Display
            if (fullImageUrl !=
                null) // Only display Image.network if a valid URL exists
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  fullImageUrl,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  // Handle errors during image loading
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 50,
                        color: Colors.grey[400],
                      ),
                    ),
                  ),
                ),
              )
            else // Display a placeholder if no valid image URL
              Container(
                height: 200,
                width: double.infinity,
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Center(
                  child: Icon(
                    Icons.fastfood,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              food.name,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              '\$${food.price.toStringAsFixed(2)}',
              style: TextStyle(
                fontSize: 20,
                color: Theme.of(context).primaryColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(food.description, style: const TextStyle(fontSize: 16)),
            const SizedBox(height: 16),
            Text(
              'Category: ${food.category}',
              style: TextStyle(fontSize: 16, color: Colors.grey[700]),
            ),
            if (food.calories != null) ...[
              const SizedBox(height: 8),
              Text(
                'Calories: ${food.calories!.toStringAsFixed(0)} kcal',
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
            ],
            const SizedBox(height: 16),
            const Text(
              'Ingredients:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: food.ingredients
                  .map(
                    (ingredient) => Chip(
                      label: Text(ingredient),
                      backgroundColor: Colors.blueGrey[50],
                    ),
                  )
                  .toList(),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.center,
              child: ElevatedButton.icon(
                onPressed: () {
                  // TODO: Implement add to cart functionality here
                  // You'll likely need to use a CartProvider here
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        'Add ${food.name} to cart functionality here!',
                      ),
                    ),
                  );
                },
                icon: const Icon(Icons.add_shopping_cart),
                label: const Text('Add to Cart'),
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
              ),
            ),
          ],
        ),
      ),
    );
  }
}
