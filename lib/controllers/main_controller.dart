import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/database/my_database.dart';

import '../database/entities/store.dart';
import '../database/entities/user.dart';
import '../pages/login_page.dart';
import '../pages/store_setup_page.dart';

class MainController extends GetxController {
  Rx<bool> loading = true.obs;

  /// this will contain the store information
  Rx<Store?> storeData = Rx(null);

  /// this will contain the store information
  Rx<User?> currentUser = Rx(null);

  @override
  void onInit() async {
    await MyDatabase.open();
    storeData.value = await MyDatabase.getStoreData();
    if (storeData.value == null) {
      Get.off(() => const StoreSetupPage());
    } else {
      // Get.off(() => const LoginPage());
      showDialog(
          context: Get.context!,
          barrierDismissible: false,
          useRootNavigator: false,
          builder: (context) {
            return const Dialog(
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(Radius.circular(5.0))),
                child: LoginPage());
          });
    }
    // loading.value = false;
    super.onInit();
  }
}
