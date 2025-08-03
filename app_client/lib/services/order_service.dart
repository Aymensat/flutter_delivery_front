import 'package:flutter/foundation.dart';
import 'api_service.dart';
import '../models/order.dart';

class OrderService {
  final ApiService _apiService = ApiService();

  Future<List<Order>> fetchOrders() async {
    try {
      final response = await _apiService.get('/orders');
      debugPrint('Raw JSON from /orders: $response');
      if (response is List) {
        return response.map((item) => Order.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      debugPrint('Failed to fetch orders: $e');
      throw Exception('Failed to load orders.');
    }
  }

  Future<Order> fetchOrderById(String orderId) async {
    try {
      final response = await _apiService.get('/orders/$orderId');
      debugPrint('Raw JSON for order $orderId: $response');
      return Order.fromJson(response);
    } catch (e) {
      debugPrint('Failed to fetch order $orderId: $e');
      throw Exception('Failed to load order details.');
    }
  }

  Future<Order> createOrder(Order order) async {
    try {
      final response = await _apiService.post('/orders/add', order.toJson());
      return Order.fromJson(response);
    } catch (e) {
      debugPrint('Failed to create order: $e');
      throw Exception('Failed to create order.');
    }
  }

  Future<Order> updateOrderStatus(
    String orderId,
    String status, {
    String? livreurId,
  }) async {
    try {
      final response = await _apiService.patch('/orders/$orderId/status', {
        'status': status,
        if (livreurId != null) 'livreur': livreurId,
      });
      return Order.fromJson(response);
    } catch (e) {
      debugPrint('Failed to update order status: $e');
      throw Exception('Failed to update order status.');
    }
  }

  Future<Order> assignDeliveryDriver(String orderId, String livreurId) async {
    try {
      final response = await _apiService.patch(
        '/orders/$orderId/assign-livreur',
        {'livreur': livreurId},
      );
      return Order.fromJson(response);
    } catch (e) {
      debugPrint('Failed to assign delivery driver: $e');
      throw Exception('Failed to assign delivery driver.');
    }
  }

  Future<void> deleteOrder(String orderId) async {
    try {
      await _apiService.delete('/orders/delete/$orderId');
    } catch (e) {
      debugPrint('Failed to delete order: $e');
      throw Exception('Failed to delete order.');
    }
  }
}
