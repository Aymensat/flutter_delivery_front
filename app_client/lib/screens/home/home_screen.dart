import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../models/restaurant.dart';
import '../../providers/restaurant_provider.dart';
import '../../providers/auth_provider.dart';
import '../../widgets/restaurant_card.dart';
import '../../widgets/search_bar.dart' as CustomSearchBar;
import '../../widgets/category_filter.dart'
    as CategoryFilterWidget; // FIX: Use prefix to avoid name conflict
import 'restaurant_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key}); // FIX: Add key parameter

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All'; // Initialize with 'All' or a default
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
      ).loadRestaurants(); // FIX: Changed from fetchRestaurants to loadRestaurants
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

  void _onSearchChanged(String query) {
    Provider.of<RestaurantProvider>(
      context,
      listen: false,
    ).setSearchQuery(query); // FIX: Assuming setSearchQuery
  }

  void _onCategorySelected(String category) {
    setState(() {
      _selectedCategory = category;
    });
    Provider.of<RestaurantProvider>(
      context,
      listen: false,
    ).filterByCategory(category); // FIX: Assuming filterByCategory
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Delivery'),
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              Navigator.pushNamed(
                context,
                '/cart',
              ); // Assuming you have a '/cart' route
            },
          ),
          // Example for logout, assuming AuthProvider handles this
          Consumer<AuthProvider>(
            builder: (context, authProvider, child) {
              return IconButton(
                icon: const Icon(Icons.logout),
                onPressed: () {
                  authProvider.logout();
                },
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: CustomSearchBar.SearchBar(
                controller: _searchController,
                onChanged: _onSearchChanged,
                hintText: 'Search restaurants...',
              ),
            ),
            Consumer<RestaurantProvider>(
              builder: (context, restaurantProvider, child) {
                return CategoryFilterWidget.CategoryFilter(
                  // FIX: Use prefixed CategoryFilter
                  categories: restaurantProvider.getCategories(),
                  selectedCategory: _selectedCategory,
                  onCategorySelected: _onCategorySelected,
                );
              },
            ),
            Expanded(
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : Consumer<RestaurantProvider>(
                      builder: (context, restaurantProvider, child) {
                        if (restaurantProvider.error != null) {
                          return Center(
                            child: Text(
                              'Error: ${restaurantProvider.error}',
                              style: const TextStyle(color: Colors.red),
                            ),
                          );
                        }
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
