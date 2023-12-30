import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/controllers/main_controller.dart';

Future<String?> showPrintOrderDialog(MainController mainController) async {
  bool rememberMyChoice = false;
  // set up the AlertDialog
  AlertDialog alert = AlertDialog(
    icon: const Icon(
      Icons.print,
      weight: 56,
    ),
    iconColor: Colors.black,
    title: const Text("طباعة الفاتورة"),
    content: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            Expanded(
              child: Container(),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
              child: IconButton(
                onPressed: () {
                  Get.back();
                },
                icon: const Icon(
                  Icons.close,
                  color: Colors.red,
                ),
              ),
            ),
          ],
        ),
        const Divider(),
        const Text(
          "أختر نوع ورق الطباعة",
          textAlign: TextAlign.center,
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          children: [
            StatefulBuilder(builder: (context, setState) {
              return Checkbox(
                  value: rememberMyChoice,
                  onChanged: (value) {
                    setState(() {
                      rememberMyChoice = value ?? false;
                    });
                  });
            }),
            const Expanded(child: Text('تذكر إختياري'))
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        OutlinedButton.icon(
            onPressed: () async {
              await mainController.getStorage
                  .write('order-print-choice', "حراري");

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
              await mainController.getStorage.write('order-print-choice', "A4");
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
    barrierDismissible: false,
    builder: (BuildContext context) {
      return alert;
    },
  );
}
