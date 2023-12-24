import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../database/entities/customer.dart';
import '../controllers/customers_controller.dart';

class CustomersDataSource extends DataGridSource {
  final List<Customer> customersData;
  CustomersDataSource(this.customersData);

  @override
  List<DataGridRow> get rows => customersData.map<DataGridRow>((c) {
        return DataGridRow(cells: [
          DataGridCell(columnName: 'ID', value: c.id),
          DataGridCell(columnName: 'Name', value: c.name),
          DataGridCell(columnName: 'Phone', value: c.phone),
          DataGridCell(columnName: 'Address', value: c.address),
          DataGridCell(columnName: 'Description', value: c.description),
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
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        alignment: Alignment.center,
        child: Text(
          row.getCells()[1].value.toString(),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        alignment: Alignment.center,
        child: Text(
          row.getCells()[2].value.toString(),
          overflow: TextOverflow.ellipsis,
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
