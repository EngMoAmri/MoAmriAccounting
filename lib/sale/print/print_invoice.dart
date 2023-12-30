import 'dart:io';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart' as intl;
import 'package:moamri_accounting/controllers/main_controller.dart';
import 'package:moamri_accounting/database/items/invoice_item.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart';

Future<dynamic> printInvoiceRoll(
    MainController mainController, InvoiceItem invoiceItem) async {
  final Document pdf = Document(
      deflate: zlib.encode,
      theme: ThemeData.withFont(
          base:
              Font.ttf(await rootBundle.load("assets/fonts/Hacen-Tunisia.ttf")),
          bold: Font.ttf(
              await rootBundle.load("assets/fonts/Hacen Tunisia Bold.ttf"))));
  final dateFormat = intl.DateFormat('yyyy-MM-dd');
  final timeFormat = intl.DateFormat('hh:mm a');
  // final img = await rootBundle.load('assets/images/customers.png');TODO
  // final imageBytes = img.buffer.asUint8List();
  // PdfImage logoImage = PdfImage.file(pdf.document, bytes: imageBytes);
  List<Widget> widgets = [];
  widgets.add(Center(
      child: Text("فاتورة مبيعات",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))));
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
  widgets.add(Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: Table(
          // border: TableBorder.all(color: PdfColors.black, width: 2),
          columnWidths: {
            0: const FlexColumnWidth(),
            1: const IntrinsicColumnWidth(),
          },
          children: [
            TableRow(children: [
              Center(
                  child: Text(dateFormat.format(
                      DateTime.fromMillisecondsSinceEpoch(
                          invoiceItem.invoice.date)))),
              Text("التاريخ"),
            ]),
            TableRow(children: [
              Center(
                  child: Text(timeFormat.format(
                      DateTime.fromMillisecondsSinceEpoch(
                          invoiceItem.invoice.date)))),
              Text("الوقت"),
            ]),
            TableRow(children: [
              Center(
                  child: Text((invoiceItem.inoviceMaterialsItems.length +
                          invoiceItem.invoiceOffersItems.length)
                      .toString())),
              Text("عدد المواد"),
            ]),
          ])));
  widgets.add(Center(child: Divider()));
  List<TableRow> rows = [
    TableRow(children: [
      Padding(
          padding: const EdgeInsets.all(4),
          child: Center(
              child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text("المجموع",
                      style: TextStyle(fontWeight: FontWeight.bold))))),
      Padding(
          padding: const EdgeInsets.all(4),
          child: Center(
              child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text("الكمية",
                      style: TextStyle(fontWeight: FontWeight.bold))))),
      Padding(
          padding: const EdgeInsets.all(4),
          child: Center(
              child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text("السعر",
                      style: TextStyle(fontWeight: FontWeight.bold))))),
      Padding(
          padding: const EdgeInsets.all(4),
          child: Center(
              child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text("المادة",
                      style: TextStyle(fontWeight: FontWeight.bold))))),
    ]),
  ];

  for (var invoiceMaterialItem in invoiceItem.inoviceMaterialsItems) {
    widgets.add(SizedBox(height: 10));
    rows.add(TableRow(children: [
      Padding(
          padding: const EdgeInsets.all(4),
          child: Center(
              child: Column(children: [
            FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(
                    "${invoiceMaterialItem.quantity * invoiceMaterialItem.material.salePrice}",
                    textAlign: TextAlign.center)),
            FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(invoiceMaterialItem.material.currency,
                    textAlign: TextAlign.center))
          ]))),
      Padding(
          padding: const EdgeInsets.all(4),
          child: Center(
              child: Column(children: [
            FittedBox(
                fit: BoxFit.fitWidth,
                child: Text("${invoiceMaterialItem.quantity}",
                    textAlign: TextAlign.center)),
            FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(invoiceMaterialItem.material.unit,
                    textAlign: TextAlign.center))
          ]))),
      Padding(
          padding: const EdgeInsets.all(4),
          child: Center(
              child: Column(children: [
            FittedBox(
                fit: BoxFit.fitWidth,
                child: Text("${invoiceMaterialItem.material.salePrice}",
                    textAlign: TextAlign.center)),
            FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(invoiceMaterialItem.material.currency,
                    textAlign: TextAlign.center))
          ]))),
      Padding(
          padding: const EdgeInsets.all(4),
          child: Center(child: Text(invoiceMaterialItem.material.name))),
    ]));
    widgets.add(Table(
        border: TableBorder.all(color: PdfColors.black, width: 1),
        columnWidths: {
          0: const FlexColumnWidth(),
          1: const FlexColumnWidth(),
          2: const FlexColumnWidth(),
          3: const FlexColumnWidth(1.5),
        },
        children: rows));
    widgets.add(SizedBox(height: 10));
  }
  widgets.add(Divider());
  widgets.add(Text("بواسطة: ${mainController.currentUser.value!.name}"));
  widgets.add(SizedBox(height: 10));
  pdf.addPage(
    Page(
        pageFormat: PdfPageFormat.roll80,
        margin: const EdgeInsets.only(right: 24, left: 2),
        orientation: PageOrientation.portrait,
        build: (Context context) {
          return Directionality(
              textDirection: TextDirection.rtl,
              child: Column(children: widgets));
        }),
  );
  await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => await pdf.save());
}

Future<dynamic> printInvoiceA4(
    MainController mainController, InvoiceItem invoiceItem) async {
  final Document pdf = Document(
      deflate: zlib.encode,
      theme: ThemeData.withFont(
          base:
              Font.ttf(await rootBundle.load("assets/fonts/Hacen-Tunisia.ttf")),
          bold: Font.ttf(
              await rootBundle.load("assets/fonts/Hacen Tunisia Bold.ttf"))));
  final dateFormat = intl.DateFormat('yyyy-MM-dd');
  final timeFormat = intl.DateFormat('hh:mm a');
  // final img = await rootBundle.load('assets/images/customers.png');TODO
  // final imageBytes = img.buffer.asUint8List();
  // PdfImage logoImage = PdfImage.file(pdf.document, bytes: imageBytes);
  List<Widget> widgets = [];
  widgets.add(Center(
      child: Text("فاتورة مبيعات",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))));
  widgets.add(SizedBox(height: 10));
  widgets.add(Directionality(
      textDirection: TextDirection.rtl,
      child: Center(
          child: Text("المواد",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)))));
  widgets.add(SizedBox(height: 10));
  widgets.add(Directionality(
      textDirection: TextDirection.rtl,
      child: Center(
          child: Text(mainController.storeData.value!.name,
              style: TextStyle(fontWeight: FontWeight.bold)))));
  widgets.add(SizedBox(height: 10));
  widgets.add(Center(child: Divider()));
  widgets.add(SizedBox(height: 10));
  widgets.add(Directionality(
      textDirection: TextDirection.rtl,
      child: Table(
          // border: TableBorder.all(color: PdfColors.black, width: 2),
          columnWidths: {
            0: const FlexColumnWidth(),
            1: const IntrinsicColumnWidth(),
            2: const FlexColumnWidth(),
            3: const IntrinsicColumnWidth(),
            4: const FlexColumnWidth(),
            5: const IntrinsicColumnWidth(),
          },
          children: [
            TableRow(children: [
              Center(child: Text(mainController.storeData.value!.address)),
              Text("العنوان", style: TextStyle(fontWeight: FontWeight.bold)),
              Center(child: Text(mainController.storeData.value!.phone)),
              Text("التلفون", style: TextStyle(fontWeight: FontWeight.bold)),
              Center(child: Text(mainController.storeData.value!.branch)),
              Text("الفرع", style: TextStyle(fontWeight: FontWeight.bold)),
            ]),
            TableRow(children: [
              Center(
                  child: Text((invoiceItem.inoviceMaterialsItems.length +
                          invoiceItem.invoiceOffersItems.length)
                      .toString())),
              Text("عدد المواد", style: TextStyle(fontWeight: FontWeight.bold)),
              Center(
                  child: Text(timeFormat.format(
                      DateTime.fromMillisecondsSinceEpoch(
                          invoiceItem.invoice.date)))),
              Text("الوقت", style: TextStyle(fontWeight: FontWeight.bold)),
              Center(
                  child: Text(dateFormat.format(
                      DateTime.fromMillisecondsSinceEpoch(
                          invoiceItem.invoice.date)))),
              Text("التاريخ", style: TextStyle(fontWeight: FontWeight.bold)),
            ]),
          ])));
  widgets.add(Center(child: Divider()));

  List<TableRow> rows = [
    TableRow(children: [
      Padding(
          padding: const EdgeInsets.all(4),
          child: Center(
              child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text("المجموع",
                      style: TextStyle(fontWeight: FontWeight.bold))))),
      Padding(
          padding: const EdgeInsets.all(4),
          child: Center(
              child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text("الكمية",
                      style: TextStyle(fontWeight: FontWeight.bold))))),
      Padding(
          padding: const EdgeInsets.all(4),
          child: Center(
              child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text("السعر",
                      style: TextStyle(fontWeight: FontWeight.bold))))),
      Padding(
          padding: const EdgeInsets.all(4),
          child: Center(
              child: FittedBox(
                  fit: BoxFit.fitWidth,
                  child: Text("المادة",
                      style: TextStyle(fontWeight: FontWeight.bold))))),
    ]),
  ];

  for (var invoiceMaterialItem in invoiceItem.inoviceMaterialsItems) {
    widgets.add(SizedBox(height: 10));
    rows.add(TableRow(children: [
      Padding(
          padding: const EdgeInsets.all(4),
          child: Center(
              child: Column(children: [
            FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(
                    "${invoiceMaterialItem.quantity * invoiceMaterialItem.material.salePrice}",
                    textAlign: TextAlign.center)),
            FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(invoiceMaterialItem.material.currency,
                    textAlign: TextAlign.center))
          ]))),
      Padding(
          padding: const EdgeInsets.all(4),
          child: Center(
              child: Column(children: [
            FittedBox(
                fit: BoxFit.fitWidth,
                child: Text("${invoiceMaterialItem.quantity}",
                    textAlign: TextAlign.center)),
            FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(invoiceMaterialItem.material.unit,
                    textAlign: TextAlign.center))
          ]))),
      Padding(
          padding: const EdgeInsets.all(4),
          child: Center(
              child: Column(children: [
            FittedBox(
                fit: BoxFit.fitWidth,
                child: Text("${invoiceMaterialItem.material.salePrice}",
                    textAlign: TextAlign.center)),
            FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(invoiceMaterialItem.material.currency,
                    textAlign: TextAlign.center))
          ]))),
      Padding(
          padding: const EdgeInsets.all(4),
          child: Center(child: Text(invoiceMaterialItem.material.name))),
    ]));
    widgets.add(Table(
        border: TableBorder.all(color: PdfColors.black, width: 1),
        columnWidths: {
          0: const FlexColumnWidth(),
          1: const FlexColumnWidth(),
          2: const FlexColumnWidth(),
          3: const FlexColumnWidth(1.5),
        },
        children: rows));
    widgets.add(SizedBox(height: 10));
  }

  widgets.add(Divider());
  widgets.add(Directionality(
      textDirection: TextDirection.rtl,
      child: Text("بواسطة: ${mainController.currentUser.value!.name}")));
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
  await Printing.layoutPdf(
      onLayout: (PdfPageFormat format) async => await pdf.save());
}
