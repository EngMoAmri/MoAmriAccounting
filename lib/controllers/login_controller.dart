import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/controllers/main_controller.dart';
import 'package:moamri_accounting/database/my_database.dart';
import 'package:moamri_accounting/pages/home_page.dart';

import '../dialogs/alerts_dialogs.dart';

class LoginController extends GetxController {
  Rx<bool> logining = false.obs;
  final formKey = GlobalKey<FormState>();
  MainController mainController = Get.find();
  final usernameController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> login() async {
    if (formKey.currentState!.validate()) {
      var username = usernameController.text;
      var password = passwordController.text;
      if (username.trim().isEmpty || password.trim().isEmpty) {
        showErrorDialog("كل الحقول مطلوبة");
        return;
      }
      try {
        mainController.currentUser.value =
            await MyDatabase.getUser(username, password);
        if (mainController.currentUser.value == null) {
          showErrorDialog("معلومات المستخدم غير صحيحة");
          // TODO limit the number of trys
        } else {
          // AudioPlayer().play(AssetSource('assets/sounds/cash-register.mp3')); TODO

          Get.off(() => const HomePage());
        }
      } catch (e) {
        log("Error: $e");
        showErrorDialog("خطأ: $e");
      }
    }
  }
}
