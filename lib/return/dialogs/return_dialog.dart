import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/controllers/main_controller.dart';
import 'package:moamri_accounting/database/entities/my_material.dart';
import 'package:moamri_accounting/return/controllers/return_controller.dart';
import 'package:moamri_accounting/utils/global_utils.dart';

Future<bool?> showReturnDialog(
    MainController mainController, ReturnController returnController) async {
  return await showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        // bill info
        returnController.billTotalInMainCurrency.value = 0;
        for (var saleData in returnController.billDataSource.value.salesData) {
          MyMaterial material = saleData['Material'];
          double rateExchange = 0.0;
          for (var currency in mainController.currencies.value) {
            if (currency.name == material.currency) {
              rateExchange = currency.exchangeRate;
              break;
            }
          }
          returnController.billTotalInMainCurrency.value +=
              rateExchange * saleData['Total'];
        }
        // double billTotalWithDiscount = billTotalInMainCurrency -
        //     (returnController.invoiceItem.value!.invoice.discount ?? 0);
        // double paymentTotalWithMainCurrency = 0;
        // for (var payment in returnController.invoiceItem.value!.payments) {
        //   paymentTotalWithMainCurrency += payment.amount * payment.exchangeRate;
        // }

        double? debtStillToBePaid =
            returnController.invoiceItem.value!.debt?.amount;
        // return info
        returnController.returnTotalInMainCurrency.value = 0;
        for (var returnData
            in returnController.returnedDataSource.value.returnsData) {
          MyMaterial material = returnData['Material'];
          double rateExchange = 0.0;
          for (var currency in mainController.currencies.value) {
            if (currency.name == material.currency) {
              rateExchange = currency.exchangeRate;
              break;
            }
          }
          returnController.returnTotalInMainCurrency.value +=
              rateExchange * returnData['Total'];
        }
        final noteTextController = TextEditingController();
        var printReceiptCheckBox = true;

        // double stillToBePaid = billTotalWithDiscount;
        return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0)),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: StatefulBuilder(builder: (context, setState) {
                  return FocusTraversalGroup(
                    policy: WidgetOrderTraversalPolicy(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 32.0),
                      child: Obx(() => Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Row(
                                children: [
                                  const SizedBox(
                                    width: 20,
                                  ),
                                  const Expanded(
                                    child: Text(
                                      "أرجاع",
                                      style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.bold),
                                    ),
                                  ),
                                  Padding(
                                    padding:
                                        const EdgeInsets.fromLTRB(20, 0, 20, 0),
                                    child: IconButton(
                                      onPressed: () {
                                        Get.back();
                                      },
                                      icon: const Icon(
                                        Icons.close,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const Divider(),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          child: Table(
                                              border: TableBorder.all(
                                                  color: Colors.black,
                                                  width: 1,
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(10))),
                                              children: [
                                                const TableRow(
                                                    decoration: BoxDecoration(
                                                        color: Colors.black,
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        10),
                                                                topRight: Radius
                                                                    .circular(
                                                                        10))),
                                                    children: [
                                                      Padding(
                                                          padding:
                                                              EdgeInsets.all(4),
                                                          child: Center(
                                                              child: Text(
                                                                  "إجمالي الفاتورة",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold)))),
                                                    ]),
                                                TableRow(children: [
                                                  Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4),
                                                      child: Center(
                                                          child: Text(
                                                              returnController
                                                                  .billTotalString
                                                                  .value,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center))),
                                                ]),
                                                const TableRow(
                                                    decoration: BoxDecoration(
                                                      color: Colors.black,
                                                    ),
                                                    children: [
                                                      Padding(
                                                          padding:
                                                              EdgeInsets.all(4),
                                                          child: Center(
                                                              child: Text(
                                                                  "الإجمالي بالعملة الرئيسية",
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold)))),
                                                    ]),
                                                TableRow(
                                                    decoration: const BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        10),
                                                                bottomRight: Radius
                                                                    .circular(
                                                                        10))),
                                                    children: [
                                                      Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(4),
                                                          child: Center(
                                                              child: Text(
                                                                  '${GlobalUtils.getMoney(returnController.billTotalInMainCurrency.value)} ${mainController.storeData.value!.currency}',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center))),
                                                    ]),
                                              ]),
                                        ),
                                        if ((debtStillToBePaid ?? 0) > 0)
                                          Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 4),
                                            child: Table(
                                                border: TableBorder.all(
                                                    color: Colors.black,
                                                    width: 1,
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                10))),
                                                children: [
                                                  const TableRow(
                                                      decoration: BoxDecoration(
                                                          color: Colors.red,
                                                          borderRadius:
                                                              BorderRadius.only(
                                                                  topLeft: Radius
                                                                      .circular(
                                                                          10),
                                                                  topRight: Radius
                                                                      .circular(
                                                                          10))),
                                                      children: [
                                                        Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    4),
                                                            child: Center(
                                                                child: Text(
                                                                    "الباقي كدين",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontWeight:
                                                                            FontWeight.bold)))),
                                                      ]),
                                                  TableRow(
                                                      decoration: const BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius.only(
                                                                  bottomLeft: Radius
                                                                      .circular(
                                                                          10),
                                                                  bottomRight: Radius
                                                                      .circular(
                                                                          10))),
                                                      children: [
                                                        Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(4),
                                                            child: Center(
                                                                child: Text(
                                                                    '${GlobalUtils.getMoney(debtStillToBePaid)} ${mainController.storeData.value!.currency}',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center))),
                                                      ]),
                                                ]),
                                          )
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 10,
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10, vertical: 4),
                                          child: Table(
                                              border: TableBorder.all(
                                                  color: Colors.black,
                                                  width: 1,
                                                  borderRadius:
                                                      const BorderRadius.all(
                                                          Radius.circular(10))),
                                              children: [
                                                const TableRow(
                                                    decoration: BoxDecoration(
                                                        color: Colors.black,
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        10),
                                                                topRight: Radius
                                                                    .circular(
                                                                        10))),
                                                    children: [
                                                      Padding(
                                                          padding:
                                                              EdgeInsets.all(4),
                                                          child: Center(
                                                              child: Text(
                                                                  "إجمالي المرتجع",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold)))),
                                                    ]),
                                                TableRow(children: [
                                                  Padding(
                                                      padding:
                                                          const EdgeInsets.all(
                                                              4),
                                                      child: Center(
                                                          child: Text(
                                                              returnController
                                                                  .returnTotalString
                                                                  .value,
                                                              textAlign:
                                                                  TextAlign
                                                                      .center))),
                                                ]),
                                                const TableRow(
                                                    decoration: BoxDecoration(
                                                      color: Colors.black,
                                                    ),
                                                    children: [
                                                      Padding(
                                                          padding:
                                                              EdgeInsets.all(4),
                                                          child: Center(
                                                              child: Text(
                                                                  "الإجمالي بالعملة الرئيسية",
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center,
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold)))),
                                                    ]),
                                                TableRow(
                                                    decoration: const BoxDecoration(
                                                        borderRadius:
                                                            BorderRadius.only(
                                                                bottomLeft: Radius
                                                                    .circular(
                                                                        10),
                                                                bottomRight: Radius
                                                                    .circular(
                                                                        10))),
                                                    children: [
                                                      Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .all(4),
                                                          child: Center(
                                                              child: Text(
                                                                  '${GlobalUtils.getMoney(returnController.returnTotalInMainCurrency.value)} ${mainController.storeData.value!.currency}',
                                                                  textAlign:
                                                                      TextAlign
                                                                          .center))),
                                                    ]),
                                              ]),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                child: TextFormField(
                                    controller: noteTextController,
                                    decoration: InputDecoration(
                                      counterText: '',
                                      labelText: "ملاحظة",
                                      filled: true,
                                      fillColor: Colors.white,
                                      isDense: true,
                                      contentPadding: const EdgeInsets.all(10),
                                      focusedBorder: OutlineInputBorder(
                                        borderSide: const BorderSide(
                                            color: Colors.green),
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      border: const OutlineInputBorder(
                                        borderRadius: BorderRadius.all(
                                            Radius.circular(12.0)),
                                      ),
                                    ),
                                    keyboardType: TextInputType.text),
                              ),
                              const Divider(),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    flex: 2,
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        Row(
                                          children: [
                                            Checkbox(
                                                value: printReceiptCheckBox,
                                                onChanged: (value) {
                                                  setState(() {
                                                    printReceiptCheckBox =
                                                        value ?? false;
                                                  });
                                                }),
                                            const Expanded(
                                                child: Text('طباعة الفاتورة')),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.stretch,
                                      children: [
                                        OutlinedButton.icon(
                                            onPressed: () async {
                                              //   var date = DateTime.now()
                                              //       .millisecondsSinceEpoch;
                                              //   List<Payment> payments = [];
                                              //   if (paymentWithMainCurrencyTextController
                                              //       .text.isNotEmpty) {
                                              //     payments.add(Payment(
                                              //         date: date,
                                              //         amount: double.parse(
                                              //             paymentWithMainCurrencyTextController
                                              //                 .text),
                                              //         currency:
                                              //             mainController
                                              //                 .storeData
                                              //                 .value!
                                              //                 .currency,
                                              //         note: noteTextController
                                              //                 .text.isEmpty
                                              //             ? null
                                              //             : noteTextController
                                              //                 .text));
                                              //   }
                                              //   for (var currencyPayment
                                              //       in differenetCurrenciesPayments
                                              //           .keys) {
                                              //     if (differenetCurrenciesPayments[
                                              //             currencyPayment]!
                                              //         .text
                                              //         .isNotEmpty) {
                                              //       payments.add(Payment(
                                              //           date: date,
                                              //           amount: double.parse(
                                              //               differenetCurrenciesPayments[
                                              //                       currencyPayment]!
                                              //                   .text),
                                              //           currency:
                                              //               currencyPayment
                                              //                   .name,
                                              //           note: noteTextController
                                              //                   .text
                                              //                   .isEmpty
                                              //               ? null
                                              //               : noteTextController
                                              //                   .text));
                                              //     }
                                              //   }
                                              //   Invoice invoice = Invoice(
                                              //       type: 'sale',
                                              //       date: date,
                                              //       discount: double.tryParse(
                                              //           discountTextController
                                              //               .text),
                                              //       total:
                                              //           billTotalInMainCurrency,
                                              //       note: noteTextController
                                              //               .text.isEmpty
                                              //           ? null
                                              //           : noteTextController
                                              //               .text);
                                              //   List<InvoiceMaterialItem>
                                              //       inoviceMaterialsItem =
                                              //       [];

                                              //   for (var saleData
                                              //       in returnController
                                              //           .dataSource
                                              //           .value
                                              //           .salesData) {
                                              //     inoviceMaterialsItem.add(
                                              //         InvoiceMaterialItem(
                                              //             material: saleData[
                                              //                 'Material'],
                                              //             invoiceMaterial:
                                              //                 InvoiceMaterial(
                                              //               materialId:
                                              //                   saleData[
                                              //                           'Material']
                                              //                       .id,
                                              //               quantity: saleData[
                                              //                   'Quantity'],
                                              //               price: saleData[
                                              //                   'Price'],
                                              //               note: saleData[
                                              //                   'Note'],
                                              //             )));
                                              //   }
                                              //   InvoiceItem invoiceItem =
                                              //       InvoiceItem(
                                              //     invoice: invoice,
                                              //     payments: payments,
                                              //     debt: null,
                                              //     customer: null,
                                              //     inoviceMaterialsItems:
                                              //         inoviceMaterialsItem,
                                              //   );
                                              //   await InvoicesDatabase
                                              //       .insertInvoiceItem(
                                              //           invoiceItem,
                                              //           mainController
                                              //               .currentUser
                                              //               .value!);
                                              //   if (printReceiptCheckBox) {
                                              //     var printChoice =
                                              //         mainController
                                              //             .getStorage
                                              //             .read(
                                              //                 'order-print-choice');
                                              //     printChoice ??=
                                              //         await showPrintOrderDialog(
                                              //             mainController);
                                              //     if (printChoice != null) {
                                              //       if (printChoice ==
                                              //           "حراري") {
                                              //         await printInvoiceRoll(
                                              //             mainController,
                                              //             invoiceItem);
                                              //       } else {
                                              //         await printInvoiceA4(
                                              //             mainController,
                                              //             invoiceItem);
                                              //       }
                                              //     }
                                              //   }

                                              // returnController
                                              //     .dataSource.value
                                              //     .clearDataGridRows(
                                              //         returnController);
                                              // InventoryController
                                              //     inventoryController =
                                              //     Get.find();
                                              // inventoryController
                                              //     .firstLoad();
                                              // CustomersController
                                              //     customersController =
                                              //     Get.find();
                                              // customersController
                                              //     .firstLoad();
                                              // returnController.dataSource
                                              //     .refresh();
                                              // await AudioPlayer().play(
                                              //     AssetSource(
                                              //         'sounds/cash-register.mp3'));

                                              // Get.back();
                                            },
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      Colors.white),
                                              foregroundColor:
                                                  MaterialStateProperty.all(
                                                      Colors.green),
                                              shape: MaterialStateProperty.all(
                                                  RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              )),
                                            ),
                                            label: Text("تم".tr),
                                            icon: const Icon(Icons.done)),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                        OutlinedButton.icon(
                                            onPressed: () {
                                              Get.back();
                                            },
                                            style: ButtonStyle(
                                              backgroundColor:
                                                  MaterialStateProperty.all(
                                                      Colors.white),
                                              foregroundColor:
                                                  MaterialStateProperty.all(
                                                      Colors.red),
                                              shape: MaterialStateProperty.all(
                                                  RoundedRectangleBorder(
                                                borderRadius:
                                                    BorderRadius.circular(10.0),
                                              )),
                                            ),
                                            label: Text("إلغاء".tr),
                                            icon: const Icon(Icons.cancel)),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 5,
                              ),
                            ],
                          )),
                    ),
                  );
                }),
              ),
            ));
      });
}
