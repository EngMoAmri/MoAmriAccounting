import 'package:get/get.dart';

import 'entities/my_material.dart';
import 'my_database.dart';

class MyMaterialsDatabase {
  static Future<int> generateMaterialID() async {
    List<Map<String, Object?>> totalRow;
    totalRow = await MyDatabase.myDatabase
        .rawQuery('SELECT seq FROM sqlite_sequence WHERE name="materials"');
    if (totalRow.isEmpty) return 10000;
    return int.tryParse(totalRow[0]["seq"].toString()) ?? 0 + 1;
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
}
