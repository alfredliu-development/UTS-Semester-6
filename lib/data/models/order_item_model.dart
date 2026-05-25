class OrderItemModel {
  final int? id;
  final int orderId;
  final int productId;
  final String productName;
  final double price;
  final int quantity;
  final String unit;

  const OrderItemModel({
    this.id,
    required this.orderId,
    required this.productId,
    required this.productName,
    required this.price,
    required this.quantity,
    this.unit = 'pcs',
  });

  double get subtotal => price * quantity;

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'order_id': orderId,
      'product_id': productId,
      'product_name': productName,
      'price': price,
      'quantity': quantity,
      'unit': unit,
    };
  }

  factory OrderItemModel.fromMap(Map<String, dynamic> map) {
    return OrderItemModel(
      id: map['id'] as int?,
      orderId: map['order_id'] as int,
      productId: map['product_id'] as int,
      productName: map['product_name'] as String,
      price: (map['price'] as num).toDouble(),
      quantity: map['quantity'] as int,
      unit: map['unit'] as String? ?? 'pcs',
    );
  }
}
