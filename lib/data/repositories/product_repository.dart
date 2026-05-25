import '../database/app_database.dart';
import '../models/product_model.dart';

class ProductRepository {
  final AppDatabase _db = AppDatabase.instance;

  Future<List<ProductModel>> getAll() async {
    final db = await _db.database;
    final result = await db.query('products', orderBy: 'name ASC');
    return result.map((e) => ProductModel.fromMap(e)).toList();
  }

  Future<List<ProductModel>> search(String query) async {
    final db = await _db.database;
    final result = await db.query(
      'products',
      where: 'name LIKE ? OR category LIKE ?',
      whereArgs: ['%$query%', '%$query%'],
      orderBy: 'name ASC',
    );
    return result.map((e) => ProductModel.fromMap(e)).toList();
  }

  Future<List<ProductModel>> getByCategory(String category) async {
    final db = await _db.database;
    final result = await db.query(
      'products',
      where: 'category = ?',
      whereArgs: [category],
      orderBy: 'name ASC',
    );
    return result.map((e) => ProductModel.fromMap(e)).toList();
  }

  Future<ProductModel?> getById(int id) async {
    final db = await _db.database;
    final result = await db.query('products', where: 'id = ?', whereArgs: [id]);

    if (result.isEmpty) return null;
    return ProductModel.fromMap(result.first);
  }

  Future<List<String>> getCategories() async {
    final db = await _db.database;
    final result = await db.rawQuery(
      'SELECT DISTINCT category FROM products ORDER BY category ASC',
    );
    return result.map((e) => e['category'] as String).toList();
  }
}
