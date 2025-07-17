import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/restaurant.dart';
import '../../models/food.dart';
import '../../providers/restaurant_provider.dart';
import '../../providers/cart_provider.dart'; // Keep if _addToCart is used
import '../../widgets/rating_stars.dart';
import 'food_detail_screen.dart'; // This import will now be used

class RestaurantDetailScreen extends StatefulWidget {
  final Restaurant restaurant;

  const RestaurantDetailScreen({super.key, required this.restaurant});

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

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadRestaurantFoods() async {
    try {
      // FIX: Correct method name 'fetchFoodsForRestaurant'
      final foods = await Provider.of<RestaurantProvider>(
        context,
        listen: false,
      ).fetchFoodsForRestaurant(widget.restaurant.id); // Corrected method call
      setState(() {
        _foods = foods;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading foods: $e')));
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: Image.network(
                widget.restaurant.imageUrl ??
                    'https://via.placeholder.com/400x250.png?text=Restaurant+Image',
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: const Color.fromRGBO(200, 200, 200, 1.0),
                  child: const Icon(
                    Icons.broken_image,
                    size: 50,
                    color: Colors.grey,
                  ),
                ),
              ),
            ),
          ),
          SliverList(
            delegate: SliverChildListDelegate([
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.restaurant.name,
                      style: const TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    // FIX: Removed 'reviewCount' as it's not defined in RatingStars
                    RatingStars(
                      rating: widget.restaurant.rating,
                      color: Colors.amber,
                      size: 24,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      widget.restaurant.description,
                      style: TextStyle(fontSize: 16, color: Colors.grey[700]),
                    ),
                    const SizedBox(height: 24),
                    _buildSectionTitle('Contact Information'),
                    _buildInfoRow(
                      Icons.location_on,
                      'Address',
                      widget.restaurant.address,
                    ),
                    _buildInfoRow(
                      Icons.phone,
                      'Phone',
                      widget.restaurant.contact,
                    ),
                    _buildInfoRow(
                      Icons.schedule,
                      'Working Hours',
                      widget.restaurant.workingHours,
                    ),
                    const SizedBox(height: 24),
                    TabBar(
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
                    SizedBox(
                      height:
                          MediaQuery.of(context).size.height *
                          0.7, // Adjust height as needed
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          _isLoading
                              ? const Center(child: CircularProgressIndicator())
                              : _buildMenuList(),
                          const Center(child: Text('Reviews Tab Content')),
                          const Center(child: Text('Info Tab Content')),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuList() {
    if (_foods.isEmpty) {
      return const Center(child: Text('No food items available.'));
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      physics:
          const NeverScrollableScrollPhysics(), // Important for nested scroll views
      shrinkWrap: true,
      itemCount: _foods.length,
      itemBuilder: (context, index) {
        final food = _foods[index];
        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 2,
          child: ListTile(
            leading: food.imageUrl != null && food.imageUrl!.isNotEmpty
                ? Image.network(
                    food.imageUrl!,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  )
                : const Icon(Icons.fastfood, size: 60),
            title: Text(
              food.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(food.description),
            trailing: Row(
              // Using a Row to contain both price and add to cart button
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('\$${food.price.toStringAsFixed(2)}'),
                IconButton(
                  icon: const Icon(Icons.add_shopping_cart),
                  onPressed: () =>
                      _addToCart(food), // FIX: Call _addToCart here
                ),
              ],
            ),
            onTap: () => _navigateToFoodDetail(food),
          ),
        );
      },
    );
  }

  Widget _buildSectionTitle(String title) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
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
    // This assumes CartProvider is imported and available via Provider.of
    // Add null checks or handle cases where context might not have a CartProvider
    Provider.of<CartProvider>(context, listen: false).addToCart(food);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${food.name} added to cart!')));
  }
}
