import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/restaurant.dart';
import '../../models/food.dart';
import '../../providers/restaurant_provider.dart';
import '../../providers/cart_provider.dart';
import '../../providers/auth_provider.dart';
import '../../providers/review_provider.dart';
import '../../widgets/rating_stars.dart';
import '../cart/cart_screen.dart';
import 'food_detail_screen.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantDetailScreen({super.key, required this.restaurant});

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoadingFoods = true;
  List<Food> _foods = [];
  String? _foodErrorMessage;

  static const String baseServerUrl = 'http://10.0.2.2:3000';

  @override
  void initState() {
    super.initState();
    debugPrint(
      'RestaurantDetailScreen: initState for restaurant: ${widget.restaurant.name}',
    );
    _tabController = TabController(length: 2, vsync: this);
    _loadData();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadData() async {
    await _loadFoods();
    _loadReviews();
  }

  Future<void> _loadFoods() async {
    debugPrint('RestaurantDetailScreen: _loadFoods called.');
    setState(() {
      _isLoadingFoods = true;
      _foodErrorMessage = null;
    });
    try {
      final restaurantProvider = Provider.of<RestaurantProvider>(
        context,
        listen: false,
      );
      _foods = await restaurantProvider.fetchFoodsForRestaurant(
        widget.restaurant.id,
      );
      debugPrint('RestaurantDetailScreen: Foods loaded: ${_foods.length}');
    } catch (e) {
      if (mounted) {
        setState(() {
          _foodErrorMessage = 'Failed to load food items: ${e.toString()}';
        });
      }
      debugPrint('RestaurantDetailScreen: Error loading foods: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingFoods = false;
        });
      }
      debugPrint('RestaurantDetailScreen: Finished loading foods.');
    }
  }

  Future<void> _loadReviews() async {
    await Provider.of<ReviewProvider>(
      context,
      listen: false,
    ).fetchReviewsForRestaurant(widget.restaurant.id);
  }

  @override
  Widget build(BuildContext context) {
    debugPrint(
      'RestaurantDetailScreen: Building for restaurant: ${widget.restaurant.name}',
    );
    final String? fullRestaurantImageUrl =
        (widget.restaurant.imageUrl != null &&
            widget.restaurant.imageUrl!.isNotEmpty)
        ? (widget.restaurant.imageUrl!.startsWith('http://') ||
                  widget.restaurant.imageUrl!.startsWith('https://'))
              ? widget.restaurant.imageUrl!
              : '$baseServerUrl${widget.restaurant.imageUrl!}'
        : null;

    debugPrint('Restaurant Image URL attempt: $fullRestaurantImageUrl');

    return Scaffold(
      appBar: AppBar(
        title: Text(widget.restaurant.name),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _loadData),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (fullRestaurantImageUrl != null)
            Image.network(
              fullRestaurantImageUrl,
              height: 200,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stackTrace) {
                debugPrint('Restaurant Image load failed: $error');
                return Container(
                  height: 200,
                  color: Colors.grey[300],
                  alignment: Alignment.center,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.broken_image,
                        size: 50,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(height: 8),
                      const Text(
                        'Could not load restaurant image',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                );
              },
            )
          else
            Container(
              height: 200,
              width: double.infinity,
              color: Colors.grey[300],
              child: Icon(
                Icons.image_not_supported,
                size: 50,
                color: Colors.grey[600],
              ),
              alignment: Alignment.center,
            ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.restaurant.name,
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                RatingStars(rating: widget.restaurant.rating),
                const SizedBox(height: 12),
                _buildInfoRow(
                  Icons.location_on,
                  'Address',
                  widget.restaurant.address,
                ),
                _buildInfoRow(
                  Icons.phone,
                  'Contact',
                  widget.restaurant.contact,
                ),
                _buildInfoRow(
                  Icons.access_time,
                  'Working Hours',
                  widget.restaurant.workingHours,
                ),
                _buildInfoRow(
                  Icons.restaurant_menu,
                  'Cuisine',
                  widget.restaurant.cuisine,
                ),
                if (widget.restaurant.openingHours != null)
                  _buildInfoRow(
                    Icons.schedule,
                    'Opening Hours',
                    '${widget.restaurant.openingHours!.open} - ${widget.restaurant.openingHours!.close}',
                  ),
              ],
            ),
          ),
          TabBar(
            controller: _tabController,
            tabs: const [
              Tab(text: 'Menu'),
              Tab(text: 'Reviews'),
            ],
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Colors.grey,
            indicatorColor: Theme.of(context).primaryColor,
          ),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [_buildMenuTab(), _buildReviewsTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTab() {
    return _isLoadingFoods
        ? const Center(child: CircularProgressIndicator())
        : _foodErrorMessage != null
        ? Center(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                _foodErrorMessage!,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red, fontSize: 16),
              ),
            ),
          )
        : _foods.isEmpty
        ? const Center(child: Text('No food items found for this restaurant.'))
        : ListView.builder(
            padding: const EdgeInsets.all(16.0),
            itemCount: _foods.length,
            itemBuilder: (context, index) {
              final food = _foods[index];
              final String? fullFoodImageUrl =
                  (food.imageUrl != null && food.imageUrl!.isNotEmpty)
                  ? (food.imageUrl!.startsWith('http://') ||
                            food.imageUrl!.startsWith('https://'))
                        ? food.imageUrl!
                        : '$baseServerUrl${food.imageUrl!}'
                  : null;

              debugPrint(
                'Food Image URL attempt for ${food.name}: $fullFoodImageUrl',
              );

              return Card(
                margin: const EdgeInsets.only(bottom: 16),
                elevation: 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: InkWell(
                  onTap: () => _navigateToFoodDetail(food),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: Row(
                      children: [
                        if (fullFoodImageUrl != null)
                          ClipRRect(
                            borderRadius: BorderRadius.circular(8.0),
                            child: Image.network(
                              fullFoodImageUrl,
                              width: 100,
                              height: 100,
                              fit: BoxFit.cover,
                              errorBuilder: (context, error, stackTrace) {
                                debugPrint(
                                  'Food Image load failed for ${food.name}: $error',
                                );
                                return Container(
                                  width: 100,
                                  height: 100,
                                  color: Colors.grey[300],
                                  child: Icon(
                                    Icons.broken_image,
                                    size: 40,
                                    color: Colors.grey[600],
                                  ),
                                  alignment: Alignment.center,
                                );
                              },
                            ),
                          ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                food.name,
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                food.description,
                                style: Theme.of(context).textTheme.bodyMedium
                                    ?.copyWith(color: Colors.grey[600]),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                '${food.price.toStringAsFixed(2)} TND',
                                style: Theme.of(context).textTheme.titleMedium
                                    ?.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Theme.of(context).primaryColor,
                                    ),
                              ),
                            ],
                          ),
                        ),
                        Consumer2<CartProvider, AuthProvider>(
                          builder: (context, cartProvider, authProvider, child) {
                            final bool isDisabled =
                                !authProvider.isAuthenticated ||
                                cartProvider.isLoading;

                            debugPrint(
                              'RestaurantDetailScreen: Add to Cart button state for ${food.name} - isAuthenticated: ${authProvider.isAuthenticated}, userId: ${authProvider.user?.id}, isLoading: ${cartProvider.isLoading}',
                            );

                            return IconButton(
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
                              color: Theme.of(context).primaryColor,
                              onPressed: isDisabled
                                  ? null
                                  : () async {
                                      debugPrint(
                                        'RestaurantDetailScreen: Add to Cart button pressed for ${food.name}.',
                                      );
                                      if (authProvider.user?.id == null) {
                                        debugPrint(
                                          'RestaurantDetailScreen: User ID is null, showing login snackbar.',
                                        );
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
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
                                        food,
                                        context,
                                      );
                                      if (mounted &&
                                          cartProvider.errorMessage == null) {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                const CartScreen(),
                                          ),
                                        );
                                      }
                                    },
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
  }

  // TODO: The "Write a Review" button and dialog should be moved to the OrderDetailScreen.
  // This is because the backend requires an orderId to submit a review.
  Widget _buildReviewsTab() {
    return Consumer<ReviewProvider>(
      builder: (context, reviewProvider, child) {
        final reviews = reviewProvider.reviews[widget.restaurant.id] ?? [];
        return Column(
          children: [
            Expanded(
              child: reviewProvider.isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : reviews.isEmpty
                  ? const Center(child: Text('No reviews yet.'))
                  : ListView.builder(
                      padding: const EdgeInsets.all(16.0),
                      itemCount: reviews.length,
                      itemBuilder: (context, index) {
                        final review = reviews[index];
                        return Card(
                          margin: const EdgeInsets.symmetric(vertical: 8.0),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      review
                                          .userId, // Replace with user's name if available
                                      style: const TextStyle(
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    RatingStars(
                                      rating: review.rating.toDouble(),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                Text(review.comment),
                                const SizedBox(height: 8),
                                Text(
                                  review.timeAgo,
                                  style: Theme.of(context).textTheme.bodySmall,
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Center(
                child: ElevatedButton(
                  onPressed: () =>
                      _showReviewDialog(context, widget.restaurant.id),
                  child: const Text('Write a Review'),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: Colors.grey),
          const SizedBox(width: 12),
          Expanded(child: Text(value, style: const TextStyle(fontSize: 16))),
        ],
      ),
    );
  }

  void _navigateToFoodDetail(Food food) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => FoodDetailScreen(food: food)),
    );
  }

  void _showReviewDialog(BuildContext context, String restaurantId) {
    final formKey = GlobalKey<FormState>();
    int rating = 0;
    String comment = '';

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Write a Review'),
          content: Form(
            key: formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Text('Rate your experience:'),
                StatefulBuilder(
                  builder: (context, setState) {
                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(5, (index) {
                        return IconButton(
                          icon: Icon(
                            index < rating ? Icons.star : Icons.star_border,
                            color: Colors.amber,
                          ),
                          onPressed: () {
                            setState(() {
                              rating = index + 1;
                            });
                          },
                        );
                      }),
                    );
                  },
                ),
                TextFormField(
                  decoration: const InputDecoration(
                    labelText: 'Comment',
                    border: OutlineInputBorder(),
                  ),
                  onSaved: (value) => comment = value ?? '',
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Please enter a comment.';
                    }
                    return null;
                  },
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () async {
                if (formKey.currentState!.validate()) {
                  formKey.currentState!.save();
                  final success =
                      await Provider.of<ReviewProvider>(
                        context,
                        listen: false,
                      ).submitReview(
                        restaurantId: restaurantId,
                        rating: rating,
                        comment: comment,
                      );
                  Navigator.of(context).pop();
                  if (success) {
                    _loadReviews();
                  }
                }
              },
              child: const Text('Submit'),
            ),
          ],
        );
      },
    );
  }
}
