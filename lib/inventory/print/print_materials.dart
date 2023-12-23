import 'dart:io';
import 'package:intl/intl.dart';
import 'package:moamri_accounting/controllers/main_controller.dart';
import 'package:moamri_accounting/database/entities/my_material.dart';
import 'package:moamri_accounting/database/my_materials_database.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart';

// TODO arabic
Future<dynamic> printMaterialsRoll(MainController mainController) async {
  var materialsMaps = await MyMaterialsDatabase.getAllMaterials();
  var materialsCount = await MyMaterialsDatabase.getMaterialsCount();
  final Document pdf = Document(
    deflate: zlib.encode,
    // theme: ThemeData.withFont(
    //   // base: Font.ttf(await rootBundle.load("assets/fonts/Hacen-Tunisia.ttf")), TODO
    //   base: Font.ttf(await rootBundle.load("assets/fonts/VT323-Regular.ttf")),
    // )
  );
  final dateFormat = DateFormat('yyyy-MM-dd');
  final timeFormat = DateFormat('hh:mm a');
  // final img = await rootBundle.load('assets/images/customers.png');TODO
  // final imageBytes = img.buffer.asUint8List();
  // PdfImage logoImage = PdfImage.file(pdf.document, bytes: imageBytes);
  List<Widget> widgets = [];
  widgets.add(SizedBox(height: 10));
  widgets.add(Center(child: Text("Materials")));
  widgets.add(SizedBox(height: 10));
  widgets.add(Center(
      child: Text(mainController.storeData.value!.name,
          style: TextStyle(fontWeight: FontWeight.bold))));
  widgets.add(Center(child: Text(mainController.storeData.value!.branch)));
  widgets.add(SizedBox(height: 4));
  widgets.add(Center(child: Text(mainController.storeData.value!.phone)));
  widgets.add(SizedBox(height: 4));
  widgets.add(Center(child: Text(mainController.storeData.value!.address)));
  widgets.add(SizedBox(height: 10));
  widgets.add(Center(child: Divider()));
  widgets.add(SizedBox(height: 10));
  widgets.add(Table(
      // border: TableBorder.all(color: PdfColors.black, width: 2),
      columnWidths: {
        0: const IntrinsicColumnWidth(),
        1: const FlexColumnWidth(),
      },
      children: [
        TableRow(children: [
          Text("Date"),
          Center(child: Text(dateFormat.format(DateTime.now()))),
        ]),
        TableRow(children: [
          Text("Time"),
          Center(child: Text(timeFormat.format(DateTime.now()))),
        ]),
        TableRow(children: [
          Text("Materials Count"),
          Center(child: Text(materialsCount.toString())),
        ]),
      ]));
  widgets.add(Center(child: Divider()));

  for (var category in materialsMaps.keys) {
    widgets.add(SizedBox(height: 10));
    widgets.add(Text(category, style: TextStyle(fontWeight: FontWeight.bold)));
    widgets.add(SizedBox(height: 10));
    List<TableRow> rows = [
      TableRow(children: [
        Padding(
            padding: const EdgeInsets.all(4),
            child: Center(
                child: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Text("Material",
                        style: TextStyle(fontWeight: FontWeight.bold))))),
        Padding(
            padding: const EdgeInsets.all(4),
            child: Center(
                child: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Text("Price",
                        style: TextStyle(fontWeight: FontWeight.bold))))),
        Padding(
            padding: const EdgeInsets.all(4),
            child: Center(
                child: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Text("Quantity",
                        style: TextStyle(fontWeight: FontWeight.bold))))),
        Padding(
            padding: const EdgeInsets.all(4),
            child: Center(
                child: FittedBox(
                    fit: BoxFit.fitWidth,
                    child: Text("TAX/VAT",
                        style: TextStyle(fontWeight: FontWeight.bold))))),
      ]),
    ];
    for (MyMaterial material in materialsMaps[category] ?? []) {
      rows.add(TableRow(children: [
        Padding(
            padding: const EdgeInsets.all(4),
            child: Center(child: Text(material.name))),
        Padding(
            padding: const EdgeInsets.all(4),
            child: Table(
                // border: TableBorder.all(color: PdfColors.grey700, width: 0.4),
                children: [
                  TableRow(children: [
                    Column(children: [
                      FittedBox(
                          fit: BoxFit.fitWidth, child: Text("Cost Price: ")),
                      Center(
                          child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Text(
                                  "${material.costPrice} ${material.currency}")))
                    ])
                  ]),
                  TableRow(children: [
                    Column(children: [
                      FittedBox(
                          fit: BoxFit.fitWidth, child: Text("Sale Price: ")),
                      Center(
                          child: FittedBox(
                              fit: BoxFit.fitWidth,
                              child: Text(
                                  "${material.salePrice} ${material.currency}")))
                    ])
                  ]),
                  // TableRow(children: [
                  //   Column(children: [
                  //     FittedBox(
                  //         fit: BoxFit.fitWidth, child: Text("Max Discount: ")),
                  //     Center(
                  //         child: FittedBox(
                  //             fit: BoxFit.fitWidth,
                  //             child: Text(
                  //                 "${material.discount} ${material.currency}")))
                  //   ])
                  // ])
                ])),
        Padding(
            padding: const EdgeInsets.all(4),
            child: Center(
                child: Column(children: [
              FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text("${material.quantity}",
                      textAlign: TextAlign.center)),
              FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text(material.unit, textAlign: TextAlign.center))
            ]))),
        Padding(
            padding: const EdgeInsets.all(4),
            child: Center(child: Text("${material.tax} %"))),
      ]));
    }
    widgets.add(Table(
        border: TableBorder.all(color: PdfColors.black, width: 1),
        columnWidths: {
          0: const FlexColumnWidth(1.5),
          1: const FlexColumnWidth(),
          2: const FlexColumnWidth(),
          3: const FlexColumnWidth(),
        },
        children: rows));
    widgets.add(SizedBox(height: 10));
  }
  widgets.add(Divider());
  widgets.add(Text("By: ${mainController.currentUser.value!.name}"));
  widgets.add(SizedBox(height: 10));
  pdf.addPage(
    Page(
        pageFormat: PdfPageFormat.roll80,
        // margin: const EdgeInsets.all(4),
        orientation: PageOrientation.portrait,
        build: (Context context) {
          return Column(children: widgets);
        }),
  );
  // final output = await getApplicationDocumentsDirectory();
  // final file = File("${output.path}/example.pdf");
  // await file.writeAsBytes(await pdf.save());
  await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => await pdf.save());
  // return file;
}

Future<dynamic> printMaterialsA4(MainController mainController) async {
  var materialsMaps = await MyMaterialsDatabase.getAllMaterials();
  var materialsCount = await MyMaterialsDatabase.getMaterialsCount();
  final Document pdf = Document(
    deflate: zlib.encode,
    // theme: ThemeData.withFont(
    //   base: Font.ttf(await rootBundle.load("assets/fonts/VT323-Regular.ttf")),
    // )
  );
  final dateFormat = DateFormat('yyyy-MM-dd');
  final timeFormat = DateFormat('hh:mm a');
  List<Widget> widgets = [];
  widgets.add(SizedBox(height: 10));
  widgets.add(Center(child: Text("Materials")));
  widgets.add(SizedBox(height: 10));
  widgets.add(Center(
      child: Text(mainController.storeData.value!.name,
          style: TextStyle(fontWeight: FontWeight.bold))));
  widgets.add(SizedBox(height: 10));
  widgets.add(Center(child: Divider()));
  widgets.add(SizedBox(height: 10));
  widgets.add(Table(
      // border: TableBorder.all(color: PdfColors.black, width: 2),
      columnWidths: {
        0: const IntrinsicColumnWidth(),
        1: const FlexColumnWidth(),
        2: const IntrinsicColumnWidth(),
        3: const FlexColumnWidth(),
        4: const IntrinsicColumnWidth(),
        5: const FlexColumnWidth(),
      },
      children: [
        TableRow(children: [
          Text("Branch", style: TextStyle(fontWeight: FontWeight.bold)),
          Center(child: Text(mainController.storeData.value!.branch)),
          Text("Phone", style: TextStyle(fontWeight: FontWeight.bold)),
          Center(child: Text(mainController.storeData.value!.phone)),
          Text("Address", style: TextStyle(fontWeight: FontWeight.bold)),
          Center(child: Text(mainController.storeData.value!.address)),
        ]),
        TableRow(children: [
          Text("Date", style: TextStyle(fontWeight: FontWeight.bold)),
          Center(child: Text(dateFormat.format(DateTime.now()))),
          Text("Time", style: TextStyle(fontWeight: FontWeight.bold)),
          Center(child: Text(timeFormat.format(DateTime.now()))),
          Text("Materials Count",
              style: TextStyle(fontWeight: FontWeight.bold)),
          Center(child: Text(materialsCount.toString())),
        ]),
      ]));
  widgets.add(Center(child: Divider()));

  for (var category in materialsMaps.keys) {
    widgets.add(SizedBox(height: 10));
    widgets.add(Text(category, style: TextStyle(fontWeight: FontWeight.bold)));
    widgets.add(SizedBox(height: 10));
    List<TableRow> rows = [
      TableRow(children: [
        Padding(
            padding: const EdgeInsets.all(4),
            child: Center(
                child: Center(
                    child: FittedBox(
                        fit: BoxFit.fitWidth,
                        child: Text("Material",
                            style: TextStyle(fontWeight: FontWeight.bold)))))),
        Padding(
            padding: const EdgeInsets.all(4),
            child: Center(
                child: Center(
                    child: FittedBox(
                        fit: BoxFit.fitWidth,
                        child: Text("Cost Price",
                            style: TextStyle(fontWeight: FontWeight.bold)))))),
        Padding(
            padding: const EdgeInsets.all(4),
            child: Center(
                child: Center(
                    child: FittedBox(
                        fit: BoxFit.fitWidth,
                        child: Text("Sale Price",
                            style: TextStyle(fontWeight: FontWeight.bold)))))),
        Padding(
            padding: const EdgeInsets.all(4),
            child: Center(
                child: Center(
                    child: FittedBox(
                        fit: BoxFit.fitWidth,
                        child: Text("Quantity",
                            style: TextStyle(fontWeight: FontWeight.bold)))))),
        Padding(
            padding: const EdgeInsets.all(4),
            child: Center(
                child: Center(
                    child: FittedBox(
                        fit: BoxFit.fitWidth,
                        child: Text("TAX/VAT",
                            style: TextStyle(fontWeight: FontWeight.bold)))))),
      ]),
    ];
    for (MyMaterial material in materialsMaps[category] ?? []) {
      rows.add(TableRow(children: [
        Padding(
            padding: const EdgeInsets.all(4),
            child: Center(child: Text(material.name))),
        Padding(
            padding: const EdgeInsets.all(4),
            child: Center(
                child: Text("${material.costPrice} ${material.currency}"))),
        Padding(
            padding: const EdgeInsets.all(4),
            child: Center(
                child: Text("${material.salePrice} ${material.currency}"))),
        Padding(
            padding: const EdgeInsets.all(4),
            child:
                Center(child: Text("${material.quantity} ${material.unit}"))),
        Padding(
            padding: const EdgeInsets.all(4),
            child: Center(child: Text("${material.tax} %"))),
      ]));
    }
    widgets.add(Table(
        border: TableBorder.all(color: PdfColors.black, width: 1),
        columnWidths: {
          0: const FlexColumnWidth(),
          1: const FlexColumnWidth(1.5),
          2: const FlexColumnWidth(),
          3: const FlexColumnWidth(),
        },
        children: rows));
    widgets.add(SizedBox(height: 10));
  }
  widgets.add(Divider());
  widgets.add(Text("By: ${mainController.currentUser.value!.name}"));
  widgets.add(SizedBox(height: 10));
  pdf.addPage(
    MultiPage(
        pageFormat: PdfPageFormat.a4,
        // margin: const EdgeInsets.all(4),
        orientation: PageOrientation.portrait,
        build: (Context context) {
          return widgets;
        }),
  );
  // final output = await getApplicationDocumentsDirectory();
  // final file = File("${output.path}/example.pdf");
  // await file.writeAsBytes(await pdf.save());
  await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => await pdf.save());
  // return file;
}
