import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:sqflite_common_ffi_web/sqflite_ffi_web.dart';
import '../models/user_model.dart';
import '../models/product_model.dart';
import '../models/cart_item_model.dart';
import '../models/order_model.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;

    if (kIsWeb) {
      databaseFactory = databaseFactoryFfiWeb;
    }

    _database = await _initDB('blinkit_clone.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 8,
      onCreate: _createDB,
      onUpgrade: (db, oldVersion, newVersion) async {
        await db.execute('DROP TABLE IF EXISTS users');
        await db.execute('DROP TABLE IF EXISTS products');
        await db.execute('DROP TABLE IF EXISTS cart');
        await db.execute('DROP TABLE IF EXISTS orders');
        await _createDB(db, newVersion);
      },
    );
  }

  Future _createDB(Database db, int version) async {
    const idType = 'INTEGER PRIMARY KEY AUTOINCREMENT';
    const textType = 'TEXT NOT NULL';
    const realType = 'REAL NOT NULL';
    const integerType = 'INTEGER NOT NULL';

    await db.execute('''
CREATE TABLE users (
  id $idType,
  name $textType,
  email $textType,
  phone $textType UNIQUE,
  password $textType
)
''');

    await db.execute('''
CREATE TABLE products (
  id $idType,
  name $textType,
  image $textType,
  price $realType,
  category $textType,
  description $textType,
  stock $integerType
)
''');

    await db.execute('''
CREATE TABLE cart (
  id $idType,
  productId $integerType,
  name $textType,
  price $realType,
  image $textType,
  quantity $integerType
)
''');

    await db.execute('''
CREATE TABLE orders (
  id $idType,
  totalPrice $realType,
  status $textType,
  orderDate $textType,
  items $textType
)
''');

    await _seedProducts(db);
  }

  Future _seedProducts(Database db) async {
    final List<Map<String, dynamic>> initialProducts = [
      // Dairy
      {
        'name': 'Amul Taaza Milk (1L)',
        'image': 'https://images.pexels.com/photos/248412/pexels-photo-248412.jpeg?auto=compress&cs=tinysrgb&w=600',
        'price': 54.0,
        'category': 'Dairy',
        'description': 'Fresh toned milk from Amul.',
        'stock': 50,
      },
      {
        'name': 'Amul Butter (100g)',
        'image': 'https://images.pexels.com/photos/1435706/pexels-photo-1435706.jpeg?auto=compress&cs=tinysrgb&w=600',
        'price': 56.0,
        'category': 'Dairy',
        'description': 'Utterly butterly delicious butter.',
        'stock': 40,
      },
      {
        'name': 'Sandwich Bread',
        'image': 'https://images.pexels.com/photos/1775043/pexels-photo-1775043.jpeg?auto=compress&cs=tinysrgb&w=600',
        'price': 45.0,
        'category': 'Dairy',
        'description': 'Soft milk bread for breakfast.',
        'stock': 25,
      },
      {
        'name': 'White Eggs (12 pcs)',
        'image': 'https://images.pexels.com/photos/162712/egg-white-food-protein-162712.jpeg?auto=compress&cs=tinysrgb&w=600',
        'price': 90.0,
        'category': 'Dairy',
        'description': 'Farm fresh large white eggs.',
        'stock': 30,
      },

      // Fruits
      {
        'name': 'Royal Gala Apple',
        'image': 'https://images.pexels.com/photos/1510392/pexels-photo-1510392.jpeg?auto=compress&cs=tinysrgb&w=600',
        'price': 120.0,
        'category': 'Fruits',
        'description': 'Sweet and crunchy gala apples.',
        'stock': 40,
      },
      {
        'name': 'Fresh Banana (1 kg)',
        'image': 'https://images.pexels.com/photos/1093038/pexels-photo-1093038.jpeg?auto=compress&cs=tinysrgb&w=600',
        'price': 65.0,
        'category': 'Fruits',
        'description': 'Fresh energy-packed bananas.',
        'stock': 55,
      },

      // Vegetables
      {
        'name': 'Fresh Tomato (500g)',
        'image': 'https://images.pexels.com/photos/533280/pexels-photo-533280.jpeg?auto=compress&cs=tinysrgb&w=600',
        'price': 30.0,
        'category': 'Vegetables',
        'description': 'Fresh red hybrid tomatoes.',
        'stock': 100,
      },
      {
        'name': 'Large Potato (1 kg)',
        'image': 'https://images.pexels.com/photos/2286776/pexels-photo-2286776.jpeg?auto=compress&cs=tinysrgb&w=600',
        'price': 40.0,
        'category': 'Vegetables',
        'description': 'Premium large potatoes.',
        'stock': 150,
      },
      {
        'name': 'Red Onion (1 kg)',
        'image': 'https://images.pexels.com/photos/175845/pexels-photo-175845.jpeg?auto=compress&cs=tinysrgb&w=600',
        'price': 35.0,
        'category': 'Vegetables',
        'description': 'Fresh onions for daily use.',
        'stock': 120,
      },

      // Grocery
      {
        'name': 'Basmati Rice (1kg)',
        'image': 'https://images.pexels.com/photos/4110251/pexels-photo-4110251.jpeg?auto=compress&cs=tinysrgb&w=600',
        'price': 110.0,
        'category': 'Grocery',
        'description': 'Aromatic premium basmati rice.',
        'stock': 80,
      },
      {
        'name': 'Wheat Atta (5kg)',
        'image': 'https://images.pexels.com/photos/5765/flour-food-kitchen-restaurant-5765.jpg?auto=compress&cs=tinysrgb&w=600',
        'price': 245.0,
        'category': 'Grocery',
        'description': 'Pure and healthy whole wheat flour.',
        'stock': 60,
      },
      {
        'name': 'Sunflower Oil (1L)',
        'image': 'https://images.pexels.com/photos/33783/olive-oil-salad-dressing-cooking-olive.jpg?auto=compress&cs=tinysrgb&w=600',
        'price': 145.0,
        'category': 'Grocery',
        'description': 'Refined sunflower oil for cooking.',
        'stock': 100,
      },

      // Snacks
      {
        'name': 'Potato Chips (50g)',
        'image': 'https://images.unsplash.com/photo-1566478989037-eec170784d0b?q=80&w=600&auto=format&fit=crop',
        'price': 20.0,
        'category': 'Snacks',
        'description': 'Classic salted potato chips.',
        'stock': 200,
      },
      {
        'name': 'Cashew Biscuits',
        'image': 'https://images.unsplash.com/photo-1558961363-fa8fdf82db35?q=80&w=600&auto=format&fit=crop',
        'price': 30.0,
        'category': 'Snacks',
        'description': 'Buttery cashew biscuits.',
        'stock': 150,
      },

      // Beverages
      {
        'name': 'Soft Drink (750ml)',
        'image': 'https://images.pexels.com/photos/50593/coca-cola-cold-drink-soft-drink-coke-50593.jpeg?auto=compress&cs=tinysrgb&w=600',
        'price': 45.0,
        'category': 'Beverages',
        'description': 'Refreshing cold drink.',
        'stock': 100,
      },
      {
        'name': 'Pepsi (750ml)',
        'image': 'https://images.pexels.com/photos/2668308/pexels-photo-2668308.jpeg?auto=compress&cs=tinysrgb&w=600',
        'price': 45.0,
        'category': 'Beverages',
        'description': 'Cola flavored cold drink.',
        'stock': 100,
      }
    ];

    for (var product in initialProducts) {
      await db.insert('products', product);
    }
  }

  // User Methods
  Future<int> createUser(UserModel user) async {
    final db = await instance.database;
    return await db.insert('users', user.toMap());
  }

  Future<UserModel?> loginUser(String phone, String password) async {
    final db = await instance.database;
    final maps = await db.query(
      'users',
      columns: ['id', 'name', 'email', 'phone', 'password'],
      where: 'phone = ? AND password = ?',
      whereArgs: [phone, password],
    );

    if (maps.isNotEmpty) {
      return UserModel.fromMap(maps.first);
    } else {
      return null;
    }
  }

  // Product Methods
  Future<List<ProductModel>> readAllProducts() async {
    final db = await instance.database;
    final result = await db.query('products');
    return result.map((json) => ProductModel.fromMap(json)).toList();
  }

  // Cart Methods
  Future<int> insertCartItem(CartItemModel item) async {
    final db = await instance.database;
    final existing = await db.query('cart', where: 'productId = ?', whereArgs: [item.productId]);
    if (existing.isNotEmpty) {
      int currentQty = existing.first['quantity'] as int;
      return await db.update('cart', {'quantity': currentQty + 1}, where: 'productId = ?', whereArgs: [item.productId]);
    }
    return await db.insert('cart', item.toMap());
  }

  Future<int> updateCartItemQuantity(int productId, int quantity) async {
    final db = await instance.database;
    if (quantity <= 0) {
      return await db.delete('cart', where: 'productId = ?', whereArgs: [productId]);
    }
    return await db.update('cart', {'quantity': quantity}, where: 'productId = ?', whereArgs: [productId]);
  }

  Future<int> deleteCartItem(int productId) async {
    final db = await instance.database;
    return await db.delete('cart', where: 'productId = ?', whereArgs: [productId]);
  }

  Future<List<CartItemModel>> readAllCartItems() async {
    final db = await instance.database;
    final result = await db.query('cart');
    return result.map((json) => CartItemModel.fromMap(json)).toList();
  }

  Future<int> clearCart() async {
    final db = await instance.database;
    return await db.delete('cart');
  }

  // Order Methods
  Future<int> insertOrder(OrderModel order) async {
    final db = await instance.database;
    return await db.insert('orders', order.toMap());
  }

  Future<List<OrderModel>> readAllOrders() async {
    final db = await instance.database;
    final result = await db.query('orders', orderBy: 'id DESC');
    return result.map((json) => OrderModel.fromMap(json)).toList();
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
