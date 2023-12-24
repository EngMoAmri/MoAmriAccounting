import 'package:moamri_accounting/database/entities/customer.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'my_database.dart';

class CustomersDatabase {
  static Future<String> generateCustomerBarcode() async {
    List<Map<String, Object?>> totalRow;
    totalRow =
        await MyDatabase.myDatabase.rawQuery("SELECT MAX(id) FROM customers");
    if (totalRow.isEmpty) return '1000';
    return '${(int.tryParse(totalRow[0]["MAX(id)"].toString()) ?? 0) + 10000}';
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

  static Future<void> insertCustomer(Customer customer) async {
    await MyDatabase.myDatabase.insert(
      'customers',
      customer.toMap(),
      conflictAlgorithm: ConflictAlgorithm.fail,
    );
  }

  static Future<void> updateCustomer(Customer customer) async {
    await MyDatabase.myDatabase.update(
      'customers',
      customer.toMap(),
      where: 'id = ?',
      whereArgs: [customer.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<void> deleteCustomer(Customer customer) async {
    await MyDatabase.myDatabase
        .delete('customers', where: 'id = ?', whereArgs: [customer.id]);
  }

  static Future<bool> isCustomerDeletable(int id) async {
    // TODO test
    List<Map<String, dynamic>> maps = await MyDatabase.myDatabase
        .query('invoices', where: "customer_id = ?", whereArgs: [id]);
    if (maps.isNotEmpty) return false;
    return true;
  }

  static Future<List<Customer>> getCustomers(int page, {orderBy, dir}) async {
    List<Map<String, dynamic>> maps;
    maps = await MyDatabase.myDatabase.query(
      'customers',
      limit: 40,
      offset: page * 40,
      orderBy: "${orderBy ?? "id"} COLLATE NOCASE ${dir ?? "ASC"}",
    );
    List<Customer> customers = [];
    for (var map in maps) {
      customers.add(Customer.fromMap(map));
    }
    return customers;
  }

  static Future<List<Customer>> getSearchedCustomers(
      int page, String searchedText) async {
    var trimText = searchedText.trim();
    List<Map<String, dynamic>> maps;
    maps = await MyDatabase.myDatabase.query(
      'customers',
      where: 'name like ?',
      whereArgs: ["%$trimText%"],
      limit: 40,
      offset: page * 40,
      orderBy: "id COLLATE NOCASE ASC",
    );
    List<Customer> customers = [];
    for (var map in maps) {
      customers.add(Customer.fromMap(map));
    }
    return customers;
  }
}
