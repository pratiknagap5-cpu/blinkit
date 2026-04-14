import 'package:flutter/material.dart';
import '../models/product_model.dart';
import '../database/db_helper.dart';

class ProductProvider with ChangeNotifier {
  List<ProductModel> _products = [];
  bool _isLoading = false;
  String _searchQuery = '';
  String _selectedCategory = 'All';

  List<ProductModel> get products => _products;
  bool get isLoading => _isLoading;
  String get searchQuery => _searchQuery;
  String get selectedCategory => _selectedCategory;

  List<ProductModel> get filteredProducts {
    List<ProductModel> filtered = _products;

    if (_selectedCategory != 'All') {
      filtered = filtered.where((p) => p.category == _selectedCategory).toList();
    }

    if (_searchQuery.isNotEmpty) {
      filtered = filtered.where((p) => 
        p.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        p.category.toLowerCase().contains(_searchQuery.toLowerCase()) ||
        p.description.toLowerCase().contains(_searchQuery.toLowerCase())
      ).toList();
    }

    return filtered;
  }

  void setSearchQuery(String query) {
    _searchQuery = query;
    notifyListeners();
  }

  void setSelectedCategory(String category) {
    _selectedCategory = category;
    notifyListeners();
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedCategory = 'All';
    notifyListeners();
  }

  Future<void> fetchProducts() async {
    _isLoading = true;
    notifyListeners();

    try {
      _products = await DatabaseHelper.instance.readAllProducts();
      if (_products.isEmpty) {
        _products = _getFallbackProducts();
      }
    } catch (e) {
      print("Error fetching products: $e. Falling back to Demo Products.");
      _products = _getFallbackProducts();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  List<ProductModel> _getFallbackProducts() {
    return [
      ProductModel(id: 1, name: 'Amul Taaza Milk (1L)', image: 'https://images.pexels.com/photos/248412/pexels-photo-248412.jpeg?auto=compress&cs=tinysrgb&w=600', price: 54.0, category: 'Dairy', description: 'Fresh toned milk from Amul.', stock: 50),
      ProductModel(id: 2, name: 'Amul Butter (100g)', image: 'https://images.pexels.com/photos/1435706/pexels-photo-1435706.jpeg?auto=compress&cs=tinysrgb&w=600', price: 56.0, category: 'Dairy', description: 'Utterly butterly delicious butter.', stock: 40),
      ProductModel(id: 3, name: 'Sandwich Bread', image: 'https://images.pexels.com/photos/1775043/pexels-photo-1775043.jpeg?auto=compress&cs=tinysrgb&w=600', price: 45.0, category: 'Dairy', description: 'Soft milk bread for breakfast.', stock: 25),
      ProductModel(id: 4, name: 'Royal Gala Apple', image: 'https://images.pexels.com/photos/1510392/pexels-photo-1510392.jpeg?auto=compress&cs=tinysrgb&w=600', price: 120.0, category: 'Fruits', description: 'Sweet and crunchy gala apples.', stock: 40),
      ProductModel(id: 5, name: 'Fresh Banana (1 kg)', image: 'https://images.pexels.com/photos/1093038/pexels-photo-1093038.jpeg?auto=compress&cs=tinysrgb&w=600', price: 65.0, category: 'Fruits', description: 'Fresh energy-packed bananas.', stock: 55),
      ProductModel(id: 6, name: 'Fresh Tomato (500g)', image: 'https://images.pexels.com/photos/533280/pexels-photo-533280.jpeg?auto=compress&cs=tinysrgb&w=600', price: 30.0, category: 'Vegetables', description: 'Fresh red hybrid tomatoes.', stock: 100),
      ProductModel(id: 7, name: 'Basmati Rice (1kg)', image: 'https://images.pexels.com/photos/4110251/pexels-photo-4110251.jpeg?auto=compress&cs=tinysrgb&w=600', price: 110.0, category: 'Grocery', description: 'Aromatic premium basmati rice.', stock: 80),
      ProductModel(id: 8, name: 'Potato Chips (50g)', image: 'https://images.unsplash.com/photo-1566478989037-eec170784d0b?q=80&w=600&auto=format&fit=crop', price: 20.0, category: 'Snacks', description: 'Classic salted potato chips.', stock: 200),
      ProductModel(id: 9, name: 'Soft Drink (750ml)', image: 'https://images.pexels.com/photos/50593/coca-cola-cold-drink-soft-drink-coke-50593.jpeg?auto=compress&cs=tinysrgb&w=600', price: 45.0, category: 'Beverages', description: 'Refreshing cold drink.', stock: 100),
    ];
  }

  List<ProductModel> getProductsByCategory(String category) {
    return _products.where((p) => p.category == category).toList();
  }
}
