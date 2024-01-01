import 'package:flutter/material.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/controllers/main_controller.dart';
import 'package:moamri_accounting/customers/dialogs/add_customer_dialog.dart';
import 'package:moamri_accounting/database/customers_database.dart';
import 'package:moamri_accounting/database/entities/currency.dart';
import 'package:moamri_accounting/database/entities/invoice.dart';
import 'package:moamri_accounting/database/entities/invoice_material.dart';
import 'package:moamri_accounting/database/entities/my_material.dart';
import 'package:moamri_accounting/database/entities/payment.dart';
import 'package:moamri_accounting/database/invoices_database.dart';
import 'package:moamri_accounting/database/items/customer_debt_item.dart';
import 'package:moamri_accounting/database/items/invoice_item.dart';
import 'package:moamri_accounting/database/items/invoice_material_item.dart';
import 'package:moamri_accounting/dialogs/alerts_dialogs.dart';
import 'package:moamri_accounting/sale/controllers/sale_controller.dart';
import 'package:moamri_accounting/sale/dialogs/add_payment_currency_dialog.dart';
import 'package:moamri_accounting/utils/global_methods.dart';

import '../../database/entities/customer.dart';
import '../../inventory/dialogs/edit_currency_dialog.dart';
import '../print/print_invoice.dart';
import 'print_order_dialog.dart';

Future<bool?> showSaleDialog(
    MainController mainController, SaleController saleController) async {
  return await showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        final formKey = GlobalKey<FormState>();
        final customerTextController = TextEditingController();

        // here to make the customer can pay with difference currencies
        Map<Currency, TextEditingController> differenetCurrenciesPayments = {};

        CustomerDebtItem? customerDebtItem;
        final paymentWithMainCurrencyTextController = TextEditingController();
        final discountTextController = TextEditingController();
        final noteTextController = TextEditingController();
        var registerTheRestAsDebtCheckBox = false;
        var printReceiptCheckBox = true;
        double totalInMainCurrency = 0;
        for (var saleData in saleController.dataSource.value.salesData) {
          MyMaterial material = saleData['Material'];
          double rateExchange = 0.0;
          for (var currency in mainController.currencies.value) {
            if (currency.name == material.currency) {
              rateExchange = currency.exchangeRate;
              break;
            }
          }
          totalInMainCurrency += rateExchange * saleData['Total'];
        }
        double totalWithDiscount = totalInMainCurrency;
        double paymentTotalWithMainCurrency = 0;
        double stillToBePaid = totalWithDiscount;
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
                                const Divider(),
                                if (customerDebtItem == null)
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: TypeAheadField(
                                            controller: customerTextController,
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
                                                customerTextController.text =
                                                    '${value.customer.name} / جوال: ${value.customer.phone}';
                                                customerDebtItem = value;
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
                                            itemBuilder: (context, suggestion) {
                                              return ListTile(
                                                title: Text(
                                                    '${suggestion.customer.name} / جوال: ${suggestion.customer.phone}'),
                                              );
                                            },
                                            builder: (context, controller,
                                                focusNode) {
                                              return TextFormField(
                                                textCapitalization:
                                                    TextCapitalization
                                                        .sentences,
                                                controller:
                                                    customerTextController,
                                                focusNode: focusNode,
                                                decoration: InputDecoration(
                                                  filled: true,
                                                  fillColor: Colors.white,
                                                  isDense: true,
                                                  contentPadding:
                                                      const EdgeInsets.all(10),
                                                  focusedBorder:
                                                      OutlineInputBorder(
                                                    borderSide:
                                                        const BorderSide(
                                                            color:
                                                                Colors.green),
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            8),
                                                  ),
                                                  border:
                                                      const OutlineInputBorder(
                                                    borderRadius:
                                                        BorderRadius.all(
                                                            Radius.circular(
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
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        OutlinedButton.icon(
                                            style: ButtonStyle(
                                                shape:
                                                    MaterialStateProperty.all(
                                                        RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          12.0),
                                                )),
                                                foregroundColor:
                                                    MaterialStateProperty.all(
                                                        Colors.blue)),
                                            onPressed: () async {
                                              Customer? customer =
                                                  await showAddCustomerDialog(
                                                      mainController);
                                              if (customer != null) {
                                                setState(() {
                                                  customerDebtItem =
                                                      CustomerDebtItem(
                                                          customer: customer,
                                                          debt: 'لا يوجد دين');
                                                });
                                              }
                                            },
                                            icon: const Icon(Icons.add),
                                            label: const Text('إضافة جديد')),
                                      ],
                                    ),
                                  )
                                else
                                  Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10, vertical: 4),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Table(
                                                border: TableBorder.all(
                                                    color: Colors.black,
                                                    width: 1,
                                                    borderRadius:
                                                        const BorderRadius.all(
                                                            Radius.circular(
                                                                10))),
                                                columnWidths: const {
                                                  0: FlexColumnWidth(2),
                                                  1: FlexColumnWidth(),
                                                },
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
                                                                child: Text(
                                                                    "العميل",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontWeight:
                                                                            FontWeight.bold)))),
                                                        Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    4),
                                                            child: Center(
                                                                child: Text(
                                                                    "مقدار الدين",
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
                                                                    '${customerDebtItem!.customer.name} / جوال ${customerDebtItem!.customer.phone}',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center))),
                                                        Padding(
                                                            padding:
                                                                const EdgeInsets
                                                                    .all(4),
                                                            child: Center(
                                                                child: Text(
                                                                    customerDebtItem!
                                                                        .debt,
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center))),
                                                      ]),
                                                ]),
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 10,
                                        ),
                                        IconButton(
                                          onPressed: () {
                                            setState(() {
                                              // cos there no customer
                                              registerTheRestAsDebtCheckBox =
                                                  false;
                                              customerTextController.text = "";

                                              customerDebtItem = null;
                                            });
                                          },
                                          icon: const Icon(
                                            Icons.close,
                                            color: Colors.red,
                                          ),
                                        ),
                                      ],
                                    ),
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
                                                                child: Text(
                                                                    "الإجمالي",
                                                                    style: TextStyle(
                                                                        color: Colors
                                                                            .white,
                                                                        fontWeight:
                                                                            FontWeight.bold)))),
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
                                                  const TableRow(
                                                      decoration: BoxDecoration(
                                                        color: Colors.black,
                                                      ),
                                                      children: [
                                                        Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    4),
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
                                                                    '${GlobalMethods.getMoney(totalInMainCurrency)} ${mainController.storeData.value!.currency}',
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center))),
                                                      ]),
                                                ]),
                                          ),
                                          if (stillToBePaid >= 0)
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 4),
                                              child: Table(
                                                  border: TableBorder.all(
                                                      color: Colors.black,
                                                      width: 1,
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  10))),
                                                  children: [
                                                    TableRow(
                                                        decoration: BoxDecoration(
                                                            color:
                                                                (stillToBePaid ==
                                                                        0)
                                                                    ? Colors
                                                                        .green
                                                                    : Colors
                                                                        .red,
                                                            borderRadius: const BorderRadius
                                                                .only(
                                                                topLeft: Radius
                                                                    .circular(
                                                                        10),
                                                                topRight: Radius
                                                                    .circular(
                                                                        10))),
                                                        children: const [
                                                          Padding(
                                                              padding:
                                                                  EdgeInsets
                                                                      .all(4),
                                                              child: Center(
                                                                  child: Text(
                                                                      "الباقي",
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white,
                                                                          fontWeight:
                                                                              FontWeight.bold)))),
                                                        ]),
                                                    TableRow(
                                                        decoration: const BoxDecoration(
                                                            borderRadius: BorderRadius.only(
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
                                                                      '${GlobalMethods.getMoney(stillToBePaid)} ${mainController.storeData.value!.currency}',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center))),
                                                        ]),
                                                  ]),
                                            )
                                          else
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 4),
                                              child: Table(
                                                  border: TableBorder.all(
                                                      color: Colors.black,
                                                      width: 1,
                                                      borderRadius:
                                                          const BorderRadius
                                                              .all(
                                                              Radius.circular(
                                                                  10))),
                                                  children: [
                                                    const TableRow(
                                                        decoration: BoxDecoration(
                                                            color: Colors.green,
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
                                                                      .all(4),
                                                              child: Center(
                                                                  child: Text(
                                                                      "الباقي للعميل",
                                                                      style: TextStyle(
                                                                          color: Colors
                                                                              .white,
                                                                          fontWeight:
                                                                              FontWeight.bold)))),
                                                        ]),
                                                    TableRow(
                                                        decoration: const BoxDecoration(
                                                            borderRadius: BorderRadius.only(
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
                                                                      '${GlobalMethods.getMoney(stillToBePaid * -1)} ${mainController.storeData.value!.currency}',
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center))),
                                                        ]),
                                                  ]),
                                            ),
                                        ],
                                      ),
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                        flex: 2,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          children: [
                                            // TODO make sure the discount not exceed the profit
                                            Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 4),
                                                child: TextFormField(
                                                  textCapitalization:
                                                      TextCapitalization
                                                          .sentences,
                                                  controller:
                                                      discountTextController,
                                                  decoration: InputDecoration(
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                    isDense: true,
                                                    contentPadding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide:
                                                          const BorderSide(
                                                              color:
                                                                  Colors.green),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    border:
                                                        const OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  8.0)),
                                                    ),
                                                    counterText: "",
                                                    labelText:
                                                        'مقدار الخصم بالعملة ${mainController.storeData.value!.currency}',
                                                  ),
                                                  onChanged: (value) {
                                                    // TODO if the discount exceeded the profit
                                                    totalWithDiscount =
                                                        totalInMainCurrency -
                                                            (double.tryParse(
                                                                    discountTextController
                                                                        .text) ??
                                                                0);
                                                    setState(() {
                                                      stillToBePaid =
                                                          totalWithDiscount -
                                                              paymentTotalWithMainCurrency;
                                                    });
                                                  },
                                                  validator: (value) {
                                                    if (value?.trim().isEmpty ??
                                                        true) {
                                                      return null;
                                                    }
                                                    if (double.tryParse(
                                                            value!.trim()) ==
                                                        null) {
                                                      return "إدخل المبلغ بشكل صحيح";
                                                    }
                                                    return null;
                                                  },
                                                  keyboardType:
                                                      TextInputType.text,
                                                )),
                                            Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10,
                                                        vertical: 4),
                                                child: TextFormField(
                                                  textCapitalization:
                                                      TextCapitalization
                                                          .sentences,
                                                  controller:
                                                      paymentWithMainCurrencyTextController,
                                                  decoration: InputDecoration(
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                    isDense: true,
                                                    contentPadding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide:
                                                          const BorderSide(
                                                              color:
                                                                  Colors.green),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    border:
                                                        const OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  8.0)),
                                                    ),
                                                    counterText: "",
                                                    labelText:
                                                        'مقدار الدفع بالعملة ${mainController.storeData.value!.currency}',
                                                  ),
                                                  onChanged: (value) {
                                                    paymentTotalWithMainCurrency =
                                                        (double.tryParse(
                                                                paymentWithMainCurrencyTextController
                                                                    .text) ??
                                                            0.0);
                                                    for (var currency
                                                        in differenetCurrenciesPayments
                                                            .keys) {
                                                      paymentTotalWithMainCurrency +=
                                                          (double.tryParse(differenetCurrenciesPayments[
                                                                          currency]!
                                                                      .text) ??
                                                                  0.0) *
                                                              currency
                                                                  .exchangeRate;
                                                    }
                                                    setState(() {
                                                      stillToBePaid =
                                                          totalWithDiscount -
                                                              paymentTotalWithMainCurrency;
                                                    });
                                                  },
                                                  validator: (value) {
                                                    if (value?.trim().isEmpty ??
                                                        true) {
                                                      return null;
                                                    }
                                                    if (double.tryParse(
                                                            value!.trim()) ==
                                                        null) {
                                                      return "إدخل المبلغ بشكل صحيح";
                                                    }
                                                    return null;
                                                  },
                                                  keyboardType:
                                                      TextInputType.text,
                                                )),
                                            ListView.builder(
                                                shrinkWrap: true,
                                                physics:
                                                    const NeverScrollableScrollPhysics(),
                                                itemCount:
                                                    differenetCurrenciesPayments
                                                        .keys.length,
                                                itemBuilder: (context, index) {
                                                  return Padding(
                                                    padding: const EdgeInsets
                                                        .symmetric(
                                                        horizontal: 10,
                                                        vertical: 4),
                                                    child: Row(
                                                      children: [
                                                        Expanded(
                                                          child: TextFormField(
                                                            controller: differenetCurrenciesPayments[
                                                                differenetCurrenciesPayments
                                                                        .keys
                                                                        .toList()[
                                                                    index]],
                                                            textCapitalization:
                                                                TextCapitalization
                                                                    .sentences,
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
                                                                borderSide: const BorderSide(
                                                                    color: Colors
                                                                        .green),
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8),
                                                              ),
                                                              border:
                                                                  const OutlineInputBorder(
                                                                borderRadius: BorderRadius
                                                                    .all(Radius
                                                                        .circular(
                                                                            8.0)),
                                                              ),
                                                              counterText: "",
                                                              labelText:
                                                                  'مقدار الدفع بالعملة ${differenetCurrenciesPayments.keys.toList()[index].name}',
                                                            ),
                                                            onChanged: (value) {
                                                              paymentTotalWithMainCurrency =
                                                                  (double.tryParse(
                                                                          paymentWithMainCurrencyTextController
                                                                              .text) ??
                                                                      0.0);
                                                              for (var currency
                                                                  in differenetCurrenciesPayments
                                                                      .keys) {
                                                                paymentTotalWithMainCurrency +=
                                                                    (double.tryParse(differenetCurrenciesPayments[currency]!.text) ??
                                                                            0.0) *
                                                                        currency
                                                                            .exchangeRate;
                                                              }
                                                              setState(() {
                                                                stillToBePaid =
                                                                    totalWithDiscount -
                                                                        paymentTotalWithMainCurrency;
                                                              });
                                                            },
                                                            validator: (value) {
                                                              if (value
                                                                      ?.trim()
                                                                      .isEmpty ??
                                                                  true) {
                                                                return null;
                                                              }
                                                              if (double.tryParse(
                                                                      value!
                                                                          .trim()) ==
                                                                  null) {
                                                                return "إدخل المبلغ بشكل صحيح";
                                                              }
                                                              return null;
                                                            },
                                                            keyboardType:
                                                                TextInputType
                                                                    .text,
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 10,
                                                        ),
                                                        OutlinedButton.icon(
                                                          onPressed: () async {
                                                            var newCurrency =
                                                                (await showEditCurrencyDialog(
                                                                    mainController,
                                                                    differenetCurrenciesPayments
                                                                            .keys
                                                                            .toList()[
                                                                        index]));
                                                            if (newCurrency !=
                                                                null) {
                                                              setState(() {
                                                                differenetCurrenciesPayments[
                                                                        newCurrency] =
                                                                    differenetCurrenciesPayments
                                                                        .remove([
                                                                  differenetCurrenciesPayments
                                                                          .keys
                                                                          .toList()[
                                                                      index]
                                                                ])!;
                                                              });
                                                            }
                                                          },
                                                          style: ButtonStyle(
                                                              shape: MaterialStateProperty
                                                                  .all(
                                                                      RoundedRectangleBorder(
                                                                borderRadius:
                                                                    BorderRadius
                                                                        .circular(
                                                                            8.0),
                                                              )),
                                                              backgroundColor:
                                                                  MaterialStateProperty
                                                                      .all(Colors
                                                                          .white),
                                                              foregroundColor:
                                                                  MaterialStateProperty
                                                                      .all(Colors
                                                                          .green)),
                                                          icon: const Icon(
                                                              Icons.edit),
                                                          label: const Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    8.0),
                                                            child:
                                                                Text('الصرف'),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  );
                                                }),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 4),
                                              child: OutlinedButton.icon(
                                                  style: ButtonStyle(
                                                      shape: MaterialStateProperty
                                                          .all(
                                                              RoundedRectangleBorder(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(12.0),
                                                      )),
                                                      foregroundColor:
                                                          MaterialStateProperty
                                                              .all(
                                                                  Colors.blue)),
                                                  onPressed: () async {
                                                    if (differenetCurrenciesPayments
                                                            .keys.length ==
                                                        3) {
                                                      showErrorDialog(
                                                          'عفواً لايمكن إضافة أكثر من 3 عملات');
                                                      return;
                                                    }
                                                    List<String> currencies = [
                                                      mainController.storeData
                                                          .value!.currency
                                                    ];
                                                    currencies.addAll(
                                                        differenetCurrenciesPayments
                                                            .keys
                                                            .map((e) => e.name)
                                                            .toList());
                                                    var newCurrency =
                                                        await showAddPaymentCurrencyDialog(
                                                            mainController,
                                                            currencies);
                                                    if (newCurrency == null) {
                                                      return;
                                                    }
                                                    setState(() {
                                                      differenetCurrenciesPayments[
                                                              newCurrency] =
                                                          TextEditingController();
                                                    });
                                                  },
                                                  icon: const Icon(Icons.add),
                                                  label: const Text(
                                                      'إضافة دفع بعملة أخرى')),
                                            ),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10,
                                                      vertical: 4),
                                              child: TextFormField(
                                                  controller:
                                                      noteTextController,
                                                  decoration: InputDecoration(
                                                    counterText: '',
                                                    labelText: "ملاحظة",
                                                    filled: true,
                                                    fillColor: Colors.white,
                                                    isDense: true,
                                                    contentPadding:
                                                        const EdgeInsets.all(
                                                            10),
                                                    focusedBorder:
                                                        OutlineInputBorder(
                                                      borderSide:
                                                          const BorderSide(
                                                              color:
                                                                  Colors.green),
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              8),
                                                    ),
                                                    border:
                                                        const OutlineInputBorder(
                                                      borderRadius:
                                                          BorderRadius.all(
                                                              Radius.circular(
                                                                  12.0)),
                                                    ),
                                                  ),
                                                  keyboardType:
                                                      TextInputType.text),
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
                                                if (formKey.currentState!
                                                    .validate()) {
                                                  // first check if there is customer
                                                  if (customerDebtItem ==
                                                      null) {
                                                    // there is no customer
                                                    // so the total must be all paid
                                                    if (stillToBePaid > 0) {
                                                      showErrorDialog(
                                                          'يجب دفع المبلغ كاملاً');
                                                      return;
                                                    }
                                                    var date = DateTime.now()
                                                        .millisecondsSinceEpoch;
                                                    List<Payment> payments = [];
                                                    if (paymentWithMainCurrencyTextController
                                                        .text.isNotEmpty) {
                                                      payments.add(Payment(
                                                          date: date,
                                                          amount: double.parse(
                                                              paymentWithMainCurrencyTextController
                                                                  .text),
                                                          currency:
                                                              mainController
                                                                  .storeData
                                                                  .value!
                                                                  .currency,
                                                          note: noteTextController
                                                                  .text.isEmpty
                                                              ? null
                                                              : noteTextController
                                                                  .text));
                                                    }
                                                    for (var currencyPayment
                                                        in differenetCurrenciesPayments
                                                            .keys) {
                                                      if (differenetCurrenciesPayments[
                                                              currencyPayment]!
                                                          .text
                                                          .isNotEmpty) {
                                                        payments.add(Payment(
                                                            date: date,
                                                            amount: double.parse(
                                                                differenetCurrenciesPayments[
                                                                        currencyPayment]!
                                                                    .text),
                                                            currency:
                                                                currencyPayment
                                                                    .name,
                                                            note: noteTextController
                                                                    .text
                                                                    .isEmpty
                                                                ? null
                                                                : noteTextController
                                                                    .text));
                                                      }
                                                    }
                                                    Invoice invoice = Invoice(
                                                        type: 'sale',
                                                        date: date,
                                                        discount: double.tryParse(
                                                            discountTextController
                                                                .text),
                                                        total:
                                                            totalInMainCurrency,
                                                        note: noteTextController
                                                                .text.isEmpty
                                                            ? null
                                                            : noteTextController
                                                                .text);
                                                    List<InvoiceMaterialItem>
                                                        inoviceMaterialsItem =
                                                        [];

                                                    for (var saleData
                                                        in saleController
                                                            .dataSource
                                                            .value
                                                            .salesData) {
                                                      inoviceMaterialsItem.add(
                                                          InvoiceMaterialItem(
                                                              material: saleData[
                                                                  'Material'],
                                                              invoiceMaterial: InvoiceMaterial(
                                                                  materialId:
                                                                      saleData[
                                                                              'Material']
                                                                          .id,
                                                                  quantity:
                                                                      saleData[
                                                                          'Quantity'])));
                                                    }
                                                    InvoiceItem invoiceItem =
                                                        InvoiceItem(
                                                            invoice: invoice,
                                                            payments: payments,
                                                            debts: [],
                                                            customer: null,
                                                            inoviceMaterialsItems:
                                                                inoviceMaterialsItem,
                                                            invoiceOffersItems: [
                                                              //TODO
                                                            ]);
                                                    await InvoicesDatabase
                                                        .insertInvoiceItem(
                                                            invoiceItem,
                                                            mainController
                                                                .currentUser
                                                                .value!);
                                                    if (printReceiptCheckBox) {
                                                      // await mainController
                                                      //     .getStorage
                                                      //     .write(
                                                      //         'order-print-choice',
                                                      //         null); // TODO delete this

                                                      var printChoice =
                                                          mainController
                                                              .getStorage
                                                              .read(
                                                                  'order-print-choice');
                                                      printChoice ??=
                                                          await showPrintOrderDialog(
                                                              mainController);
                                                      if (printChoice != null) {
                                                        if (printChoice ==
                                                            "حراري") {
                                                          await printInvoiceRoll(
                                                              mainController,
                                                              invoiceItem);
                                                        } else {
                                                          await printInvoiceA4(
                                                              mainController,
                                                              invoiceItem);
                                                        }
                                                      }
                                                    }
                                                  } else {
                                                    // there is customer
                                                    // check if the register the rest as debt is enabled
                                                    if (stillToBePaid > 0 &&
                                                        !registerTheRestAsDebtCheckBox) {
                                                      showErrorDialog(
                                                          'يجب دفع المبلغ كاملاً');
                                                      return;
                                                    }
                                                  }

                                                  // saleController
                                                  //     .dataSource.value
                                                  //     .clearDataGridRows(
                                                  //         saleController);
                                                  // saleController.dataSource
                                                  //     .refresh();
                                                  // Get.back();
                                                }
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
