import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/controllers/main_controller.dart';
import 'package:moamri_accounting/database/entities/material_larger_unit.dart';
import 'package:moamri_accounting/database/entities/my_material.dart';
import 'package:moamri_accounting/database/my_materials_database.dart';
import 'package:moamri_accounting/dialogs/alerts_dialogs.dart';
import 'package:visibility_detector/visibility_detector.dart';
import 'package:window_manager/window_manager.dart';

import '../../../utils/numerical_range_formatter.dart';

Future<bool?> showAddMaterialDialog(MainController mainController) async {
  return await showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final formKey = GlobalKey<FormState>();
        final scrollController = ScrollController();
        final barcodeTextController = TextEditingController();
        final categoryTextController = TextEditingController();
        final nameTextController = TextEditingController();
        final quantityTextController = TextEditingController();
        final unitTextController = TextEditingController();
        final currencyTextController = TextEditingController();
        final largerMaterialTextController = TextEditingController();
        MyMaterial? largerMaterial;
        final suppliedQuantityTextController = TextEditingController();
        final costPriceTextController = TextEditingController();
        final salePriceTextController = TextEditingController();
        double profit = 0.0;
        final taxTextController = TextEditingController();
        double tax = 0.0;
        final noteTextController = TextEditingController();
        var adding = false;
        var visible = false;
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 600),
            child: FocusTraversalGroup(
              policy: WidgetOrderTraversalPolicy(),
              child: Scaffold(
                appBar: AppBar(
                  centerTitle: true,
                  title: const DragToMoveArea(
                    child: Row(
                      children: [
                        Text(
                          "Add Material",
                          style: TextStyle(color: Colors.black),
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
                body: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: StatefulBuilder(builder: (context, setState) {
                    return Column(
                      children: [
                        Form(
                          key: formKey,
                          child: Expanded(
                            child: SingleChildScrollView(
                              controller: scrollController,
                              scrollDirection: Axis.vertical,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.stretch,
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
                                            print(barcode);
                                            setState(() {
                                              barcodeTextController.text =
                                                  barcode;
                                            });
                                          },
                                          child: Row(
                                            children: [
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
                                                      labelText: 'Barcode',
                                                    ),
                                                    keyboardType:
                                                        TextInputType.number,
                                                    validator: (value) {
                                                      if (value
                                                              ?.trim()
                                                              .isEmpty ??
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
                                                            BorderRadius
                                                                .circular(12.0),
                                                      )),
                                                      foregroundColor:
                                                          MaterialStateProperty
                                                              .all(
                                                                  Colors.blue)),
                                                  onPressed: () async {
                                                    var barcode =
                                                        await MyMaterialsDatabase
                                                            .generateMaterialBarcode();
                                                    setState(() {
                                                      barcodeTextController
                                                              .text =
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
                                              padding:
                                                  const EdgeInsets.symmetric(
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
                                                    categoryTextController
                                                        .text = value;
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
                                                      labelText: 'Category',
                                                    ),
                                                    keyboardType:
                                                        TextInputType.text,
                                                    validator: (value) {
                                                      if (value
                                                              ?.trim()
                                                              .isEmpty ??
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
                                              padding:
                                                  const EdgeInsets.symmetric(
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
                                                    currencyTextController
                                                        .text = value;
                                                  });
                                                },
                                                suggestionsCallback:
                                                    (String pattern) async {
                                                  return await MyMaterialsDatabase
                                                      .searchForCurrency(
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
                                                      labelText: 'Currency',
                                                    ),
                                                    keyboardType:
                                                        TextInputType.text,
                                                    validator: (value) {
                                                      if (value
                                                              ?.trim()
                                                              .isEmpty ??
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              child: TextFormField(
                                                textCapitalization:
                                                    TextCapitalization
                                                        .sentences,
                                                controller: nameTextController,
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
                                                  labelText: 'Name',
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              child: TextFormField(
                                                textCapitalization:
                                                    TextCapitalization
                                                        .sentences,
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
                                                keyboardType: TextInputType
                                                    .number, // TODO
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
                                          Expanded(
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
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
                                                      labelText: 'Unit',
                                                    ),
                                                    keyboardType:
                                                        TextInputType.text,
                                                    validator: (value) {
                                                      if (value
                                                              ?.trim()
                                                              .isEmpty ??
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              child: TypeAheadField(
                                                  controller:
                                                      largerMaterialTextController,
                                                  onSelected: (value) {
                                                    setState(() {
                                                      largerMaterial = value;
                                                      largerMaterialTextController
                                                              .text =
                                                          '${value.barcode}, ${value.name}';
                                                    });
                                                  },
                                                  suggestionsCallback:
                                                      (String pattern) async {
                                                    return await MyMaterialsDatabase
                                                        .getMaterialsSuggestions(
                                                            pattern, null);
                                                  },
                                                  itemBuilder:
                                                      (context, suggestion) {
                                                    return ListTile(
                                                      title: Text(
                                                          '${suggestion.barcode}, ${suggestion.name}'),
                                                    );
                                                  },
                                                  builder: (context, controller,
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
                                                        fillColor: Colors.white,
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
                                                                  .circular(8),
                                                        ),
                                                        border:
                                                            const OutlineInputBorder(
                                                          borderRadius:
                                                              BorderRadius.all(
                                                                  Radius
                                                                      .circular(
                                                                          8.0)),
                                                        ),
                                                        counterText: "",
                                                        labelText:
                                                            'Larger Unit Material Barcode/Name',
                                                      ),
                                                      keyboardType:
                                                          TextInputType.text,
                                                    );
                                                  }),
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
                                                controller:
                                                    suppliedQuantityTextController,
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
                                                  labelText:
                                                      'Quantity to be supplied',
                                                ),
                                                keyboardType:
                                                    TextInputType.text,
                                                validator: (value) {
                                                  if ((value?.trim().isEmpty ??
                                                          true) &&
                                                      largerMaterial != null) {
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
                                              padding:
                                                  const EdgeInsets.symmetric(
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
                                                          'Unit Cost Price',
                                                    ),
                                                    keyboardType:
                                                        TextInputType.text,
                                                    validator: (value) {
                                                      if (value
                                                              ?.trim()
                                                              .isEmpty ??
                                                          true) {
                                                        return "This field required";
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
                                                        profit = (double
                                                                    .tryParse(
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
                                                          'Unit Sale Price',
                                                    ),
                                                    keyboardType:
                                                        TextInputType.text,
                                                    validator: (value) {
                                                      if (value
                                                              ?.trim()
                                                              .isEmpty ??
                                                          true) {
                                                        return "This field required";
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
                                              padding:
                                                  const EdgeInsets.symmetric(
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              child: TextFormField(
                                                onChanged: (value) {
                                                  setState(() {
                                                    tax = (double.tryParse(
                                                                salePriceTextController
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              child: Column(
                                                children: [
                                                  Text("TAX/VAT: $tax")
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
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                      horizontal: 10),
                                              child: TextFormField(
                                                textCapitalization:
                                                    TextCapitalization
                                                        .sentences,
                                                controller: noteTextController,
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
                                                  labelText: 'Note',
                                                ),
                                                keyboardType:
                                                    TextInputType.text,
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
                                      final barcode =
                                          barcodeTextController.text;

                                      var materialByBarcode =
                                          await MyMaterialsDatabase
                                              .getMaterialByBarcode(
                                                  barcode.trim());
                                      if (materialByBarcode != null) {
                                        showErrorDialog(
                                            "This barcode is used by another material");
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
                                      final quantity = int.parse(
                                          quantityTextController.text);
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
                                          addedBy: mainController
                                              .currentUser.value!.id!,
                                          updatedBy: mainController
                                              .currentUser.value!.id!,
                                          createdDate: now,
                                          updatedDate: now);
                                      try {
                                        if (largerMaterial != null) {
                                          MaterialLargerUnit
                                              materialLargerUnit =
                                              MaterialLargerUnit(
                                                  largerMaterialID:
                                                      largerMaterial!.id!,
                                                  quantitySupplied:
                                                      suppliedQuantity!);
                                          await MyMaterialsDatabase
                                              .insertMaterial(
                                                  material, materialLargerUnit);
                                        } else {
                                          await MyMaterialsDatabase
                                              .insertMaterial(material, null);
                                        }
                                        await showSuccessDialog(
                                            "Material Added Successfully");
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
                                    backgroundColor: MaterialStateProperty.all(
                                        Colors.yellow),
                                    foregroundColor:
                                        MaterialStateProperty.all(Colors.black),
                                    shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    )),
                                  ),
                                  label: Text("Add".tr),
                                  icon: const Icon(Icons.add)),
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
          ),
        );
      });
}
