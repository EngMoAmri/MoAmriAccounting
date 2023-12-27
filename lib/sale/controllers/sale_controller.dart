import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../data_sources/sale_materials_data_source.dart';
import '../../database/entities/my_material.dart';
import '../../database/my_materials_database.dart';

class SaleController extends GetxController {
  final searchController = TextEditingController();
  Rx<bool> searching = false.obs;
  Rx<bool?> visible = Rx(null);
  Rx<Map<String, double>> totals = Rx({});
  Rx<String> totalString = ''.obs;
  Rx<bool> loadingCategories = true.obs;
  Rx<List<String>> categories = Rx([]);
  Rx<int> selectedCategory = 0.obs;
  Rx<bool> loadingMaterials = false.obs;
  Rx<List<MyMaterial>> materials = Rx([]);
  Rx<int> selectedMaterial = (-1).obs;
  final DataGridController dataGridController = DataGridController();
  Rx<SaleMaterialsDataSource> dataSource = Rx(SaleMaterialsDataSource());
  Future<void> getCategories() async {
    loadingCategories.value = true;
    categories.value.clear();
    categories.value.addAll(await MyMaterialsDatabase.getMaterialsCategories());
    categories.refresh();
    loadingCategories.value = false;
    if (categories.value.isNotEmpty) {
      getCategoryMaterials();
    }
  }

  Future<void> getCategoryMaterials() async {
    loadingMaterials.value = true;
    materials.value.clear();
    materials.value.addAll(await MyMaterialsDatabase.getCategoryMaterials(
        categories.value[selectedCategory.value]));
    materials.refresh();
    loadingMaterials.value = false;
  }

  // sale material dialog variables
  final materialDialogFormKey = GlobalKey<FormState>();
  final materialDialogScrollController = ScrollController();
  final materialDialogQuantityTextController = TextEditingController();
  Rx<int> materialDialogQuantity = 1.obs;
  final materialDialogNoteTextController = TextEditingController();

  @override
  void onInit() {
    getCategories();
    super.onInit();
  }
}
