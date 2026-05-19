import 'package:e_commerce_market/data/hash_password/security_hash.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AccountSQL {
  static final AccountSQL instance = AccountSQL._init();
  static Database? _database;

  AccountSQL._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await initDB("account.db");

    return _database!;
  }

  Future<Database> initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: createDB
    );
  }

  Future createDB(Database db, int version) async {
    await db.execute("""
      CREATE TABLE account(
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        email TEXT NOT NULL,
        password TEXT NOT NULL
      )
    """);
  }

  Future<int> register(String username, String email, String password) async {
    final db = await instance.database;

    final hashedEmail = SecurityHash.hashPassword(email);
    final hashPassword = SecurityHash.hashPassword(password);

    return await db.insert("accounts", {
      "username": username,
      "email": hashedEmail,
      "password": hashPassword
    });
  }
}