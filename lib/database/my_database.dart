import 'dart:io' as io;
import 'package:path/path.dart' as p;
import 'package:sqflite_common_ffi/sqflite_ffi.dart';
import 'package:path_provider/path_provider.dart';

import 'entities/audit.dart';
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
    // data should be store a map data of change
    // user_data should be user map data
    // user_id just in case we want to query all user action
    await myDatabase.execute('''
    CREATE TABLE IF NOT EXISTS audits(
      date INTEGER PRIMARY KEY, 
      table_name TEXT NOT NULL,
      action TEXT NOT NULL, 
      old_data TEXT, 
      new_data TEXT, 
      user_id INTEGER NOT NULL, 
      user_data TEXT NOT NULL
    )
    ''');
    await myDatabase.execute('''
    CREATE TABLE IF NOT EXISTS currencies (
      name TEXT PRIMARY KEY,
      exchange_rate REAL NOT NULL
    )
    ''');

    await myDatabase.execute('''
    CREATE TABLE IF NOT EXISTS store (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      branch TEXT NOT NULL,
      address TEXT NOT NULL,
      phone TEXT NOT NULL,
      currency TEXT NOT NULL REFERENCES currencies(name) ON DELETE NO ACTION ON UPDATE CASCADE,
      image BLOB, 
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
      role TEXT CHECK( role IN ('admin','cashier') ) NOT NULL DEFAULT 'cashier'
    )
    ''');

    await myDatabase.execute('''
    CREATE TABLE IF NOT EXISTS units (
      name TEXT PRIMARY KEY
    )
    ''');
    // insert the default units
    await myDatabase.insert('units', {'name': 'قطعة'},
        conflictAlgorithm: ConflictAlgorithm.ignore);
    await myDatabase.insert('units', {'name': 'كيلو'},
        conflictAlgorithm: ConflictAlgorithm.ignore);
    await myDatabase.insert('units', {'name': 'طن'},
        conflictAlgorithm: ConflictAlgorithm.ignore);
    await myDatabase.insert('units', {'name': 'جرام'},
        conflictAlgorithm: ConflictAlgorithm.ignore);
    await myDatabase.insert('units', {'name': 'متر'},
        conflictAlgorithm: ConflictAlgorithm.ignore);
    await myDatabase.insert('units', {'name': 'سم'},
        conflictAlgorithm: ConflictAlgorithm.ignore);
    await myDatabase.execute('''
    CREATE TABLE IF NOT EXISTS materials (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      barcode TEXT UNIQUE,
      category TEXT NOT NULL,
      unit TEXT NOT NULL REFERENCES units(name) ON DELETE RESTRICT,
      currency TEXT NOT NULL REFERENCES currencies(name) ON DELETE RESTRICT ON UPDATE CASCADE,
      quantity REAL NOT NULL,
      cost_price REAL NOT NULL,
      sale_price REAL NOT NULL,
      note TEXT,
      larger_material_id INTEGER REFERENCES materials(id) ON DELETE RESTRICT,
      larger_quantity_supplied REAL
    )
    ''');

    await myDatabase.execute('''
    CREATE TABLE IF NOT EXISTS expiries_dates (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      material_id INTEGER NOT NULL REFERENCES materials(id) ON DELETE CASCADE,
      date INTEGER NOT NULL,
      notify_before INTEGER NOT NULL
    )
    ''');

    await myDatabase.execute("""
    CREATE TABLE IF NOT EXISTS offers(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      currency TEXT NOT NULL REFERENCES currencies(name) ON DELETE RESTRICT ON UPDATE CASCADE,
      price REAl NOT NULL,
      note TEXT
    )
    """);

    await myDatabase.execute("""
    CREATE TABLE IF NOT EXISTS offers_materials(
      offer_id INTEGER, 
      material_id INTEGER,
      quantity REAL NOT NULL, 
      PRIMARY KEY(offer_id, material_id),
      FOREIGN KEY(offer_id) REFERENCES offers(id) ON DELETE CASCADE, 
      FOREIGN KEY(material_id) REFERENCES materials(id) ON DELETE RESTRICT
    )
    """);

    await myDatabase.execute('''
    CREATE TABLE IF NOT EXISTS customers(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      address TEXT NOT NULL,
      phone TEXT NOT NULL,
      description TEXT
    )
    ''');

    await myDatabase.execute('''
    CREATE TABLE IF NOT EXISTS invoices (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      type TEXT CHECK( type IN ('sale','return') ) NOT NULL,
      customer_id INTEGER REFERENCES customers(id) ON DELETE NO ACTION,
      date INTEGER NOT NULL, 
      discount REAL,
      note TEXT
    )
    ''');

    await myDatabase.execute('''
    CREATE TABLE IF NOT EXISTS invoices_materials (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      invoice_id INTEGER NOT NULL REFERENCES invoices(id) ON DELETE CASCADE,
      material_id INTEGER NOT NULL REFERENCES materials(id) ON DELETE NO ACTION,
      quantity REAL NOT NULL
    )
    ''');
    await myDatabase.execute('''
    CREATE TABLE IF NOT EXISTS invoices_offers (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      invoice_id INTEGER NOT NULL REFERENCES invoices(id) ON DELETE CASCADE,
      offer_id INTEGER NOT NULL REFERENCES offers(id) ON DELETE NO ACTION,
      quantity REAL NOT NULL
    )
    ''');

    await myDatabase.execute("""
    CREATE TABLE IF NOT EXISTS payments(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      invoice_id INTEGER REFERENCES invoices(id) ON DELETE CASCADE,    
      customer_id INTEGER REFERENCES customers(id) ON DELETE CASCADE,  
      date INTEGER NOT NULL, 
      amount REAL NOT NULL, 
      currency TEXT NOT NULL REFERENCES currencies(name) ON DELETE NO ACTION ON UPDATE CASCADE,
      note TEXT
    )
    """);

    // here we can not delete the customer except if we delete all his/her debts
    await myDatabase.execute("""
    CREATE TABLE IF NOT EXISTS debts(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      invoice_id INTEGER REFERENCES invoices(id) ON DELETE CASCADE,    
      customer_id INTEGER REFERENCES customers(id) ON DELETE RESTRICT,  
      date INTEGER NOT NULL, 
      amount REAL NOT NULL, 
      currency TEXT NOT NULL REFERENCES currencies(name) ON DELETE RESTRICT ON UPDATE CASCADE, 
      note TEXT
    )
    """);

    await myDatabase.execute('''
    CREATE TABLE IF NOT EXISTS suppliers (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      name TEXT NOT NULL,
      address TEXT NOT NULL,
      phone TEXT NOT NULL,
      email TEXT NOT NULL,
      description TEXT
    )
    ''');

    await myDatabase.execute('''
    CREATE TABLE IF NOT EXISTS purchases (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      supplier_id INTEGER NOT NULL REFERENCES suppliers(id) ON DELETE NO ACTION,
      date INTEGER NOT NULL, 
      type TEXT CHECK( type IN ('purchase','return') ) NOT NULL,
      discount REAL,
      note TEXT
    )
    ''');

    await myDatabase.execute('''
    CREATE TABLE IF NOT EXISTS purchases_materials (
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      purchase_id INTEGER NOT NULL REFERENCES purchases(id) ON DELETE CASCADE,
      material_id INTEGER NOT NULL REFERENCES materials(id) ON DELETE NO ACTION,
      quantity REAL NOT NULL,
      currency TEXT NOT NULL REFERENCES currencies(name) ON DELETE NO ACTION ON UPDATE CASCADE, 
      cost_price REAL NOT NULL
    )
    ''');

    await myDatabase.execute("""
    CREATE TABLE IF NOT EXISTS purchases_payments(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      purchase_id INTEGER REFERENCES purchases(id) ON DELETE CASCADE,    
      supplier_id INTEGER REFERENCES suppliers(id) ON DELETE CASCADE,  
      date INTEGER NOT NULL, 
      currency TEXT NOT NULL REFERENCES currencies(name) ON DELETE NO ACTION ON UPDATE CASCADE, 
      amount REAL NOT NULL, 
      note TEXT
    )
    """);

    // here we can not delete the customer except if we delete all his/her debts
    await myDatabase.execute("""
    CREATE TABLE IF NOT EXISTS purchases_debts(
      id INTEGER PRIMARY KEY AUTOINCREMENT,
      purchase_id INTEGER REFERENCES purchases(id) ON DELETE CASCADE,    
      supplier_id INTEGER REFERENCES suppliers(id) ON DELETE CASCADE,  
      currency TEXT NOT NULL REFERENCES currencies(name) ON DELETE RESTRICT ON UPDATE CASCADE, 
      date INTEGER NOT NULL, 
      amount REAL NOT NULL, 
      note TEXT
    )
    """);

    ////////////////////////////////////////////////////////////////////////////////////////////
  }

  static Future<Store?> getStoreData() async {
    var maps = await myDatabase.rawQuery('''
      SELECT * FROM store ORDER BY id DESC
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

  static Future<int> insertUser(User user, User? actionBy) async {
    return await MyDatabase.myDatabase.transaction((txn) async {
      user.id = await txn.insert(
        'users',
        user.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await txn.insert(
        'audits',
        Audit(
          date: DateTime.now().millisecondsSinceEpoch,
          action: 'add',
          table: 'users',
          oldData: null,
          newData: Audit.mapToString(user.toMap()),
          userId: actionBy?.id! ?? user.id!,
          userData: Audit.mapToString(actionBy?.toMap() ?? user.toMap()),
        ).toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return user.id!;
    });
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
// TODO ENCRYPTION
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