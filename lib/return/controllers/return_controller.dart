import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/database/items/invoice_item.dart';
import 'package:moamri_accounting/return/data_sources/bill_materials_data_source.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../data_sources/returned_materials_data_source.dart';

class ReturnController extends GetxController {
  final billIDController = TextEditingController();
  Rx<InvoiceItem?> invoiceItem = Rx(null);
  Rx<bool> searching = false.obs;
  Rx<Map<String, double>> totals = Rx({});
  Rx<String> billTotalString = ''.obs;
  Rx<String> returnTotalString = ''.obs;
  Rx<double> billTotalInMainCurrency = 0.0.obs;
  Rx<double> returnTotalInMainCurrency = 0.0.obs;
  final DataGridController billDataGridController = DataGridController();
  final DataGridController returnedDataGridController = DataGridController();
  Rx<Map<String, double>> columnWidths = Rx({
    'Barcode': double.nan,
    'Name': double.nan,
    'Unit': double.nan,
    'Unit Price': double.nan,
    'Quantity': double.nan,
    'Total': double.nan,
    'Note': double.nan
  });

  Rx<BillMaterialsDataSource> billDataSource = Rx(BillMaterialsDataSource());
  Rx<ReturnedMaterialsDataSource> returnedDataSource =
      Rx(ReturnedMaterialsDataSource());

  // sale material dialog variables
  final materialDialogFormKey = GlobalKey<FormState>();
  final materialDialogQuantityTextController = TextEditingController();
  Rx<double> materialDialogQuantity = 1.0.obs;
  final materialDialogNoteTextController = TextEditingController();

  setBillDataSource() {
    List<Map<String, dynamic>> salesData = [];
    for (var materialItem in invoiceItem.value!.inoviceMaterialsItems) {
      // TODO I know it fine , but to be sure please check if the material price has been change
      salesData.add({
        'Material': materialItem.material,
        'Price': materialItem.invoiceMaterial.price,
        'Quantity': materialItem.invoiceMaterial.quantity,
        'Total': materialItem.invoiceMaterial.quantity *
            materialItem.invoiceMaterial.price,
        'Note': materialItem.invoiceMaterial.note,
      });
    }

    billDataSource.value.setDataGridRows(salesData, this);
    billDataSource.refresh();
  }
}
