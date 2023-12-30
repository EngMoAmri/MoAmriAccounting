import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:moamri_accounting/database/my_database.dart';

import '../database/currencies_database.dart';
import '../database/entities/currency.dart';
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
  final getStorage = GetStorage();
  Rx<bool> loadingCurrenies = true.obs;
  Rx<List<Currency>> currencies = Rx([]);
  Future<void> getCurrenies() async {
    loadingCurrenies.value = true;
    currencies.value.clear();
    currencies.value.addAll(await CurrenciesDatabase.getCurrencies());
    currencies.refresh();
    loadingCurrenies.value = false;
  }

  @override
  void onInit() async {
    await MyDatabase.open();
    storeData.value = await MyDatabase.getStoreData();
    await getCurrenies();
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
