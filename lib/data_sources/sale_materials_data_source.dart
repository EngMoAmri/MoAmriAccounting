import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../database/entities/my_material.dart';

class SaleMaterialsDataSource extends DataGridSource {
  final List<Map<String, dynamic>> salesData = [];
  Map<String, double> totals = {};

  @override
  List<DataGridRow> get rows => salesData.map<DataGridRow>((saleData) {
        var m = saleData['Material'] as MyMaterial;
        return DataGridRow(cells: [
          DataGridCell(columnName: 'Barcode', value: m.barcode),
          DataGridCell(columnName: 'Name', value: m.name),
          DataGridCell(columnName: 'Price', value: m.salePrice),
          DataGridCell(
              columnName: 'Quantity',
              value: "${saleData['Quantity']} ${m.unit}"),
          DataGridCell(
              columnName: 'Total Price',
              value: '${m.salePrice * saleData['Quantity']} ${m.currency}'),
          DataGridCell(
              columnName: 'Discount',
              value: '${saleData['Discount'] ?? 0.0} ${m.currency}'),
          DataGridCell(columnName: 'TAX/VAT', value: saleData['Tax'] ?? m.tax),
          DataGridCell(
              columnName: 'Net Total', value: '${saleData['Total'] ?? ''}'),
          DataGridCell(columnName: 'Note', value: '${saleData['Note'] ?? ''}'),
        ]);
      }).toList(growable: true);

  void addDataGridRow(MyMaterial m) {
    totals[m.currency] =
        (totals[m.currency] ?? 0.0) + m.salePrice + (m.tax * m.salePrice);
    salesData.add({
      "Material": m,
      "Quantity": 1,
      "Discount": 0.0,
      "Tax": m.tax,
      "Total": (m.salePrice * m.tax) + m.salePrice,
      "Note": ''
    });
    rows.add(DataGridRow(cells: [
      DataGridCell(columnName: 'Barcode', value: m.barcode),
      DataGridCell(columnName: 'Name', value: m.name),
      DataGridCell(columnName: 'Price', value: m.salePrice),
      DataGridCell(columnName: 'Quantity', value: "1 ${m.unit}"),
      DataGridCell(
          columnName: 'Total Price', value: '${m.salePrice} ${m.currency}'),
      DataGridCell(columnName: 'Discount', value: '0.0 ${m.currency}'),
      DataGridCell(columnName: 'TAX/VAT', value: m.tax),
      DataGridCell(
          columnName: 'Total',
          value: '${(m.salePrice * m.tax) + m.salePrice} ${m.currency}'),
      const DataGridCell(columnName: 'Note', value: ''),
    ]));
    // To refresh the DataGrid based on CRUD operation.
    notifyListeners();
  }

  void removeDataGridRow(int index) {
    var m = salesData[index]["Material"];
    totals[m.currency] = (totals[m.currency] ?? 0.0) - m.salePrice;
    salesData.removeAt(index);
    // To refresh the DataGrid based on CRUD operation.
    notifyListeners();
  }

  void clearDataGridRows() {
    totals = {};
    salesData.clear();
    // To refresh the DataGrid based on CRUD operation.
    notifyListeners();
  }

  /// This method will return the index of the row contains the material. if not found -1
  int getMaterialIndex(MyMaterial m) {
    for (var element in salesData) {
      if (element["Material"] == m) {
        return salesData.indexOf(element);
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
}
