import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/controllers/inventory_controller.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../dialogs/add_material_dialog.dart';

class InventoryPage extends StatelessWidget {
  const InventoryPage({super.key});
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

  @override
  Widget build(BuildContext context) {
    final InventoryController controller = Get.put(InventoryController());
    return Column(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        Row(
          children: [
            Expanded(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 10),
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
                      borderRadius: BorderRadius.all(Radius.circular(8.0)),
                    ),
                    counterText: "",
                    hintText: 'Search by barcode or name',
                  ),
                  keyboardType: TextInputType.text,
                  onFieldSubmitted: (value) async {
                    // TODO
                    // FocusManager.instance.primaryFocus?.unfocus();
                    // controller.creating.value = true;
                    // await controller.createStore();
                    // controller.creating.value = false;
                  },
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        Expanded(
            child: Obx(() => controller.isFirstLoadRunning.value
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
                          gridLinesVisibility: GridLinesVisibility.both,
                          headerGridLinesVisibility: GridLinesVisibility.both,
                          source: controller.dataSource.value,
                          loadMoreViewBuilder: _buildLoadMoreView,
                          frozenColumnsCount: 2,
                          columns: [
                            GridColumn(
                                columnName: 'id',
                                columnWidthMode: ColumnWidthMode.fill,
                                label: Container(
                                    padding: EdgeInsets.symmetric(vertical: 2),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Barcode/No.',
                                      overflow: TextOverflow.ellipsis,
                                    ))),
                            GridColumn(
                                columnName: 'Name',
                                columnWidthMode: ColumnWidthMode.fill,
                                label: Container(
                                    padding: EdgeInsets.symmetric(vertical: 2),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Name',
                                      overflow: TextOverflow.ellipsis,
                                    ))),
                            GridColumn(
                                columnName: 'Category',
                                columnWidthMode: ColumnWidthMode.fill,
                                label: Container(
                                    padding: EdgeInsets.symmetric(vertical: 2),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Category',
                                      overflow: TextOverflow.ellipsis,
                                    ))),
                            GridColumn(
                                columnName: 'Quantity',
                                columnWidthMode: ColumnWidthMode.fill,
                                label: Container(
                                    padding: EdgeInsets.symmetric(vertical: 2),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Quantity',
                                      overflow: TextOverflow.ellipsis,
                                    ))),
                            GridColumn(
                                columnName: 'Unit',
                                columnWidthMode: ColumnWidthMode.fill,
                                label: Container(
                                    padding: EdgeInsets.symmetric(vertical: 2),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Unit',
                                      overflow: TextOverflow.ellipsis,
                                    ))),
                            GridColumn(
                                columnName: 'Cost Price',
                                columnWidthMode: ColumnWidthMode.fill,
                                label: Container(
                                    padding: EdgeInsets.symmetric(vertical: 2),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Cost Price',
                                      overflow: TextOverflow.ellipsis,
                                    ))),
                            GridColumn(
                                columnName: 'Sale Price',
                                columnWidthMode: ColumnWidthMode.fill,
                                label: Container(
                                    padding: EdgeInsets.symmetric(vertical: 2),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Sale Price',
                                      overflow: TextOverflow.ellipsis,
                                    ))),
                            GridColumn(
                                columnName: 'Note',
                                columnWidthMode: ColumnWidthMode.fill,
                                label: Container(
                                    padding: EdgeInsets.symmetric(vertical: 2),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Note',
                                      overflow: TextOverflow.ellipsis,
                                    ))),
                            GridColumn(
                                columnName: 'Discount',
                                columnWidthMode: ColumnWidthMode.fill,
                                label: Container(
                                    padding: EdgeInsets.symmetric(vertical: 2),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'Discount',
                                      overflow: TextOverflow.ellipsis,
                                    ))),
                            GridColumn(
                                columnName: 'TAX/VAT',
                                columnWidthMode: ColumnWidthMode.fill,
                                label: Container(
                                    padding: EdgeInsets.symmetric(vertical: 2),
                                    alignment: Alignment.center,
                                    child: Text(
                                      'TAX/VAT',
                                      overflow: TextOverflow.ellipsis,
                                    ))),
                            // GridColumn(
                            //     columnName: 'id',
                            //     columnWidthMode: ColumnWidthMode.fill,
                            //     label: Container(
                            //         padding: EdgeInsets.symmetric(vertical:4),
                            //         alignment: Alignment.center,
                            //         child: Text(
                            //           'ID',
                            //           overflow: TextOverflow.ellipsis,
                            //         ))),
                          ]),
                    ),
                  ))),
        Padding(
          padding: const EdgeInsets.all(10),
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                OutlinedButton.icon(
                  onPressed: () async {
                    showAddMaterialDialog();
                  },
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      )),
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                      foregroundColor: MaterialStateProperty.all(Colors.green)),
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
                  onPressed: () async {},
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      )),
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                      foregroundColor: MaterialStateProperty.all(Colors.green)),
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
                  onPressed: () async {},
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      )),
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                      foregroundColor: MaterialStateProperty.all(Colors.green)),
                  icon: const Icon(Icons.list_sharp),
                  label: const Padding(
                    padding: EdgeInsets.all(8.0),
                    child: Text('Quantity Movement'),
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