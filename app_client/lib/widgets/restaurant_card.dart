// widgets/restaurant_card.dart
import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import '../models/food.dart'; // Added: Import for Food class

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback onTap;

  const RestaurantCard({
    super.key,
    required this.restaurant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    // Define the base server URL for images.
    // This should match your backend server's address.
    // For Android Emulator, 'http://10.0.2.2:3000' is typically used.
    // For iOS Simulator/Desktop, 'http://localhost:3000' is common.
    // For a physical device, use your computer's local IP address (e.g., 'http://192.168.1.5:3000').
    const String baseServerUrl = 'http://10.0.2.2:3000';

    // Construct the full image URL for the restaurant.
    final String? fullRestaurantImageUrl =
        (restaurant.imageUrl != null && restaurant.imageUrl!.isNotEmpty)
        ? '$baseServerUrl${restaurant.imageUrl!}'
        : null;

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Restaurant Image Container
            Container(
              height: 160,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                // Conditionally set the image decoration if a valid URL exists
                image: fullRestaurantImageUrl != null
                    ? DecorationImage(
                        image: NetworkImage("${restaurant.imageUrl}"),
                        fit: BoxFit.cover,
                        // Handle errors during image loading
                        onError: (exception, stackTrace) {
                          // Print error to console for debugging
                          print(
                            'RestaurantCard NetworkImage error for ${restaurant.name}: $exception',
                          );
                        },
                      )
                    : null, // No image decoration if URL is null
              ),
              // Display a placeholder if the image URL is null or empty,
              // or if the image fails to load.
              child: fullRestaurantImageUrl == null
                  ? Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                      ),
                      child: Center(
                        child: Icon(
                          Icons.restaurant,
                          size: 80,
                          color: Colors.grey[400],
                        ),
                      ),
                    )
                  : null, // No child needed if image is loading/loaded
            ),

            Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    restaurant.name,
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.restaurant_menu,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Text(
                        restaurant.cuisine,
                        style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                      ),
                      const SizedBox(width: 12),
                      Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          restaurant.address,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    restaurant.description,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Rating: ${restaurant.rating.toStringAsFixed(1)}',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).primaryColor,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
