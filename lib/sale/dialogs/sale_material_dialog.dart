import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/controllers/main_controller.dart';
import 'package:moamri_accounting/database/my_materials_database.dart';
import 'package:moamri_accounting/sale/controllers/sale_controller.dart';
import 'package:moamri_accounting/database/entities/my_material.dart';
import 'package:moamri_accounting/dialogs/alerts_dialogs.dart';

import '../../utils/global_methods.dart';

Future<bool?> showSaleMaterialDialog(MainController mainController,
    SaleController saleController, int selectedIndex) async {
  Map<String, dynamic> saleData =
      saleController.dataSource.value.salesData[selectedIndex];
  MyMaterial material = saleData['Material'];
  saleController.searchController.clear();
  saleController.materialDialogQuantity.value = saleData['Quantity'];
  saleController.materialDialogQuantityTextController.text =
      "${saleData['Quantity']}";
  saleController.materialDialogNoteTextController.text = saleData['Note'];

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
                                                        "${GlobalMethods.getMoney(material.salePrice)} ${material.currency}")))),
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
                                                        '${GlobalMethods.getMoney(saleController.materialDialogQuantity.value * material.salePrice)} ${material.currency}',
                                                        textAlign: TextAlign
                                                            .center)))),
                                      ]),
                                    ]),
                              ),
                              Expanded(
                                flex: 2,
                                child: Form(
                                  key: saleController.materialDialogFormKey,
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
                                                  var currentQuantity = double
                                                          .tryParse(saleController
                                                              .materialDialogQuantityTextController
                                                              .text
                                                              .trim()) ??
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
                                                    saleController
                                                        .materialDialogQuantity
                                                        .value = material.quantity;
                                                    return;
                                                  }

                                                  saleController
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
                                                  var currentQuantity = double
                                                          .tryParse(saleController
                                                              .materialDialogQuantityTextController
                                                              .text
                                                              .trim()) ??
                                                      0;
                                                  // if (currentQuantity >=
                                                  //         material
                                                  //             .quantity &&
                                                  //     (largerMaterial1
                                                  //                 ?.quantity ??
                                                  //             0) <
                                                  //         1) {
                                                  //   showErrorDialog(
                                                  //       "الكمية المتوفرة في المستودع تم تجاوزها!");
                                                  //   return;
                                                  // }
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
                                            controller: saleController
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
                          const Divider(
                              // height: 1,
                              ),
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
                                                if (saleController
                                                    .materialDialogFormKey
                                                    .currentState!
                                                    .validate()) {
                                                  var materialItem =
                                                      await MyMaterialsDatabase
                                                          .getMyMaterialItem(
                                                              material);
                                                  // first we set the quantity to current material
                                                  var availableQuantity =
                                                      materialItem!
                                                          .material.quantity;
                                                  //then we search in larger material
                                                  while (materialItem
                                                          ?.largerMaterial !=
                                                      null) {
                                                    var largerQuantity =
                                                        materialItem!
                                                            .largerMaterial!
                                                            .material
                                                            .quantity;
                                                    // minus the selected one in sale page
                                                    for (var saleData2
                                                        in saleController
                                                            .dataSource
                                                            .value
                                                            .salesData) {
                                                      if (saleData2['Material']
                                                              .id ==
                                                          materialItem
                                                              .largerMaterial!
                                                              .material
                                                              .id) {
                                                        largerQuantity -=
                                                            saleData2[
                                                                'Quantity'];
                                                      }
                                                    }
                                                    var quantity = (largerQuantity *
                                                        materialItem.material
                                                            .quantitySupplied!);
                                                    var smallerMaterial =
                                                        materialItem
                                                            .smallerMaterial;
                                                    // we multiply by smaller units until we reach the unit similar to the selected one
                                                    while (smallerMaterial !=
                                                        null) {
                                                      quantity *= materialItem
                                                          .smallerMaterial!
                                                          .material
                                                          .quantitySupplied!;
                                                      smallerMaterial =
                                                          smallerMaterial
                                                              .smallerMaterial;
                                                    }
                                                    availableQuantity +=
                                                        quantity;
                                                    materialItem.largerMaterial
                                                            ?.smallerMaterial =
                                                        materialItem;
                                                    materialItem = materialItem
                                                        .largerMaterial;
                                                  }
                                                  print(availableQuantity);
                                                  // TODO make a button to open this dialog
                                                  if (availableQuantity <
                                                      saleController
                                                          .materialDialogQuantity
                                                          .value) {
                                                    var yes =
                                                        await showConfirmationDialog(
                                                            'تم تجاوز الكمية الموجودة في المستودع! هل تريد الاستمرار؟');
                                                    if (yes != true) {
                                                      return;
                                                    }
                                                  }

                                                  saleData['Quantity'] =
                                                      saleController
                                                          .materialDialogQuantity
                                                          .value;
                                                  saleData[
                                                      'Total'] = saleController
                                                          .materialDialogQuantity
                                                          .value *
                                                      material.salePrice;
                                                  saleData['Note'] = saleController
                                                      .materialDialogNoteTextController
                                                      .text
                                                      .trim();
                                                  saleController
                                                      .dataSource.value
                                                      .notifyListeners();
                                                  saleController
                                                      .dataSource.value
                                                      .calculateTotals(
                                                          saleController);
                                                  saleController.dataSource
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
