import 'package:geolocator/geolocator.dart';
import '../models/address_model.dart';
import '../database/db_helper.dart';
import '../services/location_service.dart';

class AddressProvider with ChangeNotifier {
  String _currentAddress = "Locating...";
  Position? _currentPosition;
  bool _isLoading = false;
  List<AddressModel> _savedAddresses = [];
  final LocationService _locationService = LocationService();

  String get currentAddress => _currentAddress;
  Position? get currentPosition => _currentPosition;
  bool get isLoading => _isLoading;
  List<AddressModel> get savedAddresses => _savedAddresses;

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

  Future<void> fetchSavedAddresses() async {
    final result = await DatabaseHelper.instance.readAllAddresses();
    _savedAddresses = result.map((json) => AddressModel.fromMap(json)).toList();
    notifyListeners();
  }

  Future<void> addAddress(AddressModel address) async {
    await DatabaseHelper.instance.insertAddress(address.toMap());
    await fetchSavedAddresses();
  }

  Future<void> deleteAddress(int id) async {
    await DatabaseHelper.instance.deleteAddress(id);
    await fetchSavedAddresses();
  }
}
