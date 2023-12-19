import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/controllers/main_controller.dart';
import 'package:moamri_accounting/controllers/sale_controller.dart';
import 'package:moamri_accounting/database/entities/my_material.dart';
import 'package:window_manager/window_manager.dart';

import '../../utils/numerical_range_formatter.dart';

Future<bool?> showSaleMaterialDialog(MainController mainController,
    SaleController saleController, MyMaterial selectedMaterial) async {
  return await showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: FocusTraversalGroup(
            policy: WidgetOrderTraversalPolicy(),
            child: Scaffold(
              appBar: AppBar(
                centerTitle: true,
                title: DragToMoveArea(
                  child: Row(
                    children: [
                      Text(
                        "Sale Material",
                        style: const TextStyle(color: Colors.black),
                      ),
                    ],
                  ),
                ),
                backgroundColor: Colors.white,
                foregroundColor: Colors.grey,
                elevation: 0,
                systemOverlayStyle: const SystemUiOverlayStyle(
                    statusBarColor: Colors.white,
                    systemNavigationBarColor: Colors.transparent,
                    systemNavigationBarIconBrightness: Brightness.dark,
                    statusBarIconBrightness: Brightness.dark,
                    statusBarBrightness: Brightness.light),
                actions: [
                  Padding(
                    padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
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
              body: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16.0, horizontal: 32.0),
                        child: Table(
                            border: TableBorder.all(
                                color: Colors.black,
                                width: 1,
                                borderRadius: const BorderRadius.all(
                                    Radius.circular(10))),
                            columnWidths: {
                              0: const FlexColumnWidth(1.5),
                              1: const FlexColumnWidth(),
                              2: const FlexColumnWidth(),
                            },
                            children: [
                              TableRow(children: [
                                Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Center(
                                        child: FittedBox(
                                            fit: BoxFit.fitWidth,
                                            child: Text("Material",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold))))),
                                Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Center(
                                        child: FittedBox(
                                            fit: BoxFit.fitWidth,
                                            child: Text("Price",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold))))),
                                Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Center(
                                        child: FittedBox(
                                            fit: BoxFit.fitWidth,
                                            child: Text("Available Quantity",
                                                style: TextStyle(
                                                    fontWeight:
                                                        FontWeight.bold))))),
                              ]),
                              TableRow(children: [
                                Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Column(
                                      children: [
                                        Center(
                                            child:
                                                Text(selectedMaterial.barcode)),
                                        Center(
                                            child: Text(selectedMaterial.name)),
                                      ],
                                    )),
                                Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Column(children: [
                                      FittedBox(
                                          fit: BoxFit.fitWidth,
                                          child: Text("Sale Price: ")),
                                      Center(
                                          child: FittedBox(
                                              fit: BoxFit.fitWidth,
                                              child: Text(
                                                  "${selectedMaterial.salePrice} ${selectedMaterial.currency}")))
                                    ])),
                                Padding(
                                    padding: EdgeInsets.all(4),
                                    child: Center(
                                        child: Column(children: [
                                      FittedBox(
                                          fit: BoxFit.fitWidth,
                                          child: Text(
                                              "${selectedMaterial.quantity}",
                                              textAlign: TextAlign.center)),
                                      FittedBox(
                                          fit: BoxFit.fitWidth,
                                          child: Text(selectedMaterial.unit,
                                              textAlign: TextAlign.center))
                                    ]))),
                              ]),
                            ]),
                      ),
                      Form(
                        key: saleController.formKey,
                        child: Expanded(
                          child: Scrollbar(
                            controller: saleController.scrollController,
                            interactive: true,
                            thumbVisibility: true,
                            thickness: 6, //width of scrollbar
                            radius: Radius.circular(
                                10), //corner radius of scrollbar
                            scrollbarOrientation: ScrollbarOrientation
                                .left, //which side to show scrollbar
                            child: SingleChildScrollView(
                              controller: saleController.scrollController,
                              scrollDirection: Axis.vertical,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
                                  children: [
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10),
                                              child: TextFormField(
                                                textCapitalization:
                                                    TextCapitalization
                                                        .sentences,
                                                controller: saleController
                                                    .quantityTextController,
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
                                        ],
                                      ),
                                    ),
                                    const Divider(
                                      height: 1,
                                    ),
                                    const Divider(),
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Checkbox(
                                            value: discountCheckBoxValue,
                                            onChanged: ((value) {
                                              setState(() {
                                                discountController.clear();
                                                discountCheckBoxValue =
                                                    value ?? false;
                                              });
                                            })),
                                        Text("add_discount".tr),
                                        Checkbox(
                                            value: noteCheckBoxValue,
                                            onChanged: ((value) {
                                              setState(() {
                                                noteController.clear();
                                                noteCheckBoxValue =
                                                    value ?? false;
                                              });
                                            })),
                                        Text("add_note".tr),
                                      ],
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.all(8),
                                      child: Row(
                                        children: [
                                          Expanded(
                                            child: Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 10),
                                              child: TextFormField(
                                                textCapitalization:
                                                    TextCapitalization
                                                        .sentences,
                                                controller: saleController
                                                    .discountTextController,
                                                inputFormatters: [
                                                  // TODO show alert dialog
                                                  // NumericalRangeFormatter(
                                                  //     min: 0,
                                                  //     max: selectedMaterial
                                                  //         .discount)
                                                ],
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
                                                  labelText: 'Discount',
                                                ),
                                                keyboardType:
                                                    TextInputType.number,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (saleController.adding.value)
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: CircularProgressIndicator(),
                            )
                          else
                            ElevatedButton.icon(
                                onPressed: () async {
                                  if (saleController.formKey.currentState!
                                      .validate()) {
                                    // adding = true;
                                    // final barcode = barcodeTextController.text;
                                    // var materialByBarcode =
                                    //     await MyMaterialsDatabase
                                    //         .getMaterialByBarcode(
                                    //             barcode.trim());
                                    // if (materialByBarcode != null &&
                                    //     materialByBarcode.id !=
                                    //         selectedMaterial.id) {
                                    //   showErrorDialog(
                                    //       "This barcode is used by another material");
                                    //   setState(() {
                                    //     adding = false;
                                    //   });
                                    //   return;
                                    // }
                                    // final category =
                                    //     categoryTextController.text;
                                    // final currency =
                                    //     currencyTextController.text;
                                    // final name = nameTextController.text;
                                    // final quantity =
                                    //     int.parse(quantityTextController.text);
                                    // final unit = unitTextController.text;
                                    // final suppliedQuantity = int.tryParse(
                                    //     suppliedQuantityTextController.text);
                                    // final costPrice = double.parse(
                                    //     costPriceTextController.text);
                                    // final salePrice = double.parse(
                                    //     salePriceTextController.text);
                                    // final note = noteTextController.text;
                                    // final now =
                                    //     DateTime.now().millisecondsSinceEpoch;
                                    // MyMaterial material = MyMaterial(
                                    //     id: selectedMaterial.id,
                                    //     name: name,
                                    //     barcode: barcode,
                                    //     category: category,
                                    //     currency: currency,
                                    //     unit: unit,
                                    //     quantity: quantity,
                                    //     costPrice: costPrice,
                                    //     salePrice: salePrice,
                                    //     discount: double.tryParse(
                                    //             discountTextController.text) ??
                                    //         0,
                                    //     tax: double.tryParse(
                                    //             taxTextController.text) ??
                                    //         0,
                                    //     note: note,
                                    //     addedBy: selectedMaterial.addedBy,
                                    //     updatedBy: mainController
                                    //         .currentUser.value!.id!,
                                    //     createdDate:
                                    //         selectedMaterial.createdDate,
                                    //     updatedDate: now);
                                    // try {
                                    //   if (largerMaterial != null) {
                                    //     MaterialLargerUnit materialLargerUnit =
                                    //         MaterialLargerUnit(
                                    //             materialID: selectedMaterial.id,
                                    //             largerMaterialID:
                                    //                 largerMaterial!.id!,
                                    //             quantitySupplied:
                                    //                 suppliedQuantity!);
                                    //     await MyMaterialsDatabase
                                    //         .updateMaterial(
                                    //             material, materialLargerUnit);
                                    //   } else {
                                    //     await MyMaterialsDatabase
                                    //         .updateMaterial(material, null);
                                    //   }
                                    //   await showSuccessDialog(
                                    //       "Material Edited Successfully");
                                    //   Get.back(result: true);
                                    // } catch (e) {
                                    //   setState(() {
                                    //     adding = false;
                                    //   });
                                    //   showErrorDialog('Error $e');
                                    // }
                                  }
                                },
                                style: ButtonStyle(
                                  backgroundColor:
                                      MaterialStateProperty.all(Colors.yellow),
                                  foregroundColor:
                                      MaterialStateProperty.all(Colors.black),
                                  shape: MaterialStateProperty.all(
                                      RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                  )),
                                ),
                                label: Text("Done".tr),
                                icon: const Icon(Icons.done)),
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
