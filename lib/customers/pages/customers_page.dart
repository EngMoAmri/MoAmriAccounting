import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/customers/controllers/customers_controller.dart';
import 'package:moamri_accounting/controllers/main_controller.dart';
import 'package:moamri_accounting/database/customers_database.dart';
import 'package:moamri_accounting/dialogs/alerts_dialogs.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../dialogs/sort_by_dialog.dart';
import '../dialogs/add_customer_dialog.dart';
import '../dialogs/edit_customer_dialog.dart';

class CustomersPage extends StatelessWidget {
  CustomersPage({super.key});

  final MainController mainController = Get.find();
  final CustomersController controller = Get.put(CustomersController());

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
                          hintText: 'بحث بالاسم',
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
                      child: Text("العدد: ${controller.customersCount.value}")),
                  const SizedBox(
                    width: 10,
                  )
                ],
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
                              icon: const Icon(Icons.category),
                              label: Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Text(
                                    'ترتيب حسب: ${controller.orderBy.value[controller.selectedOrderBy.value]} ترتيباً: ${(controller.selectedOrderDir.value == 0) ? 'تصاعدياً' : 'تنازلياً'}'),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    IconButton(
                        onPressed: () {
                          controller.firstLoad();
                        },
                        tooltip: "تحديث",
                        icon: const Icon(Icons.sync)),
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
                                      columnName: 'ID',
                                      width:
                                          controller.columnWidths.value['ID']!,
                                      minimumWidth: 120,
                                      label: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2),
                                          alignment: Alignment.center,
                                          child: const Text(
                                            'المعرف',
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
                                      columnName: 'Debt',
                                      width: controller
                                          .columnWidths.value['Debt']!,
                                      minimumWidth: 120,
                                      label: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2),
                                          alignment: Alignment.center,
                                          child: const Text(
                                            'إجمالي الدين',
                                            overflow: TextOverflow.ellipsis,
                                          ))),
                                  GridColumn(
                                      columnName: 'Phone',
                                      width: controller
                                          .columnWidths.value['Phone']!,
                                      minimumWidth: 120,
                                      label: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2),
                                          alignment: Alignment.center,
                                          child: const Text(
                                            'الجوال',
                                            overflow: TextOverflow.ellipsis,
                                          ))),
                                  GridColumn(
                                      columnName: 'Address',
                                      width: controller
                                          .columnWidths.value['Address']!,
                                      minimumWidth: 120,
                                      label: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2),
                                          alignment: Alignment.center,
                                          child: const Text(
                                            'العنوان',
                                            overflow: TextOverflow.ellipsis,
                                          ))),
                                  GridColumn(
                                      columnName: 'Description',
                                      columnWidthMode:
                                          ColumnWidthMode.lastColumnFill,
                                      width: controller
                                          .columnWidths.value['Description']!,
                                      minimumWidth: 120,
                                      label: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2),
                                          alignment: Alignment.center,
                                          child: const Text(
                                            'الوصف',
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
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      OutlinedButton.icon(
                        onPressed: () async {
                          if ((await showAddCustomerDialog(mainController) !=
                              null)) {
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
                            showErrorDialog("يجب عليك إختيار عميل");
                            return;
                          }
                          if ((await showEditCustomerDialog(
                                  mainController,
                                  controller
                                      .customersWithDebts
                                      .value[controller
                                          .dataGridController.selectedIndex]
                                      .customer)) ??
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
                            showErrorDialog("يجب عليك إختيار عميل");
                            return;
                          }
                          var customer = controller.customersWithDebts.value[
                              controller.dataGridController.selectedIndex];
                          if (!(await CustomersDatabase.isCustomerDeletable(
                              customer.customer.id!))) {
                            showErrorDialog(
                                "لا يمكن حذف هذا العميل لأنه لايزال لديه بعض الديون");
                            return;
                          }

                          if (!(await showConfirmationDialog(
                                  "هل أنت متأكد من الحذف؟!") ??
                              false)) {
                            return;
                          }
                          await CustomersDatabase.deleteCustomer(
                              customer.customer,
                              mainController.currentUser.value!.id!);
                          await showSuccessDialog("تم حذف العميل");
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
                          // var printType = await showPrintDialog("Materials");
                          // if (printType == null) return;
                          // if (printType == "Roll") {
                          //   await printMaterialsRoll(
                          //       mainController, controller);
                          // } else {
                          //   await printMaterialsA4(mainController, controller);
                          // }
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
