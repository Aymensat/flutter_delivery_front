import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/restaurant.dart';
import '../../models/food.dart';
import '../../providers/restaurant_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/food_card.dart';
import '../../widgets/rating_stars.dart';
import 'food_detail_screen.dart';

class RestaurantDetailScreen extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantDetailScreen({Key? key, required this.restaurant})
    : super(key: key);

  @override
  State<RestaurantDetailScreen> createState() => _RestaurantDetailScreenState();
}

class _RestaurantDetailScreenState extends State<RestaurantDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  bool _isLoading = true;
  List<Food> _foods = [];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _loadRestaurantFoods();
  }

  Future<void> _loadRestaurantFoods() async {
    try {
      final foods = await Provider.of<RestaurantProvider>(
        context,
        listen: false,
      ).fetchRestaurantFoods(widget.restaurant.id);
      setState(() {
        _foods = foods;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading menu: $e')));
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // Restaurant Header
          SliverAppBar(
            expandedHeight: 250,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  Image.network(
                    widget.restaurant.imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        color: Colors.grey[300],
                        child: const Icon(Icons.restaurant, size: 80),
                      );
                    },
                  ),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              IconButton(
                icon: const Icon(Icons.shopping_cart),
                onPressed: () => Navigator.pushNamed(context, '/cart'),
              ),
            ],
          ),

          // Restaurant Info
          SliverToBoxAdapter(
            child: Container(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    widget.restaurant.name,
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      RatingStars(rating: widget.restaurant.rating),
                      const SizedBox(width: 8),
                      Text(
                        '${widget.restaurant.rating.toStringAsFixed(1)} • ${widget.restaurant.cuisine}',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.location_on,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Expanded(
                        child: Text(
                          widget.restaurant.address,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        widget.restaurant.workingHours,
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    widget.restaurant.description,
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ),
          ),

          // Tab Bar
          SliverToBoxAdapter(
            child: Container(
              color: Colors.white,
              child: TabBar(
                controller: _tabController,
                labelColor: Theme.of(context).primaryColor,
                unselectedLabelColor: Colors.grey,
                indicatorColor: Theme.of(context).primaryColor,
                tabs: const [
                  Tab(text: 'Menu'),
                  Tab(text: 'Reviews'),
                  Tab(text: 'Info'),
                ],
              ),
            ),
          ),

          // Tab Content
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [_buildMenuTab(), _buildReviewsTab(), _buildInfoTab()],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuTab() {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (_foods.isEmpty) {
      return const Center(
        child: Text('No menu items available', style: TextStyle(fontSize: 16)),
      );
    }

    // Group foods by category
    final Map<String, List<Food>> groupedFoods = {};
    for (final food in _foods) {
      groupedFoods.putIfAbsent(food.category, () => []).add(food);
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: groupedFoods.length,
      itemBuilder: (context, index) {
        final category = groupedFoods.keys.elementAt(index);
        final foods = groupedFoods[category]!;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (index > 0) const SizedBox(height: 24),
            Text(
              category,
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ...foods.map(
              (food) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: FoodCard(
                  food: food,
                  onTap: () => _navigateToFoodDetail(food),
                  onAddToCart: () => _addToCart(food),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildReviewsTab() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: widget.restaurant.ratings.length,
      itemBuilder: (context, index) {
        final rating = widget.restaurant.ratings[index];
        return Card(
          margin: const EdgeInsets.only(bottom: 12),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const CircleAvatar(child: Icon(Icons.person)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Customer ${index + 1}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          RatingStars(rating: rating.rating.toDouble()),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                const Text(
                  'Great food and service!',
                  style: TextStyle(fontSize: 14),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildInfoTab() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildInfoSection('Contact Information', [
            _buildInfoRow(Icons.phone, 'Phone', widget.restaurant.contact),
            _buildInfoRow(
              Icons.location_on,
              'Address',
              widget.restaurant.address,
            ),
          ]),
          const SizedBox(height: 24),
          _buildInfoSection('Opening Hours', [
            _buildInfoRow(
              Icons.access_time,
              'Working Hours',
              widget.restaurant.workingHours,
            ),
            if (widget.restaurant.openingHours != null)
              _buildInfoRow(
                Icons.schedule,
                'Opens',
                widget.restaurant.openingHours!.open,
              ),
            if (widget.restaurant.openingHours != null)
              _buildInfoRow(
                Icons.schedule,
                'Closes',
                widget.restaurant.openingHours!.close,
              ),
          ]),
          const SizedBox(height: 24),
          _buildInfoSection('Restaurant Details', [
            _buildInfoRow(
              Icons.restaurant,
              'Cuisine',
              widget.restaurant.cuisine,
            ),
            _buildInfoRow(
              Icons.star,
              'Rating',
              '${widget.restaurant.rating.toStringAsFixed(1)} stars',
            ),
            _buildInfoRow(
              Icons.check_circle,
              'Status',
              widget.restaurant.isActive ? 'Open' : 'Closed',
            ),
          ]),
        ],
      ),
    );
  }

  Widget _buildInfoSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        ...children,
      ],
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
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    color: Colors.grey,
                  ),
                ),
                Text(value, style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
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

  void _addToCart(Food food) {
    Provider.of<CartProvider>(context, listen: false).addToCart(food);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('${food.name} added to cart'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
