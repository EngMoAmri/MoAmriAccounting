import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/inventory/controllers/inventory_controller.dart';
import 'package:moamri_accounting/controllers/main_controller.dart';
import 'package:moamri_accounting/database/my_materials_database.dart';
import 'package:moamri_accounting/dialogs/alerts_dialogs.dart';
import 'package:moamri_accounting/inventory/dialogs/edit_material_dialog.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../dialogs/select_category_dialog.dart';
import '../../dialogs/sort_by_dialog.dart';
import '../dialogs/add_material_dialog.dart';
import '../../dialogs/print_dialogs.dart';
import '../dialogs/currencies_dialog.dart';
import '../print/print_materials.dart';

class InventoryPage extends StatelessWidget {
  InventoryPage({super.key});

  final MainController mainController = Get.find();
  final InventoryController controller = Get.put(InventoryController());

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Obx(() => Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              const SizedBox(
                height: 10,
              ),
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10),
                      child: TextFormField(
                        textCapitalization: TextCapitalization.sentences,
                        controller: controller.searchController,
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
                          hintText: 'ابحث عن طريق اسم المادة أو الباركود',
                        ),
                        keyboardType: TextInputType.text,
                        onChanged: (value) {
                          if (value.isEmpty) {
                            controller.firstLoad();
                          } else {
                            controller.search();
                          }
                        },
                      ),
                    ),
                  ),
                  Center(
                      child: Text("العدد: ${controller.materialsCount.value}")),
                  const SizedBox(
                    width: 10,
                  ),
                  IconButton(
                      onPressed: () {
                        controller.firstLoad();
                      },
                      tooltip: "تحديث",
                      icon: const Icon(Icons.sync)),
                  const SizedBox(
                    width: 10,
                  )
                ],
              ),
              const SizedBox(
                height: 10,
              ),
              const Divider(
                height: 1,
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        scrollDirection: Axis.horizontal,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            OutlinedButton.icon(
                              onPressed: () async {
                                controller.selectedCategory
                                    .value = (await showCategoryDialog(
                                        controller.categories.value,
                                        controller.selectedCategory.value)) ??
                                    controller.selectedCategory.value;
                                controller.firstLoad();
                              },
                              style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  )),
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.white),
                                  foregroundColor: MaterialStateProperty.all(
                                      Colors.black54)),
                              icon: const Icon(Icons.category),
                              label: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                    'الصنف: ${controller.categories.value[controller.selectedCategory.value]}'),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            OutlinedButton.icon(
                              onPressed: () async {
                                var result = await showSortByDialog(
                                    controller.orderBy.value,
                                    controller.selectedOrderBy.value,
                                    controller.selectedOrderDir.value);
                                if (result == null) return;
                                controller.selectedOrderBy.value = result[0];
                                controller.selectedOrderDir.value = result[1];
                                controller.firstLoad();
                              },
                              style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  )),
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.white),
                                  foregroundColor: MaterialStateProperty.all(
                                      Colors.black54)),
                              icon: const Icon(Icons.sort),
                              label: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                    'ترتيب حسب: ${controller.orderBy.value[controller.selectedOrderBy.value]} ترتيباً: ${(controller.selectedOrderDir.value == 0) ? 'تصاعدياً' : 'تنازلياً'}'),
                              ),
                            ),
                            const SizedBox(
                              width: 10,
                            ),
                            OutlinedButton.icon(
                              onPressed: () async {
                                var refersh =
                                    await showCurrenciesDialog(mainController);
                                if (refersh) {
                                  controller.firstLoad();
                                }
                              },
                              style: ButtonStyle(
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  )),
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.white),
                                  foregroundColor: MaterialStateProperty.all(
                                      Colors.black54)),
                              icon: const Icon(Icons.money),
                              label: const Padding(
                                padding: EdgeInsets.all(8.0),
                                child: Text('العملات'),
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
                ),
              ),
              Expanded(
                  child: controller.isFirstLoadRunning.value
                      ? const Center(
                          child: CircularProgressIndicator(),
                        )
                      : SfDataGridTheme(
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
                                onColumnResizeUpdate:
                                    (ColumnResizeUpdateDetails details) {
                                  controller.columnWidths
                                          .value[details.column.columnName] =
                                      details.width;
                                  controller.columnWidths.refresh();
                                  return true;
                                },
                                headerGridLinesVisibility:
                                    GridLinesVisibility.both,
                                source: controller.dataSource.value,
                                isScrollbarAlwaysShown: true,
                                loadMoreViewBuilder: (BuildContext context,
                                    LoadMoreRows loadMoreRows) {
                                  Future<String> loadRows() async {
                                    await loadMoreRows();
                                    return Future<String>.value('Completed');
                                  }

                                  return FutureBuilder<String>(
                                    initialData: controller.hasNextPage.value
                                        ? 'Loading'
                                        : 'Completed',
                                    future: loadRows(),
                                    builder: (context, snapShot) {
                                      return snapShot.data == 'Loading'
                                          ? Container(
                                              height: 60.0,
                                              alignment: Alignment.center,
                                              width: double.infinity,
                                              child: Container(
                                                  width: 40,
                                                  height: 40,
                                                  alignment: Alignment.center,
                                                  child:
                                                      const CircularProgressIndicator(
                                                    backgroundColor:
                                                        Colors.blue,
                                                  )))
                                          : SizedBox.fromSize(size: Size.zero);
                                    },
                                  );
                                },
                                selectionMode: SelectionMode.single,
                                frozenColumnsCount: 2,
                                columns: [
                                  GridColumn(
                                      columnName: 'Barcode',
                                      width: controller
                                          .columnWidths.value['Barcode']!,
                                      minimumWidth: 120,
                                      label: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2),
                                          alignment: Alignment.center,
                                          child: const Text(
                                            'الباركود',
                                            overflow: TextOverflow.ellipsis,
                                          ))),
                                  GridColumn(
                                      columnName: 'Name',
                                      width: controller
                                          .columnWidths.value['Name']!,
                                      minimumWidth: 120,
                                      label: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2),
                                          alignment: Alignment.center,
                                          child: const Text(
                                            'الاسم',
                                            overflow: TextOverflow.ellipsis,
                                          ))),
                                  GridColumn(
                                      columnName: 'Category',
                                      width: controller
                                          .columnWidths.value['Category']!,
                                      minimumWidth: 120,
                                      label: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2),
                                          alignment: Alignment.center,
                                          child: const Text(
                                            'الصنف',
                                            overflow: TextOverflow.ellipsis,
                                          ))),
                                  GridColumn(
                                      columnName: 'Quantity',
                                      width: controller
                                          .columnWidths.value['Quantity']!,
                                      minimumWidth: 120,
                                      label: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2),
                                          alignment: Alignment.center,
                                          child: const Text(
                                            'الكمية',
                                            overflow: TextOverflow.ellipsis,
                                          ))),
                                  GridColumn(
                                      columnName: 'Unit',
                                      width: controller
                                          .columnWidths.value['Unit']!,
                                      minimumWidth: 120,
                                      label: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2),
                                          alignment: Alignment.center,
                                          child: const Text(
                                            'الوحدة',
                                            overflow: TextOverflow.ellipsis,
                                          ))),
                                  GridColumn(
                                      columnName: 'Cost Price',
                                      width: controller
                                          .columnWidths.value['Cost Price']!,
                                      minimumWidth: 120,
                                      label: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2),
                                          alignment: Alignment.center,
                                          child: const Text(
                                            'سعر الشراء',
                                            overflow: TextOverflow.ellipsis,
                                          ))),
                                  GridColumn(
                                      columnName: 'Sale Price',
                                      width: controller
                                          .columnWidths.value['Sale Price']!,
                                      minimumWidth: 120,
                                      label: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2),
                                          alignment: Alignment.center,
                                          child: const Text(
                                            'سعر البيع',
                                            overflow: TextOverflow.ellipsis,
                                          ))),
                                  GridColumn(
                                      columnName: 'Note',
                                      width: controller
                                          .columnWidths.value['Note']!,
                                      minimumWidth: 120,
                                      columnWidthMode:
                                          ColumnWidthMode.lastColumnFill,
                                      label: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2),
                                          alignment: Alignment.center,
                                          child: const Text(
                                            'ملاحظات',
                                            overflow: TextOverflow.ellipsis,
                                          ))),
                                ]),
                          ),
                        )),
              const Divider(
                height: 1,
              ),
              Padding(
                padding: const EdgeInsets.all(10),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      OutlinedButton.icon(
                        onPressed: () async {
                          if ((await showAddMaterialDialog(mainController)) ??
                              false) {
                            controller.firstLoad();
                          }
                        },
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            )),
                            backgroundColor:
                                MaterialStateProperty.all(Colors.white),
                            foregroundColor:
                                MaterialStateProperty.all(Colors.blue)),
                        icon: const Icon(Icons.add),
                        label: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('إضافة'),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      OutlinedButton.icon(
                        onPressed: () async {
                          if (controller.dataGridController.selectedIndex < 0) {
                            showErrorDialog("يجب عليك إختيار مادة");
                            return;
                          }
                          if ((await showEditMaterialDialog(
                                  mainController,
                                  controller.materials.value[controller
                                      .dataGridController.selectedIndex])) ??
                              false) {
                            controller.firstLoad();
                          }
                        },
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            )),
                            backgroundColor:
                                MaterialStateProperty.all(Colors.white),
                            foregroundColor:
                                MaterialStateProperty.all(Colors.green)),
                        icon: const Icon(Icons.edit),
                        label: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('تعديل'),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      OutlinedButton.icon(
                        onPressed: () async {
                          if (controller.dataGridController.selectedIndex < 0) {
                            showErrorDialog("يجب عليك إختيار مادة");
                            return;
                          }
                          var material = controller.materials.value[
                              controller.dataGridController.selectedIndex];
                          if (!(await MyMaterialsDatabase.isMaterialDeletable(
                              material.id!))) {
                            showErrorDialog(
                                "لا يمكن حذف المادة لأنها مستخدمة مع بعض البيانات الأخرى");
                            return;
                          }

                          if (!(await showConfirmationDialog(
                                  "هل أنت متأكد من أنك تريد الحذف؟") ??
                              false)) {
                            return;
                          }
                          await MyMaterialsDatabase.deleteMaterial(
                              material, mainController.currentUser.value!.id!);
                          await showSuccessDialog("تم حذف المادة");
                          controller.firstLoad();
                        },
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            )),
                            backgroundColor:
                                MaterialStateProperty.all(Colors.white),
                            foregroundColor:
                                MaterialStateProperty.all(Colors.red)),
                        icon: const Icon(Icons.delete),
                        label: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('حذف'),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      OutlinedButton.icon(
                        onPressed: () async {
                          var printType = await showPrintDialog("المواد");
                          if (printType == null) return;
                          if (printType == "حراري") {
                            await printMaterialsRoll(
                                mainController, controller);
                          } else {
                            await printMaterialsA4(mainController, controller);
                          }
                        },
                        style: ButtonStyle(
                            shape: MaterialStateProperty.all(
                                RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8.0),
                            )),
                            backgroundColor:
                                MaterialStateProperty.all(Colors.white),
                            foregroundColor:
                                MaterialStateProperty.all(Colors.black54)),
                        icon: const Icon(Icons.print),
                        label: const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Text('طباعة'),
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
          )),
    );
  }
}
