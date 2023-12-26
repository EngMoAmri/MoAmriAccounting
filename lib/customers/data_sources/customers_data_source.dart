import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../database/items/customer_debt_item.dart';
import '../controllers/customers_controller.dart';

class CustomersDataSource extends DataGridSource {
  final List<CustomerDebtItem> customersData;
  CustomersDataSource(this.customersData);

  @override
  List<DataGridRow> get rows => customersData.map<DataGridRow>((c) {
        return DataGridRow(cells: [
          DataGridCell(columnName: 'ID', value: c.customer.id),
          DataGridCell(columnName: 'Name', value: c.customer.name),
          DataGridCell(columnName: 'Debt', value: c.debt),
          DataGridCell(columnName: 'Phone', value: c.customer.phone),
          DataGridCell(columnName: 'Address', value: c.customer.address),
          DataGridCell(
              columnName: 'Description', value: c.customer.description),
        ]);
      }).toList(growable: false);

  @override
  DataGridRowAdapter buildRow(DataGridRow row) {
    return DataGridRowAdapter(color: Colors.white, cells: [
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        alignment: Alignment.center,
        child: Text(
          row.getCells()[0].value.toString(),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Tooltip(
        message: row.getCells()[1].value.toString(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          alignment: Alignment.center,
          child: Text(
            row.getCells()[1].value.toString(),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      Tooltip(
        message: row.getCells()[2].value.toString(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          alignment: Alignment.center,
          child: Text(
            row.getCells()[2].value.toString(),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        alignment: Alignment.center,
        child: Text(
          row.getCells()[3].value.toString(),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        alignment: Alignment.center,
        child: Text(
          row.getCells()[4].value.toString(),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Tooltip(
        message: row.getCells()[5].value.toString(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          alignment: Alignment.center,
          child: Text(
            row.getCells()[4].value.toString(),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    ]);
  }

  @override
  Future<void> handleLoadMoreRows() async {
    CustomersController controller = Get.find();

    if (customersData.length != controller.customersCount.value) {
      await Future.delayed(const Duration(seconds: 1));
      await controller.loadMore();
      notifyListeners();
    }
  }
}
