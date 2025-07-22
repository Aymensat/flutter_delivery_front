// lib/screens/home/home_screen.dart
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
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedCategory = 'All';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadRestaurants();
    });

    // Add a listener to the search controller to automatically update the provider
    // whenever the text changes (including when cleared internally by SearchBar)
    _searchController.addListener(() {
      Provider.of<RestaurantProvider>(
        context,
        listen: false,
      ).setSearchQuery(_searchController.text);
    });
  }

  Future<void> _loadRestaurants() async {
    final restaurantProvider = Provider.of<RestaurantProvider>(
      context,
      listen: false,
    );
    // Clear any previous errors before loading new data
    restaurantProvider.clearError();
    try {
      await restaurantProvider.loadRestaurants();
    } catch (e) {
      if (mounted) {
        // The error is already handled by the provider's internal state.
        // We can optionally show a snackbar here if a general loading error occurs for the home screen.
        // For now, let's rely on the provider's error message display in the UI.
        // ScaffoldMessenger.of(context).showSnackBar(
        //   SnackBar(content: Text('Error loading restaurants: $e')),
        // );
      }
    }
  }

  @override
  void dispose() {
    _searchController.dispose(); // Dispose the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final restaurantProvider = Provider.of<RestaurantProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Food Delivery App'),
        centerTitle: false,
        actions: [
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            onPressed: () {
              // Navigate to CartScreen
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              Provider.of<AuthProvider>(context, listen: false).logout();
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
                onChanged: (query) {
                  // The _searchController.text will already be updated here,
                  // so you could also use _searchController.text directly,
                  // but 'query' is passed for convenience.
                  // No need to call setSearchQuery here again if using the listener below.
                },
              ),
            ),
            Consumer<RestaurantProvider>(
              builder: (context, provider, child) {
                return CategoryFilterWidget.CategoryFilter(
                  categories: provider.getCategories(),
                  selectedCategory: _selectedCategory,
                  onCategorySelected: (category) {
                    setState(() {
                      _selectedCategory = category;
                    });
                    provider.filterByCategory(category);
                  },
                );
              },
            ),
            Expanded(
              child: Consumer<RestaurantProvider>(
                builder: (context, restaurantProvider, child) {
                  if (restaurantProvider.isLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  // Display error if present
                  if (restaurantProvider.error != null) {
                    return Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.error_outline,
                            size: 48,
                            color: Colors.red,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Error: ${restaurantProvider.error}',
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              color: Colors.red,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton.icon(
                            onPressed: () {
                              restaurantProvider
                                  .clearError(); // Clear error before retrying
                              _loadRestaurants(); // Reload restaurants
                            },
                            icon: Icon(Icons.refresh),
                            label: Text('Retry Loading Restaurants'),
                          ),
                        ],
                      ),
                    );
                  }
                  if (restaurantProvider.filteredRestaurants.isEmpty) {
                    return const Center(
                      child: Text(
                        'No restaurants found',
                        style: TextStyle(fontSize: 16),
                      ),
                    );
                  }

                  return ListView.builder(
                    padding: const EdgeInsets.all(16),
                    itemCount: restaurantProvider.filteredRestaurants.length,
                    itemBuilder: (context, index) {
                      final restaurant =
                          restaurantProvider.filteredRestaurants[index];
                      return RestaurantCard(
                        restaurant: restaurant,
                        onTap: () => _navigateToRestaurantDetail(restaurant),
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

  void _navigateToRestaurantDetail(Restaurant restaurant) async {
    // Navigate to the detail screen and wait for it to be popped
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantDetailScreen(restaurant: restaurant),
      ),
    );

    // After returning from the detail screen, clear any errors that might have been set
    // by the detail screen's food loading, so the home screen doesn't display them.
    Provider.of<RestaurantProvider>(context, listen: false).clearError();
    // Optionally, you might want to refresh the restaurant list here if needed
    // _loadRestaurants();
  }
}
