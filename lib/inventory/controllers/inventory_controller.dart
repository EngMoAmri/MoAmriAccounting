import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/database/entities/my_material.dart';
import 'package:moamri_accounting/database/my_materials_database.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../data_sources/my_materials_data_source.dart';

class InventoryController extends GetxController {
  final DataGridController dataGridController = DataGridController();
  Rx<Map<String, double>> columnWidths = Rx({
    'Barcode': double.nan,
    'Name': double.nan,
    'Category': double.nan,
    'Quantity': double.nan,
    'Unit': double.nan,
    'Cost Price': double.nan,
    'Sale Price': double.nan,
    'Note': double.nan
  });

  Rx<bool> searching = false.obs;
  Rx<List<MyMaterial>> materials = Rx([]);
  Rx<int> page = 0.obs;
  Rx<int> materialsCount = 0.obs;
  Rx<bool> isFirstLoadRunning = false.obs;
  Rx<bool> hasNextPage = true.obs;
  Rx<List<String>> categories = Rx(['الكل']);
  Rx<int> selectedCategory = 0.obs;
  final searchController = TextEditingController();
  Rx<bool> isSearching =
      false.obs; // this is to hide sort and categories button

  final Rx<List<String>> orderBy =
      Rx(['الاسم', 'الكمية', 'سعر الشراء', 'سعر البيع', 'الإضافة']);
  final Rx<List<String>> orderByDatabase = Rx([
    'name',
    'quantity',
    'exchanged_cost_price',
    'exchanged_sale_price',
    'id'
  ]);
  Rx<int> selectedOrderBy = 4.obs;
  Rx<int> selectedOrderDir = 1.obs;

  Rx<MyMaterialsDataSource> dataSource = Rx(MyMaterialsDataSource([]));
  Future<void> getCategories() async {
    var categories = await MyMaterialsDatabase.getMaterialsCategories();
    this.categories.value.clear();
    this.categories.value.add('الكل');
    this.categories.value.addAll(categories);
    this.categories.refresh();
  }

  void firstLoad() async {
    isSearching.value = false;
    // reset variables
    await getCategories();
    materials.value.clear();
    page.value = 0;
    materialsCount.value = 0;
    hasNextPage.value = true;
    isFirstLoadRunning.value = true;

    MyMaterialsDatabase.getMaterialsCount(
            category: categories.value[selectedCategory.value])
        .then((materialsCount) {
      MyMaterialsDatabase.getMaterials(
              category: categories.value[selectedCategory.value],
              orderBy: orderByDatabase.value[selectedOrderBy.value],
              dir: (selectedOrderDir.value == 0) ? "ASC" : "DESC",
              page.value)
          .then((newLoadedMaterials) {
        materials.value = newLoadedMaterials;
        dataSource.value = MyMaterialsDataSource(materials.value);
        this.materialsCount.value = materialsCount;
        if (newLoadedMaterials.isEmpty ||
            (materials.value.length) == materialsCount) {
          hasNextPage.value = false;
        }
        page.value++;
        isFirstLoadRunning.value = false;
      });
    });
  }

  void search() async {
    isSearching.value = true;

    // reset variables
    materials.value.clear();
    page.value = 0;
    materialsCount.value = 0;
    hasNextPage.value = true;
    isFirstLoadRunning.value = true;

    MyMaterialsDatabase.getMaterialsCount(searchedText: searchController.text)
        .then((materialsCount) {
      MyMaterialsDatabase.getSearchedMaterials(
              page.value, searchController.text)
          .then((newLoadedMaterials) {
        materials.value = newLoadedMaterials;
        dataSource.value = MyMaterialsDataSource(materials.value);
        this.materialsCount.value = materialsCount;
        if (newLoadedMaterials.isEmpty ||
            (materials.value.length) == materialsCount) {
          hasNextPage.value = false;
        }
        page.value++;
        isFirstLoadRunning.value = false;
      });
    });
  }

  Future<void> loadMore() async {
    if (hasNextPage.value == true) {
      if (!isSearching.value) {
        var newLoadedMaterials = await MyMaterialsDatabase.getMaterials(
            category: categories.value[selectedCategory.value],
            orderBy: orderByDatabase.value[selectedOrderBy.value],
            dir: (selectedOrderDir.value == 0) ? "ASC" : "DESC",
            page.value);
        materials.value.addAll(newLoadedMaterials);
        materials.refresh();
        dataSource.value = MyMaterialsDataSource(materials.value);
        dataSource.refresh();
        if (newLoadedMaterials.isEmpty ||
            (materials.value.length) == materialsCount.value) {
          hasNextPage.value = false;
        }
        page.value++;
      } else {
        var newLoadedMaterials = await MyMaterialsDatabase.getSearchedMaterials(
            page.value, searchController.text);
        materials.value.addAll(newLoadedMaterials);
        materials.refresh();
        dataSource.value = MyMaterialsDataSource(materials.value);
        dataSource.refresh();
        if (newLoadedMaterials.isEmpty ||
            (materials.value.length) == materialsCount.value) {
          hasNextPage.value = false;
        }
        page.value++;
      }
    }
  }

  @override
  void onInit() {
    firstLoad();
    super.onInit();
  }
}
