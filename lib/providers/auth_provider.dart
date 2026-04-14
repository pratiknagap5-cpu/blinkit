import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../models/user_model.dart';
import '../database/db_helper.dart';

class AuthProvider with ChangeNotifier {
  UserModel? _currentUser;
  bool _isLoading = false;

  UserModel? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isAuthenticated => _currentUser != null;

  AuthProvider() {
    autoLogin();
  }

  Future<void> autoLogin() async {
    debugPrint('Auth: Attempting auto-login...');
    final prefs = await SharedPreferences.getInstance();
    if (prefs.containsKey('user_data')) {
      final userData = json.decode(prefs.getString('user_data')!);
      _currentUser = UserModel.fromMap(userData);
      debugPrint('Auth: Auto-login successful for ${ _currentUser?.phone}');
      notifyListeners();
    } else {
      debugPrint('Auth: No saved session found.');
    }
  }

  Future<void> login(String phone, String password) async {
    debugPrint('Auth: Login attempt for phone: $phone');
    _isLoading = true;
    notifyListeners();

    try {
      _currentUser = await DatabaseHelper.instance.loginUser(phone, password);
      if (_currentUser != null) {
        debugPrint('Auth: Login successful for ${ _currentUser?.name}');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', json.encode(_currentUser!.toMap()));
      } else {
        debugPrint('Auth: Login failed - invalid credentials.');
      }
    } catch (e) {
      debugPrint('Auth: Login error: $e');
      _currentUser = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<bool> signup(UserModel user) async {
    debugPrint('Auth: Signup attempt for phone: ${user.phone}');
    _isLoading = true;
    notifyListeners();

    try {
      int id = await DatabaseHelper.instance.createUser(user);
      if (id > 0) {
        _currentUser = UserModel(
          id: id,
          name: user.name,
          email: user.email,
          phone: user.phone,
          password: user.password,
        );
        debugPrint('Auth: Signup successful, user ID: $id');
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('user_data', json.encode(_currentUser!.toMap()));
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        debugPrint('Auth: Signup failed (database returned 0)');
      }
    } catch (e) {
      debugPrint("Auth: Signup Error: $e");
    }
    
    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<void> logout() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('user_data');
    notifyListeners();
  }
}
