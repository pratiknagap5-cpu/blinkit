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
      print("Error fetching cart (Running Demo Mode): $e");
      // Keep _cartItems as is for in-memory demo mode
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> addToCart(ProductModel product) async {
    try {
      final item = CartItemModel(
        productId: product.id!,
        name: product.name,
        image: product.image,
        price: product.price,
        quantity: 1,
      );
      await DatabaseHelper.instance.insertCartItem(item);
      await fetchCart();
    } catch (_) {
      // Demo Mode Web Fallback
      int idx = _cartItems.indexWhere((e) => e.productId == product.id);
      if (idx >= 0) {
        _cartItems[idx].quantity += 1;
      } else {
        _cartItems.add(CartItemModel(productId: product.id!, name: product.name, image: product.image, price: product.price, quantity: 1));
      }
      notifyListeners();
    }
  }

  Future<void> updateQuantity(int productId, int quantity) async {
    try {
      if (quantity <= 0) {
        await DatabaseHelper.instance.deleteCartItem(productId);
      } else {
        await DatabaseHelper.instance.updateCartItemQuantity(productId, quantity);
      }
      await fetchCart();
    } catch (_) {
      // Demo Mode Web Fallback
      int idx = _cartItems.indexWhere((e) => e.productId == productId);
      if (idx >= 0) {
        if (quantity <= 0) {
          _cartItems.removeAt(idx);
        } else {
          _cartItems[idx].quantity = quantity;
        }
      }
      notifyListeners();
    }
  }

  Future<void> removeFromCart(int productId) async {
    try {
      await DatabaseHelper.instance.deleteCartItem(productId);
      await fetchCart();
    } catch (_) {
      _cartItems.removeWhere((e) => e.productId == productId);
      notifyListeners();
    }
  }

  Future<void> clearCart() async {
    try {
      await DatabaseHelper.instance.clearCart();
      await fetchCart();
    } catch (_) {
      _cartItems.clear();
      notifyListeners();
    }
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
