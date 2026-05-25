import 'package:flutter_bloc/flutter_bloc.dart';

import '../../data/models/cart_item_model.dart';
import '../../data/models/customer_model.dart';
import '../../data/models/order_item_model.dart';
import '../../data/models/order_model.dart';
import '../../data/repositories/order_repository.dart';
import 'order_state.dart';

class OrderCubit extends Cubit<OrderState> {
  final OrderRepository _repository;

  OrderCubit({OrderRepository? repository})
    : _repository = repository ?? OrderRepository(),
      super(OrderInitial());

  Future<void> loadOrders() async {
    emit(OrderLoading());

    try {
      final orders = await _repository.getAll();
      emit(OrderListLoaded(orders));
    } catch (e) {
      emit(OrderError('Gagal memuat riwayat order'));
    }
  }

  Future<void> loadOrderDetail(int orderId) async {
    emit(OrderLoading());

    try {
      final order = await _repository.getById(orderId);
      if (order == null) {
        emit(OrderError('Order tidak ditemukan'));
        return;
      }

      final items = await _repository.getItemsByOrderId(orderId);
      emit(OrderDetailLoaded(order: order, items: items));
    } catch (e) {
      emit(OrderError('Gagal memuat detail order'));
    }
  }

  Future<void> loadOrdersByCustomer(int customerId) async {
    emit(OrderLoading());

    try {
      final orders = await _repository.getByCustomerId(customerId);
      emit(OrderListLoaded(orders));
    } catch (e) {
      emit(OrderError('Gagal memuat order pelanggan'));
    }
  }

  Future<void> saveOrder({
    required CustomerModel customer,
    required List<CartItemModel> cartItems,
    required double totalAmount,
    String? notes,
  }) async {
    emit(OrderLoading());

    try {
      final order = OrderModel(
        customerId: customer.id!,
        customerName: customer.name,
        totalAmount: totalAmount,
        status: OrderStatus.draft,
        notes: notes,
        createdAt: DateTime.now(),
      );

      final orderItems = cartItems.map((cartItem) {
        return OrderItemModel(
          orderId: 0, // will be set in repository
          productId: cartItem.product.id!,
          productName: cartItem.product.name,
          price: cartItem.product.price,
          quantity: cartItem.quantity,
          unit: cartItem.product.unit,
        );
      }).toList();

      final orderId = await _repository.insert(order, orderItems);
      emit(OrderSaveSuccess(orderId));
    } catch (e) {
      emit(OrderError('Gagal menyimpan order'));
    }
  }

  Future<void> updateOrderStatus(int orderId, OrderStatus status) async {
    try {
      await _repository.updateStatus(orderId, status);
      await loadOrders();
    } catch (e) {
      emit(OrderError('Gagal mengubah status order'));
    }
  }
}
