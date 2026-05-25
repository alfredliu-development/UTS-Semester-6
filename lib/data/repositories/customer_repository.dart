import '../database/app_database.dart';
import '../models/customer_model.dart';

class CustomerRepository {
  final AppDatabase _db = AppDatabase.instance;

  Future<List<CustomerModel>> getAll() async {
    final db = await _db.database;
    final result = await db.query('customers', orderBy: 'name ASC');
    return result.map((e) => CustomerModel.fromMap(e)).toList();
  }

  Future<List<CustomerModel>> search(String query) async {
    final db = await _db.database;
    final result = await db.query(
      'customers',
      where: 'name LIKE ? OR address LIKE ? OR phone LIKE ?',
      whereArgs: ['%$query%', '%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
    return result.map((e) => CustomerModel.fromMap(e)).toList();
  }

  Future<CustomerModel?> getById(int id) async {
    final db = await _db.database;
    final result = await db.query(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (result.isEmpty) return null;
    return CustomerModel.fromMap(result.first);
  }

  Future<int> updateVisitStatus(int id, bool isVisited) async {
    final db = await _db.database;
    return await db.update(
      'customers',
      {'is_visited': isVisited ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> getTotalVisited() async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT COUNT(*) as count FROM customers WHERE is_visited = 1',
    );
    return result.first['count'] as int? ?? 0;
  }
}
