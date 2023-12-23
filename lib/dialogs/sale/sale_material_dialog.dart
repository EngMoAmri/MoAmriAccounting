import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/controllers/main_controller.dart';
import 'package:moamri_accounting/controllers/sale_controller.dart';
import 'package:moamri_accounting/database/entities/my_material.dart';
import 'package:moamri_accounting/dialogs/alerts_dialogs.dart';

Future<bool?> showSaleMaterialDialog(MainController mainController,
    SaleController saleController, int selectedIndex) async {
  Map<String, dynamic> saleData =
      saleController.dataSource.value.salesData[selectedIndex];
  print(saleData);
  MyMaterial material = saleData['Material'];
  saleController.searchController.clear();
  saleController.dialogQuantity.value = saleData['Quantity'];
  saleController.dialogQuantityTextController.text = "${saleData['Quantity']}";
  saleController.dialogDiscount.value = saleData['Discount'];
  saleController.dialogDiscountTextController.text =
      saleData['Discount'].toString();
  saleController.dialogTax.value = saleData['Tax'];
  saleController.dialogTaxTextController.text = saleData['Tax'].toString();
  saleController.dialogNoteTextController.text = saleData['Note'];

  return await showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: FocusTraversalGroup(
            policy: WidgetOrderTraversalPolicy(),
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 16.0, horizontal: 32.0),
              child: Obx(() => Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const SizedBox(
                        height: 10,
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 1,
                            child: Table(
                                border: TableBorder.all(
                                    color: Colors.black,
                                    width: 1,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10))),
                                children: [
                                  const TableRow(children: [
                                    Padding(
                                        padding: EdgeInsets.all(4),
                                        child: Center(
                                            child: FittedBox(
                                                fit: BoxFit.fitWidth,
                                                child: Text("Material",
                                                    style: TextStyle(
                                                        fontWeight: FontWeight
                                                            .bold))))),
                                  ]),
                                  TableRow(children: [
                                    Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Column(
                                          children: [
                                            Center(
                                                child: Text(material.barcode)),
                                            Center(child: Text(material.name)),
                                          ],
                                        )),
                                  ]),
                                  const TableRow(children: [
                                    Padding(
                                        padding: EdgeInsets.all(4),
                                        child: Center(
                                            child: FittedBox(
                                                fit: BoxFit.fitWidth,
                                                child: Text("Price",
                                                    style: TextStyle(
                                                        fontWeight: FontWeight
                                                            .bold))))),
                                  ]),
                                  TableRow(children: [
                                    Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Center(
                                            child: FittedBox(
                                                fit: BoxFit.fitWidth,
                                                child: Text(
                                                    "${material.salePrice} ${material.currency}")))),
                                  ]),
                                  const TableRow(children: [
                                    Padding(
                                        padding: EdgeInsets.all(4),
                                        child: Center(
                                            child: FittedBox(
                                                fit: BoxFit.fitWidth,
                                                child: Text(
                                                    "Available Quantity",
                                                    style: TextStyle(
                                                        fontWeight: FontWeight
                                                            .bold))))),
                                  ]),
                                  TableRow(children: [
                                    Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Center(
                                            child: Column(children: [
                                          FittedBox(
                                              fit: BoxFit.fitWidth,
                                              child: Text(
                                                  "${material.quantity}",
                                                  textAlign: TextAlign.center)),
                                          FittedBox(
                                              fit: BoxFit.fitWidth,
                                              child: Text(material.unit,
                                                  textAlign: TextAlign.center))
                                        ]))),
                                  ]),
                                  const TableRow(children: [
                                    Padding(
                                        padding: EdgeInsets.all(4),
                                        child: Center(
                                            child: FittedBox(
                                                fit: BoxFit.fitWidth,
                                                child: Text("TAX/VAT",
                                                    style: TextStyle(
                                                        fontWeight: FontWeight
                                                            .bold))))),
                                  ]),
                                  TableRow(children: [
                                    Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Center(
                                            child: Column(children: [
                                          FittedBox(
                                              fit: BoxFit.fitWidth,
                                              child: Text(
                                                  "${saleController.dialogTax.value} %",
                                                  textAlign: TextAlign.center)),
                                        ]))),
                                  ]),
                                ]),
                          ),
                          Expanded(
                            flex: 2,
                            child: Form(
                              key: saleController.dialogFormKey,
                              child: Scrollbar(
                                controller:
                                    saleController.dialogScrollController,
                                interactive: true,
                                thumbVisibility: true,
                                thickness: 6, //width of scrollbar
                                radius: const Radius.circular(
                                    10), //corner radius of scrollbar
                                scrollbarOrientation: ScrollbarOrientation
                                    .left, //which side to show scrollbar
                                child: SingleChildScrollView(
                                  controller:
                                      saleController.dialogScrollController,
                                  scrollDirection: Axis.vertical,
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.stretch,
                                    children: [
                                      Row(
                                        children: [
                                          const SizedBox(
                                            width: 10,
                                          ),
                                          CircleAvatar(
                                            radius: 20,
                                            backgroundColor: Colors.green,
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.exposure_minus_1,
                                                color: Colors.white,
                                              ),
                                              onPressed: () {
                                                var currentQuantity =
                                                    int.tryParse(saleController
                                                            .dialogQuantityTextController
                                                            .text) ??
                                                        0;
                                                if (currentQuantity == 1) {
                                                  return;
                                                }
                                                saleController
                                                    .dialogQuantityTextController
                                                    .text = (currentQuantity -
                                                        1)
                                                    .toString();

                                                saleController
                                                        .dialogQuantity.value =
                                                    currentQuantity - 1;
                                              },
                                            ),
                                          ),
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              child: TextFormField(
                                                textCapitalization:
                                                    TextCapitalization
                                                        .sentences,
                                                controller: saleController
                                                    .dialogQuantityTextController,
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
                                                  labelText: 'Quantity',
                                                ),
                                                keyboardType:
                                                    TextInputType.number,
                                                onChanged: (value) {
                                                  var currentQuantity =
                                                      int.tryParse(value) ?? 0;
                                                  saleController.dialogQuantity
                                                      .value = currentQuantity;

                                                  // if (currentQuantity >=
                                                  //     material.quantity) {
                                                  //   showErrorDialog(
                                                  //       "The Quantity at the warehouse is exceeded");
                                                  // } else if (currentQuantity <
                                                  //     1) {
                                                  //   showErrorDialog(
                                                  //       "The Quantity must be > 0");
                                                  //   saleController
                                                  //       .dialogQuantityTextController
                                                  //       .text = "1";
                                                  // }
                                                },
                                                validator: (value) {
                                                  if (value?.trim().isEmpty ??
                                                      true) {
                                                    return "This field required";
                                                  }
                                                  return null;
                                                },
                                              ),
                                            ),
                                          ),
                                          CircleAvatar(
                                            radius: 20,
                                            backgroundColor: Colors.green,
                                            child: IconButton(
                                              icon: const Icon(
                                                Icons.exposure_plus_1,
                                                color: Colors.white,
                                              ),
                                              onPressed: () {
                                                var currentQuantity =
                                                    int.tryParse(saleController
                                                            .dialogQuantityTextController
                                                            .text) ??
                                                        0;
                                                if (currentQuantity >=
                                                    material.quantity) {
                                                  showErrorDialog(
                                                      "The Quantity at the warehouse is exceeded");
                                                }
                                                saleController
                                                    .dialogQuantityTextController
                                                    .text = (currentQuantity +
                                                        1)
                                                    .toString();
                                                saleController
                                                        .dialogQuantity.value =
                                                    currentQuantity + 1;
                                              },
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 10,
                                          ),
                                        ],
                                      ),
                                      const Divider(),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4.0, horizontal: 18),
                                        child: Form(
                                          // key: discountFormKey,
                                          autovalidateMode: AutovalidateMode
                                              .onUserInteraction,
                                          child: TextFormField(
                                            controller: saleController
                                                .dialogTaxTextController,
                                            decoration: InputDecoration(
                                              counterText: '',
                                              labelText:
                                                  "TAX/VAT Default: ${material.tax} %"
                                                      .tr,
                                              filled: true,
                                              fillColor: Colors.white,
                                              isDense: true,
                                              contentPadding:
                                                  const EdgeInsets.all(10),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.green),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              border: const OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(12.0)),
                                              ),
                                            ),
                                            onChanged: (value) {
                                              saleController.dialogTax.value =
                                                  double.tryParse(saleController
                                                          .dialogTaxTextController
                                                          .text) ??
                                                      0;
                                            },
                                            keyboardType: const TextInputType
                                                .numberWithOptions(
                                                signed: false, decimal: true),
                                          ),
                                        ),
                                      ),
                                      const Divider(),
                                      // Padding(
                                      //   padding: const EdgeInsets.symmetric(
                                      //       vertical: 4.0, horizontal: 18),
                                      //   child: Form(
                                      //     // key: discountFormKey,
                                      //     autovalidateMode: AutovalidateMode
                                      //         .onUserInteraction,
                                      //     child: TextFormField(
                                      //       controller: saleController
                                      //           .dialogDiscountTextController,
                                      //       decoration: InputDecoration(
                                      //         counterText: '',
                                      //         labelText:
                                      //             "Discount Per Unit, Max: ${material.discount} ${material.currency}"
                                      //                 .tr,
                                      //         filled: true,
                                      //         fillColor: Colors.white,
                                      //         isDense: true,
                                      //         contentPadding:
                                      //             const EdgeInsets.all(10),
                                      //         focusedBorder: OutlineInputBorder(
                                      //           borderSide: const BorderSide(
                                      //               color: Colors.green),
                                      //           borderRadius:
                                      //               BorderRadius.circular(12),
                                      //         ),
                                      //         border: const OutlineInputBorder(
                                      //           borderRadius: BorderRadius.all(
                                      //               Radius.circular(12.0)),
                                      //         ),
                                      //       ),
                                      //       onChanged: (value) {
                                      //         saleController
                                      //                 .dialogDiscount.value =
                                      //             double.tryParse(saleController
                                      //                     .dialogDiscountTextController
                                      //                     .text) ??
                                      //                 0;
                                      //       },
                                      //       // TODO
                                      //       // validator: (value) {
                                      //       //   // user does not set a discount
                                      //       //   if (value!.isEmpty) {
                                      //       //     return null;
                                      //       //   }
                                      //       //   // trying to parse the new discount
                                      //       //   var newDiscount = double.tryParse(value);
                                      //       //   if (newDiscount != null) {
                                      //       //     if (newDiscount < 0 ||
                                      //       //         newDiscount > getTotalPrice()) {
                                      //       //       return "must_less_or_equal_value".trParams({
                                      //       //         'value':
                                      //       //             GlobalMethods.getMoneyWithCurrency(
                                      //       //                 getTotalPrice()),
                                      //       //       });
                                      //       //     }
                                      //       //   } else {
                                      //       //     return "invalid".tr;
                                      //       //   }
                                      //       //   return null;
                                      //       // },
                                      //       keyboardType: const TextInputType
                                      //           .numberWithOptions(
                                      //           signed: false, decimal: true),
                                      //     ),
                                      //   ),
                                      // ),
                                      // const Divider(),
                                      // if (saleController
                                      //     .dialogNoteCheckBoxValue.value)
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4.0, horizontal: 18),
                                        child: TextFormField(
                                            controller: saleController
                                                .dialogNoteTextController,
                                            decoration: InputDecoration(
                                              counterText: '',
                                              labelText: "Note".tr,
                                              filled: true,
                                              fillColor: Colors.white,
                                              isDense: true,
                                              contentPadding:
                                                  const EdgeInsets.all(10),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.green),
                                                borderRadius:
                                                    BorderRadius.circular(12),
                                              ),
                                              border: const OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(12.0)),
                                              ),
                                            ),
                                            minLines: 3,
                                            maxLines: 3,
                                            keyboardType:
                                                TextInputType.multiline),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const Divider(
                          // height: 1,
                          ),
                      Row(
                        children: [
                          Expanded(
                            child: Table(
                                border: TableBorder.all(
                                    color: Colors.black,
                                    width: 1,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10))),
                                children: [
                                  const TableRow(children: [
                                    Padding(
                                        padding: EdgeInsets.all(4),
                                        child: Center(
                                            child: FittedBox(
                                                fit: BoxFit.fitWidth,
                                                child: Text("Total",
                                                    style: TextStyle(
                                                        fontWeight: FontWeight
                                                            .bold))))),
                                  ]),
                                  TableRow(children: [
                                    Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Center(
                                            child: Column(children: [
                                          FittedBox(
                                              fit: BoxFit.fitWidth,
                                              child: Text(
                                                  "${saleController.dialogQuantity.value * (material.salePrice - saleController.dialogDiscount.value)}",
                                                  textAlign: TextAlign.center)),
                                          FittedBox(
                                              fit: BoxFit.fitWidth,
                                              child: Text(material.currency,
                                                  textAlign: TextAlign.center))
                                        ]))),
                                  ]),
                                  const TableRow(children: [
                                    Padding(
                                        padding: EdgeInsets.all(4),
                                        child: Center(
                                            child: FittedBox(
                                                fit: BoxFit.fitWidth,
                                                child: Text("Total TAX/VAT",
                                                    style: TextStyle(
                                                        fontWeight: FontWeight
                                                            .bold))))),
                                  ]),
                                  TableRow(children: [
                                    Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Center(
                                            child: Column(children: [
                                          FittedBox(
                                              fit: BoxFit.fitWidth,
                                              child: Text(
                                                  "${saleController.dialogQuantity.value * (saleController.dialogTax.value / 100) * (material.salePrice - saleController.dialogDiscount.value)}",
                                                  textAlign: TextAlign.center)),
                                          FittedBox(
                                              fit: BoxFit.fitWidth,
                                              child: Text(material.currency,
                                                  textAlign: TextAlign.center))
                                        ]))),
                                  ]),
                                ]),
                          ),
                          const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Center(
                              child: Text('='),
                            ),
                          ),
                          Expanded(
                            child: Table(
                                border: TableBorder.all(
                                    color: Colors.black,
                                    width: 1,
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(10))),
                                children: [
                                  const TableRow(children: [
                                    Padding(
                                        padding: EdgeInsets.all(4),
                                        child: Center(
                                            child: FittedBox(
                                                fit: BoxFit.fitWidth,
                                                child: Text("Total",
                                                    style: TextStyle(
                                                        fontWeight: FontWeight
                                                            .bold))))),
                                  ]),
                                  TableRow(children: [
                                    Padding(
                                        padding: const EdgeInsets.all(4),
                                        child: Center(
                                            child: Column(children: [
                                          FittedBox(
                                              fit: BoxFit.fitWidth,
                                              child: Text(
                                                  "${saleController.dialogQuantity.value * (material.salePrice - saleController.dialogDiscount.value) + saleController.dialogQuantity.value * (saleController.dialogTax.value / 100) * (material.salePrice - saleController.dialogDiscount.value)}",
                                                  textAlign: TextAlign.center)),
                                          FittedBox(
                                              fit: BoxFit.fitWidth,
                                              child: Text(material.currency,
                                                  textAlign: TextAlign.center))
                                        ]))),
                                  ]),
                                ]),
                          ),
                          Expanded(
                            child: Column(
                              children: [
                                ElevatedButton.icon(
                                    onPressed: () async {
                                      if (saleController
                                          .dialogFormKey.currentState!
                                          .validate()) {
                                        saleData['Quantity'] =
                                            saleController.dialogQuantity.value;
                                        saleData['Discount'] = (saleController
                                                .dialogDiscountTextController
                                                .text
                                                .isEmpty)
                                            ? null
                                            : saleController
                                                .dialogDiscount.value;
                                        saleData['Tax'] = (saleController
                                                .dialogTaxTextController
                                                .text
                                                .isEmpty)
                                            ? null
                                            : saleController.dialogTax.value;
                                        saleData['Total'] = saleController
                                                    .dialogQuantity.value *
                                                (material.salePrice -
                                                    saleController
                                                        .dialogDiscount.value) +
                                            saleController
                                                    .dialogQuantity.value *
                                                (saleController
                                                        .dialogTax.value /
                                                    100) *
                                                (material.salePrice -
                                                    saleController
                                                        .dialogDiscount.value);
                                        saleData['Note'] = saleController
                                            .dialogNoteTextController.text;
                                        saleController.dataSource.value
                                            .notifyListeners();
                                        saleController.dataSource.value
                                            .calculateTotals(saleController);
                                        saleController.dataSource.refresh();

                                        Get.back();
                                      }
                                    },
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Colors.green),
                                      foregroundColor:
                                          MaterialStateProperty.all(
                                              Colors.black),
                                      shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      )),
                                    ),
                                    label: Text("Done".tr),
                                    icon: const Icon(Icons.done)),
                                const SizedBox(
                                  height: 10,
                                ),
                                ElevatedButton.icon(
                                    onPressed: () {
                                      Get.back();
                                    },
                                    style: ButtonStyle(
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Colors.white),
                                      foregroundColor:
                                          MaterialStateProperty.all(Colors.red),
                                      shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(10.0),
                                      )),
                                    ),
                                    label: Text("Cancel".tr),
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
          ),
        );
      });
}
