import '../../data/models/cart_item_model.dart';

class CartState {
  final List<CartItemModel> items;

  const CartState({this.items = const []});

  double get totalAmount => items.fold(0.0, (sum, item) => sum + item.subtotal);

  int get totalItems => items.fold(0, (sum, item) => sum + item.quantity);

  bool get isEmpty => items.isEmpty;

  CartState copyWith({List<CartItemModel>? items}) {
    return CartState(items: items ?? this.items);
  }
}
