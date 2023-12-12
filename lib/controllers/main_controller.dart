import 'package:get/get.dart';
import 'package:moamri_accounting/database/my_database.dart';

import '../database/entities/store.dart';

class MainController extends GetxController {
  Rx<bool> loading = true.obs;

  /// this will contain the store information
  Rx<Store?> storeData = Rx(null);

  @override
  void onInit() async {
    await MyDatabase.open();
    storeData.value = await MyDatabase.getStoreData();
    loading.value = false;
    super.onInit();
  }
}
