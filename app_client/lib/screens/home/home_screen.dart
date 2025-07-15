import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/restaurant.dart';
import '../../providers/restaurant_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/restaurant_card.dart';
import '../../widgets/search_bar.dart';
import '../../widgets/category_filter.dart';
import 'restaurant_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadRestaurants();
  }

  Future<void> _loadRestaurants() async {
    setState(() => _isLoading = true);
    try {
      await Provider.of<RestaurantProvider>(
        context,
        listen: false,
      ).fetchRestaurants();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading restaurants: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Delivery'),
        backgroundColor: Theme.of(context).primaryColor,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () => Navigator.pushNamed(context, '/profile'),
          ),
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () => Navigator.pushNamed(context, '/cart'),
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadRestaurants,
        child: Column(
          children: [
            // Search Bar
            Container(
              padding: const EdgeInsets.all(16),
              child: CustomSearchBar(
                controller: _searchController,
                onChanged: (value) {
                  Provider.of<RestaurantProvider>(
                    context,
                    listen: false,
                  ).filterRestaurants(value, _selectedCategory);
                },
                onClear: () {
                  _searchController.clear();
                  Provider.of<RestaurantProvider>(
                    context,
                    listen: false,
                  ).filterRestaurants('', _selectedCategory);
                },
              ),
            ),

            // Category Filter
            Container(
              height: 50,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: CategoryFilter(
                selectedCategory: _selectedCategory,
                onCategorySelected: (category) {
                  setState(() => _selectedCategory = category);
                  Provider.of<RestaurantProvider>(
                    context,
                    listen: false,
                  ).filterRestaurants(_searchController.text, category);
                },
              ),
            ),

            // Restaurant List
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Consumer<RestaurantProvider>(
                      builder: (context, restaurantProvider, child) {
                        if (restaurantProvider.restaurants.isEmpty) {
                          return const Center(
                            child: Text(
                              'No restaurants found',
                              style: TextStyle(fontSize: 16),
                            ),
                          );
                        }

                        return ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount:
                              restaurantProvider.filteredRestaurants.length,
                          itemBuilder: (context, index) {
                            final restaurant =
                                restaurantProvider.filteredRestaurants[index];
                            return RestaurantCard(
                              restaurant: restaurant,
                              onTap: () =>
                                  _navigateToRestaurantDetail(restaurant),
                            );
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToRestaurantDetail(Restaurant restaurant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantDetailScreen(restaurant: restaurant),
      ),
    );
  }
}
