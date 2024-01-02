import 'package:moamri_accounting/database/items/my_material_item.dart';
import 'package:moamri_accounting/sale/controllers/sale_controller.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'entities/audit.dart';
import 'entities/my_material.dart';
import 'entities/user.dart';
import 'my_database.dart';

class MyMaterialsDatabase {
  static Future<MyMaterial?> getMaterialByBarcode(String barcode) async {
    List<Map<String, dynamic>> maps = await MyDatabase.myDatabase
        .query('materials', where: "barcode = ?", whereArgs: [barcode]);
    if (maps.isEmpty) return null;
    return MyMaterial.fromMap(maps.first);
  }

  static Future<bool> isMaterialDeletable(int materialId) async {
    List<Map<String, dynamic>> maps = await MyDatabase.myDatabase.rawQuery(
        '''SELECT * FROM materials WHERE larger_material_id = $materialId''');
    if (maps.isNotEmpty) return false;
    List<Map<String, dynamic>> maps2 = await MyDatabase.myDatabase.rawQuery(
        '''SELECT * FROM offers_materials WHERE material_id = $materialId''');
    if (maps2.isNotEmpty) return false;
    return true;
  }

  static Future<String> generateMaterialBarcode() async {
    List<Map<String, Object?>> totalRow;
    totalRow =
        await MyDatabase.myDatabase.rawQuery("SELECT MAX(id) FROM materials");
    if (totalRow.isEmpty) return '1000';
    return '${(int.tryParse(totalRow[0]["MAX(id)"].toString()) ?? 0) + 10000}';
  }

  static Future<List<String>> searchForCategories(String text) async {
    var trimText = text.trim();
    List<Map<String, dynamic>> maps = await MyDatabase.myDatabase.query(
        'materials',
        distinct: true,
        columns: ['category'],
        where: "category like ?",
        whereArgs: ["%$trimText%"],
        limit: 10);

    List<String> categories = [];
    for (var map in maps) {
      categories.add(map['category']);
    }
    return categories;
  }

  static Future<List<String>> searchForUnits(String text) async {
    var trimText = text.trim();
    List<Map<String, dynamic>> maps = await MyDatabase.myDatabase.query('units',
        distinct: true,
        where: "name like ?",
        whereArgs: ["%$trimText%"],
        limit: 10);

    List<String> categories = [];
    for (var map in maps) {
      categories.add(map['name']);
    }
    return categories;
  }

  static Future<List<String>> getMaterialsCategories() async {
    List<Map<String, dynamic>> maps = await MyDatabase.myDatabase
        .query('materials', columns: ['category'], distinct: true);
    List<String> categories = [];
    for (var map in maps) {
      if (map['category'] != null) {
        categories.add(map['category']);
      }
    }
    return categories;
  }

  static Future<int> getMaterialsCount({category, searchedText}) async {
    List<Map<String, Object?>> totalRow;
    if (searchedText == null) {
      if (category == 'الكل' || category == null) {
        totalRow = await MyDatabase.myDatabase
            .rawQuery('SELECT COUNT(id) FROM materials');
      } else {
        totalRow = await MyDatabase.myDatabase.rawQuery(
            "SELECT COUNT(id) FROM materials WHERE category = '$category'");
      }
    } else {
      var trimText = searchedText.trim();

      totalRow = await MyDatabase.myDatabase.rawQuery(
          "SELECT COUNT(id) FROM materials WHERE name like '%$trimText%' or barcode like '%$trimText%'");
    }
    return int.tryParse(totalRow[0]["COUNT(id)"].toString()) ?? 0;
  }

  static Future<List<MyMaterial>> getMaterialsSuggestions(
      String text, int? currentMaterialID) async {
    String trimText = text.trim();
    List<Map<String, dynamic>> maps;
    maps = await MyDatabase.myDatabase.query('materials',
        distinct: true,
        where: "barcode like ? or name like ?",
        whereArgs: ["%$trimText%", "%$trimText%"],
        limit: 10);
    List<MyMaterial> materials = [];
    for (var map in maps) {
      if (map['id'] != currentMaterialID) {
        materials.add(MyMaterial.fromMap(map));
      }
    }
    return materials;
  }

  static Future<List<MyMaterial>> getAvailableLargerMaterialsSuggestions(
      String text, int? currentMaterialID) async {
    String trimText = text.trim();
    List<Map<String, dynamic>> maps;
    maps = await MyDatabase.myDatabase.query('materials',
        distinct: true,
        where: "barcode like ? or name like ?",
        whereArgs: ["%$trimText%", "%$trimText%"],
        limit: 10);
    List<MyMaterial> materials = [];
    for (var map in maps) {
      if (map['id'] != currentMaterialID) {
        if (map['larger_material_id'] != null) {
          if (map['larger_material_id'] == currentMaterialID) {
            continue;
          }
        }
        materials.add(MyMaterial.fromMap(map));
      }
    }
    return materials;
  }

  static Future<int> insertMaterial(MyMaterial material, User actionBy) async {
    return await MyDatabase.myDatabase.transaction((txn) async {
      await txn.insert(
        'units',
        {'name': material.unit},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      material.id = await txn.insert(
        'materials',
        material.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await txn.insert(
        'audits',
        Audit(
          date: DateTime.now().millisecondsSinceEpoch,
          action: 'add',
          table: 'materials',
          entityId: material.id!,
          oldData: null,
          newData: Audit.mapToString(material.toMap()),
          userId: actionBy.id!,
          userData: Audit.mapToString(actionBy.toMap()),
        ).toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      return material.id!;
    });
  }

  static Future<void> updateMaterial(
      MyMaterial material, MyMaterial oldMaterial, User actionBy) async {
    return await MyDatabase.myDatabase.transaction((txn) async {
      await txn.insert(
        'units',
        {'name': material.unit},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      await txn.update(
        'materials',
        material.toMap(),
        where: 'id = ?',
        whereArgs: [material.id],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await txn.insert(
        'audits',
        Audit(
          date: DateTime.now().millisecondsSinceEpoch,
          action: 'update',
          table: 'materials',
          entityId: material.id!,
          oldData: Audit.mapToString(oldMaterial.toMap()),
          newData: Audit.mapToString(material.toMap()),
          userId: actionBy.id!,
          userData: Audit.mapToString(actionBy.toMap()),
        ).toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  static Future<void> deleteMaterial(MyMaterial material, User actionBy) async {
    return await MyDatabase.myDatabase.transaction((txn) async {
      await txn.delete(
        'materials',
        where: 'id = ?',
        whereArgs: [material.id],
      );
      await txn.insert(
        'audits',
        Audit(
          date: DateTime.now().millisecondsSinceEpoch,
          action: 'delete',
          table: 'materials',
          entityId: material.id!,
          oldData: Audit.mapToString(material.toMap()),
          newData: null,
          userId: actionBy.id!,
          userData: Audit.mapToString(actionBy.toMap()),
        ).toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  static Future<MyMaterial> getMaterialByID(int id, Transaction? tnx) async {
    if (tnx == null) {
      List<Map<String, dynamic>> maps = await MyDatabase.myDatabase
          .query('materials', where: "id = ?", whereArgs: [id]);
      // if (maps.isEmpty) return null;
      return MyMaterial.fromMap(maps.first);
    } else {
      List<Map<String, dynamic>> maps =
          await tnx.query('materials', where: "id = ?", whereArgs: [id]);
      // if (maps.isEmpty) return null;
      return MyMaterial.fromMap(maps.first);
    }
  }

  static Future<MyMaterialItem?> getMyMaterialItem(
    MyMaterial material,
  ) async {
    return MyMaterialItem(
        material: material,
        largerMaterial: (material.largerMaterialID == null)
            ? null
            : await getMyMaterialItem(
                (await getMaterialByID(material.largerMaterialID!, null))),
        smallerMaterial: null);
  }

// TODO Sale
  static Future<void> supplyMaterialQuantityFromLargerMaterialsTransaction(
      MyMaterial material, double requiredQuantity, Transaction txn) async {
    var availableQuantity = material.quantity;
    var quantityToBeSupplied = requiredQuantity - availableQuantity;
    if (quantityToBeSupplied <= 0 || (material.largerMaterialID == null)) {
      return;
    }
    var largerMaterial = await getMaterialByID(material.largerMaterialID!, txn);
    var requiredLargerQuantity =
        (quantityToBeSupplied / material.quantitySupplied!).ceil().toDouble();
    if (largerMaterial.quantity < requiredLargerQuantity) {
      await supplyMaterialQuantityFromLargerMaterialsTransaction(
          largerMaterial, requiredLargerQuantity, txn);
    }
    largerMaterial = await getMaterialByID(material.largerMaterialID!, txn);

    largerMaterial.quantity -= requiredLargerQuantity;
    await txn.update(
      'materials',
      largerMaterial.toMap(),
      where: 'id = ?',
      whereArgs: [material.largerMaterialID],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
    material.quantity += (requiredLargerQuantity * material.quantitySupplied!);
    await txn.update(
      'materials',
      material.toMap(),
      where: 'id = ?',
      whereArgs: [material.id],
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  static Future<double> getAvailableQuantity(
      MyMaterial material, SaleController? saleController) async {
    var materialItem = await MyMaterialsDatabase.getMyMaterialItem(material);

    // first we set the quantity to current material
    var availableQuantity = materialItem!.material.quantity;
    //then we search in larger material
    while (materialItem?.largerMaterial != null) {
      var largerQuantity = materialItem!.largerMaterial!.material.quantity;
      if (saleController != null) {
        // minus the selected one in sale page
        for (var saleData2 in saleController.dataSource.value.salesData) {
          if (saleData2['Material'].id ==
              materialItem.largerMaterial!.material.id) {
            largerQuantity -= saleData2['Quantity'];
          }
        }
      }
      var quantity = (largerQuantity * materialItem.material.quantitySupplied!);
      var smallerMaterial = materialItem.smallerMaterial;
      // we multiply by smaller units until we reach the unit similar to the selected one
      while (smallerMaterial != null) {
        quantity *= materialItem.smallerMaterial!.material.quantitySupplied!;
        smallerMaterial = smallerMaterial.smallerMaterial;
      }
      availableQuantity += quantity;
      materialItem.largerMaterial?.smallerMaterial = materialItem;
      materialItem = materialItem.largerMaterial;
    }
    print(availableQuantity);
    return availableQuantity;
  }

  static Future<bool> isMaterialLargerToMaterialId(
      MyMaterial material1, int? material2Id) async {
    // there is no larger material
    if (material2Id == null) return false;
    // this is the larger material
    if (material1.largerMaterialID == material2Id) return true;
    // search again
    List<Map<String, dynamic>> maps = await MyDatabase.myDatabase
        .rawQuery('''SELECT * FROM materials WHERE id = $material2Id''');
    if (maps.isEmpty) return false;
    MyMaterial material2 = MyMaterial.fromMap(maps.first);
    return await isMaterialLargerToMaterialId(material2, material2Id);
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
