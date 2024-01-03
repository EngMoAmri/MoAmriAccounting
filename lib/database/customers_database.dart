import 'package:moamri_accounting/controllers/main_controller.dart';
import 'package:moamri_accounting/database/entities/customer.dart';
import 'package:moamri_accounting/database/items/customer_debt_item.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import '../utils/global_utils.dart';
import 'entities/audit.dart';
import 'entities/user.dart';
import 'my_database.dart';

class CustomersDatabase {
  static Future<int> getCustomersDebt(Customer customer) async {
    // List<Map<String, Object?>> totalRow;
    // totalRow = await MyDatabase.myDatabase.rawQuery(
    //     "SELECT SUM(id) FROM customers WHERE name like '%$trimText%'");
    // return int.tryParse(totalRow[0]["COUNT(id)"].toString()) ?? 0;
    throw Exception("TODO");
  }

  static Future<bool> isCustomerDeletable(int customerId) async {
    List<Map<String, dynamic>> maps = await MyDatabase.myDatabase
        .rawQuery('''SELECT * FROM debts WHERE customer_id = $customerId''');
    if (maps.isNotEmpty) return false;
    return true;
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

  static Future<int> insertCustomer(Customer customer, User actionBy) async {
    return await MyDatabase.myDatabase.transaction((txn) async {
      customer.id = await txn.insert(
        "customers",
        customer.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await txn.insert(
        'audits',
        Audit(
          date: DateTime.now().millisecondsSinceEpoch,
          action: 'add',
          table: 'customers',
          entityId: customer.id!,
          oldData: null,
          newData: Audit.mapToString(customer.toMap()),
          userId: actionBy.id!,
          userData: Audit.mapToString(actionBy.toMap()),
        ).toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return customer.id!;
    });
  }

  static Future<void> updateCustomer(
      Customer customer, Customer oldCustomer, User actionBy) async {
    return await MyDatabase.myDatabase.transaction((txn) async {
      await txn.update(
        'customers',
        customer.toMap(),
        where: 'id = ?',
        whereArgs: [customer.id],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await txn.insert(
        'audits',
        Audit(
          date: DateTime.now().millisecondsSinceEpoch,
          action: 'update',
          table: 'customers',
          entityId: customer.id!,
          oldData: Audit.mapToString(oldCustomer.toMap()),
          newData: Audit.mapToString(customer.toMap()),
          userId: actionBy.id!,
          userData: Audit.mapToString(actionBy.toMap()),
        ).toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  static Future<void> deleteCustomer(Customer customer, User actionBy) async {
    return await MyDatabase.myDatabase.transaction((txn) async {
      await txn.delete(
        'customers',
        where: 'id = ?',
        whereArgs: [customer.id],
      );
      await txn.insert(
        'audits',
        Audit(
          date: DateTime.now().millisecondsSinceEpoch,
          action: 'delete',
          table: 'customers',
          entityId: customer.id!,
          oldData: Audit.mapToString(customer.toMap()),
          newData: null,
          userId: actionBy.id!,
          userData: Audit.mapToString(actionBy.toMap()),
        ).toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  static Future<List<CustomerDebtItem>> getCustomersWithDebts(
      MainController mainController, int page,
      {orderBy, dir}) async {
    List<Map<String, dynamic>> maps = await MyDatabase.myDatabase.rawQuery('''
        SELECT c.*, SUM(IFNULL((d.amount * 
            (SELECT exchange_rate 
             FROM currencies 
             WHERE name=d.currency)
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
        debt =
            '$debt${GlobalUtils.getMoney(debtMap['total_debt'])} ${debtMap['currency']}\n';
      }
      if (debt.isEmpty) {
        debt = 'لا يوجد دين';
      }
      customersWithDebts.add(CustomerDebtItem(customer: customer, debt: debt));
    }
    return customersWithDebts;
  }

  static Future<List<CustomerDebtItem>> getSearchedCustomers(
      MainController mainController, int page, String searchedText) async {
    var trimText = searchedText.trim();
    List<Map<String, dynamic>> maps = await MyDatabase.myDatabase.rawQuery('''
          SELECT c.*, SUM(IFNULL((d.amount * 
            (SELECT exchange_rate 
             FROM currencies 
             WHERE name=d.currency)
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
        debt =
            '$debt${GlobalUtils.getMoney(debtMap['total_debt'])} ${debtMap['currency']}\n';
      }
      if (debt.isEmpty) {
        debt = 'لا يوجد دين';
      }

      customersWithDebts.add(CustomerDebtItem(customer: customer, debt: debt));
    }
    return customersWithDebts;
  }

  static Future<Customer?> getCustomerByID(int? id) async {
    if (id == null) return null;
    List<Map<String, dynamic>> maps;
    maps = await MyDatabase.myDatabase.query(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
    );
    if (maps.isEmpty) return null;
    return Customer.fromMap(maps.first);
  }
}
