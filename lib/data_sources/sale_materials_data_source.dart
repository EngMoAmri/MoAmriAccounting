import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/controllers/inventory_controller.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../database/entities/my_material.dart';

class SaleMaterialsDataSource extends DataGridSource {
  final List<MyMaterial> materialsData;
  SaleMaterialsDataSource(this.materialsData);

  @override
  List<DataGridRow> get rows => materialsData.map<DataGridRow>((m) {
        return DataGridRow(cells: [
          DataGridCell(columnName: 'Barcode', value: m.barcode),
          DataGridCell(columnName: 'Name', value: m.name),
          DataGridCell(columnName: 'Price', value: m.salePrice),
          DataGridCell(
              columnName: 'Quantity', value: "${m.quantity} ${m.unit}"),
          DataGridCell(
              columnName: 'Total Price',
              value: '${m.salePrice * m.quantity} ${m.currency}'),
          DataGridCell(
              columnName: 'Discount', value: '${m.discount} ${m.currency}'),
          DataGridCell(columnName: 'TAX/VAT', value: m.tax),
          DataGridCell(columnName: 'Note', value: ''),
          DataGridCell(columnName: 'Net Total', value: ''),
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
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        alignment: Alignment.center,
        child: Text(
          row.getCells()[7].value.toString(),
          overflow: TextOverflow.ellipsis,
        ),
      ),
      Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0),
        alignment: Alignment.center,
        child: Text(
          row.getCells()[8].value.toString(),
          overflow: TextOverflow.ellipsis,
        ),
      ),
    ]);
  }

  @override
  Future<void> handleLoadMoreRows() async {
    InventoryController controller = Get.find();
    await Future.delayed(const Duration(seconds: 1));
    await controller.loadMore();
    notifyListeners();
  }
}
