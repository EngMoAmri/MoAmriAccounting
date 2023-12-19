import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/database/entities/my_material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../data_sources/sale_materials_data_source.dart';

class SaleController extends GetxController {
  final searchController = TextEditingController();
  final DataGridController dataGridController = DataGridController();

  Rx<bool> searching = false.obs;
  Rx<bool?> visible = Rx(null);

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

  Rx<SaleMaterialsDataSource> dataSource = Rx(SaleMaterialsDataSource([]));
  // sale material variables
  final formKey = GlobalKey<FormState>();
  final scrollController = ScrollController();
  final quantityTextController = TextEditingController();
  final discountTextController = TextEditingController();
  final noteTextController = TextEditingController();
  var adding = false.obs;

  @override
  void onInit() {
    quantityTextController.text = "1";
    noteTextController.text = '';
    super.onInit();
  }
}
