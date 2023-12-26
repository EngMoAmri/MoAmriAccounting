import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<dynamic> showConfirmationDialog(
  String message, // this message will be shown in this alert dialog
) {
  return showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text("إنتباه"),
            content: Text(
              message,
              textAlign: TextAlign.center,
            ),
            actionsAlignment: MainAxisAlignment.center,
            actions: [
              OutlinedButton(
                  onPressed: () {
                    Navigator.of(Get.context!).pop(true);
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                    foregroundColor: MaterialStateProperty.all(Colors.blue),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    )),
                  ),
                  child: const Text("نعم",
                      style: TextStyle(fontWeight: FontWeight.bold))),
              OutlinedButton(
                  onPressed: () {
                    Navigator.of(Get.context!).pop(false);
                  },
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all(Colors.white),
                    foregroundColor: MaterialStateProperty.all(Colors.green),
                    shape: MaterialStateProperty.all(RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.0),
                    )),
                  ),
                  child: const Text("لا",
                      style: TextStyle(fontWeight: FontWeight.bold)))
            ],
          ),
        );
      });
}

Future<void> showErrorDialog(String message) async {
// set up the button
  Widget okButton = TextButton(
    child: const Text("حسناً"),
    onPressed: () {
      Get.back();
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    icon: const Icon(Icons.error),
    iconColor: Colors.red,
    title: const Text("خطأ"),
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
    child: const Text("حسناً"),
    onPressed: () {
      Get.back();
    },
  );

  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    icon: const Icon(Icons.done),
    iconColor: Colors.green,
    title: const Text("نجاح"),
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
