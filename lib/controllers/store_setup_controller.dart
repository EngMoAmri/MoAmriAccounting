import 'package:flutter/material.dart';
import 'package:get/get.dart';

class StoreSetupController extends GetxController {
  Rx<bool> creating = false.obs;
  final storeNameController = TextEditingController();
  final storeBranchController = TextEditingController();
  final storeAddressController = TextEditingController();
  final storePhoneController = TextEditingController();
  final adminNameController = TextEditingController();
  final adminUsernameController = TextEditingController();
  final adminPasswordController = TextEditingController();

  void createStore() {}
}
