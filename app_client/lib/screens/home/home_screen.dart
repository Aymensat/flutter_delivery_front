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

// lib/screens/home/home_screen.dart (Corrected SearchBar Usage)

// ... (previous imports and class definitions) ...

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
    try {
      await Provider.of<RestaurantProvider>(
        context,
        listen: false,
      ).loadRestaurants();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error loading restaurants: $e')),
        );
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
                // The onChanged callback will be triggered whenever the text changes
                // including when the internal clear button is pressed in SearchBar.
                onChanged: (query) {
                  // The _searchController.text will already be updated here,
                  // so you could also use _searchController.text directly,
                  // but 'query' is passed for convenience.
                  // No need to call setSearchQuery here again if using the listener below.
                  // If you prefer not to use a listener, you can keep this:
                  // Provider.of<RestaurantProvider>(context, listen: false).setSearchQuery(query);
                },
                // onSubmitted is optional, if you need to trigger a search only on submit
                // onSubmitted: (query) {
                //   Provider.of<RestaurantProvider>(context, listen: false).setSearchQuery(query);
                // },
                // Remove onSearch and onClear, as they are not part of your SearchBar's API
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
                  if (restaurantProvider.error != null) {
                    return Center(
                      child: Text(
                        'Error: ${restaurantProvider.error}',
                        style: const TextStyle(color: Colors.red),
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

  void _navigateToRestaurantDetail(Restaurant restaurant) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RestaurantDetailScreen(restaurant: restaurant),
      ),
    );
  }
}
