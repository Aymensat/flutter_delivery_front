import 'package:flutter/material.dart';
import '../../models/order.dart';

class OrderTrackingScreen extends StatelessWidget {
  final Order order;

  const OrderTrackingScreen({super.key, required this.order});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Track Order #${order.reference}')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.map, size: 100, color: Colors.grey),
            const SizedBox(height: 16),
            const Text(
              'Live map tracking is not yet implemented.',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text('Order Status: ${order.status}'),
          ],
        ),
      ),
    );
  }
}
