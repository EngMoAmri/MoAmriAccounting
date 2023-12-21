import 'package:get/get.dart';
import 'package:moamri_accounting/database/entities/material_larger_unit.dart';
import 'package:moamri_accounting/database/items/material_larger_unit_item.dart';
import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'entities/my_material.dart';
import 'my_database.dart';

class MyMaterialsDatabase {
  static Future<MyMaterial?> getMaterialByBarcode(String barcode) async {
    List<Map<String, dynamic>> maps = await MyDatabase.myDatabase
        .query('materials', where: "barcode = ?", whereArgs: [barcode]);
    if (maps.isEmpty) return null;
    return MyMaterial.fromMap(maps.first);
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

  static Future<List<String>> searchForCurrency(String text) async {
    var trimText = text.trim();
    List<Map<String, dynamic>> maps = await MyDatabase.myDatabase.query(
        'currencies',
        distinct: true,
        where: "name like ?",
        whereArgs: ["%$trimText%"],
        limit: 10);

    List<String> currencies = [];
    for (var map in maps) {
      currencies.add(map['name']);
    }
    return currencies;
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

  static Future<int> getMaterialsCount({category}) async {
    List<Map<String, Object?>> totalRow;
    if (category == 'All'.tr || category == null) {
      totalRow = await MyDatabase.myDatabase
          .rawQuery('SELECT COUNT(id) FROM materials');
    } else {
      totalRow = await MyDatabase.myDatabase.rawQuery(
          "SELECT COUNT(id) FROM materials WHERE category = '$category'");
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

  static Future<void> insertCurrency(String currency) async {
    await MyDatabase.myDatabase.insert(
      'currencies',
      {'name': currency},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  static Future<void> insertMaterial(
      MyMaterial material, MaterialLargerUnit? materialLargerUnit) async {
    await MyDatabase.myDatabase.transaction((txn) async {
      await txn.insert(
        'units',
        {'name': material.unit},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      await txn.insert(
        'currencies',
        {'name': material.currency},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      var materialID = await txn.insert(
        'materials',
        material.toMap(),
        conflictAlgorithm: ConflictAlgorithm.fail,
      );
      if (materialLargerUnit != null) {
        materialLargerUnit.materialID = materialID;
        await txn.insert('materials_larger_units', materialLargerUnit.toMap());
      }
    });
  }

  static Future<void> updateMaterial(
      MyMaterial material, MaterialLargerUnit? materialLargerUnit) async {
    await MyDatabase.myDatabase.transaction((txn) async {
      await txn.insert(
        'units',
        {'name': material.unit},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      await txn.insert(
        'currencies',
        {'name': material.currency},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      await txn.update(
        'materials',
        material.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await txn.delete('materials_larger_units',
          where: 'material_id = ?', whereArgs: [material.id]);
      if (materialLargerUnit != null) {
        await txn.insert('materials_larger_units', materialLargerUnit.toMap());
      }
    });
  }

  static Future<void> deleteMaterial(MyMaterial material) async {
    await MyDatabase.myDatabase
        .delete('materials', where: 'id = ?', whereArgs: [material.id]);
  }

  static Future<MyMaterial> getMaterialByID(int id) async {
    List<Map<String, dynamic>> maps = await MyDatabase.myDatabase
        .query('materials', where: "id = ?", whereArgs: [id]);
    return MyMaterial.fromMap(maps
        .first); // the maps can not be empty or this method can not be called with empty material
  }

  static Future<bool> isMaterialDeletable(int id) async {
    // TODO test
    List<Map<String, dynamic>> maps = await MyDatabase.myDatabase
        .query('sales', where: "material_id = ?", whereArgs: [id]);
    if (maps.isNotEmpty) return false;
    List<Map<String, dynamic>> maps2 = await MyDatabase.myDatabase
        .query('purchases', where: "material_id = ?", whereArgs: [id]);
    if (maps2.isNotEmpty) return false;
    return true;
  }

  static Future<List<MyMaterial>> getMaterials(int page,
      {category, orderBy, dir}) async {
    List<Map<String, dynamic>> maps;
    if (category == 'All'.tr || category == null) {
      maps = await MyDatabase.myDatabase.query(
        'materials',
        limit: 100,
        offset: page * 100,
        orderBy: "${orderBy ?? "id"} COLLATE NOCASE ${dir ?? "ASC"}",
      );
    } else {
      maps = await MyDatabase.myDatabase.query(
        'materials',
        where: 'category = ?',
        whereArgs: [category],
        limit: 10,
        offset: page * 10,
        orderBy: "${orderBy ?? "id"} COLLATE NOCASE ${dir ?? "ASC"}",
      );
    }
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

  static Future<Map<String, List<MyMaterial>>> getAllMaterials() async {
    List<Map<String, dynamic>> maps;
    maps = await MyDatabase.myDatabase.query(
      'materials',
      orderBy: "id COLLATE NOCASE ASC",
    );
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

  static Future<MaterialLargerUnitItem?> getMaterialLargerUnitItem(
      MyMaterial material) async {
    List<Map<String, dynamic>> maps;
    maps = await MyDatabase.myDatabase.query('materials_larger_units',
        where: "material_id = ?", whereArgs: [material.id]);
    if (maps.isEmpty) return null;
    return MaterialLargerUnitItem(
        material: material,
        largerMaterial: await getMaterialByID(maps.first['larger_material_id']),
        suppliedQuantity: maps.first['quantity_supplied']);
  }
}
