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
import 'package:lottie/lottie.dart' hide Marker;
import '../../models/address_model.dart';
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
  String _addressLabel = 'Home';
  bool _isPlacingOrder = false;
  bool _isLocating = false;
  bool _isSavingAddress = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final addressProvider = Provider.of<AddressProvider>(context, listen: false);
      addressProvider.fetchSavedAddresses();
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

    if (!mounted) return;

    setState(() {
      _isPlacingOrder = false;
    });

    _showOrderSuccess();
  }

  void _showOrderSuccess() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: Colors.white,
        insetPadding: const EdgeInsets.symmetric(horizontal: 20),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Lottie.network(
                'https://lottie.host/804d0263-8a3d-4c3e-8367-73bed46f7344/WvB2rYd7G1.json',
                width: 200,
                height: 200,
                repeat: false,
              ),
              const Text(
                'Order Placed!',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900),
              ),
              const SizedBox(height: 12),
              const Text(
                'Sit back and relax. Your items are being packed!',
                textAlign: TextAlign.center,
                style: TextStyle(color: AppTheme.textLight, fontSize: 14),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 54,
                child: ElevatedButton(
                  onPressed: () {
                    Provider.of<CartProvider>(context, listen: false).clearCart();
                    Navigator.pushNamedAndRemoveUntil(context, '/home', (route) => false);
                  },
                  child: const Text('GO TO HOME'),
                ),
              ),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () {
                  Provider.of<CartProvider>(context, listen: false).clearCart();
                  Navigator.pushNamedAndRemoveUntil(context, '/orders', (route) => false);
                },
                child: const Text('View My Orders', style: TextStyle(color: AppTheme.textDark, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _saveCurrentAddress() async {
    if (_addressController.text.isEmpty || _addressController.text == "Fetching address...") {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Please select a valid address first')));
      return;
    }

    setState(() => _isSavingAddress = true);
    final provider = Provider.of<AddressProvider>(context, listen: false);
    
    final newAddress = AddressModel(
      label: _addressLabel,
      address: _addressController.text,
      latitude: _selectedLocation.latitude,
      longitude: _selectedLocation.longitude,
    );

    await provider.addAddress(newAddress);
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Address saved successfully!')));
      setState(() => _isSavingAddress = false);
    }
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
                  // Saved Addresses
                  Consumer<AddressProvider>(
                    builder: (context, provider, child) {
                      if (provider.savedAddresses.isEmpty) return const SizedBox.shrink();
                      return Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Choose from Saved', style: TextStyle(color: AppTheme.textLight, fontSize: 13, fontWeight: FontWeight.bold)),
                          const SizedBox(height: 12),
                          SizedBox(
                            height: 100,
                            child: ListView.builder(
                              scrollDirection: Axis.horizontal,
                              itemCount: provider.savedAddresses.length,
                              itemBuilder: (context, index) {
                                final addr = provider.savedAddresses[index];
                                return GestureDetector(
                                  onTap: () {
                                    _setMarkerAndAddress(LatLng(addr.latitude, addr.longitude), addr.address);
                                    setState(() => _addressLabel = addr.label);
                                  },
                                  child: Container(
                                    width: 160,
                                    margin: const EdgeInsets.only(right: 12),
                                    padding: const EdgeInsets.all(12),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(16),
                                      border: Border.all(color: Colors.grey[200]!),
                                    ),
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(
                                              addr.label.toLowerCase() == 'home' ? Icons.home : Icons.work,
                                              size: 16,
                                              color: AppTheme.primaryColor,
                                            ),
                                            const SizedBox(width: 6),
                                            Text(addr.label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(addr.address, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          const SizedBox(height: 24),
                        ],
                      );
                    },
                  ),

                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.grey[50],
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: Colors.grey[200]!),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            _buildLabelChip('Home'),
                            const SizedBox(width: 8),
                            _buildLabelChip('Work'),
                            const SizedBox(width: 8),
                            _buildLabelChip('Other'),
                          ],
                        ),
                        const Divider(),
                        TextField(
                          controller: _addressController,
                          maxLines: 2,
                          style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            hintText: 'Select on map or enter here',
                            hintStyle: TextStyle(color: AppTheme.textLight, fontSize: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),
                  TextButton.icon(
                    onPressed: _isSavingAddress ? null : _saveCurrentAddress,
                    icon: _isSavingAddress 
                        ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                        : const Icon(Icons.bookmark_border, size: 20),
                    label: const Text('Save this address for later'),
                    style: TextButton.styleFrom(foregroundColor: AppTheme.primaryColor),
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
              color: Colors.black.withValues(alpha: 0.05),
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

  Widget _buildLabelChip(String label) {
    bool isSelected = _addressLabel == label;
    return GestureDetector(
      onTap: () => setState(() => _addressLabel = label),
      child: Chip(
        label: Text(label),
        labelStyle: TextStyle(
          color: isSelected ? Colors.black : Colors.grey,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          fontSize: 12,
        ),
        backgroundColor: isSelected ? AppTheme.primaryColor : Colors.white,
        side: BorderSide(color: isSelected ? AppTheme.primaryColor : Colors.grey[300]!),
        padding: EdgeInsets.zero,
        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
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
