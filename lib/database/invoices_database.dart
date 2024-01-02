import 'package:moamri_accounting/database/items/invoice_item.dart';
import 'package:moamri_accounting/database/my_materials_database.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'entities/audit.dart';
import 'entities/my_material.dart';
import 'entities/user.dart';
import 'my_database.dart';

class InvoicesDatabase {
  static Future<int> insertInvoiceItem(
      InvoiceItem invoiceItem, User actionBy) async {
    return await MyDatabase.myDatabase.transaction((txn) async {
      invoiceItem.invoice.id = await txn.insert(
        'invoices',
        invoiceItem.invoice.toMap(),
        conflictAlgorithm: ConflictAlgorithm.fail,
      );
      // set invoice id
      for (var invoiceMaterialItem in invoiceItem.inoviceMaterialsItems) {
        invoiceMaterialItem.invoiceMaterial.invoiceId = invoiceItem.invoice.id;
      }
      for (var invoiceOfferItem in invoiceItem.invoiceOffersItems) {
        invoiceOfferItem.invoiceOffer.invoiceId = invoiceItem.invoice.id;
      }
      for (var payment in invoiceItem.payments) {
        payment.invoiceId = invoiceItem.invoice.id;
      }
      invoiceItem.debt?.invoiceId = invoiceItem.invoice.id;
      // insert invoice data
      for (var invoiceMaterialItem in invoiceItem.inoviceMaterialsItems) {
        await txn.insert(
          'invoices_materials',
          invoiceMaterialItem.invoiceMaterial.toMap(),
          conflictAlgorithm: ConflictAlgorithm.fail,
        );
        await MyMaterialsDatabase
            .supplyMaterialQuantityFromLargerMaterialsTransaction(
                invoiceMaterialItem.material,
                invoiceMaterialItem.invoiceMaterial.quantity,
                txn);
      }
      for (var invoiceOfferItem in invoiceItem.invoiceOffersItems) {
        await txn.insert(
          'invoices_offers',
          invoiceOfferItem.invoiceOffer.toMap(),
          conflictAlgorithm: ConflictAlgorithm.fail,
        );
        if (invoiceOfferItem.invoiceOffer.quantity > 0) {
          throw Exception('TODO reduce the quantity with in update function');
        }
        // reduce the quantity
        // MyMaterial newMaterial = invoiceOfferItem.offer;
        // newMaterial.quantity -= invoiceMaterialItem.invoiceMaterial.quantity;
        // await txn.update(
        //   'materials',
        //   newMaterial.toMap(),
        //   where: 'id = ?',
        //   whereArgs: [newMaterial.id],
        //   conflictAlgorithm: ConflictAlgorithm.fail,
        // );
      }
      for (var payment in invoiceItem.payments) {
        await txn.insert(
          'payments',
          payment.toMap(),
          conflictAlgorithm: ConflictAlgorithm.fail,
        );
      }
      if (invoiceItem.debt != null) {
        await txn.insert(
          'debts',
          invoiceItem.debt!.toMap(),
          conflictAlgorithm: ConflictAlgorithm.fail,
        );
      }
      await txn.insert(
        'audits',
        Audit(
          date: DateTime.now().millisecondsSinceEpoch,
          action: 'add',
          table: 'invoices',
          entityId: invoiceItem.invoice.id!,
          oldData: null,
          newData: Audit.mapToString(invoiceItem.toAuditMap()),
          userId: actionBy.id!,
          userData: Audit.mapToString(actionBy.toMap()),
        ).toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return invoiceItem.invoice.id!;
    });
  }

  // static Future<void> updateInvoice(InvoiceItem invoiceItem,
  //     InvoiceItem oldInvoiceItem, User actionBy) async {
  //   return await MyDatabase.myDatabase.transaction((txn) async {
  //     // delete prevous invoice item data
  //     await txn.delete(
  //       'invoices_materials',
  //       where: 'invoice_id = ?',
  //       whereArgs: [oldInvoiceItem.invoice.id],
  //     );
  //     await txn.delete(
  //       'invoices_offers',
  //       where: 'invoice_id = ?',
  //       whereArgs: [oldInvoiceItem.invoice.id],
  //     );
  //     await txn.delete(
  //       'payments',
  //       where: 'invoice_id = ?',
  //       whereArgs: [oldInvoiceItem.invoice.id],
  //     );
  //     await txn.delete(
  //       'debts',
  //       where: 'invoice_id = ?',
  //       whereArgs: [oldInvoiceItem.invoice.id],
  //     );
  //     // update invoice data
  //     await txn.update(
  //       'invoices',
  //       invoiceItem.invoice.toMap(),
  //       where: 'id = ?',
  //       whereArgs: [invoiceItem.invoice.id],
  //       conflictAlgorithm: ConflictAlgorithm.fail,
  //     );
  //     // set invoice id
  //     for (var invoiceMaterialItem in invoiceItem.inoviceMaterialsItems) {
  //       invoiceMaterialItem.invoiceMaterial.invoiceId = invoiceItem.invoice.id;
  //     }
  //     for (var invoiceOfferItem in invoiceItem.invoiceOffersItems) {
  //       invoiceOfferItem.invoiceOffer.invoiceId = invoiceItem.invoice.id;
  //     }
  //     for (var payment in invoiceItem.payments) {
  //       payment.invoiceId = invoiceItem.invoice.id;
  //     }
  //     invoiceItem.debt?.invoiceId = invoiceItem.invoice.id;
  //     // insert invoice data
  //     for (var invoiceMaterialItem in invoiceItem.inoviceMaterialsItems) {
  //       await txn.insert(
  //         'invoices_materials',
  //         invoiceMaterialItem.invoiceMaterial.toMap(),
  //         conflictAlgorithm: ConflictAlgorithm.fail,
  //       );
  //       // reduce the quantity
  //       // TODO test this
  //       MyMaterial newMaterial = invoiceMaterialItem.material;
  //       for (var oldMaterialItem in oldInvoiceItem.inoviceMaterialsItems) {
  //         if (newMaterial.id == oldMaterialItem.material.id) {
  //           newMaterial.quantity += oldMaterialItem.invoiceMaterial.quantity;
  //           break;
  //         }
  //       }
  //       newMaterial.quantity -= invoiceMaterialItem.invoiceMaterial.quantity;
  //       await txn.update(
  //         'materials',
  //         newMaterial.toMap(),
  //         where: 'id = ?',
  //         whereArgs: [newMaterial.id],
  //         conflictAlgorithm: ConflictAlgorithm.fail,
  //       );
  //     }
  //     for (var invoiceOfferItem in invoiceItem.invoiceOffersItems) {
  //       await txn.insert(
  //         'invoices_offers',
  //         invoiceOfferItem.invoiceOffer.toMap(),
  //         conflictAlgorithm: ConflictAlgorithm.fail,
  //       );
  //     }
  //     for (var payment in invoiceItem.payments) {
  //       await txn.insert(
  //         'payments',
  //         payment.toMap(),
  //         conflictAlgorithm: ConflictAlgorithm.fail,
  //       );
  //     }
  //     if (invoiceItem.debt != null) {
  //       await txn.insert(
  //         'debts',
  //         invoiceItem.debt!.toMap(),
  //         conflictAlgorithm: ConflictAlgorithm.fail,
  //       );
  //     }

  //     await txn.insert(
  //       'audits',
  //       Audit(
  //         date: DateTime.now().millisecondsSinceEpoch,
  //         action: 'update',
  //         table: 'invoices',
  //         entityId: invoiceItem.invoice.id!,
  //         oldData: Audit.mapToString(oldInvoiceItem.toAuditMap()),
  //         newData: Audit.mapToString(invoiceItem.toAuditMap()),
  //         userId: actionBy.id!,
  //         userData: Audit.mapToString(actionBy.toMap()),
  //       ).toMap(),
  //       conflictAlgorithm: ConflictAlgorithm.replace,
  //     );
  //   });
  // }

  // static Future<void> deleteMaterial(
  //     InvoiceItem invoiceItem, User actionBy) async {
  //   return await MyDatabase.myDatabase.transaction((txn) async {
  //     await txn.delete(
  //       'invoices',
  //       where: 'id = ?',
  //       whereArgs: [invoiceItem.invoice.id],
  //     );
  //     // all related invoice items will be deleted by foreign key constraint
  //     await txn.insert(
  //       'audits',
  //       Audit(
  //         date: DateTime.now().millisecondsSinceEpoch,
  //         action: 'delete',
  //         table: 'invoices',
  //         entityId: invoiceItem.invoice.id!,
  //         oldData: Audit.mapToString(invoiceItem.toAuditMap()),
  //         newData: null,
  //         userId: actionBy.id!,
  //         userData: Audit.mapToString(actionBy.toMap()),
  //       ).toMap(),
  //       conflictAlgorithm: ConflictAlgorithm.replace,
  //     );
  //   });
  // }

  static Future<MyMaterial> getMaterialByID(int id) async {
    List<Map<String, dynamic>> maps = await MyDatabase.myDatabase
        .query('materials', where: "id = ?", whereArgs: [id]);
    return MyMaterial.fromMap(maps
        .first); // the maps can not be empty or this method can not be called with empty material
  }

  static Future<List<MyMaterial>> getMaterials(int page,
      {category, orderBy, dir}) async {
    List<Map<String, dynamic>> maps;
    if (category == 'الكل' || category == null) {
      maps = await MyDatabase.myDatabase.rawQuery('''
        SELECT *, 
          (cost_price * (
          SELECT exchange_rate 
          FROM currencies 
          WHERE name=currency
          )) as exchanged_cost_price,
          (sale_price * (
          SELECT exchange_rate 
          FROM currencies 
          WHERE name=currency
          )) as exchanged_sale_price 
        FROM materials 
        ORDER BY ${orderBy ?? "id"} COLLATE NOCASE ${dir ?? "ASC"} 
        LIMIT ${page * 40}, 40
     ''');
    } else {
      maps = await MyDatabase.myDatabase.rawQuery('''
        SELECT *, 
          (cost_price * (
          SELECT exchange_rate 
          FROM currencies 
          WHERE name=currency
          )) as exchanged_cost_price,
          (sale_price * (
          SELECT exchange_rate 
          FROM currencies 
          WHERE name=currency
          )) as exchanged_sale_price 
        FROM materials 
        WHERE category = '$category'
        ORDER BY ${orderBy ?? "id"} COLLATE NOCASE ${dir ?? "ASC"} 
        LIMIT ${page * 40}, 40
     ''');
    }
    List<MyMaterial> materials = [];
    for (var map in maps) {
      materials.add(MyMaterial.fromMap(map));
    }
    return materials;
  }

  static Future<List<MyMaterial>> getSearchedMaterials(
      int page, String searchedText) async {
    var trimText = searchedText.trim();
    List<Map<String, dynamic>> maps;
    maps = await MyDatabase.myDatabase.query(
      'materials',
      where: 'name like ? or barcode like ?',
      whereArgs: ["%$trimText%", "%$trimText%"],
      limit: 40,
      offset: page * 40,
      orderBy: "id COLLATE NOCASE ASC",
    );
    List<MyMaterial> materials = [];
    for (var map in maps) {
      materials.add(MyMaterial.fromMap(map));
    }
    return materials;
  }

  static Future<List<MyMaterial>> getCategoryMaterials(String category) async {
    List<Map<String, dynamic>> maps;
    maps = await MyDatabase.myDatabase.query(
      'materials',
      where: 'category = ?',
      whereArgs: [category],
    );
    List<MyMaterial> materials = [];
    for (var map in maps) {
      materials.add(MyMaterial.fromMap(map));
    }
    return materials;
  }

  static Future<Map<String, List<MyMaterial>>> getAllMaterials(
      category, orderBy, dir) async {
    List<Map<String, dynamic>> maps;

    if (category == 'الكل' || category == null) {
      maps = await MyDatabase.myDatabase.query(
        'materials',
        orderBy: "${orderBy ?? "id"} COLLATE NOCASE ${dir ?? "ASC"}",
      );
    } else {
      maps = await MyDatabase.myDatabase.query(
        'materials',
        where: 'category = ?',
        whereArgs: [category],
        orderBy: "${orderBy ?? "id"} COLLATE NOCASE ${dir ?? "ASC"}",
      );
    }

    Map<String, List<MyMaterial>> materialsMap = {};
    for (var map in maps) {
      var material = MyMaterial.fromMap(map);
      if (materialsMap.keys.contains(material.category)) {
        materialsMap[material.category]!.add(material);
      } else {
        materialsMap[material.category] = [material];
      }
    }
    return materialsMap;
  }

  static Future<MyMaterial?> getMaterialLargerUnitItem(
      MyMaterial material) async {
    List<Map<String, dynamic>> maps;
    maps = await MyDatabase.myDatabase.query('materials',
        where: "id = ?", whereArgs: [material.largerMaterialID]);
    if (maps.isEmpty) return null;
    return MyMaterial.fromMap(maps.first);
  }
}
