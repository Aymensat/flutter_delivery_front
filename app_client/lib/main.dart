import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'config/theme.dart';
import 'providers/auth_provider.dart';
import 'providers/cart_provider.dart';
import 'providers/restaurant_provider.dart';
// import 'providers/order_provider.dart'; // FIX: Remove unused import for now if OrderProvider isn't ready
import 'screens/auth/login_screen.dart';
import 'screens/home/home_screen.dart';
import 'services/api_service.dart'; // Assuming ApiService is used to load token

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load saved token (assuming ApiService handles this or it's moved to AuthService)
  // If token loading is part of AuthProvider's init or AuthService, this line might be removed.
  // For now, keeping it if it's the standard entry point for token loading.
  await ApiService()
      .loadToken(); // Ensure ApiService().loadToken() exists or move this logic

  runApp(const MyApp()); // FIX: Add const
}

class MyApp extends StatelessWidget {
  const MyApp({super.key}); // FIX: Add key parameter

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => CartProvider()),
        ChangeNotifierProvider(create: (_) => RestaurantProvider()),
        // FIX: If OrderProvider is not yet implemented or causing errors,
        // comment it out or ensure it's correctly defined.
        // ChangeNotifierProvider(create: (_) => OrderProvider()),
      ],
      child: MaterialApp(
        title: 'Food Delivery',
        theme: AppTheme.lightTheme,
        home: const AuthWrapper(), // FIX: Add const
        debugShowCheckedModeBanner: false,
      ),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key}); // FIX: Add key parameter

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, authProvider, child) {
        if (authProvider.isLoading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (authProvider.isAuthenticated) {
          return const HomeScreen(); // FIX: Add const
        } else {
          return const LoginScreen(); // FIX: Add const
        }
      },
    );
  }
}
