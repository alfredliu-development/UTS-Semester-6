import '../database/app_database.dart';
import '../models/sales_model.dart';

class SalesRepository {
  final AppDatabase _db = AppDatabase.instance;

  Future<SalesModel?> login(String username, String password) async {
    final db = await _db.database;
    final result = await db.query(
      'sales',
      where: 'username = ? AND password = ?',
      whereArgs: [username, password],
    );

    if (result.isEmpty) return null;
    return SalesModel.fromMap(result.first);
  }

  Future<SalesModel?> getById(int id) async {
    final db = await _db.database;
    final result = await db.query('sales', where: 'id = ?', whereArgs: [id]);

    if (result.isEmpty) return null;
    return SalesModel.fromMap(result.first);
  }

  /// Returns the newly created [SalesModel] on success.
  /// Throws [RegisterException] if username or email already exists.
  Future<SalesModel> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
  }) async {
    final db = await _db.database;

    // Check username uniqueness
    final byUsername = await db.query(
      'sales',
      where: 'username = ?',
      whereArgs: [username],
    );
    if (byUsername.isNotEmpty) {
      throw RegisterException('Username sudah digunakan');
    }

    // Check email uniqueness
    final byEmail = await db.query(
      'sales',
      where: 'email = ?',
      whereArgs: [email],
    );
    if (byEmail.isNotEmpty) {
      throw RegisterException('Email sudah terdaftar');
    }

    final id = await db.insert('sales', {
      'username': username,
      'email': email,
      'password': password,
      'full_name': fullName,
      'role': 'sales',
    });

    return SalesModel(
      id: id,
      username: username,
      email: email,
      password: password,
      fullName: fullName,
    );
  }
}

class RegisterException implements Exception {
  final String message;
  RegisterException(this.message);

  @override
  String toString() => message;
}
