// lib/services/order_service.dart
import 'dart:convert';
import '../config/app_config.dart';
import 'api_service.dart';
import '../models/order.dart';

class OrderService {
  final ApiService _apiService = ApiService();

  Future<List<Order>> fetchOrders() async {
    try {
      final response = await _apiService.get('/orders');
      if (response is List) {
        return response.map((item) => Order.fromJson(item)).toList();
      }
      return [];
    } catch (e) {
      print('Failed to fetch orders: $e');
      throw Exception('Failed to load orders.');
    }
  }

  Future<Order> fetchOrderById(String orderId) async {
    try {
      final response = await _apiService.get('/orders/$orderId');
      return Order.fromJson(response);
    } catch (e) {
      print('Failed to fetch order $orderId: $e');
      throw Exception('Failed to load order details.');
    }
  }

  Future<Order> createOrder({
    required String restaurantId,
    required List<OrderItem> items,
    required String deliveryAddress,
    String? specialInstructions,
    required String paymentMethod,
  }) async {
    try {
      final response = await _apiService.post('/orders', {
        'restaurantId': restaurantId,
        'items': items.map((item) => item.toJson()).toList(),
        'deliveryAddress': deliveryAddress,
        'specialInstructions': specialInstructions,
        'paymentMethod': paymentMethod,
      });
      return Order.fromJson(response);
    } catch (e) {
      print('Failed to create order: $e');
      throw Exception('Failed to create order.');
    }
  }

  Future<Order> updateOrderStatus(String orderId, OrderStatus status) async {
    try {
      final response = await _apiService.put('/orders/$orderId/status', {
        'status': status.name, // Assuming enum name matches API string
      });
      return Order.fromJson(response);
    } catch (e) {
      print('Failed to update order status: $e');
      throw Exception('Failed to update order status.');
    }
  }

  Future<Order> assignDeliveryDriver(String orderId, String livreurId) async {
    try {
      final response = await _apiService.put(
        '/orders/$orderId/assign-livreur',
        {'livreurId': livreurId},
      );
      return Order.fromJson(response);
    } catch (e) {
      print('Failed to assign delivery driver: $e');
      throw Exception('Failed to assign delivery driver.');
    }
  }

  Future<void> deleteOrder(String orderId) async {
    try {
      await _apiService.delete('/orders/delete/$orderId');
    } catch (e) {
      print('Failed to delete order: $e');
      throw Exception('Failed to delete order.');
    }
  }
}
