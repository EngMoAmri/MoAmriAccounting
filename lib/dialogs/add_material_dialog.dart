import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/database/my_materials_database.dart';
import 'package:window_manager/window_manager.dart';

import '../utils/numerical_range_formatter.dart';

Future<bool?> showAddMaterialDialog() async {
  return await showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final scrollController = ScrollController();
        final barcodeTextController = TextEditingController();
        final categoryTextController = TextEditingController();
        final nameTextController = TextEditingController();
        final quantityTextController = TextEditingController();
        final unitTextController = TextEditingController();
        final largerMaterialTextController = TextEditingController();
        final suppliedQuantityTextController = TextEditingController();
        final costPriceTextController = TextEditingController();
        final salePriceTextController = TextEditingController();
        double profit = 0.0;
        final taxTextController = TextEditingController();
        double tax = 0.0;
        final discountTextController = TextEditingController();
        double discount = 0.0;
        final noteTextController = TextEditingController();
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: DragToMoveArea(
                child: Row(
                  children: [
                    Text(
                      "Add Material",
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
              child: StatefulBuilder(builder: (context, setState) {
                return Column(
                  children: [
                    Expanded(
                      child: Scrollbar(
                        controller: scrollController,
                        interactive: true,
                        thumbVisibility: true,
                        thickness: 6, //width of scrollbar
                        radius:
                            Radius.circular(10), //corner radius of scrollbar
                        scrollbarOrientation: ScrollbarOrientation
                            .left, //which side to show scrollbar
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
                                  child: BarcodeKeyboardListener(
                                    bufferDuration: Duration(milliseconds: 200),
                                    onBarcodeScanned: (barcode) {
                                      print(barcode);
                                      setState(() {
                                        barcodeTextController.text = barcode;
                                      });
                                    },
                                    child: Row(
                                      children: [
                                        Expanded(
                                          child: Padding(
                                            padding: EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: TextFormField(
                                              textCapitalization:
                                                  TextCapitalization.sentences,
                                              controller: barcodeTextController,
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
                                                labelText: 'Barcode or ID',
                                              ),
                                              keyboardType:
                                                  TextInputType.number,
                                            ),
                                          ),
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
                                              var barcode =
                                                  await MyMaterialsDatabase
                                                      .generateMaterialID();
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
                                const Divider(
                                  height: 1,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: TypeAheadField(
                                            onSelected: (value) {
                                              setState(() {
                                                categoryTextController.text =
                                                    value;
                                              });
                                            },
                                            suggestionsCallback:
                                                (String pattern) async {
                                              return await MyMaterialsDatabase
                                                  .searchForCategories(pattern);
                                            },
                                            itemBuilder: (context, suggestion) {
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
                                                  labelText: 'Category',
                                                ),
                                                keyboardType:
                                                    TextInputType.text,
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
                                          padding: EdgeInsets.symmetric(
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
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.green),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              border: const OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(8.0)),
                                              ),
                                              counterText: "",
                                              labelText: 'Name',
                                            ),
                                            keyboardType: TextInputType.text,
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
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: TextFormField(
                                            textCapitalization:
                                                TextCapitalization.sentences,
                                            controller: quantityTextController,
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor: Colors.white,
                                              isDense: true,
                                              contentPadding:
                                                  const EdgeInsets.all(10),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.green),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              border: const OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(8.0)),
                                              ),
                                              counterText: "",
                                              labelText: 'Quantity',
                                            ),
                                            keyboardType: TextInputType.number,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: TypeAheadField(
                                            onSelected: (value) {
                                              setState(() {
                                                unitTextController.text = value;
                                              });
                                            },
                                            suggestionsCallback:
                                                (String pattern) async {
                                              return await MyMaterialsDatabase
                                                  .searchForUnits(pattern);
                                            },
                                            itemBuilder: (context, suggestion) {
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
                                                controller: unitTextController,
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
                                                  labelText: 'Unit',
                                                ),
                                                keyboardType:
                                                    TextInputType.text,
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
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: TextFormField(
                                            textCapitalization:
                                                TextCapitalization.sentences,
                                            controller:
                                                largerMaterialTextController,
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor: Colors.white,
                                              isDense: true,
                                              contentPadding:
                                                  const EdgeInsets.all(10),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.green),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              border: const OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(8.0)),
                                              ),
                                              counterText: "",
                                              labelText:
                                                  'Larger Unit Material Barcode/ID',
                                            ),
                                            keyboardType: TextInputType.text,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: TextFormField(
                                            textCapitalization:
                                                TextCapitalization.sentences,
                                            controller:
                                                suppliedQuantityTextController,
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor: Colors.white,
                                              isDense: true,
                                              contentPadding:
                                                  const EdgeInsets.all(10),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.green),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              border: const OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(8.0)),
                                              ),
                                              counterText: "",
                                              labelText:
                                                  'Quantity to be supplied',
                                            ),
                                            keyboardType: TextInputType.text,
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
                                          padding: EdgeInsets.symmetric(
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
                                                  labelText: 'Cost Price',
                                                ),
                                                keyboardType:
                                                    TextInputType.text,
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
                                                    discount = (double.tryParse(
                                                                value) ??
                                                            0) *
                                                        (double.tryParse(
                                                                discountTextController
                                                                    .text) ??
                                                            0) /
                                                        100;
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
                                                  labelText: 'Sale Price',
                                                ),
                                                keyboardType:
                                                    TextInputType.text,
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Column(
                                            children: [Text("Profit: $profit")],
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
                                          padding: EdgeInsets.symmetric(
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
                                                  min: 1, max: 100),
                                            ],
                                            controller: taxTextController,
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor: Colors.white,
                                              isDense: true,
                                              contentPadding:
                                                  const EdgeInsets.all(10),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.green),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              border: const OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(8.0)),
                                              ),
                                              counterText: "",
                                              labelText: 'TAX/VAT %',
                                            ),
                                            keyboardType: TextInputType.number,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
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
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: TextFormField(
                                            onChanged: (value) {
                                              setState(() {
                                                discount = (double.tryParse(
                                                            value) ??
                                                        0) *
                                                    (double.tryParse(
                                                            salePriceTextController
                                                                .text) ??
                                                        0) /
                                                    100;
                                              });
                                            },
                                            textCapitalization:
                                                TextCapitalization.sentences,
                                            controller: discountTextController,
                                            inputFormatters: [
                                              NumericalRangeFormatter(
                                                  min: 1, max: 100),
                                            ],
                                            decoration: InputDecoration(
                                              filled: true,
                                              fillColor: Colors.white,
                                              isDense: true,
                                              contentPadding:
                                                  const EdgeInsets.all(10),
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.green),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              border: const OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
                                                    Radius.circular(8.0)),
                                              ),
                                              counterText: "",
                                              labelText: 'Max Discount %',
                                            ),
                                            keyboardType: TextInputType.number,
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: Column(
                                            children: [
                                              Text("Max Discount: $discount")
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
                                          padding: EdgeInsets.symmetric(
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
                                              focusedBorder: OutlineInputBorder(
                                                borderSide: const BorderSide(
                                                    color: Colors.green),
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                              ),
                                              border: const OutlineInputBorder(
                                                borderRadius: BorderRadius.all(
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
                        ElevatedButton.icon(
                            onPressed: () async {},
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
        );
      });
}
