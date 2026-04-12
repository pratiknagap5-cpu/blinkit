class ProductModel {
  final int? id;
  final String name;
  final String image;
  final double price;
  final String category;
  final String description;
  final int stock;

  ProductModel({
    this.id,
    required this.name,
    required this.image,
    required this.price,
    required this.category,
    required this.description,
    required this.stock,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'image': image,
      'price': price,
      'category': category,
      'description': description,
      'stock': stock,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'],
      name: map['name'],
      image: map['image'],
      price: map['price'],
      category: map['category'],
      description: map['description'],
      stock: map['stock'],
    );
  }
}
