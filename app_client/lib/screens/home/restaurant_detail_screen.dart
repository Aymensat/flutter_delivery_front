import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/restaurant.dart';
import '../../models/food.dart';
import '../../providers/restaurant_provider.dart';
import '../../providers/cart_provider.dart';
import '../../widgets/rating_stars.dart';
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
  bool _isLoadingFoods = true; // Renamed for clarity
  List<Food> _foods = [];
  String? _foodErrorMessage; // To store specific food loading errors

  // Define the base server URL for images.
  // This should match your backend server's address.
  // For Android Emulator, 'http://10.0.2.2:3000' is typically used.
  // For iOS Simulator/Desktop, 'http://localhost:3000' is common.
  // For a physical device, use your computer's local IP address (e.g., 'http://192.168.1.5:3000').
  static const String baseServerUrl = 'http://10.0.2.2:3000';

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
    setState(() {
      _isLoadingFoods = true;
      _foodErrorMessage = null; // Clear previous errors
    });

    try {
      final foods = await Provider.of<RestaurantProvider>(
        context,
        listen: false,
      ).fetchFoodsForRestaurant(widget.restaurant.id);
      setState(() {
        _foods = foods;
      });
      if (foods.isEmpty) {
        _foodErrorMessage = 'No food items available for this restaurant yet.';
      }
    } catch (e) {
      // Check if the error is a 404 (Not Found) specifically for foods
      if (e.toString().contains('404') && e.toString().contains('/foods')) {
        _foodErrorMessage = 'No food items found for this restaurant.';
      } else {
        _foodErrorMessage = 'Error loading food menu: ${e.toString()}';
      }
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(_foodErrorMessage!)));
      }
      _foods = []; // Ensure food list is empty on error
    } finally {
      setState(() {
        _isLoadingFoods = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    // Construct the full image URL for the restaurant's main image.
    final String? fullRestaurantImageUrl =
        (widget.restaurant.imageUrl != null &&
            widget.restaurant.imageUrl!.isNotEmpty)
        ? '$baseServerUrl${widget.restaurant.imageUrl!}'
        : null;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 250.0,
            floating: false,
            pinned: true,
            flexibleSpace: FlexibleSpaceBar(
              background: fullRestaurantImageUrl != null
                  ? Image.network(
                      fullRestaurantImageUrl,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Container(
                        color: Colors.grey[300],
                        child: Center(
                          child: Icon(
                            Icons.broken_image,
                            size: 50,
                            color: Colors.grey[400],
                          ),
                        ),
                      ),
                    )
                  : Container(
                      color: Colors.grey[300],
                      child: Center(
                        child: Icon(
                          Icons.restaurant,
                          size: 80,
                          color: Colors.grey[400],
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
                          _isLoadingFoods
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
    if (_foodErrorMessage != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.info_outline, size: 48, color: Colors.grey),
              SizedBox(height: 8),
              Text(
                _foodErrorMessage!,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, color: Colors.grey[700]),
              ),
              SizedBox(height: 16),
              ElevatedButton.icon(
                onPressed: _loadRestaurantFoods,
                icon: Icon(Icons.refresh),
                label: Text('Retry Loading Menu'),
              ),
            ],
          ),
        ),
      );
    }
    if (_foods.isEmpty) {
      return const Center(
        child: Text('No food items available for this restaurant.'),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      physics:
          const NeverScrollableScrollPhysics(), // Important for nested scroll views
      shrinkWrap: true,
      itemCount: _foods.length,
      itemBuilder: (context, index) {
        final food = _foods[index];
        // Construct the full image URL for each food item in the menu.
        final String? fullFoodImageUrl =
            (food.imageUrl != null && food.imageUrl!.isNotEmpty)
            ? '$baseServerUrl${food.imageUrl!}'
            : null;

        return Card(
          margin: const EdgeInsets.symmetric(vertical: 8),
          elevation: 2,
          child: ListTile(
            leading: fullFoodImageUrl != null
                ? Image.network(
                    fullFoodImageUrl,
                    width: 60, // Adjust size as needed
                    height: 60, // Adjust size as needed
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => Container(
                      width: 60,
                      height: 60,
                      color: Colors.grey[200],
                      child: Center(
                        child: Icon(
                          Icons.broken_image,
                          color: Colors.grey[400],
                        ),
                      ),
                    ),
                  )
                : Container(
                    width: 60,
                    height: 60,
                    color: Colors.grey[200],
                    child: Center(
                      child: Icon(Icons.fastfood, color: Colors.grey[400]),
                    ),
                  ),
            title: Text(
              food.name,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(food.description),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('\$${food.price.toStringAsFixed(2)}'),
                IconButton(
                  icon: const Icon(Icons.add_shopping_cart),
                  onPressed: () => _addToCart(food),
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
    Provider.of<CartProvider>(context, listen: false).addToCart(food.id);
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${food.name} added to cart!')));
  }
}
