import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';
import '../../providers/cart_provider.dart';
import '../../providers/address_provider.dart';
import '../../providers/order_provider.dart';
import '../../models/order_model.dart';
import '../../services/location_service.dart';
import '../../theme.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key});

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final MapController _mapController = MapController();
  LatLng _selectedLocation = const LatLng(28.6139, 77.2090); // Default Delhi
  final TextEditingController _addressController = TextEditingController();
  bool _isPlacingOrder = false;
  bool _isLocating = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final addressProvider = Provider.of<AddressProvider>(context, listen: false);
      if (addressProvider.currentPosition != null) {
        _setMarkerAndAddress(
          LatLng(addressProvider.currentPosition!.latitude, addressProvider.currentPosition!.longitude),
          addressProvider.currentAddress,
        );
      } else {
        _useCurrentLocation();
      }
    });
  }

  void _setMarkerAndAddress(LatLng location, String address) {
    setState(() {
      _selectedLocation = location;
      _addressController.text = address;
    });
    _mapController.move(location, 16);
  }

  Future<void> _useCurrentLocation() async {
    setState(() => _isLocating = true);
    final addressProvider = Provider.of<AddressProvider>(context, listen: false);
    await addressProvider.fetchCurrentLocation();
    
    if (addressProvider.currentPosition != null) {
      _setMarkerAndAddress(
        LatLng(addressProvider.currentPosition!.latitude, addressProvider.currentPosition!.longitude),
        addressProvider.currentAddress,
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Failed to get location')));
    }
    setState(() => _isLocating = false);
  }

  Future<void> _handleMapTap(TapPosition tapPosition, LatLng point) async {
    setState(() {
      _selectedLocation = point;
      _addressController.text = "Fetching address...";
    });
    
    final address = await LocationService().getAddressFromLatLng(
      Position(
        latitude: point.latitude,
        longitude: point.longitude,
        timestamp: DateTime.now(),
        accuracy: 0,
        altitude: 0,
        heading: 0,
        speed: 0,
        speedAccuracy: 0,
        altitudeAccuracy: 0,
        headingAccuracy: 0,
      )
    );
    
    setState(() {
      _addressController.text = address;
    });
  }

  Future<void> _placeOrder() async {
    final cart = Provider.of<CartProvider>(context, listen: false);
    final orderProvider = Provider.of<OrderProvider>(context, listen: false);

    if (_addressController.text.trim().isEmpty || _addressController.text == "Fetching address...") {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a valid address')));
      return;
    }

    setState(() {
      _isPlacingOrder = true;
    });

    final items = cart.cartItems.map((item) => OrderItemModel(
      productId: item.productId,
      name: item.name,
      price: item.price,
      quantity: item.quantity,
    )).toList();

    final order = OrderModel(
      date: DateTime.now().toString(),
      totalAmount: cart.totalAmount,
      address: _addressController.text,
      items: items,
    );

    await orderProvider.placeOrder(order);

    setState(() {
      _isPlacingOrder = false;
    });

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Order Placed Successfully!'),
        content: const Text('Your order has been placed and will be delivered shortly.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
            },
            child: const Text('Go to Home', style: TextStyle(color: AppTheme.successColor)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pushNamedAndRemoveUntil(context, '/orders', (route) => false);
            },
            child: const Text('View Orders', style: TextStyle(color: AppTheme.textDark)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: const Text('Checkout'),
        elevation: 0,
      ),
      body: Column(
        children: [
          // Top Section: Flutter Map
          SizedBox(
            height: 300,
            child: Stack(
              children: [
                FlutterMap(
                  mapController: _mapController,
                  options: MapOptions(
                    initialCenter: _selectedLocation,
                    initialZoom: 16,
                    onTap: _handleMapTap,
                  ),
                  children: [
                    TileLayer(
                      urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                      userAgentPackageName: 'com.example.blinkitclone',
                    ),
                    MarkerLayer(
                      markers: [
                        Marker(
                          point: _selectedLocation,
                          width: 80,
                          height: 80,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 40,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                Positioned(
                  bottom: 20,
                  right: 20,
                  child: FloatingActionButton(
                    heroTag: "btn_loc",
                    backgroundColor: AppTheme.primaryColor,
                    onPressed: _isLocating ? null : _useCurrentLocation,
                    child: _isLocating 
                      ? const CircularProgressIndicator(color: Colors.black, strokeWidth: 2)
                      : const Icon(Icons.my_location, color: Colors.black),
                  ),
                )
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Delivery Address',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: TextField(
                      controller: _addressController,
                      maxLines: 2,
                      style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Select on map or enter here',
                        hintStyle: TextStyle(color: AppTheme.textLight, fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  
                  // Summary
                  const Text(
                    'Order Summary',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                  ),
                  const SizedBox(height: 12),
                  Consumer<CartProvider>(
                    builder: (context, cart, child) {
                      return Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: Colors.grey[200]!),
                        ),
                        child: Column(
                          children: [
                            _buildSummaryRow('Item Total', '₹${cart.totalAmount.toStringAsFixed(2)}'),
                            const SizedBox(height: 12),
                            _buildSummaryRow('Delivery Fee', 'FREE', isSuccess: true),
                            const Divider(height: 32),
                            _buildSummaryRow('Grand Total', '₹${cart.totalAmount.toStringAsFixed(2)}', isBold: true),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomSheet: Container(
        padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
        decoration: BoxDecoration(
          color: Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: _isPlacingOrder ? null : _placeOrder,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryColor,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: 0,
            ),
            child: _isPlacingOrder
                ? const SizedBox(
                    height: 24,
                    width: 24,
                    child: CircularProgressIndicator(color: Colors.black, strokeWidth: 2),
                  )
                : const Text(
                    'PLACE ORDER',
                    style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18),
                  ),
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false, bool isSuccess = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: isBold ? AppTheme.textDark : AppTheme.textLight,
            fontWeight: isBold ? FontWeight.w900 : FontWeight.w500,
            fontSize: isBold ? 18 : 15,
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: isSuccess ? AppTheme.successColor : AppTheme.textDark,
            fontWeight: isBold || isSuccess ? FontWeight.w900 : FontWeight.w600,
            fontSize: isBold ? 18 : 15,
          ),
        ),
      ],
    );
  }
}
