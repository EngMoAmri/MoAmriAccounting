import 'package:flutter/material.dart';
import 'package:moamri_accounting/return/controllers/return_controller.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../database/entities/my_material.dart';
import '../../utils/global_utils.dart';

class ReturnedMaterialsDataSource extends DataGridSource {
  final List<Map<String, dynamic>> returnsData = [];
  @override
  List<DataGridRow> get rows => returnsData.map<DataGridRow>((saleData) {
        var m = saleData['Material'] as MyMaterial;

        return DataGridRow(cells: [
          DataGridCell(columnName: 'Barcode', value: m.barcode),
          DataGridCell(columnName: 'Name', value: m.name),
          DataGridCell(columnName: 'Unit', value: m.unit),
          DataGridCell(
              columnName: 'Price',
              value:
                  '${GlobalUtils.getMoney(saleData['Price'])} ${m.currency}'),
          DataGridCell(
              columnName: 'Quantity', value: "${saleData['Quantity']}"),
          DataGridCell(
              columnName: 'Total',
              value:
                  '${GlobalUtils.getMoney(saleData['Total'])} ${m.currency}'),
          DataGridCell(columnName: 'Note', value: '${saleData['Note'] ?? ''}'),
        ]);
      }).toList(growable: true);

  void calculateTotals(ReturnController controller) {
    controller.totals.value.clear();
    if (returnsData.isNotEmpty) {
      for (var saleData in returnsData) {
        var material = saleData["Material"] as MyMaterial;
        controller.totals.value[material.currency] =
            (controller.totals.value[material.currency] ?? 0.0) +
                saleData["Total"];
      }
      controller.totals.refresh();
      controller.totalString.value = "";
      for (var currency in controller.totals.value.keys.toList()) {
        controller.totalString.value +=
            '${GlobalUtils.getMoney(controller.totals.value[currency])} $currency \n';
      }
      controller.totalString.value = controller.totalString.value.trim();
    } else {
      controller.totalString.value = '';
    }
  }

  void addDataGridRow(
      Map<String, dynamic> returnedData, ReturnController controller) {
    returnsData.add(returnedData);
    calculateTotals(controller);
    // To refresh the DataGrid based on CRUD operation.
    notifyListeners();
  }

  void removeDataGridRow(int index, ReturnController controller) {
    returnsData.removeAt(index);
    calculateTotals(controller);
    // To refresh the DataGrid based on CRUD operation.
    notifyListeners();
  }

  void clearDataGridRows(ReturnController controller) {
    returnsData.clear();
    calculateTotals(controller);
    // To refresh the DataGrid based on CRUD operation.
    notifyListeners();
  }

  /// This method will return the index of the row contains the material. if not found -1
  int getMaterialIndex(MyMaterial m) {
    for (var element in returnsData) {
      if (element["Material"].id == m.id) {
        return returnsData.indexOf(element);
      }
    }
    return -1;
  }

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
      Tooltip(
        message: row.getCells()[6].value.toString(),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          alignment: Alignment.center,
          child: Text(
            row.getCells()[6].value.toString(),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ),
    ]);
  }
}
