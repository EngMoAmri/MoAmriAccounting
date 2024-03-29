import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/controllers/main_controller.dart';
import 'package:moamri_accounting/database/entities/my_material.dart';
import 'package:moamri_accounting/database/my_materials_database.dart';
import 'package:moamri_accounting/dialogs/alerts_dialogs.dart';
import 'package:moamri_accounting/sale/dialogs/sale_material_dialog.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../controllers/sale_controller.dart';
import '../dialogs/sale_dialog.dart';

// TODO add button to edit quantity to selected item
class SalePage extends StatelessWidget {
  SalePage({super.key});
  final MainController mainController = Get.find();
  final SaleController controller = Get.put(SaleController());
  final categoriesScrollController = ScrollController();
  final materialsScrollController = ScrollController();

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
                      controller: controller.searchController,
                      emptyBuilder: (context) {
                        return const SizedBox(
                          height: 60,
                          child: Center(
                            child: Text("لم يتم إيجاد المادة"),
                          ),
                        );
                      },
                      onSelected: (value) async {
                        var index =
                            controller.dataSource.value.getMaterialIndex(value);
                        if (index == -1) {
                          if (value.quantity < 1) {
                            showErrorDialog(
                                "لا يمكن إضافة المادة لعدم توفر كمية في المستودع!");
                            return;
                          }
                          controller.dataSource.value
                              .addDataGridRow(value, controller);
                          await AudioPlayer()
                              .play(AssetSource('sounds/scanner-beep.mp3'));

                          controller.dataSource.refresh();
                        } else {
                          showSaleMaterialDialog(
                              mainController, controller, index);
                        }
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
                            labelText: 'بحث عن المواد بواسطة الاسم أو الباركود',
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
        // Add visiblity detector to handle barcode
        // values only when widget is visible
        VisibilityDetector(
          onVisibilityChanged: (VisibilityInfo info) {
            controller.visible.value = info.visibleFraction > 0;
          },
          key: const Key('visible-detector-key'),
          child: BarcodeKeyboardListener(
            bufferDuration: const Duration(milliseconds: 200),
            onBarcodeScanned: (barcode) async {
              if (!(controller.visible.value ?? false)) return;
              MyMaterial? selectedMaterial =
                  await MyMaterialsDatabase.getMaterialByBarcode(barcode);
              if (selectedMaterial == null) {
                showErrorDialog("لا يوجد مادة بهذا الباركود");
                return;
              }
              if (selectedMaterial.quantity < 1) {
                showErrorDialog(
                    "لا يمكن إضافة المادة لعدم توفر كمية في المستودع!");
                return;
              }

              var index = controller.dataSource.value
                  .getMaterialIndex(selectedMaterial);
              if (index == -1) {
                controller.dataSource.value
                    .addDataGridRow(selectedMaterial, controller);
                controller.dataSource.refresh();
              } else {
                showSaleMaterialDialog(mainController, controller, index);
              }
            },
            child: Container(),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
          child: Row(
            children: [
              Expanded(
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue[400]!, width: 1),
                      borderRadius: BorderRadius.circular(5),
                      shape: BoxShape.rectangle,
                      color: Colors.white),
                  child: Obx(
                    () => (controller.loadingCategories.value)
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : Scrollbar(
                            controller: categoriesScrollController,
                            thumbVisibility: true,
                            trackVisibility: true,
                            child: ListView.builder(
                                controller: categoriesScrollController,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      controller.selectedCategory.value = index;
                                      controller.getCategoryMaterials();
                                      controller.categories.refresh();
                                    },
                                    child: Container(
                                      color:
                                          (controller.selectedCategory.value ==
                                                  index)
                                              ? Colors.blue[200]
                                              : Colors.transparent,
                                      child: ListTile(
                                        dense: true,
                                        visualDensity: const VisualDensity(
                                            vertical: -3), // to compact
                                        title: Text(
                                            controller.categories.value[index]),
                                      ),
                                    ),
                                  );
                                },
                                itemCount: controller.categories.value.length),
                          ),
                  ),
                ),
              ),
              const SizedBox(
                width: 5,
              ),
              Expanded(
                flex: 2,
                child: Container(
                  height: 80,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.blue[400]!, width: 1),
                      borderRadius: BorderRadius.circular(5),
                      shape: BoxShape.rectangle,
                      color: Colors.white),
                  child: Obx(
                    () => (controller.loadingMaterials.value)
                        ? const Center(
                            child: CircularProgressIndicator(),
                          )
                        : Scrollbar(
                            controller: materialsScrollController,
                            thumbVisibility: true,
                            trackVisibility: true,
                            child: ListView.builder(
                                controller: materialsScrollController,
                                itemBuilder: (context, index) {
                                  return GestureDetector(
                                    onTap: () {
                                      controller.selectedMaterial.value = index;
                                      controller.materials.refresh();
                                    },
                                    onDoubleTap: () async {
                                      var index1 = controller.dataSource.value
                                          .getMaterialIndex(controller
                                              .materials.value[index]);
                                      if (index1 != -1) {
                                        showSaleMaterialDialog(
                                            mainController, controller, index1);
                                      } else {
                                        if (controller.materials.value[index]
                                                .quantity <
                                            1) {
                                          showErrorDialog(
                                              "لا يمكن إضافة المادة لعدم توفر كمية في المستودع!");
                                          return;
                                        }

                                        controller.selectedMaterial.value =
                                            index;
                                        controller.dataSource.value
                                            .addDataGridRow(
                                                controller
                                                    .materials.value[index],
                                                controller);
                                        await AudioPlayer().play(AssetSource(
                                            'sounds/scanner-beep.mp3'));

                                        controller.materials.refresh();
                                        controller.dataSource.refresh();
                                      }
                                    },
                                    child: Container(
                                      color:
                                          (controller.selectedMaterial.value ==
                                                  index)
                                              ? Colors.blue[200]
                                              : Colors.transparent,
                                      child: ListTile(
                                        dense: true,
                                        visualDensity: const VisualDensity(
                                            vertical: -3), // to compact
                                        title: Text(
                                            '${controller.materials.value[index].barcode} : ${controller.materials.value[index].unit} :: ${controller.materials.value[index].name}'),
                                      ),
                                    ),
                                  );
                                },
                                itemCount: controller.materials.value.length),
                          ),
                  ),
                ),
              ),
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
                    showSaleMaterialDialog(mainController, controller,
                        details.rowColumnIndex.rowIndex - 1);
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
                        showSaleDialog(mainController, controller);
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
