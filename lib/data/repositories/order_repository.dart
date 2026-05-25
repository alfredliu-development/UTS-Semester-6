import '../database/app_database.dart';
import '../models/order_item_model.dart';
import '../models/order_model.dart';

class OrderRepository {
  final AppDatabase _db = AppDatabase.instance;

  Future<List<OrderModel>> getAll() async {
    final db = await _db.database;
    final result = await db.query('orders', orderBy: 'created_at DESC');
    return result.map((e) => OrderModel.fromMap(e)).toList();
  }

  Future<List<OrderModel>> getTodayOrders() async {
    final db = await _db.database;
    final today = DateTime.now();
    final startOfDay = DateTime(
      today.year,
      today.month,
      today.day,
    ).toIso8601String();
    final endOfDay = DateTime(
      today.year,
      today.month,
      today.day,
      23,
      59,
      59,
    ).toIso8601String();

    final result = await db.query(
      'orders',
      where: 'created_at >= ? AND created_at <= ?',
      whereArgs: [startOfDay, endOfDay],
      orderBy: 'created_at DESC',
    );
    return result.map((e) => OrderModel.fromMap(e)).toList();
  }

  Future<OrderModel?> getById(int id) async {
    final db = await _db.database;
    final result = await db.query('orders', where: 'id = ?', whereArgs: [id]);

    if (result.isEmpty) return null;
    return OrderModel.fromMap(result.first);
  }

  Future<List<OrderModel>> getByCustomerId(int customerId) async {
    final db = await _db.database;
    final result = await db.query(
      'orders',
      where: 'customer_id = ?',
      whereArgs: [customerId],
      orderBy: 'created_at DESC',
    );
    return result.map((e) => OrderModel.fromMap(e)).toList();
  }

  Future<int> insert(OrderModel order, List<OrderItemModel> items) async {
    final db = await _db.database;

    return await db.transaction((txn) async {
      final orderId = await txn.insert('orders', order.toMap()..remove('id'));

      for (final item in items) {
        await txn.insert('order_items', {
          ...item.toMap()..remove('id'),
          'order_id': orderId,
        });
      }

      return orderId;
    });
  }

  Future<int> updateStatus(int id, OrderStatus status) async {
    final db = await _db.database;
    return await db.update(
      'orders',
      {'status': status.value},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<OrderItemModel>> getItemsByOrderId(int orderId) async {
    final db = await _db.database;
    final result = await db.query(
      'order_items',
      where: 'order_id = ?',
      whereArgs: [orderId],
    );
    return result.map((e) => OrderItemModel.fromMap(e)).toList();
  }

  Future<double> getTodayTotalAmount() async {
    final db = await _db.database;
    final today = DateTime.now();
    final startOfDay = DateTime(
      today.year,
      today.month,
      today.day,
    ).toIso8601String();
    final endOfDay = DateTime(
      today.year,
      today.month,
      today.day,
      23,
      59,
      59,
    ).toIso8601String();

    final result = await db.rawQuery(
      'SELECT SUM(total_amount) as total FROM orders WHERE created_at >= ? AND created_at <= ?',
      [startOfDay, endOfDay],
    );

    return (result.first['total'] as num?)?.toDouble() ?? 0.0;
  }

  Future<int> getTodayOrderCount() async {
    final db = await _db.database;
    final today = DateTime.now();
    final startOfDay = DateTime(
      today.year,
      today.month,
      today.day,
    ).toIso8601String();
    final endOfDay = DateTime(
      today.year,
      today.month,
      today.day,
      23,
      59,
      59,
    ).toIso8601String();

    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM orders WHERE created_at >= ? AND created_at <= ?',
      [startOfDay, endOfDay],
    );

    return result.first['count'] as int? ?? 0;
  }
}
