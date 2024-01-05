import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/controllers/main_controller.dart';
import 'package:moamri_accounting/utils/global_utils.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../database/invoices_database.dart';
import '../../dialogs/alerts_dialogs.dart';
import '../controllers/return_controller.dart';
import '../dialogs/return_dialog.dart';
import '../dialogs/return_material_dialog.dart';

class ReturnPage extends StatelessWidget {
  ReturnPage({super.key});
  final MainController mainController = Get.find();
  final ReturnController controller = Get.put(ReturnController());

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
                        if (controller.billIDController.text.isEmpty) {
                          return const SizedBox(
                            height: 0,
                          );
                        }
                        return const SizedBox(
                          height: 60,
                          child: Center(
                            child: Text("لم يتم إيجاد الفاتورة"),
                          ),
                        );
                      },
                      onSelected: (value) async {
                        controller.invoiceItem.value = value;
                        await AudioPlayer()
                            .play(AssetSource('sounds/scanner-beep.mp3'));

                        controller.setBillDataSource();
                        controller.billIDController.clear();
                      },
                      suggestionsCallback: (String pattern) async {
                        return await InvoicesDatabase.getInvoicesSuggestions(
                            pattern);
                      },
                      itemBuilder: (context, suggestion) {
                        return ListTile(
                          title: Text(
                              'رقم الفاتورة: ${suggestion.invoice.id!}: التأريخ:${GlobalUtils.dateFormat.format(DateTime.fromMillisecondsSinceEpoch(suggestion.invoice.date))} ${(suggestion.customer == null) ? '' : ',العميل ${suggestion.customer!.name}'}'),
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
            ],
          ),
        ),
        const SizedBox(
          height: 4,
        ),
        const Row(
          children: [
            Expanded(
              child: Divider(
                height: 1,
              ),
            ),
            Text('عناصر الفاتورة'),
            Expanded(
              child: Divider(
                height: 1,
              ),
            ),
          ],
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
                  controller: controller.billDataGridController,
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
                  source: controller.billDataSource.value,
                  isScrollbarAlwaysShown: true,
                  onCellTap: (details) {
                    if (details.rowColumnIndex.rowIndex < 1) return;
                    if ((details.rowColumnIndex.rowIndex - 1) !=
                        controller.billDataGridController.selectedIndex) {
                      return;
                    }
                    showReturnMaterialDialog(
                        mainController,
                        controller,
                        details.rowColumnIndex.rowIndex - 1,
                        controller.billDataSource.value
                                .salesData[details.rowColumnIndex.rowIndex - 1]
                            ['Material']);
                  },
                  selectionMode: SelectionMode.single,
                  frozenColumnsCount: 2,
                  columns: [
                    GridColumn(
                        columnName: 'Barcode',
                        width: controller.columnWidths.value['Barcode']!,
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
                        width: controller.columnWidths.value['Name']!,
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
                        width: controller.columnWidths.value['Unit']!,
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
                        width: controller.columnWidths.value['Unit Price']!,
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
                        width: controller.columnWidths.value['Quantity']!,
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
                        width: controller.columnWidths.value['Total']!,
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
        const Row(
          children: [
            Expanded(
              child: Divider(
                height: 1,
              ),
            ),
            Text('العناصر المرتجعة'),
            Expanded(
              child: Divider(
                height: 1,
              ),
            ),
          ],
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
                  controller: controller.returnedDataGridController,
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
                  source: controller.returnedDataSource.value,
                  isScrollbarAlwaysShown: true,
                  onCellTap: (details) {
                    if (details.rowColumnIndex.rowIndex < 1) return;
                    if ((details.rowColumnIndex.rowIndex - 1) !=
                        controller.returnedDataGridController.selectedIndex) {
                      return;
                    }
                    showReturnMaterialDialog(
                        mainController,
                        controller,
                        details.rowColumnIndex.rowIndex - 1,
                        controller.returnedDataSource.value.returnsData[
                            details.rowColumnIndex.rowIndex - 1]['Material']);
                  },
                  selectionMode: SelectionMode.single,
                  frozenColumnsCount: 2,
                  columns: [
                    GridColumn(
                        columnName: 'Barcode',
                        width: controller.columnWidths.value['Barcode']!,
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
                        width: controller.columnWidths.value['Name']!,
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
                        width: controller.columnWidths.value['Unit']!,
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
                        width: controller.columnWidths.value['Unit Price']!,
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
                        width: controller.columnWidths.value['Quantity']!,
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
                        width: controller.columnWidths.value['Total']!,
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
        Padding(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    if (controller.returnedDataGridController.selectedIndex >=
                        0) {
                      controller.returnedDataSource.value.removeDataGridRow(
                          controller.returnedDataGridController.selectedIndex,
                          controller);
                      controller.returnedDataSource.refresh();
                    } else {
                      showErrorDialog("يرجى إختيار المادة المراد إزالتها");
                    }
                  },
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      )),
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                      foregroundColor: MaterialStateProperty.all(Colors.red)),
                  icon: const Icon(Icons.clear),
                  label: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 120),
                    child: const FittedBox(
                        fit: BoxFit.fitWidth,
                        child: Text('إزالة المادة المختارة')),
                  ),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    if (!(await showConfirmationDialog(
                            "هل أنت متأكد من أنك تريد تفريغ العناصر؟!") ??
                        false)) {
                      return;
                    }

                    controller.billDataSource.value
                        .clearDataGridRows(controller);
                    controller.billDataSource.refresh();
                    controller.returnedDataSource.value
                        .clearDataGridRows(controller);
                    controller.returnedDataSource.refresh();
                    controller.invoiceItem.value = null;
                  },
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      )),
                      backgroundColor: MaterialStateProperty.all(Colors.red),
                      foregroundColor: MaterialStateProperty.all(Colors.white)),
                  icon: const Icon(Icons.clear),
                  label: const FittedBox(
                      fit: BoxFit.fitWidth,
                      child: Text(
                        'تفريغ العناصر',
                      )),
                ),
              ),
              const SizedBox(
                width: 10,
              ),
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: () async {
                    showReturnDialog(mainController, controller);
                    var printType = await showPrintDialog("الطلب");
                    if (printType == "حراري") {
                      await printOrderRoll(mainController, controller);
                    } else {
                      await printOrderA4(mainController, controller);
                    }
                  },
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      )),
                      backgroundColor: MaterialStateProperty.all(Colors.green),
                      foregroundColor: MaterialStateProperty.all(Colors.black)),
                  icon: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: Image.asset(
                      'assets/images/return.png',
                      width: 30,
                    ),
                  ),
                  label: const FittedBox(
                      fit: BoxFit.fitWidth, child: Text('إرجاع')),
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
