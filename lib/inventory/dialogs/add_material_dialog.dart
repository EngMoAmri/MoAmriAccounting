import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_barcode_listener/flutter_barcode_listener.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/controllers/main_controller.dart';
import 'package:moamri_accounting/database/entities/my_material.dart';
import 'package:moamri_accounting/dialogs/alerts_dialogs.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../../database/currencies_database.dart';
import '../../database/entities/currency.dart';
import '../../database/my_materials_database.dart';
import '../../sale/controllers/sale_controller.dart';
import '../../utils/global_utils.dart';
import 'add_currency_dialog.dart';

Future<bool?> showAddMaterialDialog(MainController mainController) async {
  return await showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final formKey = GlobalKey<FormState>();
        // final scrollController = ScrollController();
        final barcodeTextController = TextEditingController();
        final categoryTextController = TextEditingController();
        final nameTextController = TextEditingController();
        final quantityTextController = TextEditingController();
        final unitTextController = TextEditingController();
        final currencyTextController = TextEditingController();
        Currency? currency;

        final largerMaterialTextController = TextEditingController();
        MyMaterial? largerMaterial;
        final suppliedQuantityTextController = TextEditingController();
        final costPriceTextController = TextEditingController();
        final salePriceTextController = TextEditingController();
        double profit = 0.0;
        final noteTextController = TextEditingController();
        var adding = false;
        var visible = false;
        final FocusNode nameFocusNode = FocusNode();
        final FocusNode suppliedQuantityFocusNode = FocusNode();
        final FocusNode costPriceFocusNode = FocusNode();
        final FocusNode salePriceFocusNode = FocusNode();

        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 600),
              child: FocusTraversalGroup(
                policy: WidgetOrderTraversalPolicy(),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: StatefulBuilder(builder: (context, setState) {
                    return Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Row(
                          children: [
                            const SizedBox(
                              width: 20,
                            ),
                            const Expanded(
                              child: Text(
                                "إضافة مادة",
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
                        Form(
                          key: formKey,
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  // Add visiblity detector to handle barcode
                                  // values only when widget is visible
                                  child: VisibilityDetector(
                                    onVisibilityChanged: (VisibilityInfo info) {
                                      visible = info.visibleFraction > 0;
                                    },
                                    key: const Key('visible-detector-key'),
                                    child: BarcodeKeyboardListener(
                                      bufferDuration:
                                          const Duration(milliseconds: 200),
                                      onBarcodeScanned: (barcode) async {
                                        if (!visible || barcode.isEmpty) return;
                                        await AudioPlayer().play(AssetSource(
                                            'sounds/scanner-beep.mp3'));

                                        setState(() {
                                          barcodeTextController.text = barcode;
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
                                                  labelText: 'الباركود',
                                                ),
                                                keyboardType:
                                                    TextInputType.number,
                                                validator: (value) {
                                                  if (value?.trim().isEmpty ??
                                                      true) {
                                                    return "هذا الحقل مطلوب";
                                                  }
                                                  return null;
                                                },
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
                                                  backgroundColor:
                                                      MaterialStateProperty.all(
                                                          Colors.blue),
                                                  foregroundColor:
                                                      MaterialStateProperty.all(
                                                          Colors.white)),
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
                                              label: const Text('توليد')),
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
                                            controller: categoryTextController,
                                            emptyBuilder: (context) =>
                                                Container(
                                              height: 0,
                                            ),
                                            onSelected: (value) {
                                              nameFocusNode.requestFocus();
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
                                                  labelText: 'الصنف',
                                                ),
                                                keyboardType:
                                                    TextInputType.text,
                                                validator: (value) {
                                                  if (value?.trim().isEmpty ??
                                                      true) {
                                                    return "هذا الحقل مطلوب";
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
                                            focusNode: nameFocusNode,
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
                                              labelText: 'الاسم',
                                            ),
                                            keyboardType: TextInputType.text,
                                            validator: (value) {
                                              if (value?.trim().isEmpty ??
                                                  true) {
                                                return "هذا الحقل مطلوب";
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
                                              labelText: 'الكمية',
                                            ),
                                            keyboardType: TextInputType.number,
                                            validator: (value) {
                                              if (value?.trim().isEmpty ??
                                                  true) {
                                                return "هذا الحقل مطلوب";
                                              }

                                              if (double.tryParse(
                                                      value!.trim()) ==
                                                  null) {
                                                return "إدخل الكمية بشكل صحيح";
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
                                              costPriceFocusNode.requestFocus();
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
                                                  labelText: 'الوحدة',
                                                ),
                                                keyboardType:
                                                    TextInputType.text,
                                                validator: (value) {
                                                  if (value?.trim().isEmpty ??
                                                      true) {
                                                    return "هذا الحقل مطلوب";
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
                                const SizedBox(
                                  height: 8,
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: TextFormField(
                                            onChanged: (value) {
                                              setState(() {
                                                profit = (double.tryParse(
                                                            salePriceTextController
                                                                .text
                                                                .trim()) ??
                                                        0) -
                                                    (double.tryParse(value) ??
                                                        0);
                                              });
                                            },
                                            textCapitalization:
                                                TextCapitalization.sentences,
                                            controller: costPriceTextController,
                                            focusNode: costPriceFocusNode,
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
                                              labelText: 'سعر شراء الوحدة',
                                            ),
                                            keyboardType: TextInputType.text,
                                            validator: (value) {
                                              if (value?.trim().isEmpty ??
                                                  true) {
                                                return "هذا الحقل مطلوب";
                                              }
                                              if (double.tryParse(
                                                      value!.trim()) ==
                                                  null) {
                                                return "إدخل المبلغ بشكل صحيح";
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
                                          child: (currency == null)
                                              ? Row(
                                                  children: [
                                                    Expanded(
                                                      child: Padding(
                                                        padding:
                                                            const EdgeInsets
                                                                .symmetric(
                                                                horizontal: 10),
                                                        child: TypeAheadField(
                                                          controller:
                                                              currencyTextController,
                                                          emptyBuilder:
                                                              (context) =>
                                                                  Container(
                                                            height: 0,
                                                          ),
                                                          onSelected: (value) {
                                                            salePriceFocusNode
                                                                .requestFocus();
                                                            setState(() {
                                                              currency = value;
                                                              currencyTextController
                                                                      .text =
                                                                  value.name;
                                                            });
                                                          },
                                                          suggestionsCallback:
                                                              (String
                                                                  pattern) async {
                                                            return await CurrenciesDatabase
                                                                .searchForCurrencies(
                                                                    pattern);
                                                          },
                                                          itemBuilder: (context,
                                                              suggestion) {
                                                            return ListTile(
                                                              title: Text(
                                                                  suggestion
                                                                      .name),
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
                                                                  currencyTextController,
                                                              focusNode:
                                                                  focusNode,
                                                              decoration:
                                                                  InputDecoration(
                                                                filled: true,
                                                                fillColor:
                                                                    Colors
                                                                        .white,
                                                                isDense: true,
                                                                contentPadding:
                                                                    const EdgeInsets
                                                                        .all(
                                                                        10),
                                                                focusedBorder:
                                                                    OutlineInputBorder(
                                                                  borderSide:
                                                                      const BorderSide(
                                                                          color:
                                                                              Colors.green),
                                                                  borderRadius:
                                                                      BorderRadius
                                                                          .circular(
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
                                                                    'العملة',
                                                              ),
                                                              keyboardType:
                                                                  TextInputType
                                                                      .text,
                                                              validator:
                                                                  (value) {
                                                                if (value
                                                                        ?.trim()
                                                                        .isEmpty ??
                                                                    true) {
                                                                  return "هذا الحقل مطلوب";
                                                                }
                                                                return null;
                                                              },
                                                            );
                                                          },
                                                        ),
                                                      ),
                                                    ),
                                                    OutlinedButton.icon(
                                                        style: ButtonStyle(
                                                            shape: MaterialStateProperty.all(
                                                                RoundedRectangleBorder(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          12.0),
                                                            )),
                                                            backgroundColor:
                                                                MaterialStateProperty
                                                                    .all(Colors
                                                                        .blue),
                                                            foregroundColor:
                                                                MaterialStateProperty
                                                                    .all(Colors
                                                                        .white)),
                                                        onPressed: () async {
                                                          currency =
                                                              await showAddCurrencyDialog(
                                                                  mainController);
                                                          setState(() {
                                                            currencyTextController
                                                                .text = currency
                                                                    ?.name ??
                                                                currencyTextController
                                                                    .text;
                                                          });
                                                        },
                                                        icon: const Icon(
                                                            Icons.money),
                                                        label: const Text(
                                                            'إضافة')),
                                                  ],
                                                )
                                              : Row(
                                                  children: [
                                                    Expanded(
                                                      child: Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .symmetric(
                                                                  horizontal:
                                                                      10),
                                                          child: Text(
                                                              'العملة ${currency!.name}')),
                                                    ),
                                                    Padding(
                                                      padding: const EdgeInsets
                                                          .fromLTRB(
                                                          20, 0, 20, 0),
                                                      child: IconButton(
                                                        onPressed: () {
                                                          setState(() {
                                                            currencyTextController
                                                                .text = "";

                                                            currency = null;
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
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: TextFormField(
                                            onChanged: (value) {
                                              setState(() {
                                                profit = (double.tryParse(
                                                            value) ??
                                                        0) -
                                                    (double.tryParse(
                                                            costPriceTextController
                                                                .text
                                                                .trim()) ??
                                                        0);
                                              });
                                            },
                                            textCapitalization:
                                                TextCapitalization.sentences,
                                            controller: salePriceTextController,
                                            focusNode: salePriceFocusNode,
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
                                              labelText: 'سعر بيع الوحدة',
                                            ),
                                            keyboardType: TextInputType.text,
                                            validator: (value) {
                                              if (value?.trim().isEmpty ??
                                                  true) {
                                                return "هذا الحقل مطلوب";
                                              }
                                              if (double.tryParse(
                                                      value!.trim()) ==
                                                  null) {
                                                return "إدخل الرقم بشكل صحيح";
                                              }

                                              return null;
                                            },
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Center(
                                          child: Padding(
                                            padding: const EdgeInsets.symmetric(
                                                horizontal: 10),
                                            child: Text(
                                                "الربح: ${GlobalUtils.getMoney(profit)} ${currency?.name ?? ''}"),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 8,
                                ),
                                const Divider(
                                  height: 1,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Row(
                                    children: [
                                      Expanded(
                                        flex: 2,
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: TypeAheadField(
                                              controller:
                                                  largerMaterialTextController,
                                              emptyBuilder: (context) {
                                                return const SizedBox(
                                                  height: 60,
                                                  child: Center(
                                                    child: Text(
                                                        "لم يتم إيجاد مادة مناسبة"),
                                                  ),
                                                );
                                              },
                                              onSelected: (value) {
                                                suppliedQuantityFocusNode
                                                    .requestFocus();
                                                setState(() {
                                                  largerMaterial = value;
                                                  largerMaterialTextController
                                                          .text =
                                                      '${value.barcode}, ${value.unit} ${value.name}';
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
                                                      '${suggestion.barcode}, ${suggestion.unit} ${suggestion.name}'),
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
                                                        'الباركود أو اسم المادة ذو الوحدة اﻷكبر',
                                                  ),
                                                  keyboardType:
                                                      TextInputType.text,
                                                );
                                              }),
                                        ),
                                      ),
                                      Expanded(
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 10),
                                          child: TextFormField(
                                            textCapitalization:
                                                TextCapitalization.sentences,
                                            controller:
                                                suppliedQuantityTextController,
                                            focusNode:
                                                suppliedQuantityFocusNode,
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
                                              labelText: 'الكمية الموردة منها',
                                            ),
                                            keyboardType: TextInputType.text,
                                            validator: (value) {
                                              if ((value?.trim().isEmpty ??
                                                      true) &&
                                                  largerMaterial != null) {
                                                return "هذا الحقل مطلوب";
                                              }
                                              if ((value?.trim().isNotEmpty ??
                                                      false) &&
                                                  (double.tryParse(
                                                          value!.trim()) ==
                                                      null)) {
                                                return "إدخل الرقم بشكل صحيح";
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
                                              labelText: 'ملاحظات',
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
                        // ),
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
                                          barcodeTextController.text.trim();

                                      var materialByBarcode =
                                          await MyMaterialsDatabase
                                              .getMaterialByBarcode(
                                                  barcode.trim());
                                      if (materialByBarcode != null) {
                                        showErrorDialog(
                                            "هذا الباركود ينتمي لمادة أخرى");
                                        setState(() {
                                          adding = false;
                                        });
                                        return;
                                      }
                                      if (currency == null ||
                                          (currencyTextController.text.trim() !=
                                              currency?.name)) {
                                        showErrorDialog("يرجى إختيار عملة");
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
                                            "يرجى اختيار مادة ذو وحدة أكبر بشكل صحيح");
                                        setState(() {
                                          adding = false;
                                        });
                                        return;
                                      }
                                      if (largerMaterial != null &&
                                          (double.parse(
                                                  suppliedQuantityTextController
                                                      .text
                                                      .trim()) <=
                                              0)) {
                                        showErrorDialog(
                                            "يرجى اختيار الكمية المزودة من الوحدة الأكبر بشكل صحيح");
                                        setState(() {
                                          adding = false;
                                        });
                                        return;
                                      }
                                      final category =
                                          categoryTextController.text.trim();
                                      final name =
                                          nameTextController.text.trim();
                                      final quantity = double.parse(
                                          quantityTextController.text.trim());
                                      final unit =
                                          unitTextController.text.trim();
                                      final suppliedQuantity =
                                          (largerMaterial == null)
                                              ? null
                                              : double.parse(
                                                  suppliedQuantityTextController
                                                      .text
                                                      .trim());
                                      final costPrice = double.parse(
                                          costPriceTextController.text.trim());
                                      final salePrice = double.parse(
                                          salePriceTextController.text.trim());
                                      final note =
                                          noteTextController.text.trim();
                                      MyMaterial material = MyMaterial(
                                          name: name,
                                          barcode: barcode,
                                          category: category,
                                          currency: currency!.name,
                                          unit: unit,
                                          quantity: quantity,
                                          costPrice: costPrice,
                                          salePrice: salePrice,
                                          note: note,
                                          largerMaterialID: largerMaterial?.id,
                                          quantitySupplied: suppliedQuantity);

                                      try {
                                        await MyMaterialsDatabase
                                            .insertMaterial(
                                                material,
                                                mainController
                                                    .currentUser.value!);
                                        await showSuccessDialog(
                                            "تم إضافة المادة بنجاح");
                                        SaleController saleController =
                                            Get.find();
                                        saleController.getCategories();

                                        Get.back(result: true);
                                      } catch (e) {
                                        setState(() {
                                          adding = false;
                                        });
                                        showErrorDialog('خطأ $e');
                                      }
                                    }
                                  },
                                  style: ButtonStyle(
                                    backgroundColor:
                                        MaterialStateProperty.all(Colors.green),
                                    foregroundColor:
                                        MaterialStateProperty.all(Colors.black),
                                    shape: MaterialStateProperty.all(
                                        RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10.0),
                                    )),
                                  ),
                                  label: Text("إضافة".tr),
                                  icon: const Icon(Icons.add)),
                            const SizedBox(width: 10)
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
