import 'package:flutter/material.dart';
import '../../models/food.dart'; // Make sure this path is correct for your Food model

class FoodDetailScreen extends StatelessWidget {
  final Food food;

  const FoodDetailScreen({super.key, required this.food});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(food.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (food.imageUrl != null && food.imageUrl!.isNotEmpty)
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  food.imageUrl!,
                  height: 200,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => Container(
                    height: 200,
                    color: Colors.grey[300],
                    child: const Center(
                      child: Icon(
                        Icons.broken_image,
                        size: 50,
                        color: Colors.grey,
                      ),
                    ),
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
            Text(
              'Ingredients:',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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
