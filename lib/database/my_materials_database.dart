import 'package:sqflite_common_ffi/sqflite_ffi.dart';

import 'entities/activity.dart';
import 'entities/my_material.dart';
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

  static Future<int> insertMaterial(MyMaterial material, int actionBy) async {
    return await MyDatabase.myDatabase.transaction((txn) async {
      var actionDate = DateTime.now().millisecondsSinceEpoch;
      await txn.insert(
        'units',
        {'name': material.unit},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      // await txn.insert(
      //   'currencies',
      //   {'name': material.currency},
      //   conflictAlgorithm: ConflictAlgorithm.ignore,
      // );
      material.id = await txn.insert(
        'materials',
        material.toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      await txn.insert(
        'activities',
        Activity(
                date: actionDate, action: 'add', tableName: 'materials_history')
            .toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      var historyMap = material.toMap();
      historyMap['id'] = null;
      historyMap.putIfAbsent('material_id', () => material.id);
      historyMap.putIfAbsent('action_by', () => actionBy);
      historyMap.putIfAbsent('action_date', () => actionDate);
      await txn.insert(
        'materials_history',
        historyMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );

      return material.id!;
    });
  }

  static Future<void> updateMaterial(MyMaterial material, int actionBy) async {
    return await MyDatabase.myDatabase.transaction((txn) async {
      var actionDate = DateTime.now().millisecondsSinceEpoch;
      await txn.insert(
        'units',
        {'name': material.unit},
        conflictAlgorithm: ConflictAlgorithm.ignore,
      );
      // await txn.insert(
      //   'currencies',
      //   {'name': material.currency},
      //   conflictAlgorithm: ConflictAlgorithm.ignore,
      // );
      await txn.update(
        'materials',
        material.toMap(),
        where: 'id = ?',
        whereArgs: [material.id],
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      await txn.insert(
        'activities',
        Activity(
                date: actionDate,
                action: 'update',
                tableName: 'materials_history')
            .toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      var historyMap = material.toMap();
      historyMap['id'] = null;
      historyMap.putIfAbsent('material_id', () => material.id);
      historyMap.putIfAbsent('action_by', () => actionBy);
      historyMap.putIfAbsent('action_date', () => actionDate);
      await txn.insert(
        'materials_history',
        historyMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
    });
  }

  static Future<void> deleteMaterial(MyMaterial material, int actionBy) async {
    return await MyDatabase.myDatabase.transaction((txn) async {
      var actionDate = DateTime.now().millisecondsSinceEpoch;
      await txn.delete(
        'materials',
        where: 'id = ?',
        whereArgs: [material.id],
      );
      await txn.insert(
        'activities',
        Activity(
                date: actionDate,
                action: 'delete',
                tableName: 'materials_history')
            .toMap(),
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
      var historyMap = material.toMap();
      historyMap['id'] = null;
      historyMap.putIfAbsent('material_id', () => material.id);
      historyMap.putIfAbsent('action_by', () => actionBy);
      historyMap.putIfAbsent('action_date', () => actionDate);
      await txn.insert(
        'materials_history',
        historyMap,
        conflictAlgorithm: ConflictAlgorithm.replace,
      );
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
