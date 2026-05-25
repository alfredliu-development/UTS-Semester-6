import 'product_model.dart';

class CartItemModel {
  final ProductModel product;
  final int quantity;

  const CartItemModel({required this.product, required this.quantity});

  double get subtotal => product.price * quantity;

  CartItemModel copyWith({ProductModel? product, int? quantity}) {
    return CartItemModel(
      product: product ?? this.product,
      quantity: quantity ?? this.quantity,
    );
  }
}
