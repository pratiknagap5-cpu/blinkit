import 'dart:convert';

class OrderItemModel {
  final int productId;
  final String name;
  final double price;
  final int quantity;

  OrderItemModel({
    required this.productId,
    required this.name,
    required this.price,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'productId': productId,
      'name': name,
      'price': price,
      'quantity': quantity,
    };
  }

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      productId: map['productId'],
      name: map['name'],
      price: map['price'],
      quantity: map['quantity'],
    );
  }
}

class OrderModel {
  final int? id;
  final String date;
  final double totalAmount;
  final String address;
  final List<OrderItemModel> items;

  OrderModel({
    this.id,
    required this.date,
    required this.totalAmount,
    required this.address,
    required this.items,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'date': date,
      'totalAmount': totalAmount,
      'address': address,
      'items': jsonEncode(items.map((e) => e.toMap()).toList()),
    };
  }

  factory OrderModel.fromMap(Map<String, dynamic> map) {
    var itemsList = jsonDecode(map['items']) as List;
    return OrderModel(
      id: map['id'],
      date: map['date'],
      totalAmount: map['totalAmount'],
      address: map['address'],
      items: itemsList.map((e) => OrderItemModel.fromMap(e)).toList(),
    );
  }
}
