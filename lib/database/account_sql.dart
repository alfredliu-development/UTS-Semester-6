import 'dart:convert';

import 'package:crypto/crypto.dart';
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
      onCreate: createDB,
    );
  }

  Future createDB(Database db, int version) async {
    await db.execute("""
      CREATE TABLE account (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL,
        email TEXT NOT NULL,
        password TEXT NOT NULL
      )
    """
    );
  }

  String hashValue(String value) {
    var bytes = utf8.encode(value);
    var digest = sha256.convert(bytes);

    return digest.toString();
  }

  Future<int> register(String username, String email, String password) async {
    final db = await instance.database;

    final hashedEmail = hashValue(email);
    final hashPassword = hashValue(password);

    final result = await db.query(
      "account",
      where: "email = ?",
      whereArgs: [hashedEmail]
    );

    if (result.isNotEmpty) return -1;

    return await db.insert("account", {
      "username": username,
      "email": hashedEmail,
      "password": hashPassword
    });
  }

  Future<bool> login(String email, String password) async {
    final db = await instance.database;

    final hashedEmail = hashValue(email);
    final hashPassword = hashValue(password);

    final result = await db.query(
      "account",
      where: "email = ? AND password = ?",
      whereArgs: [hashedEmail, hashPassword]
    );

    return result.isNotEmpty;
  }
}