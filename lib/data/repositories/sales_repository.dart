import '../../core/utils/hash_helper.dart';
import '../database/app_database.dart';
import '../models/sales_model.dart';

class SalesRepository {
  final AppDatabase _db = AppDatabase.instance;

  // ─── Login ───────────────────────────────────────────────────────────────

  Future<SalesModel?> login(String username, String password) async {
    final db = await _db.database;
    final hashed = HashHelper.hash(password);

    final result = await db.query(
      'sales',
      where: 'username = ? AND password = ?',
      whereArgs: [username, hashed],
    );

    if (result.isEmpty) return null;
    return SalesModel.fromMap(result.first);
  }

  // ─── Get by ID ────────────────────────────────────────────────────────────

  Future<SalesModel?> getById(int id) async {
    final db = await _db.database;
    final result = await db.query('sales', where: 'id = ?', whereArgs: [id]);

    if (result.isEmpty) return null;
    return SalesModel.fromMap(result.first);
  }

  // ─── Register ─────────────────────────────────────────────────────────────

  /// Throws [RegisterException] jika username atau email sudah digunakan.
  Future<SalesModel> register({
    required String username,
    required String email,
    required String password,
    required String fullName,
  }) async {
    final db = await _db.database;

    // Cek keunikan username
    final byUsername = await db.query(
      'sales',
      where: 'LOWER(username) = LOWER(?)',
      whereArgs: [username],
    );
    if (byUsername.isNotEmpty) {
      throw RegisterException('Username sudah digunakan');
    }

    // Cek keunikan email
    final byEmail = await db.query(
      'sales',
      where: 'LOWER(email) = LOWER(?)',
      whereArgs: [email],
    );
    if (byEmail.isNotEmpty) {
      throw RegisterException('Email sudah terdaftar');
    }

    final hashedPassword = HashHelper.hash(password);

    final id = await db.insert('sales', {
      'username': username,
      'email': email,
      'password': hashedPassword,
      'full_name': fullName,
      'role': 'sales',
    });

    return SalesModel(
      id: id,
      username: username,
      email: email,
      password: hashedPassword,
      fullName: fullName,
    );
  }

  // ─── Update Account ───────────────────────────────────────────────────────

  /// Update nama lengkap dan username.
  /// Throws [RegisterException] jika username baru sudah dipakai akun lain.
  Future<void> updateAccount({
    required int id,
    required String fullName,
    required String username,
  }) async {
    final db = await _db.database;

    // Cek keunikan username (kecuali milik sendiri)
    final byUsername = await db.query(
      'sales',
      where: 'LOWER(username) = LOWER(?) AND id != ?',
      whereArgs: [username, id],
    );
    if (byUsername.isNotEmpty) {
      throw RegisterException('Username sudah digunakan akun lain');
    }

    await db.update(
      'sales',
      {'full_name': fullName, 'username': username},
      where: 'id = ?',
      whereArgs: [id],
    );
  }
}

// ─── Exception ────────────────────────────────────────────────────────────────

class RegisterException implements Exception {
  final String message;
  RegisterException(this.message);

  @override
  String toString() => message;
}
