import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/controllers/main_controller.dart';
import 'package:moamri_accounting/database/entities/currency.dart';
import 'package:moamri_accounting/dialogs/alerts_dialogs.dart';

import '../../database/currencies_database.dart';

Future<Currency?> showEditCurrencyDialog(
    MainController mainController, Currency oldCurrency) async {
  return await showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final formKey = GlobalKey<FormState>();
        final nameTextController = TextEditingController();
        nameTextController.text = oldCurrency.name;
        final exchangeRateTextController = TextEditingController();
        exchangeRateTextController.text = oldCurrency.exchangeRate.toString();

        var adding = false;
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
                                "تعديل عملة",
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
                                        labelText: 'رمز العملة أو اسمها',
                                      ),
                                      keyboardType: TextInputType.text,
                                      validator: (value) {
                                        if (value?.trim().isEmpty ?? true) {
                                          return "هذا الحقل مطلوب";
                                        }
                                        return null;
                                      },
                                    ),
                                  ),
                                ),
                                const Divider(
                                  height: 1,
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(8),
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 10),
                                    child: TextFormField(
                                      textCapitalization:
                                          TextCapitalization.sentences,
                                      controller: exchangeRateTextController,
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
                                            'سعر صرف هذه العملة إلى ${mainController.storeData.value!.currency}',
                                      ),
                                      keyboardType: TextInputType.text,
                                      validator: (value) {
                                        if (value?.trim().isEmpty ?? true) {
                                          return "هذا الحقل مطلوب";
                                        }
                                        if (double.tryParse(value!.trim()) ==
                                            null) {
                                          return "إدخل المبلغ بشكل صحيح";
                                        }
                                        return null;
                                      },
                                    ),
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
                                      final name =
                                          nameTextController.text.trim();

                                      if ((name.trim() != oldCurrency.name) &&
                                          await CurrenciesDatabase
                                              .isCurrencyExists(name.trim())) {
                                        showErrorDialog(
                                            "هذه العملة موجودة مسبقاً");
                                        setState(() {
                                          adding = false;
                                        });
                                        return;
                                      }
                                      final exchangeRate = double.parse(
                                          exchangeRateTextController.text
                                              .trim());
                                      var currency = Currency(
                                          name: name,
                                          exchangeRate: exchangeRate);
                                      try {
                                        await CurrenciesDatabase.updateCurrency(
                                            currency,
                                            oldCurrency,
                                            mainController
                                                .currentUser.value!.id!);
                                        await showSuccessDialog(
                                            "تم تعديل العملة بنجاح");
                                        Get.back(result: currency);
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
                                  label: const Text("تم"),
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
