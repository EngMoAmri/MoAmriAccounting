import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<String?> showPrintDialog(String printAction) async {
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    icon: const Icon(
      Icons.print,
      weight: 56,
    ),
    iconColor: Colors.black,
    title: Text("طباعة $printAction"),
    content: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text(
          "أختر نوع ورق الطباعة",
          textAlign: TextAlign.center,
        ),
        const SizedBox(
          height: 10,
        ),
        OutlinedButton.icon(
            onPressed: () async {
              Get.back(result: "حراري");
            },
            icon: Image.asset('assets/images/roll-of-paper.png', width: 36),
            style: ButtonStyle(
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                )),
                backgroundColor: MaterialStateProperty.all(Colors.white),
                foregroundColor: MaterialStateProperty.all(Colors.black)),
            label: const Text("80mm ورق حراري")),
        const SizedBox(
          height: 10,
        ),
        OutlinedButton.icon(
            onPressed: () async {
              Get.back(result: "A4");
            },
            icon: Image.asset(
              'assets/images/document.png',
              width: 30,
            ),
            style: ButtonStyle(
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                )),
                backgroundColor: MaterialStateProperty.all(Colors.white),
                foregroundColor: MaterialStateProperty.all(Colors.black)),
            label: const Text("A4 ورق"))
      ],
    ),
  );

  // show the dialog
  return await showDialog(
    context: Get.context!,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
