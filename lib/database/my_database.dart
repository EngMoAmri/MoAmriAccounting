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
    CREATE TABLE IF NOT EXISTS currencies (
      name TEXT PRIMARY KEY
    )
    ''');
    await myDatabase.execute('''
    CREATE TABLE IF NOT EXISTS currencies_exchange (
      currency_1 TEXT NOT NULL REFERENCES currencies(name) ON DELETE CASCADE,
      currency_2 TEXT NOT NULL REFERENCES currencies(name) ON DELETE CASCADE,
      exchange_rate REAL NOT NULL,
      PRIMARY KEY(currency_1, currency_2)
    )
    ''');
    await myDatabase.execute('''
    CREATE TABLE IF NOT EXISTS units (
      name TEXT PRIMARY KEY
    )
    ''');
    // insert the default units
    await myDatabase.insert('units', {'name': 'CM'},
        conflictAlgorithm: ConflictAlgorithm.ignore);
    await myDatabase.insert('units', {'name': 'Meter'},
        conflictAlgorithm: ConflictAlgorithm.ignore);
    await myDatabase.insert('units', {'name': 'Ton'},
        conflictAlgorithm: ConflictAlgorithm.ignore);
    await myDatabase.insert('units', {'name': 'Pound'},
        conflictAlgorithm: ConflictAlgorithm.ignore);
    await myDatabase.insert('units', {'name': 'Kilo'},
        conflictAlgorithm: ConflictAlgorithm.ignore);
    await myDatabase.insert('units', {'name': 'Gram'},
        conflictAlgorithm: ConflictAlgorithm.ignore);
    await myDatabase.insert('units', {'name': 'Piece'},
        conflictAlgorithm: ConflictAlgorithm.ignore);
    await myDatabase.execute('''
    CREATE TABLE IF NOT EXISTS materials (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      barcode TEXT UNIQUE,
      category TEXT NOT NULL,
      unit TEXT NOT NULL REFERENCES units(name) ON DELETE RESTRICT,
      currency TEXT NOT NULL REFERENCES currencies(name) ON DELETE RESTRICT,
      quantity INTEGER NOT NULL,
      cost_price REAL NOT NULL,
      sale_price REAL NOT NULL,
      tax REAL,
      note TEXT,
      added_by INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
      updated_by INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
    ''');
    await myDatabase.execute('''
    CREATE TABLE IF NOT EXISTS materials_larger_units (
      material_id INTEGER NOT NULL REFERENCES materials(id) ON DELETE CASCADE,
      larger_material_id INTEGER NOT NULL REFERENCES materials(id) ON DELETE CASCADE,
      quantity_supplied INTEGER NOT NULL,
      PRIMARY KEY(material_id, larger_material_id)
    )
    ''');
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
      added_by INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
      updated_by INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
    ''');
    await myDatabase.execute('''
    DROP TABLE invoices;
    '''); // TODO DELETE
    await myDatabase.execute('''
    CREATE TABLE IF NOT EXISTS invoices (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      customer_id INTEGER REFERENCES customers(id) ON DELETE RESTRICT,
      type TEXT CHECK( type IN ('sale','return') ) NOT NULL,
      payment_type TEXT CHECK( payment_type IN ('cash','debt') ) NOT NULL,
      payment_amount REAL NOT NULL,
      debt_amount REAL NOT NULL,
      added_by INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
      updated_by INTEGER NOT NULL REFERENCES users(id) ON DELETE RESTRICT,
      created_at INTEGER NOT NULL,
      updated_at INTEGER NOT NULL
    )
    ''');
    await myDatabase.execute('''
    CREATE TABLE IF NOT EXISTS invoices_material (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      invoice_id INTEGER NOT NULL REFERENCES invoices(id) ON DELETE CASCADE,
      material_id INTEGER NOT NULL REFERENCES materials(id) ON DELETE RESTRICT,
      quantity INTEGER NOT NULL
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

  static Future<int> insertUser(User user) async {
    return await MyDatabase.myDatabase.insert(
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


/*
// ENCRYPTION
import 'dart:ffi';
import 'dart:io';
import 'dart:math';
import 'package:sqflite_common/sqlite_api.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:sqlite3/open.dart';

Future<void> main(List<String> arguments) async {
  final dbFactory = createDatabaseFactoryFfi(ffiInit: ffiInit);

  final db = await dbFactory.openDatabase(
    Directory.current.path + "/db_pass_1234.db",
    options: OpenDatabaseOptions(
      version: 1,
      onConfigure: (db) async {
        // This is the part where we pass the "password"
        await db.rawQuery("PRAGMA KEY='1234'");
      },
      onCreate: (db, version) async {
        db.execute("CREATE TABLE t (i INTEGER)");
      },
    ),
  );
  print(await db.rawQuery("PRAGMA cipher_version"));
  print(await db.rawQuery("SELECT * FROM sqlite_master"));
  print(db.path);
  await db.close();
}

void ffiInit() {
  open.overrideForAll(sqlcipherOpen);
}

DynamicLibrary sqlcipherOpen() {
  // Taken from https://github.com/simolus3/sqlite3.dart/blob/e66702c5bec7faec2bf71d374c008d5273ef2b3b/sqlite3/lib/src/load_library.dart#L24
  if (Platform.isLinux || Platform.isAndroid) {
    try {
      return DynamicLibrary.open('libsqlcipher.so');
    } catch (_) {
      if (Platform.isAndroid) {
        // On some (especially old) Android devices, we somehow can't dlopen
        // libraries shipped with the apk. We need to find the full path of the
        // library (/data/data/<id>/lib/libsqlite3.so) and open that one.
        // For details, see https://github.com/simolus3/moor/issues/420
        final appIdAsBytes = File('/proc/self/cmdline').readAsBytesSync();

        // app id ends with the first \0 character in here.
        final endOfAppId = max(appIdAsBytes.indexOf(0), 0);
        final appId = String.fromCharCodes(appIdAsBytes.sublist(0, endOfAppId));

        return DynamicLibrary.open('/data/data/$appId/lib/libsqlcipher.so');
      }

      rethrow;
    }
  }
  if (Platform.isIOS) {
    return DynamicLibrary.process();
  }
  if (Platform.isMacOS) {
    // TODO: Unsure what the path is in macos
    return DynamicLibrary.open('/usr/lib/libsqlite3.dylib');
  }
  if (Platform.isWindows) {
    // TODO: This dll should be the one that gets generated after compiling SQLcipher on Windows
    return DynamicLibrary.open('sqlite3.dll');
  }

  throw UnsupportedError('Unsupported platform: ${Platform.operatingSystem}');
} */