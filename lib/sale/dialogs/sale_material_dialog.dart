import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/controllers/main_controller.dart';
import 'package:moamri_accounting/sale/controllers/sale_controller.dart';
import 'package:moamri_accounting/database/entities/my_material.dart';
import 'package:moamri_accounting/dialogs/alerts_dialogs.dart';

Future<bool?> showSaleMaterialDialog(MainController mainController,
    SaleController saleController, int selectedIndex) async {
  Map<String, dynamic> saleData =
      saleController.dataSource.value.salesData[selectedIndex];
  MyMaterial material = saleData['Material'];
  saleController.searchController.clear();
  saleController.materialDialogQuantity.value = saleData['Quantity'];
  saleController.materialDialogQuantityTextController.text =
      "${saleData['Quantity']}";
  saleController.materialDialogTax.value = saleData['Tax'];
  saleController.materialDialogTaxTextController.text =
      saleData['Tax'].toString();
  saleController.materialDialogNoteTextController.text = saleData['Note'];

  return await showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: FocusTraversalGroup(
              policy: WidgetOrderTraversalPolicy(),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                    vertical: 16.0, horizontal: 32.0),
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
                                                  child:
                                                      Text(material.barcode)),
                                              Center(
                                                  child: Text(material.name)),
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
                                                      "${material.salePrice.toStringAsFixed(2)} ${material.currency}")))),
                                    ]),
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
                                                    (saleController
                                                                .materialDialogQuantity
                                                                .value *
                                                            material.salePrice)
                                                        .toStringAsFixed(2),
                                                    textAlign:
                                                        TextAlign.center)),
                                            FittedBox(
                                                fit: BoxFit.fitWidth,
                                                child: Text(material.currency,
                                                    textAlign:
                                                        TextAlign.center))
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
                                                    (saleController
                                                                .materialDialogQuantity
                                                                .value *
                                                            (saleController
                                                                    .materialDialogTax
                                                                    .value /
                                                                100) *
                                                            material.salePrice)
                                                        .toStringAsFixed(2),
                                                    textAlign:
                                                        TextAlign.center)),
                                            FittedBox(
                                                fit: BoxFit.fitWidth,
                                                child: Text(material.currency,
                                                    textAlign:
                                                        TextAlign.center))
                                          ]))),
                                    ]),
                                  ]),
                            ),
                            Expanded(
                              flex: 2,
                              child: Form(
                                key: saleController.materialDialogFormKey,
                                child: Scrollbar(
                                  controller: saleController
                                      .materialDialogScrollController,
                                  interactive: true,
                                  thumbVisibility: true,
                                  thickness: 6, //width of scrollbar
                                  radius: const Radius.circular(
                                      10), //corner radius of scrollbar
                                  scrollbarOrientation: ScrollbarOrientation
                                      .left, //which side to show scrollbar
                                  child: SingleChildScrollView(
                                    controller: saleController
                                        .materialDialogScrollController,
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
                                              radius: 22,
                                              backgroundColor: Colors.blue,
                                              child: CircleAvatar(
                                                radius: 20,
                                                backgroundColor: Colors.white,
                                                child: IconButton(
                                                  icon: const Icon(
                                                    Icons.exposure_minus_1,
                                                    color: Colors.black,
                                                  ),
                                                  onPressed: () {
                                                    var currentQuantity =
                                                        int.tryParse(saleController
                                                                .materialDialogQuantityTextController
                                                                .text) ??
                                                            0;
                                                    if (currentQuantity == 1) {
                                                      return;
                                                    }
                                                    saleController
                                                        .materialDialogQuantityTextController
                                                        .text = (currentQuantity -
                                                            1)
                                                        .toString();

                                                    saleController
                                                            .materialDialogQuantity
                                                            .value =
                                                        currentQuantity - 1;
                                                  },
                                                ),
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
                                                      .materialDialogQuantityTextController,
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
                                                        'Quantity Available = ${material.quantity}',
                                                  ),
                                                  keyboardType:
                                                      TextInputType.number,
                                                  onChanged: (value) {
                                                    var currentQuantity =
                                                        int.tryParse(value) ??
                                                            0;
                                                    saleController
                                                        .materialDialogQuantity
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
                                                    if (int.tryParse(
                                                            value?.trim() ??
                                                                '') ==
                                                        null) {
                                                      return "Enter a valid number";
                                                    }

                                                    return null;
                                                  },
                                                ),
                                              ),
                                            ),
                                            CircleAvatar(
                                              radius: 22,
                                              backgroundColor: Colors.blue,
                                              child: CircleAvatar(
                                                radius: 20,
                                                backgroundColor: Colors.white,
                                                child: IconButton(
                                                  icon: const Icon(
                                                    Icons.exposure_plus_1,
                                                    color: Colors.black,
                                                  ),
                                                  onPressed: () {
                                                    var currentQuantity =
                                                        int.tryParse(saleController
                                                                .materialDialogQuantityTextController
                                                                .text) ??
                                                            0;
                                                    if (currentQuantity >=
                                                        material.quantity) {
                                                      showErrorDialog(
                                                          "The Quantity at the warehouse is exceeded");
                                                    }
                                                    saleController
                                                        .materialDialogQuantityTextController
                                                        .text = (currentQuantity +
                                                            1)
                                                        .toString();
                                                    saleController
                                                            .materialDialogQuantity
                                                            .value =
                                                        currentQuantity + 1;
                                                  },
                                                ),
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
                                            autovalidateMode: AutovalidateMode
                                                .onUserInteraction,
                                            child: TextFormField(
                                              controller: saleController
                                                  .materialDialogTaxTextController,
                                              decoration: InputDecoration(
                                                counterText: '',
                                                // labelText:
                                                //     "TAX/VAT Default: ${material.tax} %"
                                                //         .tr,
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
                                              onChanged: (value) {
                                                saleController.materialDialogTax
                                                    .value = double.tryParse(
                                                        saleController
                                                            .materialDialogTaxTextController
                                                            .text) ??
                                                    0;
                                              },
                                              keyboardType:
                                                  TextInputType.number,
                                              validator: (value) {
                                                if (!(value?.trim().isEmpty ??
                                                    true)) {
                                                  if (double.tryParse(
                                                          value!.trim()) ==
                                                      null) {
                                                    return "Enter a valid percentage";
                                                  }
                                                }
                                                return null;
                                              },
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
                                                  .materialDialogNoteTextController,
                                              decoration: InputDecoration(
                                                counterText: '',
                                                labelText: "Note".tr,
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
                                              minLines: 6,
                                              maxLines: 6,
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
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                                                    (saleController.materialDialogQuantity
                                                                    .value *
                                                                material
                                                                    .salePrice +
                                                            saleController
                                                                    .materialDialogQuantity
                                                                    .value *
                                                                (saleController
                                                                        .materialDialogTax
                                                                        .value /
                                                                    100) *
                                                                material
                                                                    .salePrice)
                                                        .toStringAsFixed(2),
                                                    textAlign:
                                                        TextAlign.center)),
                                            FittedBox(
                                                fit: BoxFit.fitWidth,
                                                child: Text(material.currency,
                                                    textAlign:
                                                        TextAlign.center))
                                          ]))),
                                    ]),
                                  ]),
                            ),
                            Expanded(
                              flex: 2,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(flex: 2, child: Container()),
                                      Expanded(
                                        child: OutlinedButton.icon(
                                            onPressed: () async {
                                              if (saleController
                                                  .materialDialogFormKey
                                                  .currentState!
                                                  .validate()) {
                                                saleData['Quantity'] =
                                                    saleController
                                                        .materialDialogQuantity
                                                        .value;
                                                saleData[
                                                    'Tax'] = (saleController
                                                        .materialDialogTaxTextController
                                                        .text
                                                        .isEmpty)
                                                    ? null
                                                    : saleController
                                                        .materialDialogTax
                                                        .value;
                                                saleData[
                                                    'Total'] = saleController
                                                            .materialDialogQuantity
                                                            .value *
                                                        material.salePrice +
                                                    saleController
                                                            .materialDialogQuantity
                                                            .value *
                                                        (saleController
                                                                .materialDialogTax
                                                                .value /
                                                            100) *
                                                        material.salePrice;
                                                saleData['Note'] = saleController
                                                    .materialDialogNoteTextController
                                                    .text;
                                                saleController.dataSource.value
                                                    .notifyListeners();
                                                saleController.dataSource.value
                                                    .calculateTotals(
                                                        saleController);
                                                saleController.dataSource
                                                    .refresh();

                                                Get.back();
                                              }
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
                                            label: Text("Done".tr),
                                            icon: const Icon(Icons.done)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Row(
                                    children: [
                                      Expanded(flex: 2, child: Container()),
                                      Expanded(
                                        child: OutlinedButton.icon(
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
                                            label: Text("Cancel".tr),
                                            icon: const Icon(Icons.cancel)),
                                      ),
                                    ],
                                  ),
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
          ),
        );
      });
}
