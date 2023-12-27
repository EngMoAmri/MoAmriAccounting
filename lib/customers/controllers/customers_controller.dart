import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/controllers/main_controller.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../database/customers_database.dart';
import '../../database/items/customer_debt_item.dart';
import '../data_sources/customers_data_source.dart';

class CustomersController extends GetxController {
  MainController mainController = Get.find();
  final DataGridController dataGridController = DataGridController();
  Rx<Map<String, double>> columnWidths = Rx({
    'ID': double.nan,
    'Name': double.nan,
    'Debt': double.nan,
    'Phone': double.nan,
    'Address': double.nan,
    'Description': double.nan,
  });

  Rx<bool> searching = false.obs;
  Rx<List<CustomerDebtItem>> customersWithDebts = Rx([]);
  Rx<int> page = 0.obs;
  Rx<int> customersCount = 0.obs;
  Rx<bool> isFirstLoadRunning = false.obs;
  Rx<bool> hasNextPage = true.obs;
  final searchController = TextEditingController();
  Rx<bool> isSearching = false.obs;

  final Rx<List<String>> orderBy =
      Rx(['الاسم', 'إجمالي الدين', 'العنوان', 'الإضافة']);
  final Rx<List<String>> orderByDatabase =
      Rx(['name', 'debt', 'address', 'id']);
  Rx<int> selectedOrderBy = 3.obs;
  Rx<int> selectedOrderDir = 1.obs;

  Rx<CustomersDataSource> dataSource = Rx(CustomersDataSource([]));
  void firstLoad() async {
    isSearching.value = false;
    // reset variables
    customersWithDebts.value.clear();
    page.value = 0;
    customersCount.value = 0;
    hasNextPage.value = true;
    isFirstLoadRunning.value = true;

    CustomersDatabase.getCustomersCount().then((customersCount) {
      CustomersDatabase.getCustomersWithDebts(
              mainController,
              orderBy: orderByDatabase.value[selectedOrderBy.value],
              dir: (selectedOrderDir.value == 0) ? "ASC" : "DESC",
              page.value)
          .then((newLoadedCustomers) {
        customersWithDebts.value = newLoadedCustomers;
        dataSource.value = CustomersDataSource(customersWithDebts.value);
        this.customersCount.value = customersCount;
        if (newLoadedCustomers.isEmpty ||
            (customersWithDebts.value.length) == customersCount) {
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
    customersWithDebts.value.clear();
    page.value = 0;
    customersCount.value = 0;
    hasNextPage.value = true;
    isFirstLoadRunning.value = true;

    CustomersDatabase.getCustomersCount(searchedText: searchController.text)
        .then((customersCount) {
      CustomersDatabase.getSearchedCustomers(
              mainController, page.value, searchController.text)
          .then((newLoadedCustomers) {
        customersWithDebts.value = newLoadedCustomers;
        dataSource.value = CustomersDataSource(customersWithDebts.value);
        this.customersCount.value = customersCount;
        if (newLoadedCustomers.isEmpty ||
            (customersWithDebts.value.length) == customersCount) {
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
        var newLoadedCustomers = await CustomersDatabase.getCustomersWithDebts(
            mainController,
            orderBy: orderByDatabase.value[selectedOrderBy.value],
            dir: (selectedOrderDir.value == 0) ? "ASC" : "DESC",
            page.value);
        customersWithDebts.value.addAll(newLoadedCustomers);
        customersWithDebts.refresh();
        dataSource.value = CustomersDataSource(customersWithDebts.value);
        dataSource.refresh();
        if (newLoadedCustomers.isEmpty ||
            (customersWithDebts.value.length) == customersCount.value) {
          hasNextPage.value = false;
        }
        page.value++;
      } else {
        var newLoadedCustomers = await CustomersDatabase.getSearchedCustomers(
            mainController, page.value, searchController.text);
        customersWithDebts.value.addAll(newLoadedCustomers);
        customersWithDebts.refresh();
        dataSource.value = CustomersDataSource(customersWithDebts.value);
        dataSource.refresh();
        if (newLoadedCustomers.isEmpty ||
            (customersWithDebts.value.length) == customersCount.value) {
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
