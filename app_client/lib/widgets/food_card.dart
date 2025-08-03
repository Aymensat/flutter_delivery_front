// lib/widgets/food_card.dart
import 'package:flutter/material.dart';
import '../models/food.dart'; // Ensure this import path is correct

class FoodCard extends StatelessWidget {
  final Food food;
  final VoidCallback onAddToCart;

  const FoodCard({super.key, required this.food, required this.onAddToCart});

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

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Food Image Container
            Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                // Conditionally set the image decoration if a valid URL exists
                image: fullImageUrl != null
                    ? DecorationImage(
                        image: NetworkImage(fullImageUrl),
                        fit: BoxFit.cover,
                        // Handle errors during image loading
                        onError: (exception, stackTrace) {
                          // Print error to console for debugging
                          debugPrint(
                            'FoodCard NetworkImage error for ${food.name}: $exception',
                          );
                        },
                      )
                    : null, // No image decoration if URL is null
              ),
              // Display a placeholder icon if the image URL is null or empty,
              // or if the image fails to load.
              child: fullImageUrl == null
                  ? Center(
                      child: Icon(
                        Icons.fastfood,
                        size: 60,
                        color: Colors.grey[400],
                      ),
                    )
                  : null, // No child needed if image is loading/loaded
            ),
            const SizedBox(width: 12),
            // Food Details Section
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    food.description,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Text(
                        '\$${food.price.toStringAsFixed(2)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                      // Display calories if available and greater than 0
                      if (food.calories != null && food.calories! > 0) ...[
                        const SizedBox(width: 8),
                        Text(
                          '${food.calories!.toStringAsFixed(0)} cal',
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            // Add to Cart Button
            IconButton(
              onPressed: onAddToCart,
              icon: Icon(
                Icons.add_shopping_cart,
                color: Theme.of(context).primaryColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
