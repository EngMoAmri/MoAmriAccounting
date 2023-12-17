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
    List<Map<String, dynamic>> maps = await MyDatabase.myDatabase.query(
        'materials',
        distinct: true,
        columns: ['unit'],
        where: "unit like ?",
        whereArgs: ["%$trimText%"],
        limit: 10);

    List<String> categories = [
      'Gram',
      'Kilo',
      'Pound',
      'Ton',
      'Piece',
      'Meter',
      'CM'
    ];
    for (var map in maps) {
      if (categories.contains(map['unit'])) {
        categories.add(map['unit']);
      }
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

  static Future<List<MyMaterial>> getMaterialsSuggestions(String text) async {
    String trimText = text.trim();
    List<Map<String, dynamic>> maps;
    maps = await MyDatabase.myDatabase.query('materials',
        distinct: true,
        where: "barcode like ? or name like ?",
        whereArgs: ["%$trimText%", "%$trimText%"],
        limit: 10);
    List<MyMaterial> materials = [];
    for (var map in maps) {
      materials.add(MyMaterial.fromMap(map));
    }
    return materials;
  }

  static Future<void> insertMaterial(
      MyMaterial material, MaterialLargerUnit? materialLargerUnit) async {
    await MyDatabase.myDatabase.transaction((txn) async {
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

  static Future<MyMaterial> getMaterialByID(int id) async {
    List<Map<String, dynamic>> maps = await MyDatabase.myDatabase
        .query('materials', where: "id = ?", whereArgs: [id]);
    return MyMaterial.fromMap(maps
        .first); // the maps can not be empty or this method can not be called with empty material
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
