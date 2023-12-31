import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/controllers/main_controller.dart';
import 'package:moamri_accounting/database/currencies_database.dart';
import 'package:moamri_accounting/dialogs/alerts_dialogs.dart';
import 'package:moamri_accounting/inventory/dialogs/edit_currency_dialog.dart';
import 'package:syncfusion_flutter_core/theme.dart';
import 'package:syncfusion_flutter_datagrid/datagrid.dart';

import '../../dialogs/print_dialogs.dart';
import '../data_sources/currencies_data_source.dart';
import '../print/print_currencies.dart';
import 'add_currency_dialog.dart';

Future<bool> showCurrenciesDialog(MainController mainController) async {
  return await showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        CurrenciesDataSource currenciesDataSource =
            CurrenciesDataSource(mainController.currencies.value);
        final DataGridController dataGridController = DataGridController();

        var loading = false;
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
                                  source: currenciesDataSource,
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
                                  if ((await showAddCurrencyDialog(
                                          mainController)) !=
                                      null) {
                                    setState(() {
                                      loading = true;
                                    });
                                    CurrenciesDatabase.getCurrencies()
                                        .then((value) {
                                      currenciesDataSource =
                                          CurrenciesDataSource(value);
                                      setState(() {
                                        loading = false;
                                      });
                                    });
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
                                  if (dataGridController.selectedIndex < 0) {
                                    showErrorDialog("يجب عليك إختيار عملة");
                                    return;
                                  }
                                  if ((await showEditCurrencyDialog(
                                          mainController,
                                          currenciesDataSource.currenciesData[
                                              dataGridController
                                                  .selectedIndex])) !=
                                      null) {
                                    setState(() {
                                      refereshPrevoisPage = true;
                                      loading = true;
                                    });
                                    CurrenciesDatabase.getCurrencies()
                                        .then((value) {
                                      currenciesDataSource =
                                          CurrenciesDataSource(value);
                                      setState(() {
                                        loading = false;
                                      });
                                    });
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
                                        Colors.green)),
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
                                  if (dataGridController.selectedIndex < 0) {
                                    showErrorDialog("يجب عليك إختيار عملة");
                                    return;
                                  }
                                  if (!(await CurrenciesDatabase
                                      .isCurrencyDeletable(currenciesDataSource
                                          .currenciesData[
                                              dataGridController.selectedIndex]
                                          .name))) {
                                    showErrorDialog(
                                        "لا يمكن حذف العملة لأنها مستخدمة مع بعض البيانات الأخرى");
                                    return;
                                  }
                                  var currency =
                                      currenciesDataSource.currenciesData[
                                          dataGridController.selectedIndex];
                                  if (!(await showConfirmationDialog(
                                          "هل أنت متأكد من أنك تريد الحذف؟") ??
                                      false)) {
                                    return;
                                  }
                                  await CurrenciesDatabase.deleteCurrency(
                                      currency,
                                      mainController.currentUser.value!);
                                  await showSuccessDialog("تم حذف العملة");
                                  setState(() {
                                    refereshPrevoisPage = true;
                                    loading = true;
                                  });
                                  CurrenciesDatabase.getCurrencies()
                                      .then((value) {
                                    currenciesDataSource =
                                        CurrenciesDataSource(value);
                                    setState(() {
                                      loading = false;
                                    });
                                  });
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
                                  var printType =
                                      await showPrintDialog("العملات");
                                  if (printType == null) return;
                                  if (printType == "حراري") {
                                    await printCurrenciesRoll(mainController,
                                        currenciesDataSource.currenciesData);
                                  } else {
                                    await printCurrenciesA4(mainController,
                                        currenciesDataSource.currenciesData);
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
