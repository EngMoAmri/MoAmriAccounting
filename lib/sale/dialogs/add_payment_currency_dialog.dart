import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/controllers/main_controller.dart';
import 'package:moamri_accounting/database/currencies_database.dart';
import 'package:moamri_accounting/dialogs/alerts_dialogs.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../database/entities/currency.dart';
import '../../inventory/data_sources/currencies_data_source.dart';

// TODO double click to select
Future<Currency?> showAddPaymentCurrencuDialog(
    MainController mainController, List<String> currencies) async {
  return await showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        CurrenciesDataSource? currenciesDataSource;
        final DataGridController dataGridController = DataGridController();

        var loading = true;
        var refereshPrevoisPage = false;
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: FocusTraversalGroup(
                policy: WidgetOrderTraversalPolicy(),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: StatefulBuilder(builder: (context, setState) {
                    if (currenciesDataSource == null) {
                      CurrenciesDatabase.getCurrenciesWithout(currencies)
                          .then((value) {
                        currenciesDataSource = CurrenciesDataSource(value);
                        setState(() {
                          loading = false;
                        });
                      });
                    }
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            const SizedBox(
                              width: 20,
                            ),
                            const Expanded(
                              child: Text(
                                "العملات",
                                style: TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.bold),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                              child: IconButton(
                                onPressed: () {
                                  Get.back(result: refereshPrevoisPage);
                                },
                                icon: const Icon(
                                  Icons.close,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (loading)
                          const Center(
                            child: CircularProgressIndicator(),
                          )
                        else
                          SfDataGridTheme(
                            data: SfDataGridThemeData(
                              headerColor: Colors.white,
                            ),
                            child: Container(
                              color: Colors.black12,
                              child: SfDataGrid(
                                  controller: dataGridController,
                                  gridLinesVisibility: GridLinesVisibility.both,
                                  headerGridLinesVisibility:
                                      GridLinesVisibility.both,
                                  source: currenciesDataSource!,
                                  isScrollbarAlwaysShown: true,
                                  selectionMode: SelectionMode.single,
                                  columns: [
                                    GridColumn(
                                        columnName: 'Currency',
                                        minimumWidth: 120,
                                        label: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 2),
                                            alignment: Alignment.center,
                                            child: const Text(
                                              'العملة',
                                              overflow: TextOverflow.ellipsis,
                                            ))),
                                    GridColumn(
                                        columnName: 'Exchange Rate',
                                        minimumWidth: 120,
                                        columnWidthMode:
                                            ColumnWidthMode.lastColumnFill,
                                        label: Container(
                                            padding: const EdgeInsets.symmetric(
                                                vertical: 2),
                                            alignment: Alignment.center,
                                            child: Text(
                                              'سعر صرف هذه العملة إلى ${mainController.storeData.value!.currency}',
                                              // overflow: TextOverflow.ellipsis,
                                            ))),
                                  ]),
                            ),
                          ),
                        const Divider(
                          height: 1,
                        ),
                        Padding(
                          padding: const EdgeInsets.all(10),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceAround,
                            children: [
                              OutlinedButton.icon(
                                onPressed: () async {
                                  if (dataGridController.selectedIndex < 0) {
                                    showErrorDialog("يجب عليك إختيار عملة");
                                    return;
                                  }
                                  Get.back(
                                      result: currenciesDataSource!
                                              .currenciesData[
                                          dataGridController.selectedIndex]);
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
                                  child: Text('إختيار'),
                                ),
                              ),
                              const SizedBox(
                                width: 10,
                              ),
                              OutlinedButton.icon(
                                onPressed: () async {
                                  Get.back();
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
                                icon: const Icon(Icons.close),
                                label: const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Text('إلغاء'),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ),
        );
      });
}
