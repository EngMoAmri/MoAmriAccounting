import 'package:flutter/material.dart';
import 'package:moamri_accounting/database/entities/currency.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../utils/global_utils.dart';

class CurrenciesDataSource extends DataGridSource {
  final List<Currency> currenciesData;
  CurrenciesDataSource(this.currenciesData);

  @override
  List<DataGridRow> get rows => currenciesData.map<DataGridRow>((c) {
        return DataGridRow(cells: [
          DataGridCell(columnName: 'Currency', value: c.name),
          DataGridCell(
              columnName: 'Exchange Rate',
              value: GlobalUtils.getMoney(c.exchangeRate)),
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
    ]);
  }
}
