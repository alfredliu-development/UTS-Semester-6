class ProductModel {
  final int? id;
  final String name;
  final String category;
  final double price;
  final int stock;
  final String unit;
  final String? description;

  const ProductModel({
    this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    this.unit = 'pcs',
    this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'price': price,
      'stock': stock,
      'unit': unit,
      'description': description,
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] as int?,
      name: map['name'] as String,
      category: map['category'] as String,
      price: (map['price'] as num).toDouble(),
      stock: map['stock'] as int,
      unit: map['unit'] as String? ?? 'pcs',
      description: map['description'] as String?,
    );
  }

  ProductModel copyWith({
    int? id,
    String? name,
    String? category,
    double? price,
    int? stock,
    String? unit,
    String? description,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      unit: unit ?? this.unit,
      description: description ?? this.description,
    );
  }
}
