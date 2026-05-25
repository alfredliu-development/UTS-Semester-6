import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/cart_item_model.dart';
import '../../data/models/product_model.dart';
import 'cart_state.dart';

class CartCubit extends Cubit<CartState> {
  CartCubit() : super(const CartState());

  void addProduct(ProductModel product) {
    final items = List<CartItemModel>.from(state.items);
    final index = items.indexWhere((item) => item.product.id == product.id);

    if (index >= 0) {
      final existing = items[index];
      items[index] = existing.copyWith(quantity: existing.quantity + 1);
    } else {
      items.add(CartItemModel(product: product, quantity: 1));
    }

    emit(state.copyWith(items: items));
  }

  void increaseQuantity(int productId) {
    final items = List<CartItemModel>.from(state.items);
    final index = items.indexWhere((item) => item.product.id == productId);

    if (index >= 0) {
      final existing = items[index];
      items[index] = existing.copyWith(quantity: existing.quantity + 1);
      emit(state.copyWith(items: items));
    }
  }

  void decreaseQuantity(int productId) {
    final items = List<CartItemModel>.from(state.items);
    final index = items.indexWhere((item) => item.product.id == productId);

    if (index >= 0) {
      final existing = items[index];
      if (existing.quantity <= 1) {
        items.removeAt(index);
      } else {
        items[index] = existing.copyWith(quantity: existing.quantity - 1);
      }
      emit(state.copyWith(items: items));
    }
  }

  void removeProduct(int productId) {
    final items = state.items
        .where((item) => item.product.id != productId)
        .toList();
    emit(state.copyWith(items: items));
  }

  void clearCart() {
    emit(const CartState());
  }

  bool isProductInCart(int productId) {
    return state.items.any((item) => item.product.id == productId);
  }

  int getProductQuantity(int productId) {
    final item = state.items.firstWhere(
      (item) => item.product.id == productId,
      orElse: () => CartItemModel(
        product: ProductModel(
          id: -1,
          name: '',
          category: '',
          price: 0,
          stock: 0,
        ),
        quantity: 0,
      ),
    );
    return item.quantity;
  }
}
