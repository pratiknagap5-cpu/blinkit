import 'package:flutter/material.dart';
import '../models/cart_item_model.dart';
import '../models/product_model.dart';
import '../database/db_helper.dart';

class CartProvider with ChangeNotifier {
  List<CartItemModel> _cartItems = [];
  bool _isLoading = false;

  List<CartItemModel> get cartItems => _cartItems;
  bool get isLoading => _isLoading;

  double get totalAmount {
    return _cartItems.fold(0, (sum, item) => sum + (item.price * item.quantity));
  }

  Future<void> fetchCart() async {
    _isLoading = true;
    notifyListeners();
    try {
      _cartItems = await DatabaseHelper.instance.readAllCartItems();
    } catch (e) {
      print("Error fetching cart: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(ProductModel product) async {
    final item = CartItemModel(
      productId: product.id!,
      name: product.name,
      image: product.image,
      price: product.price,
      quantity: 1,
    );
    await DatabaseHelper.instance.insertCartItem(item);
    await fetchCart();
  }

  Future<void> updateQuantity(int productId, int quantity) async {
    if (quantity <= 0) {
      await DatabaseHelper.instance.deleteCartItem(productId);
    } else {
      await DatabaseHelper.instance.updateCartItemQuantity(productId, quantity);
    }
    await fetchCart();
  }

  Future<void> removeFromCart(int productId) async {
    await DatabaseHelper.instance.deleteCartItem(productId);
    await fetchCart();
  }

  Future<void> clearCart() async {
    await DatabaseHelper.instance.clearCart();
    await fetchCart();
  }

  int getQuantity(int productId) {
    try {
      final item = _cartItems.firstWhere((element) => element.productId == productId);
      return item.quantity;
    } catch (e) {
      return 0;
    }
  }
}
