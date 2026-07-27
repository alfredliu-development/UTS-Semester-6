import '../api/api_service.dart';
import '../models/order_item_model.dart';
import '../models/order_model.dart';

class OrderRepository {
  final ApiService _api = ApiService.instance;

  Future<List<OrderModel>> getAll() async {
    try {
      final response = await _api.get('/orders');
      final List data = response.data as List;
      return data
          .map((e) => OrderModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } on ApiException {
      return [];
    }
  }

  Future<List<OrderModel>> getTodayOrders() async {
    try {
      final response = await _api.get('/orders/today');
      final List data = response.data as List;
      return data
          .map((e) => OrderModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } on ApiException {
      return [];
    }
  }

  Future<List<OrderModel>> getByCustomerId(int customerId) async {
    try {
      final response = await _api.get(
        '/orders',
        queryParameters: {'customer_id': customerId},
      );
      final List data = response.data as List;
      return data
          .map((e) => OrderModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } on ApiException {
      return [];
    }
  }

  Future<OrderModel?> getById(int id) async {
    try {
      final response = await _api.get('/orders/$id');
      if (response.data == null) return null;
      return OrderModel.fromMap(response.data as Map<String, dynamic>);
    } on ApiException {
      return null;
    } catch (_) {
      return null;
    }
  }

  /// Insert order baru. Mengembalikan ID order yang baru dibuat.
  /// Melempar [ApiException] jika gagal.
  Future<int> insert(OrderModel order, List<OrderItemModel> items) async {
    final response = await _api.post(
      '/orders',
      data: {
        'order': order.toMap()..remove('id'),
        'items': items.map((e) => e.toMap()..remove('id')).toList(),
      },
    );
    return (response.data['id'] as int?) ?? 0;
  }

  /// Update status order. Melempar [ApiException] jika gagal.
  Future<void> updateStatus(int id, OrderStatus status) async {
    await _api.put('/orders/$id/status', data: {'status': status.value});
  }

  Future<List<OrderItemModel>> getItemsByOrderId(int orderId) async {
    try {
      final response = await _api.get('/orders/$orderId/items');
      final List data = response.data as List;
      return data
          .map((e) => OrderItemModel.fromMap(e as Map<String, dynamic>))
          .toList();
    } on ApiException {
      return [];
    }
  }

  Future<double> getTodayTotalAmount() async {
    try {
      final response = await _api.get('/orders/stats/today-total');
      return (response.data['total'] as num?)?.toDouble() ?? 0.0;
    } on ApiException {
      return 0.0;
    }
  }

  Future<int> getTodayOrderCount() async {
    try {
      final response = await _api.get('/orders/stats/today-count');
      return (response.data['count'] as int?) ?? 0;
    } on ApiException {
      return 0;
    }
  }
}
