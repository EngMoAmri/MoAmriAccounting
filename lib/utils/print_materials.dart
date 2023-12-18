import 'dart:io';
// import 'package:flutter/services.dart';
import 'package:moamri_accounting/database/entities/my_material.dart';
import 'package:moamri_accounting/database/my_materials_database.dart';
// import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart';
// import 'package:flutter/material.dart' show AssetImage;

Future<dynamic> printMaterialsRoll57() async {
  var materialsMaps = await MyMaterialsDatabase.getAllMaterials();
  final Document pdf = Document(deflate: zlib.encode);
  // final img = await rootBundle.load('assets/images/customers.png');TODO
  // final imageBytes = img.buffer.asUint8List();
  // PdfImage logoImage = PdfImage.file(pdf.document, bytes: imageBytes);
  List<Widget> widgets = [];
  for (var category in materialsMaps.keys) {
    widgets.add(SizedBox(height: 10));
    widgets.add(Center(child: Text(category)));
    for (MyMaterial material in materialsMaps[category] ?? []) {
      widgets.add(Table(
          border: TableBorder.all(color: PdfColors.black, width: 2),
          columnWidths: {
            0: const FlexColumnWidth(),
          },
          children: [
            TableRow(children: [
              Table(
                  border: TableBorder.all(color: PdfColors.grey700),
                  columnWidths: {
                    0: const FlexColumnWidth(),
                    1: const FlexColumnWidth(),
                  },
                  children: [
                    TableRow(
                      children: [
                        Text(material.barcode,
                            style: const TextStyle(color: PdfColors.black)),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(4, 0, 0, 0),
                          child: Text(material.name,
                              style: const TextStyle(color: PdfColors.black)),
                        )
                      ],
                    ),
                    TableRow(
                      children: [
                        Text(
                            "Cost Price: ${material.costPrice} ${material.currency}",
                            style: const TextStyle(color: PdfColors.black)),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(4, 0, 0, 0),
                          child: Text(
                              "Sale Price: ${material.salePrice} ${material.currency}",
                              style: const TextStyle(color: PdfColors.black)),
                        )
                      ],
                    ),
                    TableRow(
                      children: [
                        Text("Max Discount: ${material.discount}",
                            style: const TextStyle(color: PdfColors.black)),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(4, 0, 0, 0),
                          child: Text("TAX/VAT: ${material.discount} %",
                              style: const TextStyle(color: PdfColors.black)),
                        )
                      ],
                    ),
                    TableRow(
                      children: [
                        Text("Quantity: ${material.quantity}",
                            style: const TextStyle(color: PdfColors.black)),
                        Padding(
                          padding: const EdgeInsets.fromLTRB(4, 0, 0, 0),
                          child: Text("Unit ${material.unit}",
                              style: const TextStyle(color: PdfColors.black)),
                        )
                      ],
                    ),
                  ]),
            ])
          ]));
    }
    widgets.add(SizedBox(height: 10));
  }
  pdf.addPage(
    Page(
        pageFormat: PdfPageFormat.roll57,
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
