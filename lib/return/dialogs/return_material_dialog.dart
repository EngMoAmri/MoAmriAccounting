import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/controllers/main_controller.dart';
import 'package:moamri_accounting/database/entities/invoice_material.dart';
import 'package:moamri_accounting/return/controllers/return_controller.dart';
import 'package:moamri_accounting/database/entities/my_material.dart';
import 'package:moamri_accounting/dialogs/alerts_dialogs.dart';

import '../../utils/global_utils.dart';

Future<bool?> showReturnMaterialDialog(MainController mainController,
    ReturnController returnController, int selectedIndex) async {
  Map<String, dynamic> saleData =
      returnController.billDataSource.value.salesData[selectedIndex];
  InvoiceMaterial? invoiceMaterial;
  MyMaterial material = saleData['Material'];
  for (var inoviceMaterialItem
      in returnController.invoiceItem.value!.inoviceMaterialsItems) {
    if (material.id == inoviceMaterialItem.invoiceMaterial.materialId) {
      invoiceMaterial = inoviceMaterialItem.invoiceMaterial;
      break;
    }
  }
  // returnController.searchController.clear();
  returnController.materialDialogQuantity.value = saleData['Quantity'];
  returnController.materialDialogQuantityTextController.text =
      "${saleData['Quantity']}";
  returnController.materialDialogNoteTextController.text = saleData['Note'];

  return await showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 800),
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
                                      const TableRow(
                                          decoration: BoxDecoration(
                                              color: Colors.black,
                                              borderRadius: BorderRadius.only(
                                                  topLeft: Radius.circular(10),
                                                  topRight:
                                                      Radius.circular(10))),
                                          children: [
                                            Padding(
                                                padding: EdgeInsets.all(4),
                                                child: Center(
                                                    child: FittedBox(
                                                        fit: BoxFit.fitWidth,
                                                        child: Text("المادة",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
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
                                                    child: Text(
                                                        '${material.unit} ${material.name}')),
                                              ],
                                            )),
                                      ]),
                                      const TableRow(
                                          decoration: BoxDecoration(
                                            color: Colors.black,
                                          ),
                                          children: [
                                            Padding(
                                                padding: EdgeInsets.all(4),
                                                child: Center(
                                                    child: FittedBox(
                                                        fit: BoxFit.fitWidth,
                                                        child: Text(
                                                            "سعر الوحدة",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold))))),
                                          ]),
                                      TableRow(children: [
                                        Padding(
                                            padding: const EdgeInsets.all(4),
                                            child: Center(
                                                child: FittedBox(
                                                    fit: BoxFit.fitWidth,
                                                    child: Text(
                                                        "${GlobalUtils.getMoney(saleData['Price'])} ${material.currency}")))),
                                      ]),
                                      const TableRow(
                                          decoration: BoxDecoration(
                                            color: Colors.black,
                                          ),
                                          children: [
                                            Padding(
                                                padding: EdgeInsets.all(4),
                                                child: Center(
                                                    child: FittedBox(
                                                        fit: BoxFit.fitWidth,
                                                        child: Text("الإجمالي",
                                                            style: TextStyle(
                                                                color: Colors
                                                                    .white,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold))))),
                                          ]),
                                      TableRow(children: [
                                        Padding(
                                            padding: const EdgeInsets.all(4),
                                            child: Center(
                                                child: FittedBox(
                                                    fit: BoxFit.fitWidth,
                                                    child: Text(
                                                        '${GlobalUtils.getMoney(returnController.materialDialogQuantity.value * saleData['Price'])} ${material.currency}',
                                                        textAlign: TextAlign
                                                            .center)))),
                                      ]),
                                    ]),
                              ),
                              Expanded(
                                flex: 2,
                                child: Form(
                                  key: returnController.materialDialogFormKey,
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
                                                      double.tryParse(
                                                              returnController
                                                                  .materialDialogQuantityTextController
                                                                  .text
                                                                  .trim()) ??
                                                          0;
                                                  if (currentQuantity == 1) {
                                                    return;
                                                  }
                                                  returnController
                                                      .materialDialogQuantityTextController
                                                      .text = (currentQuantity -
                                                          1)
                                                      .toString();

                                                  returnController
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
                                                controller: returnController
                                                    .materialDialogQuantityTextController,
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
                                                  labelText: 'الكمية',
                                                ),
                                                keyboardType:
                                                    TextInputType.number,
                                                onChanged: (value) {
                                                  var currentQuantity =
                                                      double.tryParse(value) ??
                                                          0;
                                                  // if (currentQuantity >=
                                                  //     material.quantity) {
                                                  //   showErrorDialog(
                                                  //       "الكمية المتوفرة في المستودع تم تجاوزها!");
                                                  //   saleController
                                                  //           .materialDialogQuantity
                                                  //           .value =
                                                  //       material.quantity;
                                                  //   return;
                                                  // }
                                                  if (currentQuantity <= 0) {
                                                    showErrorDialog(
                                                        "لا يمكن أن تكون الكمية أقل من أو تساوي الصفر!");
                                                    returnController
                                                        .materialDialogQuantity
                                                        .value = material.quantity;
                                                    return;
                                                  }

                                                  returnController
                                                      .materialDialogQuantity
                                                      .value = currentQuantity;
                                                },
                                                validator: (value) {
                                                  if (value?.trim().isEmpty ??
                                                      true) {
                                                    return "هذا الحقل مطلوب";
                                                  }
                                                  if (double.tryParse(
                                                          value?.trim() ??
                                                              '') ==
                                                      null) {
                                                    return "أدخل كمية مناسبة";
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
                                                      double.tryParse(
                                                              returnController
                                                                  .materialDialogQuantityTextController
                                                                  .text
                                                                  .trim()) ??
                                                          0;
                                                  // if (currentQuantity >=
                                                  //         material
                                                  //             .quantity &&
                                                  //     (invoiceMaterial
                                                  //                 !.quantity) <
                                                  //         1) {
                                                  //   showErrorDialog(
                                                  //       "لا يمكن إرجاع كمية أكثر من المباعة!");
                                                  //   return;
                                                  // }
                                                  returnController
                                                      .materialDialogQuantityTextController
                                                      .text = (currentQuantity +
                                                          1)
                                                      .toString();
                                                  returnController
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
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      const Divider(),
                                      const SizedBox(
                                        height: 8,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 4.0, horizontal: 18),
                                        child: TextFormField(
                                            controller: returnController
                                                .materialDialogNoteTextController,
                                            decoration: InputDecoration(
                                              counterText: '',
                                              labelText: "ملاحظة",
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
                                            minLines: 4,
                                            maxLines: 4,
                                            keyboardType: TextInputType.text),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                          const Divider(),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Row(
                                      children: [
                                        Expanded(flex: 2, child: Container()),
                                        Expanded(
                                          child: OutlinedButton.icon(
                                              onPressed: () async {
                                                if (returnController
                                                    .materialDialogFormKey
                                                    .currentState!
                                                    .validate()) {
                                                  if (returnController
                                                              .materialDialogQuantity
                                                              .value >=
                                                          material.quantity &&
                                                      (invoiceMaterial!
                                                              .quantity) <
                                                          1) {
                                                    var ok =
                                                        await showConfirmationDialog(
                                                            "الكمية المرجعة أكثر من المباعة! استمرار؟");
                                                    if (!ok) return;
                                                  }
                                                  // TODO complete here
                                                  Map<String, dynamic>
                                                      returnedData = {
                                                    'Material': material,
                                                    'Quantity': returnController
                                                        .materialDialogQuantity
                                                        .value,
                                                    'Total': returnController
                                                            .materialDialogQuantity
                                                            .value *
                                                        saleData['Price'],
                                                    'Price': saleData['Price'],
                                                    'Note': returnController
                                                        .materialDialogNoteTextController
                                                        .text
                                                        .trim()
                                                  };
                                                  returnController
                                                      .returnedDataSource.value
                                                      .addDataGridRow(
                                                          returnedData,
                                                          returnController);

                                                  // returnController
                                                  //     .dataSource.value
                                                  //     .notifyListeners();
                                                  // returnController
                                                  //     .dataSource.value
                                                  //     .calculateTotals(
                                                  //         returnController);
                                                  returnController
                                                      .returnedDataSource
                                                      .refresh();
                                                  await AudioPlayer().play(
                                                      AssetSource(
                                                          'sounds/scanner-beep.mp3'));

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
                                                shape:
                                                    MaterialStateProperty.all(
                                                        RoundedRectangleBorder(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          10.0),
                                                )),
                                              ),
                                              label: const Text("تم"),
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
          ),
        );
      });
}
