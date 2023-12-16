import 'dart:io' as io;
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';

import 'entities/store.dart';
import 'entities/user.dart';

/// this class will create the database and will contain
class MyDatabase {
  static late Database myDatabase;

  /// create tables if not exist and triggers
  static Future<void> open() async {
    // Init ffi loader if needed.
    sqfliteFfiInit();

    var databaseFactory = databaseFactoryFfi;
    final io.Directory appDocumentsDir =
        await getApplicationDocumentsDirectory();

    //Create path for database
    String dbPath = p.join(appDocumentsDir.path, "databases", "myDb.db");
    myDatabase = await databaseFactory.openDatabase(
      dbPath,
    );
    // this is for making on delete cascade works
    await myDatabase.execute("PRAGMA foreign_keys=ON");

    await myDatabase.execute('''
    CREATE TABLE IF NOT EXISTS store (
      id INTEGER PRIMARY KEY,
      name TEXT NOT NULL,
      branch TEXT NOT NULL,
      address TEXT NOT NULL,
      phone TEXT NOT NULL,
      image BLOB, 
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
    ''');
    await myDatabase.execute('''
    CREATE TABLE IF NOT EXISTS users (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      enabled INTEGER  CHECK( enabled IN (1, 0) ) NOT NULL DEFAULT 1,
      username TEXT NOT NULL,
      password TEXT NOT NULL,
      role TEXT CHECK( role IN ('admin','saller') ) NOT NULL DEFAULT 'saller',
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
    ''');

    await myDatabase.execute('''
    CREATE TABLE IF NOT EXISTS materials (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL UNIQUE,
      barcode TEXT UNIQUE,
      category TEXT NOT NULL,
      unit TEXT NOT NULL,
      quantity INTEGER NOT NULL,
      cost_price REAL NOT NULL,
      sell_price REAL NOT NULL,
      discount REAL,
      tax REAL,
      note TEXT,
      added_by INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
      updated_by INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
    ''');
    await myDatabase.execute(
        '''UPDATE SQLITE_SEQUENCE SET seq = 10000 WHERE name = 'materials';''');
    await myDatabase.execute('''
    CREATE TABLE IF NOT EXISTS expiries_dates (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      material_id INTEGER NOT NULL REFERENCES materials(id) ON DELETE CASCADE,
      date INTEGER NOT NULL
    )
    ''');

    await myDatabase.execute('''
    CREATE TABLE IF NOT EXISTS customers (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      address TEXT NOT NULL,
      phone TEXT NOT NULL,
      description TEXT NOT NULL,
      enabled INTEGER  CHECK( enabled IN (1, 0) ) NOT NULL DEFAULT 1,
      added_by INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
      updated_by INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
    ''');
    await myDatabase.execute('''
    CREATE TABLE IF NOT EXISTS invoices (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      customer_id INTEGER NOT NULL REFERENCES customers(id) ON DELETE RESTRICT,
      payment_type TEXT CHECK( payment_type IN ('cash','later') ) NOT NULL,
      total_amount REAL NOT NULL,
      added_by INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
      updated_by INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
    ''');
    await myDatabase.execute('''
    CREATE TABLE IF NOT EXISTS sales (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      invoice_id INTEGER NOT NULL REFERENCES invoices(id) ON DELETE CASCADE,
      material_id INTEGER NOT NULL REFERENCES materials(id) ON DELETE RESTRICT,
      quantity INTEGER NOT NULL,
      unit_price REAL NOT NULL
    )
    ''');
    await myDatabase.execute('''
    CREATE TABLE IF NOT EXISTS suppliers (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      address TEXT NOT NULL,
      phone TEXT NOT NULL,
      email TEXT NOT NULL,
      description TEXT NOT NULL,
      added_by INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
      updated_by INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
    ''');
    await myDatabase.execute('''
    CREATE TABLE IF NOT EXISTS purchases_invoices (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      supplier_id INTEGER NOT NULL REFERENCES suppliers(id) ON DELETE RESTRICT,
      payment_type TEXT CHECK( payment_type IN ('cash','later') ) NOT NULL,
      total_amount REAL NOT NULL,
      added_by INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
      updated_by INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
    ''');
    await myDatabase.execute('''
    CREATE TABLE IF NOT EXISTS purchases (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      invoice_id INTEGER NOT NULL REFERENCES purchases_invoices(id) ON DELETE CASCADE,
      material_id INTEGER NOT NULL REFERENCES materials(id) ON DELETE RESTRICT,
      received_date INTEGER NOT NULL,
      quantity INTEGER NOT NULL,
      unit_price REAL NOT NULL
    )
    ''');
  }

  static Future<Store?> getStoreData() async {
    var maps = await myDatabase.rawQuery('''
      SELECT * FROM store
    ''');
    if (maps.isEmpty) return null;
    return Store.fromMap(maps.first);
  }

  static Future<void> setStoreData(Store store) async {
    await MyDatabase.myDatabase.insert(
      'store',
      store.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> insertUser(User user) async {
    await MyDatabase.myDatabase.insert(
      'users',
      user.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<User?> getUser(String username, String password) async {
    var maps = await MyDatabase.myDatabase.query(
      'users',
      where: 'username = ? and password = ?',
      whereArgs: [username, password],
    );
    if (maps.isEmpty) return null;
    return User.fromMap(maps.first);
  }

  static Future close() async => MyDatabase.myDatabase.close();
}
