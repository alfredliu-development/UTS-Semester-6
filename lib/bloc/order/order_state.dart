import '../../data/models/order_item_model.dart';
import '../../data/models/order_model.dart';

abstract class OrderState {}

class OrderInitial extends OrderState {}

class OrderLoading extends OrderState {}

class OrderListLoaded extends OrderState {
  final List<OrderModel> orders;

  OrderListLoaded(this.orders);
}

class OrderDetailLoaded extends OrderState {
  final OrderModel order;
  final List<OrderItemModel> items;

  OrderDetailLoaded({required this.order, required this.items});
}

class OrderSaveSuccess extends OrderState {
  final int orderId;
  OrderSaveSuccess(this.orderId);
}

class OrderError extends OrderState {
  final String message;
  OrderError(this.message);
}
