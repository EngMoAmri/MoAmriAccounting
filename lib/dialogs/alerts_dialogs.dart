import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<void> showErrorDialog(String message) async {
// set up the button
  Widget okButton = TextButton(
    child: const Text("OK"),
    onPressed: () {
      Get.back();
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    icon: const Icon(Icons.error),
    iconColor: Colors.red,
    title: const Text("Attention"),
    content: Text(
      message,
      textAlign: TextAlign.center,
    ),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  await showDialog(
    context: Get.context!,
    builder: (BuildContext context) {
      return alert;
    },
  );
}

Future<void> showSuccessDialog(String message) async {
// set up the button
  Widget okButton = TextButton(
    child: const Text("OK"),
    onPressed: () {
      Get.back();
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    icon: const Icon(Icons.done),
    iconColor: Colors.green,
    title: const Text("Success"),
    content: Text(
      message,
      textAlign: TextAlign.center,
    ),
    actions: [
      okButton,
    ],
  );

  // show the dialog
  await showDialog(
    context: Get.context!,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
