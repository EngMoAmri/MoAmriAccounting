import 'package:flutter/material.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/controllers/main_controller.dart';
import 'package:moamri_accounting/database/entities/material_larger_unit.dart';
import 'package:moamri_accounting/database/entities/my_material.dart';
import 'package:moamri_accounting/database/my_materials_database.dart';
import 'package:moamri_accounting/dialogs/alerts_dialogs.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../utils/numerical_range_formatter.dart';

Future<bool?> showEditMaterialDialog(
    MainController mainController, MyMaterial oldMaterial) async {
  return await showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final formKey = GlobalKey<FormState>();
        final scrollController = ScrollController();
        final barcodeTextController = TextEditingController();
        barcodeTextController.text = oldMaterial.barcode;
        final categoryTextController = TextEditingController();
        categoryTextController.text = oldMaterial.category;
        final nameTextController = TextEditingController();
        nameTextController.text = oldMaterial.name;
        final quantityTextController = TextEditingController();
        quantityTextController.text = oldMaterial.quantity.toString();
        final unitTextController = TextEditingController();
        unitTextController.text = oldMaterial.unit;
        final currencyTextController = TextEditingController();
        currencyTextController.text = oldMaterial.currency;
        final largerMaterialTextController = TextEditingController();
        MyMaterial? largerMaterial;
        final suppliedQuantityTextController = TextEditingController();
        bool loadingLargerMaterial = true;
        final costPriceTextController = TextEditingController();
        costPriceTextController.text = oldMaterial.costPrice.toString();
        final salePriceTextController = TextEditingController();
        salePriceTextController.text = oldMaterial.salePrice.toString();
        double profit = oldMaterial.salePrice - oldMaterial.costPrice;
        final taxTextController = TextEditingController();
        taxTextController.text = oldMaterial.tax.toString();
        double tax = oldMaterial.tax;

        final noteTextController = TextEditingController();
        noteTextController.text = oldMaterial.note ?? '';
        var adding = false;
        var visible = false;
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: FocusTraversalGroup(
              policy: WidgetOrderTraversalPolicy(),
              child: Padding(
                padding: const EdgeInsets.all(8.0),
                child: StatefulBuilder(builder: (context, setState) {
                  if (largerMaterial == null) {
                    MyMaterialsDatabase.getMaterialLargerUnitItem(oldMaterial)
                        .then((value) {
                      largerMaterial = value?.largerMaterial;
                      suppliedQuantityTextController.text =
                          value?.suppliedQuantity.toString() ?? "";
                      loadingLargerMaterial = false;
                      setState(() {});
                    });
                  }
                  return Column(
                    children: [
                      Row(
                        children: [
                          const SizedBox(
                            width: 20,
                          ),
                          Expanded(
                            child: Text(
                              "Edit Material",
                              style: TextStyle(
                                  color: Colors.black,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Padding(
                            padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
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
                      Expanded(
                        child: Form(
                          key: formKey,
                          child: SingleChildScrollView(
                            controller: scrollController,
                            scrollDirection: Axis.vertical,
                            child: Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    // Add visiblity detector to handle barcode
                                    // values only when widget is visible
                                    child: VisibilityDetector(
                                      onVisibilityChanged:
                                          (VisibilityInfo info) {
                                        visible = info.visibleFraction > 0;
                                      },
                                      key: const Key('visible-detector-key'),
                                      child: BarcodeKeyboardListener(
                                        bufferDuration:
                                            const Duration(milliseconds: 200),
                                        onBarcodeScanned: (barcode) {
                                          if (!visible) return;
                                          setState(() {
                                            barcodeTextController.text =
                                                barcode;
                                          });
                                        },
                                        child: Row(
                                          children: [
                                            Expanded(
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                        horizontal: 10),
                                                child: TextFormField(
                                                  textCapitalization:
                                                      TextCapitalization
                                                          .sentences,
                                                  controller:
                                                      barcodeTextController,
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
                                                    labelText: 'Barcode',
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
                                            OutlinedButton.icon(
                                                style: ButtonStyle(
                                                    shape: MaterialStateProperty
                                                        .all(
                                                            RoundedRectangleBorder(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              12.0),
                                                    )),
                                                    foregroundColor:
                                                        MaterialStateProperty
                                                            .all(Colors.blue)),
                                                onPressed: () async {
                                                  var barcode =
                                                      await MyMaterialsDatabase
                                                          .generateMaterialBarcode();
                                                  setState(() {
                                                    barcodeTextController.text =
                                                        (barcode).toString();
                                                  });
                                                },
                                                icon: const Icon(
                                                    Icons.barcode_reader),
                                                label: Text('Generate'.tr)),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                  const Divider(
                                    height: 1,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: TypeAheadField(
                                              controller:
                                                  categoryTextController,
                                              emptyBuilder: (context) =>
                                                  Container(
                                                height: 0,
                                              ),
                                              onSelected: (value) {
                                                setState(() {
                                                  categoryTextController.text =
                                                      value;
                                                });
                                              },
                                              suggestionsCallback:
                                                  (String pattern) async {
                                                return await MyMaterialsDatabase
                                                    .searchForCategories(
                                                        pattern);
                                              },
                                              itemBuilder:
                                                  (context, suggestion) {
                                                return ListTile(
                                                  title: Text(suggestion),
                                                );
                                              },
                                              builder: (context, controller,
                                                  focusNode) {
                                                return TextFormField(
                                                  textCapitalization:
                                                      TextCapitalization
                                                          .sentences,
                                                  controller:
                                                      categoryTextController,
                                                  focusNode: focusNode,
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
                                                    labelText: 'Category',
                                                  ),
                                                  keyboardType:
                                                      TextInputType.text,
                                                  validator: (value) {
                                                    if (value?.trim().isEmpty ??
                                                        true) {
                                                      return "This field required";
                                                    }
                                                    return null;
                                                  },
                                                );
                                              },
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: TypeAheadField(
                                              controller:
                                                  currencyTextController,
                                              emptyBuilder: (context) =>
                                                  Container(
                                                height: 0,
                                              ),
                                              onSelected: (value) {
                                                setState(() {
                                                  currencyTextController.text =
                                                      value;
                                                });
                                              },
                                              suggestionsCallback:
                                                  (String pattern) async {
                                                return await MyMaterialsDatabase
                                                    .searchForCurrency(pattern);
                                              },
                                              itemBuilder:
                                                  (context, suggestion) {
                                                return ListTile(
                                                  title: Text(suggestion),
                                                );
                                              },
                                              builder: (context, controller,
                                                  focusNode) {
                                                return TextFormField(
                                                  textCapitalization:
                                                      TextCapitalization
                                                          .sentences,
                                                  controller:
                                                      currencyTextController,
                                                  focusNode: focusNode,
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
                                                    labelText: 'Currency',
                                                  ),
                                                  keyboardType:
                                                      TextInputType.text,
                                                  validator: (value) {
                                                    if (value?.trim().isEmpty ??
                                                        true) {
                                                      return "This field required";
                                                    }
                                                    return null;
                                                  },
                                                );
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
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: TextFormField(
                                              textCapitalization:
                                                  TextCapitalization.sentences,
                                              controller: nameTextController,
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
                                                labelText: 'Name',
                                              ),
                                              keyboardType: TextInputType.text,
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
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: TextFormField(
                                              textCapitalization:
                                                  TextCapitalization.sentences,
                                              controller:
                                                  quantityTextController,
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
                                                labelText: 'Quantity',
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                              validator: (value) {
                                                if (value?.trim().isEmpty ??
                                                    true) {
                                                  return "This field required";
                                                }
                                                if (int.tryParse(
                                                        value!.trim()) ==
                                                    null) {
                                                  return "Enter a valid number";
                                                }
                                                return null;
                                              },
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: TypeAheadField(
                                              controller: unitTextController,
                                              emptyBuilder: (context) =>
                                                  Container(
                                                height: 0,
                                              ),
                                              onSelected: (value) {
                                                setState(() {
                                                  unitTextController.text =
                                                      value;
                                                });
                                              },
                                              suggestionsCallback:
                                                  (String pattern) async {
                                                return await MyMaterialsDatabase
                                                    .searchForUnits(pattern);
                                              },
                                              itemBuilder:
                                                  (context, suggestion) {
                                                return ListTile(
                                                  title: Text(suggestion),
                                                );
                                              },
                                              builder: (context, controller,
                                                  focusNode) {
                                                return TextFormField(
                                                  textCapitalization:
                                                      TextCapitalization
                                                          .sentences,
                                                  controller:
                                                      unitTextController,
                                                  focusNode: focusNode,
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
                                                    labelText: 'Unit',
                                                  ),
                                                  keyboardType:
                                                      TextInputType.text,
                                                  validator: (value) {
                                                    if (value?.trim().isEmpty ??
                                                        true) {
                                                      return "This field required";
                                                    }
                                                    return null;
                                                  },
                                                );
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
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: loadingLargerMaterial
                                        ? const Center(
                                            child: CircularProgressIndicator(),
                                          )
                                        : Row(
                                            children: [
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10),
                                                  child: TypeAheadField(
                                                      controller:
                                                          largerMaterialTextController,
                                                      onSelected: (value) {
                                                        setState(() {
                                                          largerMaterial =
                                                              value;
                                                          largerMaterialTextController
                                                                  .text =
                                                              '${value.barcode}, ${value.name}';
                                                        });
                                                      },
                                                      suggestionsCallback:
                                                          (String
                                                              pattern) async {
                                                        return await MyMaterialsDatabase
                                                            .getMaterialsSuggestions(
                                                                pattern,
                                                                oldMaterial.id);
                                                      },
                                                      itemBuilder: (context,
                                                          suggestion) {
                                                        return ListTile(
                                                          title: Text(
                                                              '${suggestion.barcode}, ${suggestion.name}'),
                                                        );
                                                      },
                                                      builder: (context,
                                                          controller,
                                                          focusNode) {
                                                        return TextFormField(
                                                          textCapitalization:
                                                              TextCapitalization
                                                                  .sentences,
                                                          controller:
                                                              largerMaterialTextController,
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
                                                              borderRadius: BorderRadius
                                                                  .all(Radius
                                                                      .circular(
                                                                          8.0)),
                                                            ),
                                                            counterText: "",
                                                            labelText:
                                                                'Larger Unit Material Barcode/Name',
                                                          ),
                                                          keyboardType:
                                                              TextInputType
                                                                  .text,
                                                        );
                                                      }),
                                                ),
                                              ),
                                              Expanded(
                                                child: Padding(
                                                  padding: const EdgeInsets
                                                      .symmetric(
                                                      horizontal: 10),
                                                  child: TextFormField(
                                                    textCapitalization:
                                                        TextCapitalization
                                                            .sentences,
                                                    controller:
                                                        suppliedQuantityTextController,
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
                                                                color: Colors
                                                                    .green),
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(8),
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
                                                          'Quantity to be supplied',
                                                    ),
                                                    keyboardType:
                                                        TextInputType.text,
                                                    validator: (value) {
                                                      if ((value
                                                                  ?.trim()
                                                                  .isEmpty ??
                                                              true) &&
                                                          largerMaterial !=
                                                              null) {
                                                        return "This field required";
                                                      }
                                                      if ((value
                                                                  ?.trim()
                                                                  .isNotEmpty ??
                                                              false) &&
                                                          (int.tryParse(value!
                                                                  .trim()) ==
                                                              null)) {
                                                        return "Enter a valid number";
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
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Column(
                                              children: [
                                                TextFormField(
                                                  onChanged: (value) {
                                                    setState(() {
                                                      profit = (double.tryParse(
                                                                  salePriceTextController
                                                                      .text) ??
                                                              0) -
                                                          (double.tryParse(
                                                                  value) ??
                                                              0);
                                                    });
                                                  },
                                                  textCapitalization:
                                                      TextCapitalization
                                                          .sentences,
                                                  controller:
                                                      costPriceTextController,
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
                                                        'Unit Cost Price',
                                                  ),
                                                  keyboardType:
                                                      TextInputType.text,
                                                  validator: (value) {
                                                    if (value?.trim().isEmpty ??
                                                        true) {
                                                      return "This field required";
                                                    }
                                                    if (double.tryParse(
                                                            value!.trim()) ==
                                                        null) {
                                                      return "Enter a valid number";
                                                    }

                                                    return null;
                                                  },
                                                ),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                                TextFormField(
                                                  onChanged: (value) {
                                                    setState(() {
                                                      profit = (double.tryParse(
                                                                  value) ??
                                                              0) -
                                                          (double.tryParse(
                                                                  costPriceTextController
                                                                      .text) ??
                                                              0);
                                                      tax = (double.tryParse(
                                                                  taxTextController
                                                                      .text) ??
                                                              0) *
                                                          (double.tryParse(
                                                                  value) ??
                                                              0) /
                                                          100;
                                                    });
                                                  },
                                                  textCapitalization:
                                                      TextCapitalization
                                                          .sentences,
                                                  controller:
                                                      salePriceTextController,
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
                                                        'Unit Sale Price',
                                                  ),
                                                  keyboardType:
                                                      TextInputType.text,
                                                  validator: (value) {
                                                    if (value?.trim().isEmpty ??
                                                        true) {
                                                      return "This field required";
                                                    }
                                                    if (double.tryParse(
                                                            value!.trim()) ==
                                                        null) {
                                                      return "Enter a valid number";
                                                    }

                                                    return null;
                                                  },
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Column(
                                              children: [
                                                Text("Profit: $profit")
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(
                                    height: 1,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: TextFormField(
                                              onChanged: (value) {
                                                setState(() {
                                                  tax = (double.tryParse(
                                                              salePriceTextController
                                                                  .text) ??
                                                          0) *
                                                      (double.tryParse(value) ??
                                                          0) /
                                                      100;
                                                });
                                              },
                                              textCapitalization:
                                                  TextCapitalization.sentences,
                                              inputFormatters: [
                                                NumericalRangeFormatter(
                                                    min: 0, max: 100),
                                              ],
                                              controller: taxTextController,
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
                                                labelText: 'TAX/VAT %',
                                              ),
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
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Column(
                                              children: [Text("TAX/VAT: $tax")],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const Divider(
                                    height: 1,
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.all(8),
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: TextFormField(
                                              textCapitalization:
                                                  TextCapitalization.sentences,
                                              controller: noteTextController,
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
                                                labelText: 'Note',
                                              ),
                                              keyboardType: TextInputType.text,
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
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          if (adding)
                            const Padding(
                              padding: EdgeInsets.symmetric(horizontal: 8.0),
                              child: CircularProgressIndicator(),
                            )
                          else
                            ElevatedButton.icon(
                                onPressed: () async {
                                  if (formKey.currentState!.validate()) {
                                    setState(() {
                                      adding = true;
                                    });
                                    final barcode = barcodeTextController.text;
                                    var materialByBarcode =
                                        await MyMaterialsDatabase
                                            .getMaterialByBarcode(
                                                barcode.trim());
                                    if (materialByBarcode != null &&
                                        materialByBarcode.id !=
                                            oldMaterial.id) {
                                      showErrorDialog(
                                          "This barcode is used by another material");
                                      setState(() {
                                        adding = false;
                                      });
                                      return;
                                    }

                                    if (largerMaterial == null &&
                                        largerMaterialTextController.text
                                            .trim()
                                            .isNotEmpty) {
                                      showErrorDialog(
                                          "Please select a valid larger material");
                                      setState(() {
                                        adding = false;
                                      });
                                      return;
                                    }
                                    if (largerMaterial != null &&
                                        (int.parse(
                                                suppliedQuantityTextController
                                                    .text) <=
                                            0)) {
                                      showErrorDialog(
                                          "Please select a valid quantity supplied by larger material");
                                      setState(() {
                                        adding = false;
                                      });
                                      return;
                                    }

                                    final category =
                                        categoryTextController.text;
                                    final currency =
                                        currencyTextController.text;
                                    final name = nameTextController.text;
                                    final quantity =
                                        int.parse(quantityTextController.text);
                                    final unit = unitTextController.text;
                                    final suppliedQuantity = int.tryParse(
                                        suppliedQuantityTextController.text);
                                    final costPrice = double.parse(
                                        costPriceTextController.text);
                                    final salePrice = double.parse(
                                        salePriceTextController.text);
                                    final note = noteTextController.text;
                                    final now =
                                        DateTime.now().millisecondsSinceEpoch;
                                    MyMaterial material = MyMaterial(
                                        id: oldMaterial.id,
                                        name: name,
                                        barcode: barcode,
                                        category: category,
                                        currency: currency,
                                        unit: unit,
                                        quantity: quantity,
                                        costPrice: costPrice,
                                        salePrice: salePrice,
                                        tax: double.tryParse(
                                                taxTextController.text) ??
                                            0,
                                        note: note,
                                        addedBy: oldMaterial.addedBy,
                                        updatedBy: mainController
                                            .currentUser.value!.id!,
                                        createdDate: oldMaterial.createdDate,
                                        updatedDate: now);
                                    try {
                                      if (largerMaterial != null) {
                                        MaterialLargerUnit materialLargerUnit =
                                            MaterialLargerUnit(
                                                materialID: oldMaterial.id,
                                                largerMaterialID:
                                                    largerMaterial!.id!,
                                                quantitySupplied:
                                                    suppliedQuantity!);
                                        await MyMaterialsDatabase
                                            .updateMaterial(
                                                material, materialLargerUnit);
                                      } else {
                                        await MyMaterialsDatabase
                                            .updateMaterial(material, null);
                                      }
                                      await showSuccessDialog(
                                          "Material Edited Successfully");
                                      Get.back(result: true);
                                    } catch (e) {
                                      setState(() {
                                        adding = false;
                                      });
                                      showErrorDialog('Error $e');
                                    }
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
                  );
                }),
              ),
            ),
          ),
        );
      });
}
