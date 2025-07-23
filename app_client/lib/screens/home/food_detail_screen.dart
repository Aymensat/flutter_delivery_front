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
    // MODIFIED: Check if imageUrl is already a full URL before prepending baseServerUrl.
    final String? fullImageUrl =
        (food.imageUrl != null && food.imageUrl!.isNotEmpty)
        ? (food.imageUrl!.startsWith('http://') ||
                  food.imageUrl!.startsWith('https://'))
              ? food.imageUrl! // It's already a full URL, use as is
              : '$baseServerUrl${food.imageUrl!}' // It's a relative path, prepend base URL
        : null;

    return Scaffold(
      appBar: AppBar(title: Text(food.name)),
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
                    food.name,
                    style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Text(
                  '${food.price.toStringAsFixed(2)} TND', // Display price in TND
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
              food.category,
              style: Theme.of(
                context,
              ).textTheme.titleMedium?.copyWith(color: Colors.grey[600]),
            ),
            const SizedBox(height: 16),
            // Food Description
            Text(
              food.description,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 16),
            // Calories (if available)
            if (food.calories != null && food.calories! > 0)
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
                      '${food.calories!.toStringAsFixed(0)} kcal',
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
              ),
            // Ingredients
            Text(
              'Ingredients:',
              style: Theme.of(
                context,
              ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0, // gap between adjacent chips
              runSpacing: 4.0, // gap between lines
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
