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
  Widget _buildProgressIndicator() {
    return Container(
        height: 60.0,
        alignment: Alignment.center,
        width: double.infinity,
        decoration: const BoxDecoration(
            border: BorderDirectional(
                top: BorderSide(
          width: 1.0,
        ))),
        child: Container(
            width: 40,
            height: 40,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(
              backgroundColor: Colors.transparent,
            )));
  }

  Widget _buildLoadMoreView(BuildContext context, LoadMoreRows loadMoreRows) {
    Future<String> loadRows() async {
      // Call the loadMoreRows function to call the
      // DataGridSource.handleLoadMoreRows method. So, additional
      // rows can be added from handleLoadMoreRows method.
      await loadMoreRows();
      return Future<String>.value('Completed');
    }

    return FutureBuilder<String>(
      initialData: 'Loading',
      future: loadRows(),
      builder: (context, snapShot) {
        return snapShot.data == 'Loading'
            ? _buildProgressIndicator()
            : SizedBox.fromSize(size: Size.zero);
      },
    );
  }

  final MainController mainController = Get.find();
  final CustomersController controller = Get.put(CustomersController());

  @override
  Widget build(BuildContext context) {
    return Obx(() => (controller.isFirstLoadRunning.value)
        ? const Center(
            child: CircularProgressIndicator(),
          )
        : Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
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
                          hintText: 'Search by name',
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
                      child: Text("Count: ${controller.customersCount.value}")),
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
                                    'Order By: ${controller.orderBy.value[controller.selectedOrderBy.value]},  Sorted: ${(controller.selectedOrderDir.value == 0) ? 'Ascending' : 'Descending'}'),
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
                        tooltip: "Referesh",
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
                                headerGridLinesVisibility:
                                    GridLinesVisibility.both,
                                source: controller.dataSource.value,
                                loadMoreViewBuilder: _buildLoadMoreView,
                                selectionMode: SelectionMode.single,
                                frozenColumnsCount: 2,
                                columns: [
                                  GridColumn(
                                      columnName: 'ID',
                                      columnWidthMode:
                                          ColumnWidthMode.fitByCellValue,
                                      minimumWidth: 120,
                                      label: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2),
                                          alignment: Alignment.center,
                                          child: const Text(
                                            'ID',
                                            overflow: TextOverflow.ellipsis,
                                          ))),
                                  GridColumn(
                                      columnName: 'Name',
                                      columnWidthMode:
                                          ColumnWidthMode.fitByCellValue,
                                      minimumWidth: 120,
                                      label: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2),
                                          alignment: Alignment.center,
                                          child: const Text(
                                            'Name',
                                            overflow: TextOverflow.ellipsis,
                                          ))),
                                  GridColumn(
                                      columnName: 'Phone',
                                      columnWidthMode:
                                          ColumnWidthMode.fitByCellValue,
                                      minimumWidth: 120,
                                      label: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2),
                                          alignment: Alignment.center,
                                          child: const Text(
                                            'Phone',
                                            overflow: TextOverflow.ellipsis,
                                          ))),
                                  GridColumn(
                                      columnName: 'Address',
                                      columnWidthMode:
                                          ColumnWidthMode.fitByCellValue,
                                      minimumWidth: 120,
                                      label: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2),
                                          alignment: Alignment.center,
                                          child: const Text(
                                            'Address',
                                            overflow: TextOverflow.ellipsis,
                                          ))),
                                  GridColumn(
                                      columnName: 'Description',
                                      columnWidthMode:
                                          ColumnWidthMode.lastColumnFill,
                                      minimumWidth: 120,
                                      label: Container(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 2),
                                          alignment: Alignment.center,
                                          child: const Text(
                                            'Description',
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
                          if ((await showAddCustomerDialog(mainController)) ??
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
                          child: Text('Add'),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      OutlinedButton.icon(
                        onPressed: () async {
                          if (controller.dataGridController.selectedIndex < 0) {
                            showErrorDialog("You Must Select a Customer");
                            return;
                          }
                          if ((await showEditCustomerDialog(
                                  mainController,
                                  controller.customers.value[controller
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
                          child: Text('Edit'),
                        ),
                      ),
                      const SizedBox(
                        width: 10,
                      ),
                      OutlinedButton.icon(
                        onPressed: () async {
                          if (controller.dataGridController.selectedIndex < 0) {
                            showErrorDialog("You Must Select a Customer");
                            return;
                          }
                          var customer = controller.customers.value[
                              controller.dataGridController.selectedIndex];
                          var deletable =
                              await CustomersDatabase.isCustomerDeletable(
                                  customer.id!);
                          if (!deletable) {
                            showErrorDialog(
                                "This Customer Has Some Invoices, So He/She Cannot Be Deleted");
                            return;
                          }
                          if (!(await showConfirmationDialog(
                                  "Are you sure? you want to delete!") ??
                              false)) {
                            return;
                          }
                          await CustomersDatabase.deleteCustomer(customer);
                          await showSuccessDialog("Customer Has Been Deleted");
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
                          child: Text('Delete'),
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
          ));
  }
}
