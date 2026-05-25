import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

class AppDatabase {
  static final AppDatabase instance = AppDatabase._init();
  static Database? _database;

  AppDatabase._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('sales_order.db');
    return _database!;
  }

  Future<Database> _initDB(String fileName) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, fileName);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Add email column to sales table
      await db.execute(
        "ALTER TABLE sales ADD COLUMN email TEXT NOT NULL DEFAULT ''",
      );
    }
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE sales (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        username TEXT NOT NULL UNIQUE,
        email TEXT NOT NULL DEFAULT '',
        password TEXT NOT NULL,
        full_name TEXT NOT NULL,
        role TEXT NOT NULL DEFAULT 'sales'
      )
    ''');

    await db.execute('''
      CREATE TABLE customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        address TEXT NOT NULL,
        phone TEXT NOT NULL,
        is_visited INTEGER NOT NULL DEFAULT 0,
        notes TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE products (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name TEXT NOT NULL,
        category TEXT NOT NULL,
        price REAL NOT NULL,
        stock INTEGER NOT NULL,
        unit TEXT NOT NULL DEFAULT 'pcs',
        description TEXT
      )
    ''');

    await db.execute('''
      CREATE TABLE orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER NOT NULL,
        customer_name TEXT NOT NULL,
        total_amount REAL NOT NULL,
        status TEXT NOT NULL DEFAULT 'draft',
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (customer_id) REFERENCES customers(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE order_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER NOT NULL,
        product_id INTEGER NOT NULL,
        product_name TEXT NOT NULL,
        price REAL NOT NULL,
        quantity INTEGER NOT NULL,
        unit TEXT NOT NULL DEFAULT 'pcs',
        FOREIGN KEY (order_id) REFERENCES orders(id) ON DELETE CASCADE
      )
    ''');

    await _seedData(db);
  }

  Future<void> _seedData(Database db) async {
    // Seed sales user
    await db.insert('sales', {
      'username': 'sales01',
      'email': 'sales01@example.com',
      'password': 'sales123',
      'full_name': 'Budi Santoso',
      'role': 'sales',
    });

    await db.insert('sales', {
      'username': 'sales02',
      'email': 'sales02@example.com',
      'password': 'sales123',
      'full_name': 'Dewi Rahayu',
      'role': 'sales',
    });

    // Seed customers
    final customers = [
      {
        'name': 'Toko Maju Jaya',
        'address': 'Jl. Sudirman No. 12, Jakarta Pusat',
        'phone': '081234567890',
        'is_visited': 1,
      },
      {
        'name': 'Warung Bu Sari',
        'address': 'Jl. Pahlawan No. 5, Bandung',
        'phone': '082345678901',
        'is_visited': 0,
      },
      {
        'name': 'Minimarket Sejahtera',
        'address': 'Jl. Gatot Subroto No. 88, Surabaya',
        'phone': '083456789012',
        'is_visited': 1,
      },
      {
        'name': 'Toko Berkah Abadi',
        'address': 'Jl. Diponegoro No. 33, Yogyakarta',
        'phone': '084567890123',
        'is_visited': 0,
      },
      {
        'name': 'Swalayan Makmur',
        'address': 'Jl. Ahmad Yani No. 77, Semarang',
        'phone': '085678901234',
        'is_visited': 1,
      },
      {
        'name': 'Toko Harapan Baru',
        'address': 'Jl. Imam Bonjol No. 21, Medan',
        'phone': '086789012345',
        'is_visited': 0,
      },
      {
        'name': 'Kios Pak Hendra',
        'address': 'Jl. Veteran No. 9, Malang',
        'phone': '087890123456',
        'is_visited': 1,
      },
      {
        'name': 'Toko Sumber Rezeki',
        'address': 'Jl. Merdeka No. 45, Makassar',
        'phone': '088901234567',
        'is_visited': 0,
      },
    ];

    for (final c in customers) {
      await db.insert('customers', c);
    }

    // Seed products
    final products = [
      {
        'name': 'Indomie Goreng',
        'category': 'Mie Instan',
        'price': 3500.0,
        'stock': 500,
        'unit': 'pcs',
        'description': 'Mie goreng rasa ayam bawang',
      },
      {
        'name': 'Indomie Kuah Ayam',
        'category': 'Mie Instan',
        'price': 3500.0,
        'stock': 400,
        'unit': 'pcs',
        'description': 'Mie kuah rasa ayam',
      },
      {
        'name': 'Aqua 600ml',
        'category': 'Minuman',
        'price': 4000.0,
        'stock': 300,
        'unit': 'botol',
        'description': 'Air mineral 600ml',
      },
      {
        'name': 'Aqua 1500ml',
        'category': 'Minuman',
        'price': 7000.0,
        'stock': 200,
        'unit': 'botol',
        'description': 'Air mineral 1500ml',
      },
      {
        'name': 'Teh Botol Sosro',
        'category': 'Minuman',
        'price': 5000.0,
        'stock': 250,
        'unit': 'botol',
        'description': 'Teh manis dalam botol',
      },
      {
        'name': 'Beras Premium 5kg',
        'category': 'Sembako',
        'price': 75000.0,
        'stock': 100,
        'unit': 'karung',
        'description': 'Beras premium kualitas terbaik',
      },
      {
        'name': 'Minyak Goreng 2L',
        'category': 'Sembako',
        'price': 35000.0,
        'stock': 150,
        'unit': 'botol',
        'description': 'Minyak goreng 2 liter',
      },
      {
        'name': 'Gula Pasir 1kg',
        'category': 'Sembako',
        'price': 16000.0,
        'stock': 200,
        'unit': 'kg',
        'description': 'Gula pasir putih 1kg',
      },
      {
        'name': 'Sabun Lifebuoy',
        'category': 'Kebersihan',
        'price': 5500.0,
        'stock': 300,
        'unit': 'pcs',
        'description': 'Sabun mandi antibakteri',
      },
      {
        'name': 'Shampo Pantene 170ml',
        'category': 'Kebersihan',
        'price': 18000.0,
        'stock': 150,
        'unit': 'botol',
        'description': 'Shampo perawatan rambut',
      },
      {
        'name': 'Susu Ultra 1L',
        'category': 'Susu & Dairy',
        'price': 18500.0,
        'stock': 120,
        'unit': 'kotak',
        'description': 'Susu UHT full cream 1 liter',
      },
      {
        'name': 'Biskuit Roma Kelapa',
        'category': 'Snack',
        'price': 8500.0,
        'stock': 200,
        'unit': 'pcs',
        'description': 'Biskuit rasa kelapa',
      },
    ];

    for (final p in products) {
      await db.insert('products', p);
    }

    // Seed dummy orders
    final now = DateTime.now();
    final orderId1 = await db.insert('orders', {
      'customer_id': 1,
      'customer_name': 'Toko Maju Jaya',
      'total_amount': 175000.0,
      'status': 'done',
      'notes': 'Pengiriman pagi',
      'created_at': now.subtract(const Duration(days: 2)).toIso8601String(),
    });

    await db.insert('order_items', {
      'order_id': orderId1,
      'product_id': 1,
      'product_name': 'Indomie Goreng',
      'price': 3500.0,
      'quantity': 20,
      'unit': 'pcs',
    });
    await db.insert('order_items', {
      'order_id': orderId1,
      'product_id': 6,
      'product_name': 'Beras Premium 5kg',
      'price': 75000.0,
      'quantity': 1,
      'unit': 'karung',
    });

    final orderId2 = await db.insert('orders', {
      'customer_id': 3,
      'customer_name': 'Minimarket Sejahtera',
      'total_amount': 320000.0,
      'status': 'sent',
      'notes': null,
      'created_at': now.subtract(const Duration(days: 1)).toIso8601String(),
    });

    await db.insert('order_items', {
      'order_id': orderId2,
      'product_id': 7,
      'product_name': 'Minyak Goreng 2L',
      'price': 35000.0,
      'quantity': 4,
      'unit': 'botol',
    });
    await db.insert('order_items', {
      'order_id': orderId2,
      'product_id': 11,
      'product_name': 'Susu Ultra 1L',
      'price': 18500.0,
      'quantity': 8,
      'unit': 'kotak',
    });

    final orderId3 = await db.insert('orders', {
      'customer_id': 5,
      'customer_name': 'Swalayan Makmur',
      'total_amount': 95000.0,
      'status': 'draft',
      'notes': 'Konfirmasi dulu',
      'created_at': now.toIso8601String(),
    });

    await db.insert('order_items', {
      'order_id': orderId3,
      'product_id': 3,
      'product_name': 'Aqua 600ml',
      'price': 4000.0,
      'quantity': 10,
      'unit': 'botol',
    });
    await db.insert('order_items', {
      'order_id': orderId3,
      'product_id': 9,
      'product_name': 'Sabun Lifebuoy',
      'price': 5500.0,
      'quantity': 5,
      'unit': 'pcs',
    });
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
