import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:app_client/models/order.dart';
import 'package:app_client/services/auth_service.dart';
import 'package:app_client/models/user_public_profile.dart';

class DeliveryTrackingScreen extends StatefulWidget {
  final Order order;

  const DeliveryTrackingScreen({super.key, required this.order});

  @override
  DeliveryTrackingScreenState createState() => DeliveryTrackingScreenState();
}

class DeliveryTrackingScreenState extends State<DeliveryTrackingScreen> {
  // TODO: Replace with live location tracking from the backend
  late LatLng _deliveryPersonLocation;
  late Timer _locationTimer;
  UserPublicProfile? _livreurProfile;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _deliveryPersonLocation = const LatLng(36.81897, 10.16579);
    _fetchLivreurProfile();

    // Mock location updates every 5 seconds
    _locationTimer = Timer.periodic(const Duration(seconds: 5), (timer) {
      if (mounted) {
        setState(() {
          // Simulate a small change in location
          _deliveryPersonLocation = LatLng(
            _deliveryPersonLocation.latitude + 0.0001,
            _deliveryPersonLocation.longitude + 0.0001,
          );
        });
      }
    });
  }

  @override
  void dispose() {
    _locationTimer.cancel();
    super.dispose();
  }

  Future<void> _fetchLivreurProfile() async {
    if (widget.order.livreur != null) {
      try {
        final authService = AuthService();
        final profile = await authService.getUserProfileById(
          widget.order.livreur!,
        );
        if (mounted) {
          setState(() {
            _livreurProfile = profile;
            _isLoading = false;
          });
        }
      } catch (e) {
        // Handle error, e.g., show a snackbar
        if (mounted) {
          setState(() {
            _isLoading = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error fetching driver details: $e')),
          );
        }
      }
    } else {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _makePhoneCall(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Driver\'s phone number is not available.'),
        ),
      );
      return;
    }
    final Uri launchUri = Uri(scheme: 'tel', path: phoneNumber);
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not launch phone call to $phoneNumber')),
      );
    }
  }

  Future<void> _makeWhatsAppCall(String? phoneNumber) async {
    if (phoneNumber == null || phoneNumber.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Driver\'s phone number is not available.'),
        ),
      );
      return;
    }
    // Note: This requires WhatsApp to be installed.
    final Uri launchUri = Uri.parse('whatsapp://call?phone=$phoneNumber');
    if (await canLaunchUrl(launchUri)) {
      await launchUrl(launchUri);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Could not make WhatsApp call. Please ensure WhatsApp is installed.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Track Delivery')),
      body: Column(
        children: [
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: _deliveryPersonLocation,
                initialZoom: 15,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                ),
                MarkerLayer(
                  markers: [
                    Marker(
                      width: 80.0,
                      height: 80.0,
                      point: _deliveryPersonLocation,
                      child: const Icon(
                        Icons.delivery_dining,
                        color: Colors.red,
                        size: 40.0,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                const Text(
                  'Your order is on the way!',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                if (_livreurProfile != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Text(
                      'Driver: ${_livreurProfile!.firstName} ${_livreurProfile!.name}',
                      style: const TextStyle(fontSize: 16),
                    ),
                  ),
                const SizedBox(height: 16),
                if (_isLoading)
                  const CircularProgressIndicator()
                else
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ElevatedButton.icon(
                        onPressed: _livreurProfile == null
                            ? null
                            : () => _makePhoneCall(_livreurProfile!.phone),
                        icon: const Icon(Icons.phone),
                        label: const Text('Call Driver'),
                      ),
                      ElevatedButton.icon(
                        onPressed: _livreurProfile == null
                            ? null
                            : () => _makeWhatsAppCall(_livreurProfile!.phone),
                        icon: const Icon(Icons.call),
                        label: const Text('Call on WhatsApp'),
                      ),
                    ],
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
