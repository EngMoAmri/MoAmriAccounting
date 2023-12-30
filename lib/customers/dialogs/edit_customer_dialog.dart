import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/controllers/main_controller.dart';
import 'package:moamri_accounting/database/customers_database.dart';
import 'package:moamri_accounting/dialogs/alerts_dialogs.dart';

import '../../database/entities/customer.dart';

Future<bool?> showEditCustomerDialog(
    MainController mainController, Customer oldCustomer) async {
  return await showDialog(
      context: Get.context!,
      barrierDismissible: false,
      builder: (BuildContext context) {
        final formKey = GlobalKey<FormState>();
        final nameTextController = TextEditingController();
        nameTextController.text = oldCustomer.name;

        final phoneTextController = TextEditingController();
        phoneTextController.text = oldCustomer.phone;

        final addressTextController = TextEditingController();
        addressTextController.text = oldCustomer.address;

        final descriptionTextController = TextEditingController();
        descriptionTextController.text = oldCustomer.description;
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
                                "تعديل عميل",
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
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
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
                                            controller: phoneTextController,
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
                                              labelText: 'الجوال',
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
                                            controller: addressTextController,
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
                                              labelText: 'العنوان',
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
                                              controller:
                                                  descriptionTextController,
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
                                                labelText: 'الوصف',
                                              ),
                                              minLines: 3,
                                              maxLines: 3,
                                              keyboardType:
                                                  TextInputType.multiline),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
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
                                      final name =
                                          nameTextController.text.trim();
                                      final phone =
                                          phoneTextController.text.trim();
                                      final address =
                                          addressTextController.text.trim();
                                      final description =
                                          descriptionTextController.text.trim();

                                      Customer customer = Customer(
                                        id: oldCustomer.id,
                                        name: name,
                                        phone: phone,
                                        address: address,
                                        description: description,
                                      );
                                      try {
                                        await CustomersDatabase.updateCustomer(
                                            customer,
                                            oldCustomer,
                                            mainController.currentUser.value!);
                                        await showSuccessDialog(
                                            "تم تعديل العميل");
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
                                  label: Text("تم".tr),
                                  icon: const Icon(Icons.done)),
                            const SizedBox(
                              width: 10,
                            ),
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
