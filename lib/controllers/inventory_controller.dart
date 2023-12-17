import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/database/entities/my_material.dart';
import 'package:moamri_accounting/database/my_materials_database.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../data_sources/my_materials_data_source.dart';

class InventoryController extends GetxController {
  final searchController = TextEditingController();
  final DataGridController dataGridController = DataGridController();

  Rx<bool> searching = false.obs;
  Rx<List<MyMaterial>> materials = Rx([]);
  Rx<int> page = 0.obs;
  Rx<int> materialsCount = 0.obs;
  Rx<bool> isFirstLoadRunning = false.obs;
  Rx<bool> hasNextPage = true.obs;
  Rx<List<String>> categories = Rx(['All'.tr]);
  Rx<int> selectedCategory = 0.obs;

  Rx<List<String>> orderBy =
      Rx(['ID', 'Name', 'Price', 'Addition', 'Discount', 'Tax']);
  Rx<int> selectedOrderBy = 0.obs;
  Rx<int> selectedOrderDir = 1.obs;

  Rx<MyMaterialsDataSource> dataSource = Rx(MyMaterialsDataSource([]));
  Future<void> getCategories() async {
    var categories = await MyMaterialsDatabase.getMaterialsCategories();
    this.categories.value.clear();
    this.categories.value.add('All'.tr);
    this.categories.value.addAll(categories);
    this.categories.refresh();
  }

  void firstLoad() async {
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
              orderBy: orderBy.value[selectedOrderBy.value],
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

  Future<void> loadMore() async {
    if (hasNextPage.value == true) {
      var newLoadedMaterials = await MyMaterialsDatabase.getMaterials(
          category: categories.value[selectedCategory.value],
          orderBy: orderBy.value[selectedOrderBy.value],
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
    }
  }

  @override
  void onInit() {
    firstLoad();
    super.onInit();
  }
}
