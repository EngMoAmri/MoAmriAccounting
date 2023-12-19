import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/controllers/main_controller.dart';

import '../utils/print_materials.dart';

Future<void> showPrintDialog(
    String printAction, MainController mainController) async {
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    icon: const Icon(
      Icons.print,
      weight: 56,
    ),
    iconColor: Colors.black,
    title: Text("Print $printAction"),
    content: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          "Select Paper Type",
          textAlign: TextAlign.center,
        ),
        const SizedBox(
          height: 10,
        ),
        OutlinedButton.icon(
            onPressed: () async {
              if (printAction == "Materials") {
                await printMaterialsRoll57(mainController);
                Get.back();
              }
            },
            icon: Image.asset('assets/images/roll-of-paper.png', width: 36),
            style: ButtonStyle(
                shape: MaterialStateProperty.all(RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12.0),
                )),
                backgroundColor: MaterialStateProperty.all(Colors.white),
                foregroundColor: MaterialStateProperty.all(Colors.black)),
            label: Text("80mm Thermal Paper")),
        const SizedBox(
          height: 10,
        ),
        OutlinedButton.icon(
            onPressed: () async {
              if (printAction == "Materials") {
                await printMaterialsA4(mainController);
                Get.back();
              }
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
            label: Text("A4 Paper"))
      ],
    ),
  );

  // show the dialog
  await showDialog(
    context: Get.context!,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
