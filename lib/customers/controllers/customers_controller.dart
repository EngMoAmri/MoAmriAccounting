import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/database/entities/customer.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../database/customers_database.dart';
import '../data_sources/customers_data_source.dart';

class CustomersController extends GetxController {
  final DataGridController dataGridController = DataGridController();

  Rx<bool> searching = false.obs;
  Rx<List<Customer>> customers = Rx([]);
  Rx<int> page = 0.obs;
  Rx<int> customersCount = 0.obs;
  Rx<bool> isFirstLoadRunning = false.obs;
  Rx<bool> hasNextPage = true.obs;
  final searchController = TextEditingController();
  Rx<bool> isSearching = false.obs;

  final Rx<List<String>> orderBy = Rx([
    'Name',
    'Quantity',
    'Cost Price',
    'Sale Price',
    'Addition Date',
    'Modification Date',
    'Tax'
  ]);
  final Rx<List<String>> orderByDatabase = Rx([
    'name',
    'quantity',
    'cost_price',
    'sale_price',
    'created_at',
    'updated_at',
    'tax'
  ]);
  Rx<int> selectedOrderBy = 4.obs;
  Rx<int> selectedOrderDir = 1.obs;

  Rx<CustomersDataSource> dataSource = Rx(CustomersDataSource([]));
  void firstLoad() async {
    isSearching.value = false;
    // reset variables
    customers.value.clear();
    page.value = 0;
    customersCount.value = 0;
    hasNextPage.value = true;
    isFirstLoadRunning.value = true;

    CustomersDatabase.getCustomersCount().then((customersCount) {
      CustomersDatabase.getCustomers(
              orderBy: orderByDatabase.value[selectedOrderBy.value],
              dir: (selectedOrderDir.value == 0) ? "ASC" : "DESC",
              page.value)
          .then((newLoadedCustomers) {
        customers.value = newLoadedCustomers;
        dataSource.value = CustomersDataSource(customers.value);
        this.customersCount.value = customersCount;
        if (newLoadedCustomers.isEmpty ||
            (customers.value.length) == customersCount) {
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
    customers.value.clear();
    page.value = 0;
    customersCount.value = 0;
    hasNextPage.value = true;
    isFirstLoadRunning.value = true;

    CustomersDatabase.getCustomersCount(searchedText: searchController.text)
        .then((customersCount) {
      CustomersDatabase.getSearchedCustomers(page.value, searchController.text)
          .then((newLoadedCustomers) {
        customers.value = newLoadedCustomers;
        dataSource.value = CustomersDataSource(customers.value);
        this.customersCount.value = customersCount;
        if (newLoadedCustomers.isEmpty ||
            (customers.value.length) == customersCount) {
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
        var newLoadedCustomers = await CustomersDatabase.getCustomers(
            orderBy: orderByDatabase.value[selectedOrderBy.value],
            dir: (selectedOrderDir.value == 0) ? "ASC" : "DESC",
            page.value);
        customers.value.addAll(newLoadedCustomers);
        customers.refresh();
        dataSource.value = CustomersDataSource(customers.value);
        dataSource.refresh();
        if (newLoadedCustomers.isEmpty ||
            (customers.value.length) == customersCount.value) {
          hasNextPage.value = false;
        }
        page.value++;
      } else {
        var newLoadedCustomers = await CustomersDatabase.getSearchedCustomers(
            page.value, searchController.text);
        customers.value.addAll(newLoadedCustomers);
        customers.refresh();
        dataSource.value = CustomersDataSource(customers.value);
        dataSource.refresh();
        if (newLoadedCustomers.isEmpty ||
            (customers.value.length) == customersCount.value) {
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
