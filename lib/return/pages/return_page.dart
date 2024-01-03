import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/controllers/main_controller.dart';
import 'package:moamri_accounting/dialogs/alerts_dialogs.dart';
import 'package:moamri_accounting/utils/global_utils.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../database/invoices_database.dart';
import '../controllers/return_controller.dart';
import '../dialogs/return_material_dialog.dart';

// TODO add button to edit quantity to selected item
class ReturnPage extends StatelessWidget {
  ReturnPage({super.key});
  final MainController mainController = Get.find();
  final ReturnController controller = Get.put(ReturnController());
  // final categoriesScrollController = ScrollController();
  // final materialsScrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  child: TypeAheadField(
                      controller: controller.billIDController,
                      emptyBuilder: (context) {
                        return const SizedBox(
                          height: 60,
                          child: Center(
                            child: Text("لم يتم إيجاد الفاتورة"),
                          ),
                        );
                      },
                      onSelected: (value) async {
                        controller.invoiceItem.value = value;
                      },
                      suggestionsCallback: (String pattern) async {
                        return await InvoicesDatabase.getInvoicesSuggestions(
                            pattern);
                      },
                      itemBuilder: (context, suggestion) {
                        return ListTile(
                          title: Text(
                              '${suggestion.invoice.id}: تأريخ:${GlobalUtils.dateFormat.format(DateTime.fromMillisecondsSinceEpoch(suggestion.invoice.date))} ${(suggestion.customer == null) ? '' : ',العميل ${suggestion.customer!.name}'}'),
                        );
                      },
                      builder: (context, controller2, focusNode) {
                        return TextFormField(
                          controller: controller.billIDController,
                          focusNode: focusNode,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.white,
                            isDense: true,
                            contentPadding: const EdgeInsets.all(10),
                            focusedBorder: OutlineInputBorder(
                              borderSide: const BorderSide(color: Colors.green),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            border: const OutlineInputBorder(
                              borderRadius:
                                  BorderRadius.all(Radius.circular(8.0)),
                            ),
                            counterText: "",
                            labelText: 'أدخل رقم الفاتورة',
                          ),
                          keyboardType: TextInputType.text,
                        );
                      }),
                ),
              ),
              IconButton(
                  onPressed: () {
                    controller.getCategories();
                  },
                  tooltip: "تحديث",
                  icon: const Icon(Icons.sync)),
            ],
          ),
        ),
        const SizedBox(
          height: 4,
        ),
        Expanded(
            child: Obx(
          () => SfDataGridTheme(
            data: SfDataGridThemeData(
              headerColor: Colors.white,
            ),
            child: Container(
              color: Colors.black12,
              child: SfDataGrid(
                  controller: controller.dataGridController,
                  gridLinesVisibility: GridLinesVisibility.both,
                  allowColumnsResizing: true,
                  columnResizeMode: ColumnResizeMode.onResizeEnd,
                  onColumnResizeUpdate: (ColumnResizeUpdateDetails details) {
                    controller.columnWidths.value[details.column.columnName] =
                        details.width;
                    controller.columnWidths.refresh();
                    return true;
                  },
                  headerGridLinesVisibility: GridLinesVisibility.both,
                  source: controller.dataSource.value,
                  isScrollbarAlwaysShown: true,
                  onCellTap: (details) {
                    if (details.rowColumnIndex.rowIndex < 1) return;
                    if ((details.rowColumnIndex.rowIndex - 1) !=
                        controller.dataGridController.selectedIndex) {
                      return;
                    }
                    showReturnMaterialDialog(mainController, controller,
                        details.rowColumnIndex.rowIndex - 1);
                  },
                  selectionMode: SelectionMode.single,
                  frozenColumnsCount: 2,
                  columns: [
                    GridColumn(
                        columnName: 'Barcode',
                        columnWidthMode: ColumnWidthMode.fitByCellValue,
                        minimumWidth: 120,
                        label: Container(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            alignment: Alignment.center,
                            child: const Text(
                              'الباركود',
                              overflow: TextOverflow.ellipsis,
                            ))),
                    GridColumn(
                        columnName: 'Name',
                        columnWidthMode: ColumnWidthMode.fitByCellValue,
                        minimumWidth: 120,
                        label: Container(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            alignment: Alignment.center,
                            child: const Text(
                              'الاسم',
                              overflow: TextOverflow.ellipsis,
                            ))),
                    GridColumn(
                        columnName: 'Unit',
                        columnWidthMode: ColumnWidthMode.fitByCellValue,
                        minimumWidth: 120,
                        label: Container(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            alignment: Alignment.center,
                            child: const Text(
                              'الوحدة',
                              overflow: TextOverflow.ellipsis,
                            ))),
                    GridColumn(
                        columnName: 'Unit Price',
                        columnWidthMode: ColumnWidthMode.fitByCellValue,
                        minimumWidth: 120,
                        label: Container(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            alignment: Alignment.center,
                            child: const Text(
                              'سعر الوحدة',
                              overflow: TextOverflow.ellipsis,
                            ))),
                    GridColumn(
                        columnName: 'Quantity',
                        columnWidthMode: ColumnWidthMode.fitByCellValue,
                        minimumWidth: 120,
                        label: Container(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            alignment: Alignment.center,
                            child: const Text(
                              'الكمية',
                              overflow: TextOverflow.ellipsis,
                            ))),
                    GridColumn(
                        columnName: 'Total',
                        columnWidthMode: ColumnWidthMode.fitByColumnName,
                        minimumWidth: 120,
                        label: Container(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            alignment: Alignment.center,
                            child: const Text(
                              'الإجمالي',
                              overflow: TextOverflow.ellipsis,
                            ))),
                    GridColumn(
                        columnName: 'Note',
                        columnWidthMode: ColumnWidthMode.lastColumnFill,
                        minimumWidth: 120,
                        label: Container(
                            padding: const EdgeInsets.symmetric(vertical: 2),
                            alignment: Alignment.center,
                            child: const Text(
                              'ملاحظة',
                              overflow: TextOverflow.ellipsis,
                            ))),
                  ]),
            ),
          ),
        )),
        const Divider(
          height: 1,
        ),
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            // mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Expanded(
                  child: Stack(
                children: <Widget>[
                  Container(
                      width: double.infinity,
                      height: 120,
                      margin: const EdgeInsets.all(8),
                      padding: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.blue[400]!, width: 1),
                          borderRadius: BorderRadius.circular(5),
                          shape: BoxShape.rectangle,
                          color: Colors.white),
                      child: Obx(() => Padding(
                            padding: const EdgeInsets.only(
                                top: 20, left: 8, right: 8),
                            child: SingleChildScrollView(
                                child: Center(
                                    child: Text(controller.totalString.value))),
                          ))),
                  Positioned(
                    right: 20,
                    top: 0,
                    child: Container(
                      padding: const EdgeInsets.only(
                          bottom: 10, left: 10, right: 10),
                      color: Colors.white,
                      child: const Text(
                        'الإجمالي',
                        style: TextStyle(color: Colors.black, fontSize: 12),
                      ),
                    ),
                  ),
                ],
              )),
              Expanded(child: Container()
                  // Column(
                  //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  //   crossAxisAlignment: CrossAxisAlignment.stretch,
                  //   children: [

                  //   ],
                  // ),
                  ),
              Expanded(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    OutlinedButton.icon(
                      onPressed: () async {
                        if (controller.dataGridController.selectedIndex >= 0) {
                          controller.dataSource.value.removeDataGridRow(
                              controller.dataGridController.selectedIndex,
                              controller);
                          controller.dataSource.refresh();
                        } else {
                          showErrorDialog("يرجى إختيار المادة المراد إزالتها");
                        }
                      },
                      style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          )),
                          backgroundColor:
                              MaterialStateProperty.all(Colors.white),
                          foregroundColor:
                              MaterialStateProperty.all(Colors.red)),
                      icon: const Icon(Icons.clear),
                      label: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 120),
                        child: const FittedBox(
                            fit: BoxFit.fitWidth,
                            child: Text('إزالة المادة المختارة')),
                      ),
                    ),
                    const SizedBox(
                      height: 4,
                    ),
                    OutlinedButton.icon(
                      onPressed: () async {
                        if (!(await showConfirmationDialog(
                                "هل أنت متأكد من أنك تريد تفريغ قائمة البيع؟!") ??
                            false)) {
                          return;
                        }

                        controller.dataSource.value
                            .clearDataGridRows(controller);
                        controller.dataSource.refresh();
                      },
                      style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          )),
                          backgroundColor:
                              MaterialStateProperty.all(Colors.red),
                          foregroundColor:
                              MaterialStateProperty.all(Colors.white)),
                      icon: const Icon(Icons.clear),
                      label: FittedBox(
                          fit: BoxFit.fitWidth,
                          child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 120),
                              child: const Text(
                                'تفريغ قائمة البيع',
                              ))),
                    ),
                    const Divider(),
                    OutlinedButton.icon(
                      onPressed: () async {
                        // showReturnDialog(mainController, controller);
                        // var printType = await showPrintDialog("الطلب");
                        // if (printType == "حراري") {
                        //   await printOrderRoll(mainController, controller);
                        // } else {
                        //   await printOrderA4(mainController, controller);
                        // }
                      },
                      style: ButtonStyle(
                          shape:
                              MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0),
                          )),
                          backgroundColor:
                              MaterialStateProperty.all(Colors.green),
                          foregroundColor:
                              MaterialStateProperty.all(Colors.black)),
                      icon: const Icon(Icons.shopping_bag),
                      label: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 120),
                        child: const FittedBox(
                            fit: BoxFit.fitWidth, child: Text('بيع')),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                width: 10,
              ),
            ],
          ),
        ),
      ],
    );
  }
}
