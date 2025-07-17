// widgets/restaurant_card.dart
import 'package:flutter/material.dart';
import '../models/restaurant.dart';
import '../models/food.dart'; // Added: Import for Food class
// import 'rating_stars.dart'; // Commented out: Unused import for RestaurantCard

class RestaurantCard extends StatelessWidget {
  final Restaurant restaurant;
  final VoidCallback onTap;

  const RestaurantCard({
    super.key, // FIX: Use super.key
    required this.restaurant,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
            // Restaurant Image
            Container(
              height: 160,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(12),
                ),
                // FIX: Conditional image loading to avoid errorBuilder on NetworkImage
                image:
                    restaurant.imageUrl != null &&
                        restaurant.imageUrl!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(restaurant.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null, // No image if URL is null or empty
              ),
              // FIX: Display placeholder if image URL is null or empty
              child:
                  (restaurant.imageUrl == null || restaurant.imageUrl!.isEmpty)
                  ? Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: const BorderRadius.vertical(
                          top: Radius.circular(12),
                        ),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.restaurant,
                          size: 80,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : null, // If image is set, no child needed
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

class FoodCard extends StatelessWidget {
  final Food food;
  final VoidCallback onAddToCart;

  const FoodCard({
    super.key, // FIX: Use super.key
    required this.food,
    required this.onAddToCart,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8),
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Row(
          children: [
            // Food Image
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(8),
                // FIX: Conditional image loading to avoid errorBuilder on NetworkImage
                image: food.imageUrl != null && food.imageUrl!.isNotEmpty
                    ? DecorationImage(
                        image: NetworkImage(food.imageUrl!),
                        fit: BoxFit.cover,
                      )
                    : null,
              ),
              // FIX: Display placeholder if image URL is null or empty
              child: (food.imageUrl == null || food.imageUrl!.isEmpty)
                  ? Container(
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: const Center(
                        child: Icon(
                          Icons.fastfood,
                          size: 40,
                          color: Colors.grey,
                        ),
                      ),
                    )
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    food.name,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    food.description,
                    style: const TextStyle(fontSize: 13, color: Colors.grey),
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
                      // FIX: Null check for calories before using '>' operator and displaying
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
