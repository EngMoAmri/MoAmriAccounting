import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/controllers/main_controller.dart';
import 'package:moamri_accounting/database/entities/store.dart';
import 'package:moamri_accounting/database/entities/user.dart';
import 'package:moamri_accounting/database/my_database.dart';
import 'package:moamri_accounting/pages/home_page.dart';

import '../database/currencies_database.dart';
import '../database/entities/currency.dart';
import '../dialogs/alerts_dialogs.dart';

class StoreSetupController extends GetxController {
  Rx<bool> creating = false.obs;
  final formKey = GlobalKey<FormState>();

  final storeNameController = TextEditingController();
  final storeBranchController = TextEditingController();
  final storeAddressController = TextEditingController();
  final storePhoneController = TextEditingController();
  final storeCurrencyController = TextEditingController();
  final adminNameController = TextEditingController();
  final adminUsernameController = TextEditingController();
  final adminPasswordController = TextEditingController();

  Future<void> createStore() async {
    if (formKey.currentState!.validate()) {
      var storeName = storeNameController.text.trim();
      var storeBranch = storeBranchController.text.trim();
      var storeAddress = storeAddressController.text.trim();
      var storePhone = storePhoneController.text.trim();
      var currency = storeCurrencyController.text.trim();
      var adminName = adminNameController.text.trim();
      var adminUsername = adminUsernameController.text.trim();
      var adminPassword = adminPasswordController.text.trim();
      if (storeName.isEmpty ||
          storeBranch.isEmpty ||
          storeAddress.isEmpty ||
          storePhone.isEmpty ||
          currency.isEmpty ||
          adminName.isEmpty ||
          adminUsername.isEmpty ||
          adminPassword.isEmpty) {
        showErrorDialog("كل الحقول مطلوبة");

        return;
      }
      // store data
      Store store = Store(
          name: storeName,
          branch: storeBranch,
          address: storeAddress,
          phone: storePhone,
          currency: currency,
          updatedDate: DateTime.now().millisecondsSinceEpoch);
      // admin data
      User user = User(
        name: adminName,
        enabled: 1,
        username: adminUsername,
        password: adminPassword,
        role: "admin",
      );
      try {
        user.id = await MyDatabase.insertUser(user, null);
        await CurrenciesDatabase.insertCurrency(
            Currency(name: currency, exchangeRate: 1), user);
        await MyDatabase.setStoreData(store);
        final mainController = Get.put(MainController());
        mainController.storeData.value = store;
        mainController.currentUser.value = user;
        // AudioPlayer().play(AssetSource('assets/sounds/cash-register.mp3')); TODO
        await showSuccessDialog("تم إنشاء متجرك بنجاح");

        Get.off(() => const HomePage());
      } catch (e) {
        log("Error: $e");
        showErrorDialog("خطأ: $e");
      }
    }
  }
}
