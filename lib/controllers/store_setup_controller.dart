import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/database/entities/store.dart';
import 'package:moamri_accounting/database/entities/user.dart';
import 'package:moamri_accounting/database/my_database.dart';
import 'package:moamri_accounting/pages/home_page.dart';

import '../dialogs/alerts_dialogs.dart';

class StoreSetupController extends GetxController {
  Rx<bool> creating = false.obs;
  final formKey = GlobalKey<FormState>();

  final storeNameController = TextEditingController();
  final storeBranchController = TextEditingController();
  final storeAddressController = TextEditingController();
  final storePhoneController = TextEditingController();
  final adminNameController = TextEditingController();
  final adminUsernameController = TextEditingController();
  final adminPasswordController = TextEditingController();

  Future<void> createStore() async {
    if (formKey.currentState!.validate()) {
      var storeName = storeNameController.text;
      var storeBranch = storeBranchController.text;
      var storeAddress = storeAddressController.text;
      var storePhone = storePhoneController.text;
      var adminName = adminNameController.text;
      var adminUsername = adminUsernameController.text;
      var adminPassword = adminPasswordController.text;
      if (storeName.trim().isEmpty ||
          storeBranch.trim().isEmpty ||
          storeAddress.trim().isEmpty ||
          storePhone.trim().isEmpty ||
          adminName.trim().isEmpty ||
          adminUsername.trim().isEmpty ||
          adminPassword.trim().isEmpty) {
        showErrorDialog("All Feilds Are Required");

        return;
      }
      // store data
      Store store = Store(
          id: 1,
          name: storeName,
          branch: storeBranch,
          address: storeAddress,
          phone: storePhone,
          createdDate: DateTime.now().millisecondsSinceEpoch,
          updatedDate: DateTime.now().millisecondsSinceEpoch);
      // admin data
      User user = User(
          name: adminName,
          enabled: 1,
          username: adminUsername,
          password: adminPassword,
          role: "admin",
          createdDate: DateTime.now().millisecondsSinceEpoch,
          updatedDate: DateTime.now().millisecondsSinceEpoch);
      try {
        await MyDatabase.setStoreData(store);
        await MyDatabase.insertUser(user);
        // AudioPlayer().play(AssetSource('assets/sounds/cash-register.mp3')); TODO
        await showSuccessDialog("Store Created Successfully");

        Get.off(() => const HomePage());
      } catch (e) {
        log("Error: $e");
        Get.showSnackbar(GetSnackBar(
          title: "Error: $e",
        ));
      }
    }
  }
}
