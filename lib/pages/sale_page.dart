import 'package:flutter/material.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/controllers/main_controller.dart';
import 'package:moamri_accounting/database/entities/my_material.dart';
import 'package:moamri_accounting/database/my_materials_database.dart';
import 'package:moamri_accounting/dialogs/alerts_dialogs.dart';
import 'package:moamri_accounting/dialogs/sale/sale_material_dialog.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../controllers/sale_controller.dart';
import '../dialogs/print_dialogs.dart';

class SalePage extends StatelessWidget {
  const SalePage({super.key});
  @override
  Widget build(BuildContext context) {
    final MainController mainController = Get.find();
    final SaleController controller = Get.put(SaleController());
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Row(
            children: [
              Expanded(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 10),
                  child: TypeAheadField(
                      controller: controller.searchController,
                      emptyBuilder: (context) {
                        return Center(
                          child: Text("Material Not Found"),
                        );
                      },
                      onSelected: (value) {
                        showSaleMaterialDialog(
                            mainController, controller, value);
                        controller.searchController.clear();
                      },
                      suggestionsCallback: (String pattern) async {
                        return await MyMaterialsDatabase
                            .getMaterialsSuggestions(pattern, null);
                      },
                      itemBuilder: (context, suggestion) {
                        return ListTile(
                          title:
                              Text('${suggestion.barcode}, ${suggestion.name}'),
                        );
                      },
                      builder: (context, controller2, focusNode) {
                        return TextFormField(
                          controller: controller.searchController,
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
                            labelText: 'Search By Barcode / Name',
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
          height: 10,
        ),
        // Add visiblity detector to handle barcode
        // values only when widget is visible
        VisibilityDetector(
          onVisibilityChanged: (VisibilityInfo info) {
            controller.visible.value = info.visibleFraction > 0;
          },
          key: const Key('visible-detector-key'),
          child: BarcodeKeyboardListener(
            bufferDuration: Duration(milliseconds: 200),
            onBarcodeScanned: (barcode) async {
              if (!(controller.visible.value ?? false)) return;
              MyMaterial? selectedMaterial =
                  await MyMaterialsDatabase.getMaterialByBarcode(barcode);
              if (selectedMaterial == null) {
                showErrorDialog("There is no material with this barcode");
                return;
              }
              showSaleMaterialDialog(
                  mainController, controller, selectedMaterial);
            },
            child: Container(),
          ),
        ),
        Expanded(
            child: SfDataGridTheme(
          data: SfDataGridThemeData(
            headerColor: Colors.white,
          ),
          child: Container(
            color: Colors.black12,
            child: SfDataGrid(
                controller: controller.dataGridController,
                gridLinesVisibility: GridLinesVisibility.both,
                headerGridLinesVisibility: GridLinesVisibility.both,
                source: controller.dataSource.value,
                selectionMode: SelectionMode.single,
                frozenColumnsCount: 2,
                columns: [
                  GridColumn(
                      columnName: 'Barcode',
                      columnWidthMode: ColumnWidthMode.fitByCellValue,
                      minimumWidth: 120,
                      label: Container(
                          padding: EdgeInsets.symmetric(vertical: 2),
                          alignment: Alignment.center,
                          child: Text(
                            'Barcode/No.',
                            overflow: TextOverflow.ellipsis,
                          ))),
                  GridColumn(
                      columnName: 'Name',
                      columnWidthMode: ColumnWidthMode.fitByCellValue,
                      minimumWidth: 120,
                      label: Container(
                          padding: EdgeInsets.symmetric(vertical: 2),
                          alignment: Alignment.center,
                          child: Text(
                            'Name',
                            overflow: TextOverflow.ellipsis,
                          ))),
                  GridColumn(
                      columnName: 'Price',
                      columnWidthMode: ColumnWidthMode.fitByCellValue,
                      minimumWidth: 120,
                      label: Container(
                          padding: EdgeInsets.symmetric(vertical: 2),
                          alignment: Alignment.center,
                          child: Text(
                            'Price',
                            overflow: TextOverflow.ellipsis,
                          ))),
                  GridColumn(
                      columnName: 'Quantity',
                      columnWidthMode: ColumnWidthMode.fitByCellValue,
                      minimumWidth: 120,
                      label: Container(
                          padding: EdgeInsets.symmetric(vertical: 2),
                          alignment: Alignment.center,
                          child: Text(
                            'Quantity',
                            overflow: TextOverflow.ellipsis,
                          ))),
                  GridColumn(
                      columnName: 'Total Price',
                      columnWidthMode: ColumnWidthMode.fitByCellValue,
                      minimumWidth: 120,
                      label: Container(
                          padding: EdgeInsets.symmetric(vertical: 2),
                          alignment: Alignment.center,
                          child: Text(
                            'Total Price',
                            overflow: TextOverflow.ellipsis,
                          ))),
                  GridColumn(
                      columnName: 'Discount',
                      columnWidthMode: ColumnWidthMode.fitByCellValue,
                      minimumWidth: 120,
                      label: Container(
                          padding: EdgeInsets.symmetric(vertical: 2),
                          alignment: Alignment.center,
                          child: Text(
                            'Discount',
                            overflow: TextOverflow.ellipsis,
                          ))),
                  GridColumn(
                      columnName: 'TAX/VAT',
                      columnWidthMode: ColumnWidthMode.fitByCellValue,
                      minimumWidth: 120,
                      label: Container(
                          padding: EdgeInsets.symmetric(vertical: 2),
                          alignment: Alignment.center,
                          child: Text(
                            'TAX/VAT',
                            overflow: TextOverflow.ellipsis,
                          ))),
                  GridColumn(
                      columnName: 'Note',
                      columnWidthMode: ColumnWidthMode.fitByColumnName,
                      minimumWidth: 120,
                      label: Container(
                          padding: EdgeInsets.symmetric(vertical: 2),
                          alignment: Alignment.center,
                          child: Text(
                            'Note',
                            overflow: TextOverflow.ellipsis,
                          ))),
                  GridColumn(
                      columnName: 'Net Total',
                      columnWidthMode: ColumnWidthMode.fitByCellValue,
                      minimumWidth: 120,
                      label: Container(
                          padding: EdgeInsets.symmetric(vertical: 2),
                          alignment: Alignment.center,
                          child: Text(
                            'Net Total',
                            overflow: TextOverflow.ellipsis,
                          ))),
                ]),
          ),
        )),
        Padding(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                OutlinedButton.icon(
                  onPressed: () async {},
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      )),
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                      foregroundColor: MaterialStateProperty.all(Colors.blue)),
                  icon: const Icon(Icons.add),
                  label: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Add'),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                OutlinedButton.icon(
                  onPressed: () async {},
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      )),
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                      foregroundColor: MaterialStateProperty.all(Colors.green)),
                  icon: const Icon(Icons.edit),
                  label: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Edit'),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                OutlinedButton.icon(
                  onPressed: () async {
                    if (controller.dataGridController.selectedIndex < 0) {
                      showErrorDialog("You Must Select a Material");
                      return;
                    }
                    // var material = controller.materials
                    //     .value[controller.dataGridController.selectedIndex];
                    // var deletable =
                    //     await MyMaterialsDatabase.isMaterialDeletable(
                    //         material.id!);
                    // if (!deletable) {
                    //   showErrorDialog(
                    //       "This Material Belong to Some Purchase or Sales, So It Cannot Be Deleted");
                    //   return;
                    // }
                    // await MyMaterialsDatabase.deleteMaterial(material);
                    // await showSuccessDialog("Material Has Been Deleted");
                    // controller.firstLoad();
                  },
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      )),
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                      foregroundColor: MaterialStateProperty.all(Colors.red)),
                  icon: const Icon(Icons.delete),
                  label: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Delete'),
                  ),
                ),
                // const SizedBox(
                //   width: 10,
                // ),
                // OutlinedButton.icon(
                //   onPressed: () async {},
                //   style: ButtonStyle(
                //       shape: MaterialStateProperty.all(RoundedRectangleBorder(
                //         borderRadius: BorderRadius.circular(8.0),
                //       )),
                //       backgroundColor: MaterialStateProperty.all(Colors.white),
                //       foregroundColor: MaterialStateProperty.all(Colors.green)),
                //   icon: const Icon(Icons.list_sharp),
                //   label: const Padding(
                //     padding: EdgeInsets.all(8.0),
                //     child: Text('Quantity Movement'),
                //   ),
                // ),
                const SizedBox(
                  width: 10,
                ),
                OutlinedButton.icon(
                  onPressed: () async {
                    await showPrintDialog("Materials", mainController);
                  },
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      )),
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                      foregroundColor:
                          MaterialStateProperty.all(Colors.black54)),
                  icon: const Icon(Icons.print),
                  label: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Print'),
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
