class AppConfig {
  static const String baseUrl = 'YOUR_API_BASE_URL/api';
  static const String socketUrl = 'YOUR_SOCKET_URL';

  // API Endpoints
  static const String loginEndpoint = '/auth/login';
  static const String registerEndpoint = '/auth/register';
  static const String restaurantsEndpoint = '/restaurants';
  static const String foodsEndpoint = '/food';
  static const String cartEndpoint = '/cart';
  static const String ordersEndpoint = '/orders';
  static const String paymentsEndpoint = '/payments';

  // App Settings
  static const int requestTimeout = 30;
  static const String appName = 'Food Delivery';
}
