import 'package:app_client/models/food.dart';
import 'package:app_client/services/food_service.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/order.dart';
import 'delivery_tracking_screen.dart';

class OrderDetailScreen extends StatefulWidget {
  final Order order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  _OrderDetailScreenState createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen> {
  late Future<List<Food?>> _foodItemsFuture;
  final FoodService _foodService = FoodService();

  @override
  void initState() {
    super.initState();
    _foodItemsFuture = _fetchFoodItems();
  }

  Future<List<Food?>> _fetchFoodItems() async {
    // Use Future.wait for parallel fetching
    return Future.wait(
      widget.order.items.map((item) async {
        try {
          return await _foodService.fetchFoodById(item.food);
        } catch (e) {
          debugPrint('Failed to fetch food with id ${item.food}: $e');
          // Return null on error to handle it gracefully in the UI
          return null;
        }
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order #${widget.order.reference}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status: ${widget.order.status}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            // Display restaurant name, with a fallback
            Text(
              'Restaurant: ${widget.order.restaurantName?.isNotEmpty == true ? widget.order.restaurantName : "Unknown Restaurant"}',
            ),
            Text(
              'Order Date: ${DateFormat.yMMMd().add_jm().format(widget.order.createdAt)}',
            ),
            Text('Payment Method: ${widget.order.paymentMethod.value}'),
            Text(
              'Delivery Address: ${widget.order.latitude}, ${widget.order.longitude}',
            ),
            const SizedBox(height: 16),
            Text('Items:', style: Theme.of(context).textTheme.titleLarge),
            Expanded(
              child: FutureBuilder<List<Food?>>(
                future: _foodItemsFuture,
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (snapshot.hasError || !snapshot.hasData) {
                    return const Center(
                      child: Text('Error loading food items.'),
                    );
                  }

                  final List<Food?> foodItems = snapshot.data!;

                  return ListView.builder(
                    itemCount: foodItems.length,
                    itemBuilder: (context, index) {
                      final Food? food = foodItems[index];
                      final OrderItem orderItem = widget.order.items[index];

                      // Handle the case where a food item could not be fetched
                      if (food == null) {
                        return ListTile(
                          title: const Text('Unknown Food'),
                          subtitle: Text('ID: ${orderItem.food}'),
                          trailing: Text('x${orderItem.quantity}'),
                          tileColor: Colors.grey[200],
                        );
                      }

                      final String exclusions =
                          orderItem.excludedIngredients.isNotEmpty
                          ? 'Excluding: ${orderItem.excludedIngredients.join(', ')}'
                          : 'No exclusions';

                      return ListTile(
                        title: Text(food.name),
                        subtitle: Text(exclusions),
                        trailing: Text('x${orderItem.quantity}'),
                      );
                    },
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Total: \$${widget.order.totalPrice.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () { // Always enabled for demo purposes
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) =>
                        DeliveryTrackingScreen(order: widget.order),
                  ),
                );
              },
              child: const Text('Track Order'),
            ),
          ],
        ),
      ),
    );
  }
}
