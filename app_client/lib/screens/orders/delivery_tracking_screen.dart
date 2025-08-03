import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:app_client/models/order.dart';

class DeliveryTrackingScreen extends StatefulWidget {
  final Order order;

  const DeliveryTrackingScreen({super.key, required this.order});

  @override
  DeliveryTrackingScreenState createState() => DeliveryTrackingScreenState();
}

class DeliveryTrackingScreenState extends State<DeliveryTrackingScreen> {
  // TODO: Implement live location tracking of the delivery person
  static const LatLng _deliveryPersonLocation = LatLng(36.81897, 10.16579);

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
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement phone call functionality
                      },
                      icon: const Icon(Icons.phone),
                      label: const Text('Call Driver'),
                    ),
                    ElevatedButton.icon(
                      onPressed: () {
                        // TODO: Implement WhatsApp messaging functionality
                      },
                      icon: const Icon(Icons.message),
                      label: const Text('Message on WhatsApp'),
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
