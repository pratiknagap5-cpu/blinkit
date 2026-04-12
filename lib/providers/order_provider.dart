import 'package:flutter/material.dart';
import '../models/order_model.dart';
import '../database/db_helper.dart';

class OrderProvider with ChangeNotifier {
  List<OrderModel> _orders = [];
  bool _isLoading = false;

  List<OrderModel> get orders => _orders;
  bool get isLoading => _isLoading;

  Future<void> fetchOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      _orders = await DatabaseHelper.instance.readAllOrders();
    } catch (e) {
      print("Error fetching orders: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> placeOrder(OrderModel order) async {
    try {
      await DatabaseHelper.instance.insertOrder(order);
      await DatabaseHelper.instance.clearCart();
      await fetchOrders();
    } catch (e) {
      print("Error placing order: $e");
    }
  }
}
