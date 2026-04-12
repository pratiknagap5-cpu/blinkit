import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../services/location_service.dart';

class AddressProvider with ChangeNotifier {
  String _currentAddress = "Locating...";
  Position? _currentPosition;
  bool _isLoading = false;
  final LocationService _locationService = LocationService();

  String get currentAddress => _currentAddress;
  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;

  Future<void> fetchCurrentLocation() async {
    _isLoading = true;
    _currentAddress = "Loading...";
    notifyListeners();

    try {
      _currentPosition = await _locationService.getCurrentLocation();
      if (_currentPosition != null) {
        _currentAddress = await _locationService.getAddressFromLatLng(_currentPosition!);
      } else {
        _currentAddress = "Location not available";
      }
    } catch (e) {
      _currentAddress = "Error: $e";
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void updateAddress(String newAddress) {
    _currentAddress = newAddress;
    notifyListeners();
  }
}
