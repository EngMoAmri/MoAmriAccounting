import 'package:moamri_accounting/controllers/main_controller.dart';
import 'package:moamri_accounting/database/entities/customer.dart';
import 'package:moamri_accounting/database/items/customer_debt_item.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'entities/activity.dart';
import 'my_database.dart';

class CustomersDatabase {
  static Future<int> getCustomersDebt(Customer customer) async {
    // List<Map<String, Object?>> totalRow;
    // totalRow = await MyDatabase.myDatabase.rawQuery(
    //     "SELECT SUM(id) FROM customers WHERE name like '%$trimText%'");
    // return int.tryParse(totalRow[0]["COUNT(id)"].toString()) ?? 0;
    throw Exception("TODO");
  }

  static Future<int> getCustomersCount({searchedText}) async {
    List<Map<String, Object?>> totalRow;
    if (searchedText == null) {
      totalRow = await MyDatabase.myDatabase
          .rawQuery('SELECT COUNT(id) FROM customers');
    } else {
      var trimText = searchedText.trim();
      totalRow = await MyDatabase.myDatabase.rawQuery(
          "SELECT COUNT(id) FROM customers WHERE name like '%$trimText%'");
    }
    return int.tryParse(totalRow[0]["COUNT(id)"].toString()) ?? 0;
  }

  static Future<List<Customer>> getCustomersSuggestions(String text) async {
    String trimText = text.trim();
    List<Map<String, dynamic>> maps;
    maps = await MyDatabase.myDatabase.query('customers',
        distinct: true,
        where: "name like ?",
        whereArgs: ["%$trimText%"],
        limit: 10);
    List<Customer> customers = [];
    for (var map in maps) {
      customers.add(Customer.fromMap(map));
    }
    return customers;
  }

  static Future<int> insertCustomer(Customer customer, int actionBy) async {
    return await MyDatabase.myDatabase.transaction((txn) async {
      var actionDate = DateTime.now().millisecondsSinceEpoch;
      customer.id = await txn.insert(
        'customers',
        customer.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      await txn.insert(
        'activities',
        Activity(
                date: actionDate, action: 'add', tableName: 'customers_history')
            .toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      var historyMap = customer.toMap();
      historyMap['id'] = null;
      historyMap.putIfAbsent('customer_id', () => customer.id);
      historyMap.putIfAbsent('action_by', () => actionBy);
      historyMap.putIfAbsent('action_date', () => actionDate);
      await txn.insert(
        'customers_history',
        historyMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return customer.id!;
    });
  }

  static Future<void> updateCustomer(Customer customer, int actionBy) async {
    return await MyDatabase.myDatabase.transaction((txn) async {
      var actionDate = DateTime.now().millisecondsSinceEpoch;
      await txn.update(
        'customers',
        customer.toMap(),
        where: 'id = ?',
        whereArgs: [customer.id],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await txn.insert(
        'activities',
        Activity(
                date: actionDate,
                action: 'update',
                tableName: 'customers_history')
            .toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      var historyMap = customer.toMap();
      historyMap['id'] = null;
      historyMap.putIfAbsent('customer_id', () => customer.id!);
      historyMap.putIfAbsent('action_by', () => actionBy);
      historyMap.putIfAbsent('action_date', () => actionDate);
      await txn.insert(
        'customers_history',
        historyMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  static Future<void> deleteCustomer(Customer customer, int actionBy) async {
    return await MyDatabase.myDatabase.transaction((txn) async {
      var actionDate = DateTime.now().millisecondsSinceEpoch;
      await txn.delete(
        'customers',
        where: 'id = ?',
        whereArgs: [customer.id],
      );
      await txn.insert(
        'activities',
        Activity(
                date: actionDate,
                action: 'delete',
                tableName: 'customers_history')
            .toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      var historyMap = customer.toMap();
      historyMap['id'] = null;
      historyMap.putIfAbsent('customer_id', () => customer.id);
      historyMap.putIfAbsent('action_by', () => actionBy);
      historyMap.putIfAbsent('action_date', () => actionDate);
      await txn.insert(
        'customers_history',
        historyMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  static Future<List<CustomerDebtItem>> getCustomersWithDebts(
      MainController mainController, int page,
      {orderBy, dir}) async {
    List<Map<String, dynamic>> maps = await MyDatabase.myDatabase.rawQuery('''
        SELECT c.*, SUM(IFNULL((d.amount * (
            SELECT exchange_rate 
            FROM currencies_exchange 
            WHERE currency_1='${mainController.storeData.value!.currency}' 
            AND currency_2='d.currency'
            )
          ), 0)) as debt
        FROM customers AS c LEFT JOIN debts as d ON c.id = d.customer_id 
        GROUP BY c.id
        ORDER BY ${orderBy ?? "id"} COLLATE NOCASE ${dir ?? "ASC"} 
        LIMIT ${page * 40}, 40
     ''');
    List<CustomerDebtItem> customersWithDebts = [];
    for (var map in maps) {
      var customer = Customer.fromMap(map);
      List<Map<String, dynamic>> debtsMaps =
          await MyDatabase.myDatabase.rawQuery("""
        SELECT currency, SUM(amount) AS total_debt
        FROM debts
        WHERE customer_id = ${customer.id} 
        GROUP BY currency;
      """);
      String debt = '';
      for (var debtMap in debtsMaps) {
        debt = '$debt${debtMap['total_debt']} ${debtMap['currency']}\n';
      }
      customersWithDebts.add(CustomerDebtItem(customer: customer, debt: debt));
    }
    return customersWithDebts;
  }

  static Future<List<CustomerDebtItem>> getSearchedCustomers(
      MainController mainController, int page, String searchedText) async {
    var trimText = searchedText.trim();
    List<Map<String, dynamic>> maps = await MyDatabase.myDatabase.rawQuery('''
        SELECT c.*, SUM(IFNULL((d.amount * (
            SELECT exchange_rate 
            FROM currencies_exchange 
            WHERE currency_1='${mainController.storeData.value!.currency}' 
            AND currency_2='d.currency'
            )
          ), 0)) as debt
        FROM customers AS c LEFT JOIN debts as d ON c.id = d.customer_id 
        WHERE name like '%$trimText%'
        GROUP BY c.id
        ORDER BY id COLLATE NOCASE ASC 
        LIMIT ${page * 40}, 40
     ''');
    List<CustomerDebtItem> customersWithDebts = [];
    for (var map in maps) {
      var customer = Customer.fromMap(map);
      List<Map<String, dynamic>> debtsMaps =
          await MyDatabase.myDatabase.rawQuery("""
        SELECT currency, SUM(amount) AS total_debt
        FROM debts
        WHERE customer_id = ${customer.id} 
        GROUP BY currency;
      """);
      String debt = '';
      for (var debtMap in debtsMaps) {
        debt = '$debt${debtMap['total_debt']} ${debtMap['currency']}\n';
      }
      customersWithDebts.add(CustomerDebtItem(customer: customer, debt: debt));
    }
    return customersWithDebts;
  }
}
