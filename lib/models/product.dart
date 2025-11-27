import 'dart:convert';

class Product {
  int? id;
  String name;
  String? barcode;
  int categoryId;
  int? brandId;
  String? model;
  int stock;
  double purchasePrice;
  double salePrice;
  String? imagePath;
  String? description;
  String createdAt;
  String updatedAt;

  Product({
    this.id,
    required this.name,
    this.barcode,
    required this.categoryId,
    this.brandId,
    this.model,
    required this.stock,
    required this.purchasePrice,
    required this.salePrice,
    this.imagePath,
    this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  factory Product.fromMap(Map<String, dynamic> map) => Product(
    id: map['id'] as int?,
    name: map['name'] as String,
    barcode: map['barcode'] as String?,
    categoryId: map['category_id'] as int,
    brandId: map['brand_id'] as int?,
    model: map['model'] as String?,
    stock: map['stock'] as int,
    purchasePrice: (map['purchase_price'] as num).toDouble(),
    salePrice: (map['sale_price'] as num).toDouble(),
    imagePath: map['image_path'] as String?,
    description: map['description'] as String?,
    createdAt: map['created_at'] as String,
    updatedAt: map['updated_at'] as String,
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'barcode': barcode,
    'category_id': categoryId,
    'brand_id': brandId,
    'model': model,
    'stock': stock,
    'purchase_price': purchasePrice,
    'sale_price': salePrice,
    'image_path': imagePath,
    'description': description,
    'created_at': createdAt,
    'updated_at': updatedAt,
  };

  String toJson() => json.encode(toMap());
}
