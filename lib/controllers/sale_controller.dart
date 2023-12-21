import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../data_sources/sale_materials_data_source.dart';
import '../database/entities/my_material.dart';
import '../database/my_materials_database.dart';

class SaleController extends GetxController {
  final searchController = TextEditingController();
  Rx<bool> searching = false.obs;
  Rx<bool?> visible = Rx(null);
  Rx<Map<String, double>> totals = Rx({});

  Rx<bool> loadingCategories = true.obs;
  Rx<List<String>> categories = Rx([]);
  Rx<int> selectedCategory = 0.obs;
  Rx<bool> loadingMaterials = true.obs;
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
    getCategoryMaterials();
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
  final dialogFormKey = GlobalKey<FormState>();
  final dialogScrollController = ScrollController();
  final dialogQuantityTextController = TextEditingController();
  Rx<int> dialogQuantity = 1.obs;
  // var dialogDiscountCheckBoxValue = false.obs;
  // var dialogNoteCheckBoxValue = false.obs;
  final dialogDiscountTextController = TextEditingController();
  Rx<double> dialogDiscount = 0.0.obs;
  final dialogTaxTextController = TextEditingController();
  Rx<double> dialogTax = 0.0.obs;
  final dialogNoteTextController = TextEditingController();

  @override
  void onInit() {
    getCategories();
    super.onInit();
  }
}
