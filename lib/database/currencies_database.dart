import 'package:moamri_accounting/database/entities/currency.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'entities/activity.dart';
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

  static Future<void> insertCurrency(Currency currency, int actionBy) async {
    return await MyDatabase.myDatabase.transaction((txn) async {
      var actionDate = DateTime.now().millisecondsSinceEpoch;
      await txn.insert(
        'currencies',
        currency.toMap(),
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      await txn.insert(
        'activities',
        Activity(
                date: actionDate,
                action: 'add',
                tableName: 'currencies_history')
            .toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      var historyMap = currency.toMap();
      historyMap['id'] = null;
      historyMap.putIfAbsent('action_by', () => actionBy);
      historyMap.putIfAbsent('action_date', () => actionDate);
      await txn.insert(
        'currencies_history',
        historyMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  static Future<void> updateCurrency(
      Currency currency, Currency oldCurrency, int actionBy) async {
    return await MyDatabase.myDatabase.transaction((txn) async {
      var actionDate = DateTime.now().millisecondsSinceEpoch;
      await txn.update(
        'currencies',
        currency.toMap(),
        where: 'name = ?',
        whereArgs: [oldCurrency.name],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      await txn.insert(
        'activities',
        Activity(
                date: actionDate,
                action: 'update',
                tableName: 'currencies_history')
            .toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      var historyMap = currency.toMap();
      historyMap['id'] = null;
      historyMap.putIfAbsent('action_by', () => actionBy);
      historyMap.putIfAbsent('action_date', () => actionDate);
      await txn.insert(
        'currencies_history',
        historyMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  static Future<void> deleteCurrency(Currency currency, int actionBy) async {
    return await MyDatabase.myDatabase.transaction((txn) async {
      var actionDate = DateTime.now().millisecondsSinceEpoch;
      await txn
          .delete('currencies', where: 'name = ?', whereArgs: [currency.name]);
      await txn.insert(
        'activities',
        Activity(
                date: actionDate,
                action: 'delete',
                tableName: 'currencies_history')
            .toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      var historyMap = currency.toMap();
      historyMap['id'] = null;
      historyMap.putIfAbsent('action_by', () => actionBy);
      historyMap.putIfAbsent('action_date', () => actionDate);
      await txn.insert(
        'currencies_history',
        historyMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }
}
