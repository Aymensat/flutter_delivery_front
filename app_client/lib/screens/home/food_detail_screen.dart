import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/food.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../cart/cart_screen.dart';

class FoodDetailScreen extends StatefulWidget {
  final Food food;
  final List<String> excludedIngredients;

  const FoodDetailScreen({
    super.key,
    required this.food,
    this.excludedIngredients = const [],
  });

  @override
  State<FoodDetailScreen> createState() => _FoodDetailScreenState();
}

class _FoodDetailScreenState extends State<FoodDetailScreen> {
  late List<String> _excludedIngredients;

  @override
  void initState() {
    super.initState();
    _excludedIngredients = List.from(widget.excludedIngredients);
  }

  @override
  Widget build(BuildContext context) {
    const String baseServerUrl = 'http://10.0.2.2:3000';
    final String? fullImageUrl =
        (widget.food.imageUrl != null && widget.food.imageUrl!.isNotEmpty)
            ? (widget.food.imageUrl!.startsWith('http'))
                ? widget.food.imageUrl!
                : '$baseServerUrl${widget.food.imageUrl!}'
            : null;

    return Scaffold(
      appBar: AppBar(title: Text(widget.food.name)),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (fullImageUrl != null)
              Center(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12.0),
                  child: Image.network(
                    fullImageUrl,
                    height: 250,
                    width: double.infinity,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        const Icon(Icons.broken_image, size: 100),
                  ),
                ),
              ),
            const SizedBox(height: 16),
            Text(
              widget.food.name,
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              '${widget.food.price.toStringAsFixed(2)} TND',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Theme.of(context).primaryColor,
                  ),
            ),
            const SizedBox(height: 16),
            Text(widget.food.description),
            const SizedBox(height: 24),
            Text(
              'Exclude Ingredients:',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Wrap(
              spacing: 8.0,
              runSpacing: 4.0,
              children: widget.food.ingredients.map((ingredient) {
                final isExcluded = _excludedIngredients.contains(ingredient);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isExcluded) {
                        _excludedIngredients.remove(ingredient);
                      } else {
                        _excludedIngredients.add(ingredient);
                      }
                    });
                  },
                  child: Chip(
                    label: Text(ingredient),
                    backgroundColor: isExcluded ? Colors.red.withOpacity(0.2) : null,
                    shape: StadiumBorder(
                      side: BorderSide(
                        color: isExcluded ? Colors.red : Colors.grey,
                        width: 1.0,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 24),
            Center(
              child: Consumer2<CartProvider, AuthProvider>(
                builder: (context, cartProvider, authProvider, child) {
                  if (!authProvider.isAuthenticated) {
                    return const Text('Please log in to add items to your cart.');
                  }

                  return ElevatedButton.icon(
                    onPressed: () async {
                      await cartProvider.addToCart(
                        widget.food,
                        context,
                        excludedIngredients: _excludedIngredients,
                      );
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Item added to cart!'),
                            duration: Duration(seconds: 2),
                          ),
                        );
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const CartScreen()),
                        );
                      }
                    },
                    icon: const Icon(Icons.add_shopping_cart),
                    label: const Text('Add to Cart'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 40, vertical: 15),
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