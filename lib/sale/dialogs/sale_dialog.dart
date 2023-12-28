import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/controllers/main_controller.dart';
import 'package:moamri_accounting/customers/dialogs/add_customer_dialog.dart';
import 'package:moamri_accounting/database/customers_database.dart';
import 'package:moamri_accounting/database/items/customer_debt_item.dart';
import 'package:moamri_accounting/dialogs/alerts_dialogs.dart';
import 'package:moamri_accounting/sale/controllers/sale_controller.dart';

import '../../database/entities/customer.dart';

Future<bool?> showSaleDialog(
    MainController mainController, SaleController saleController) async {
  return await showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        final formKey = GlobalKey<FormState>();
        final customerTextController = TextEditingController();
        CustomerDebtItem? customerDebtItem;
        final paymentTextController = TextEditingController();
        final discountTextController = TextEditingController();
        final noteTextController = TextEditingController();
        var registerTheRestAsDebtCheckBox = false;
        var printReceiptCheckBox = true;
        return Dialog(
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12.0)),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 800),
                child: StatefulBuilder(builder: (context, setState) {
                  return FocusTraversalGroup(
                    policy: WidgetOrderTraversalPolicy(),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          vertical: 16.0, horizontal: 32.0),
                      child: Obx(() => Form(
                            key: formKey,
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Row(
                                  children: [
                                    const SizedBox(
                                      width: 20,
                                    ),
                                    const Expanded(
                                      child: Text(
                                        "بيع",
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.fromLTRB(
                                          20, 0, 20, 0),
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
                                const Divider(height: 1),
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
                                          const SizedBox(
                                            height: 4,
                                          ),
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
                                                                EdgeInsets.all(
                                                                    4),
                                                            child: Center(
                                                                child: FittedBox(
                                                                    fit: BoxFit
                                                                        .fitWidth,
                                                                    child: Text(
                                                                        "الإجمالي",
                                                                        style: TextStyle(
                                                                            color:
                                                                                Colors.white,
                                                                            fontWeight: FontWeight.bold))))),
                                                      ]),
                                                  TableRow(children: [
                                                    Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .all(4),
                                                        child: Center(
                                                            child: Text(
                                                                saleController
                                                                    .totalString
                                                                    .value,
                                                                textAlign:
                                                                    TextAlign
                                                                        .center))),
                                                  ]),
                                                ]),
                                          ),
                                          if (customerDebtItem == null)
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10,
                                                      vertical: 4),
                                                  child: TypeAheadField(
                                                    controller:
                                                        customerTextController,
                                                    emptyBuilder: (context) {
                                                      return const SizedBox(
                                                        height: 60,
                                                        child: Center(
                                                          child: Text(
                                                              "لم يتم إيجاد العميل"),
                                                        ),
                                                      );
                                                    },
                                                    onSelected: (value) {
                                                      setState(() {
                                                        customerTextController
                                                                .text =
                                                            '${value.customer.name} / جوال: ${value.customer.phone}';
                                                        customerDebtItem =
                                                            value;
                                                      });
                                                    },
                                                    suggestionsCallback:
                                                        (String pattern) async {
                                                      return await CustomersDatabase
                                                          .getSearchedCustomers(
                                                              mainController,
                                                              0,
                                                              pattern);
                                                    },
                                                    itemBuilder:
                                                        (context, suggestion) {
                                                      return ListTile(
                                                        title: Text(
                                                            '${suggestion.customer.name} / جوال: ${suggestion.customer.phone}'),
                                                      );
                                                    },
                                                    builder: (context,
                                                        controller, focusNode) {
                                                      return TextFormField(
                                                        textCapitalization:
                                                            TextCapitalization
                                                                .sentences,
                                                        controller:
                                                            customerTextController,
                                                        focusNode: focusNode,
                                                        decoration:
                                                            InputDecoration(
                                                          filled: true,
                                                          fillColor:
                                                              Colors.white,
                                                          isDense: true,
                                                          contentPadding:
                                                              const EdgeInsets
                                                                  .all(10),
                                                          focusedBorder:
                                                              OutlineInputBorder(
                                                            borderSide:
                                                                const BorderSide(
                                                                    color: Colors
                                                                        .green),
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        8),
                                                          ),
                                                          border:
                                                              const OutlineInputBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            8.0)),
                                                          ),
                                                          counterText: "",
                                                          labelText: 'العميل',
                                                        ),
                                                        keyboardType:
                                                            TextInputType.text,
                                                      );
                                                    },
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10,
                                                      vertical: 4),
                                                  child: OutlinedButton.icon(
                                                      style: ButtonStyle(
                                                          shape: MaterialStateProperty
                                                              .all(
                                                                  RoundedRectangleBorder(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        12.0),
                                                          )),
                                                          foregroundColor:
                                                              MaterialStateProperty
                                                                  .all(Colors
                                                                      .blue)),
                                                      onPressed: () async {
                                                        Customer? customer =
                                                            await showAddCustomerDialog(
                                                                mainController);
                                                        if (customer != null) {
                                                          setState(() {
                                                            customerDebtItem =
                                                                CustomerDebtItem(
                                                                    customer:
                                                                        customer,
                                                                    debt:
                                                                        'لا يوجد دين');
                                                          });
                                                        }
                                                      },
                                                      icon:
                                                          const Icon(Icons.add),
                                                      label: const Text(
                                                          'إضافة جديد')),
                                                ),
                                              ],
                                            )
                                          else
                                            Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.stretch,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              children: [
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10,
                                                      vertical: 4),
                                                  child: Row(
                                                    children: [
                                                      Expanded(
                                                        child: Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .symmetric(
                                                                    horizontal:
                                                                        10),
                                                            child: Text(
                                                                'العميل ${customerDebtItem!.customer.name}')),
                                                      ),
                                                      Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .fromLTRB(
                                                                20, 0, 20, 0),
                                                        child: IconButton(
                                                          onPressed: () {
                                                            setState(() {
                                                              // cos there no customer
                                                              registerTheRestAsDebtCheckBox =
                                                                  false;
                                                              customerTextController
                                                                  .text = "";

                                                              customerDebtItem =
                                                                  null;
                                                            });
                                                          },
                                                          icon: const Icon(
                                                            Icons.close,
                                                            color: Colors.red,
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10,
                                                      vertical: 4),
                                                  child: Table(
                                                      border: TableBorder.all(
                                                          color: Colors.black,
                                                          width: 1,
                                                          borderRadius:
                                                              const BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          10))),
                                                      children: [
                                                        const TableRow(
                                                            decoration: BoxDecoration(
                                                                color: Colors
                                                                    .black,
                                                                borderRadius: BorderRadius.only(
                                                                    topLeft: Radius
                                                                        .circular(
                                                                            10),
                                                                    topRight: Radius
                                                                        .circular(
                                                                            10))),
                                                            children: [
                                                              Padding(
                                                                  padding:
                                                                      EdgeInsets
                                                                          .all(
                                                                              4),
                                                                  child: Center(
                                                                      child: FittedBox(
                                                                          fit: BoxFit
                                                                              .fitWidth,
                                                                          child: Text(
                                                                              "مقدار الدين",
                                                                              style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))))),
                                                            ]),
                                                        TableRow(children: [
                                                          Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                      .all(4),
                                                              child: Center(
                                                                  child: Column(
                                                                      children: [
                                                                    Text(
                                                                        (customerDebtItem?.debt ??
                                                                            ''),
                                                                        textAlign:
                                                                            TextAlign.center),
                                                                  ]))),
                                                        ]),
                                                      ]),
                                                ),
                                              ],
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                        child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const SizedBox(
                                          height: 4,
                                        ),
                                        Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 4),
                                            child: TextFormField(
                                              textCapitalization:
                                                  TextCapitalization.sentences,
                                              controller: paymentTextController,
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor: Colors.white,
                                                isDense: true,
                                                contentPadding:
                                                    const EdgeInsets.all(10),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      color: Colors.green),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                border:
                                                    const OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(8.0)),
                                                ),
                                                counterText: "",
                                                labelText: 'مقدار الدفع',
                                              ),
                                              keyboardType: TextInputType.text,
                                            )),
                                        Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10, vertical: 4),
                                            child: TextFormField(
                                              textCapitalization:
                                                  TextCapitalization.sentences,
                                              controller:
                                                  discountTextController,
                                              decoration: InputDecoration(
                                                filled: true,
                                                fillColor: Colors.white,
                                                isDense: true,
                                                contentPadding:
                                                    const EdgeInsets.all(10),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      color: Colors.green),
                                                  borderRadius:
                                                      BorderRadius.circular(8),
                                                ),
                                                border:
                                                    const OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(8.0)),
                                                ),
                                                counterText: "",
                                                labelText: 'مقدار الخصم',
                                              ),
                                              keyboardType: TextInputType.text,
                                            )),
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
                                                contentPadding:
                                                    const EdgeInsets.all(10),
                                                focusedBorder:
                                                    OutlineInputBorder(
                                                  borderSide: const BorderSide(
                                                      color: Colors.green),
                                                  borderRadius:
                                                      BorderRadius.circular(12),
                                                ),
                                                border:
                                                    const OutlineInputBorder(
                                                  borderRadius:
                                                      BorderRadius.all(
                                                          Radius.circular(
                                                              12.0)),
                                                ),
                                              ),
                                              minLines: 3,
                                              maxLines: 3,
                                              keyboardType: TextInputType.text),
                                        ),
                                      ],
                                    ))
                                  ],
                                ),
                                const Divider(),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Expanded(
                                      flex: 2,
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
                                                                .circular(10),
                                                            topRight:
                                                                Radius.circular(
                                                                    10))),
                                                children: [
                                                  Padding(
                                                      padding:
                                                          EdgeInsets.all(4),
                                                      child: Center(
                                                          child: FittedBox(
                                                              fit: BoxFit
                                                                  .fitWidth,
                                                              child: Text(
                                                                  "الباقي",
                                                                  style: TextStyle(
                                                                      color: Colors
                                                                          .white,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .bold))))),
                                                ]),
                                            TableRow(children: [
                                              Padding(
                                                  padding:
                                                      const EdgeInsets.all(4),
                                                  child: Center(
                                                      child: Text(
                                                          '${}',
                                                          textAlign: TextAlign
                                                              .center))),
                                            ]),
                                          ]),
                                    ),
                                    Expanded(
                                      flex: 3,
                                      child: Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.stretch,
                                        children: [
                                          Row(
                                            children: [
                                              Checkbox(
                                                  value:
                                                      registerTheRestAsDebtCheckBox,
                                                  onChanged: (value) {
                                                    if (customerDebtItem ==
                                                        null) {
                                                      showErrorDialog(
                                                          'يجب عليك إختيار العميل أولاً');
                                                      return;
                                                    }
                                                    setState(() {
                                                      registerTheRestAsDebtCheckBox =
                                                          value ?? false;
                                                    });
                                                  }),
                                              const Expanded(
                                                  child: Text(
                                                      'تسجيل باقي المبلغ كدين')),
                                            ],
                                          ),
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
                                                  child:
                                                      Text('طباعة الفاتورة')),
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
                                                // if (saleController
                                                //     .materialDialogFormKey
                                                //     .currentState!
                                                //     .validate()) {
                                                //   saleData['Quantity'] =
                                                //       saleController
                                                //           .materialDialogQuantity
                                                //           .value;
                                                //   saleData[
                                                //       'Tax'] = (saleController
                                                //           .materialDialogTaxTextController
                                                //           .text
                                                //           .isEmpty)
                                                //       ? null
                                                //       : saleController
                                                //           .materialDialogTax
                                                //           .value;
                                                //   saleData['Total'] = saleController
                                                //               .materialDialogQuantity
                                                //               .value *
                                                //           material
                                                //               .salePrice +
                                                //       saleController
                                                //               .materialDialogQuantity
                                                //               .value *
                                                //           (saleController
                                                //                   .materialDialogTax
                                                //                   .value /
                                                //               100) *
                                                //           material
                                                //               .salePrice;
                                                //   saleData['Note'] =
                                                //       saleController
                                                //           .materialDialogNoteTextController
                                                //           .text
                                                //           .trim();
                                                //   saleController
                                                //       .dataSource.value
                                                //       .notifyListeners();
                                                //   saleController
                                                //       .dataSource.value
                                                //       .calculateTotals(
                                                //           saleController);
                                                //   saleController
                                                //       .dataSource
                                                //       .refresh();

                                                //   Get.back();
                                                // }
                                              },
                                              style: ButtonStyle(
                                                backgroundColor:
                                                    MaterialStateProperty.all(
                                                        Colors.white),
                                                foregroundColor:
                                                    MaterialStateProperty.all(
                                                        Colors.green),
                                                shape:
                                                    MaterialStateProperty.all(
                                                        RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
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
                                                shape:
                                                    MaterialStateProperty.all(
                                                        RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
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
                            ),
                          )),
                    ),
                  );
                }),
              ),
            ));
      });
}
