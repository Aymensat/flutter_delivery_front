class AppConfig {
  static const String baseUrl =
      'http://10.0.2.2:3000/api'; // ✅ Emulator accesses host via 10.0.2.2
  static const String socketUrl = 'ws://10.0.2.2:3000';

  // API Endpoints
  static const String loginEndpoint = '/users/login';
  static const String registerEndpoint = '/users/register';
  static const String restaurantsEndpoint = '/restaurants';
  static const String foodsEndpoint = '/food';
  static const String cartEndpoint = '/cart';
  static const String ordersEndpoint = '/orders';
  static const String paymentsEndpoint = '/payments';

  // App Settings
  static const int requestTimeout = 30;
  static const String appName = 'Food Delivery';
}
