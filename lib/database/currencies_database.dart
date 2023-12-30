import 'package:moamri_accounting/database/entities/currency.dart';
import 'package:moamri_accounting/database/entities/user.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'entities/audit.dart';
import 'my_database.dart';

class CurrenciesDatabase {
  static Future<bool> isCurrencyExists(String currency) async {
    List<Map<String, dynamic>> maps = await MyDatabase.myDatabase
        .query('currencies', where: "name = ?", whereArgs: [currency.trim()]);
    if (maps.isEmpty) return false;
    return true;
  }

  /// this function must search if the currency being used by some important tables
  static Future<bool> isCurrencyDeletable(String currency) async {
    List<Map<String, dynamic>> maps = await MyDatabase.myDatabase.rawQuery(
        '''SELECT currency FROM store WHERE id = (SELECT MAX(id) FROM store)''');
    if (maps.first['currency'] == currency) return false;
    List<Map<String, dynamic>> maps2 = await MyDatabase.myDatabase
        .rawQuery('''SELECT id FROM materials WHERE currency = '$currency' ''');
    if (maps2.isNotEmpty) return false;
    List<Map<String, dynamic>> maps3 = await MyDatabase.myDatabase
        .rawQuery('''SELECT id FROM offers WHERE currency = '$currency' ''');
    if (maps3.isNotEmpty) return false;
    List<Map<String, dynamic>> maps4 = await MyDatabase.myDatabase
        .rawQuery('''SELECT id FROM debts WHERE currency = '$currency' ''');
    if (maps4.isNotEmpty) return false;
    List<Map<String, dynamic>> maps5 = await MyDatabase.myDatabase.rawQuery(
        '''SELECT id FROM purchases_debts WHERE currency = '$currency' ''');
    if (maps5.isNotEmpty) return false;
    return true;
  }

  static Future<List<Currency>> searchForCurrencies(String text) async {
    var trimText = text.trim();
    List<Map<String, dynamic>> maps = await MyDatabase.myDatabase.query(
        'currencies',
        distinct: true,
        where: "name like ?",
        whereArgs: ["%$trimText%"],
        limit: 10);

    List<Currency> currencies = [];
    for (var map in maps) {
      currencies.add(Currency.fromMap(map));
    }
    return currencies;
  }

  static Future<List<Currency>> getCurrencies() async {
    List<Map<String, dynamic>> maps =
        await MyDatabase.myDatabase.query('currencies');

    List<Currency> currencies = [];
    for (var map in maps) {
      currencies.add(Currency.fromMap(map));
    }
    return currencies;
  }

  // this is to get currencies to payment
  static Future<List<Currency>> getCurrenciesWithout(
      List<String> oldCurrencies) async {
    List<Map<String, dynamic>> maps = await MyDatabase.myDatabase.query(
        'currencies',
        where:
            'name NOT IN (${List.filled(oldCurrencies.length, '?').join(',')})',
        whereArgs: oldCurrencies);

    List<Currency> currencies = [];
    for (var map in maps) {
      currencies.add(Currency.fromMap(map));
    }
    return currencies;
  }

  static Future<void> insertCurrency(Currency currency, User actionBy) async {
    return await MyDatabase.myDatabase.transaction((txn) async {
      await txn.insert(
        'currencies',
        currency.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      await txn.insert(
        'audits',
        Audit(
          date: DateTime.now().millisecondsSinceEpoch,
          action: 'add',
          table: 'currencies',
          oldData: null,
          newData: Audit.mapToString(currency.toMap()),
          userId: actionBy.id!,
          userData: Audit.mapToString(actionBy.toMap()),
        ).toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  static Future<void> updateCurrency(
      Currency currency, Currency oldCurrency, User actionBy) async {
    return await MyDatabase.myDatabase.transaction((txn) async {
      await txn.update(
        'currencies',
        currency.toMap(),
        where: 'name = ?',
        whereArgs: [oldCurrency.name],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await txn.insert(
        'audits',
        Audit(
          date: DateTime.now().millisecondsSinceEpoch,
          action: 'update',
          table: 'currencies',
          oldData: Audit.mapToString(oldCurrency.toMap()),
          newData: Audit.mapToString(currency.toMap()),
          userId: actionBy.id!,
          userData: Audit.mapToString(actionBy.toMap()),
        ).toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  static Future<void> deleteCurrency(Currency currency, User actionBy) async {
    return await MyDatabase.myDatabase.transaction((txn) async {
      await txn
          .delete('currencies', where: 'name = ?', whereArgs: [currency.name]);
      await txn.insert(
        'audits',
        Audit(
          date: DateTime.now().millisecondsSinceEpoch,
          action: 'delete',
          table: 'currencies',
          oldData: Audit.mapToString(currency.toMap()),
          newData: null,
          userId: actionBy.id!,
          userData: Audit.mapToString(actionBy.toMap()),
        ).toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }
}
