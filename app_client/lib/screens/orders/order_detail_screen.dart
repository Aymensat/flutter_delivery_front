import 'package:flutter/material.dart';
import '../../models/order.dart';
import 'order_tracking_screen.dart';

class OrderDetailScreen extends StatelessWidget {
  final Order order;

  const OrderDetailScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Order #${order.reference}')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Status: ${order.status}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            Text('Restaurant: ${order.restaurantName}'),
            Text(
              'Delivery Address: ${order.latitude}, ${order.longitude}',
            ), // Assuming you have address field
            const SizedBox(height: 16),
            Text('Items:', style: Theme.of(context).textTheme.titleLarge),
            Expanded(
              child: ListView.builder(
                itemCount: order.items.length,
                itemBuilder: (context, index) {
                  final item = order.items[index];
                  return ListTile(
                    title: Text(
                      'Item ID: ${item.food}',
                    ), // Showing food ID for now
                    trailing: Text('Quantity: ${item.quantity}'),
                  );
                },
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Total: \$${order.totalPrice.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => OrderTrackingScreen(order: order),
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
