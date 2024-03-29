import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/inventory/controllers/inventory_controller.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../database/entities/my_material.dart';
import '../../utils/global_utils.dart';

class MyMaterialsDataSource extends DataGridSource {
  final List<MyMaterial> materialsData;
  MyMaterialsDataSource(this.materialsData);

  @override
  List<DataGridRow> get rows => materialsData.map<DataGridRow>((m) {
        return DataGridRow(cells: [
          DataGridCell(columnName: 'Barcode', value: m.barcode),
          DataGridCell(columnName: 'Name', value: m.name),
          DataGridCell(columnName: 'Category', value: m.category),
          DataGridCell(columnName: 'Quantity', value: m.quantity),
          DataGridCell(columnName: 'Unit', value: m.unit),
          DataGridCell(
              columnName: 'Cost Price',
              value: '${GlobalUtils.getMoney(m.costPrice)} ${m.currency}'),
          DataGridCell(
              columnName: 'Sale Price',
              value: '${GlobalUtils.getMoney(m.salePrice)} ${m.currency}'),
          DataGridCell(columnName: 'Note', value: m.note ?? ''),
          // DataGridCell(columnName: 'Expiry Date', value: m.), TODO
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
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        alignment: Alignment.center,
        child: Text(
          row.getCells()[5].value.toString(),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        alignment: Alignment.center,
        child: Text(
          row.getCells()[6].value.toString(),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Tooltip(
        message: row.getCells()[7].value.toString(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          alignment: Alignment.center,
          child: Text(
            row.getCells()[7].value.toString(),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    ]);
  }

  @override
  Future<void> handleLoadMoreRows() async {
    InventoryController controller = Get.find();

    if (materialsData.length != controller.materialsCount.value) {
      await Future.delayed(const Duration(seconds: 1));
      await controller.loadMore();
      notifyListeners();
    }
  }
}
