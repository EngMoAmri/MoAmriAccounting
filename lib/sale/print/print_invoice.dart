import 'dart:io';
import 'package:flutter/services.dart';
import 'package:moamri_accounting/controllers/main_controller.dart';
import 'package:moamri_accounting/database/items/invoice_item.dart';
import 'package:pdf/pdf.dart';
import 'package:printing/printing.dart';
import 'package:pdf/widgets.dart';

import '../../utils/global_utils.dart';

// TODO write exchange if there is different currencies
Future<dynamic> printInvoiceRoll(
    MainController mainController, InvoiceItem invoiceItem) async {
  final Document pdf = Document(
      deflate: zlib.encode,
      theme: ThemeData.withFont(
          base:
              Font.ttf(await rootBundle.load("assets/fonts/Hacen-Tunisia.ttf")),
          bold: Font.ttf(
              await rootBundle.load("assets/fonts/Hacen Tunisia Bold.ttf"))));
  List<Widget> widgets = [];
  widgets.add(Center(
      child: Text("فاتورة مبيعات",
          style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold))));
  widgets.add(Center(
      child: Text("${invoiceItem.invoice.id!}",
          style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold))));
  widgets.add(SizedBox(height: 4));
  widgets.add(Center(
      child: Text(mainController.storeData.value!.name,
          style: TextStyle(fontWeight: FontWeight.bold))));
  widgets.add(Center(child: Text(mainController.storeData.value!.branch)));
  widgets.add(SizedBox(height: 4));
  widgets.add(Center(child: Text(mainController.storeData.value!.phone)));
  widgets.add(SizedBox(height: 4));
  widgets.add(Center(child: Text(mainController.storeData.value!.address)));
  widgets.add(Center(child: Divider()));

  if (invoiceItem.customer != null) {
    widgets.add(Center(child: Text("العميل")));
    widgets.add(SizedBox(height: 4));
    widgets.add(Center(child: Text(invoiceItem.customer!.name)));
    widgets.add(SizedBox(height: 4));
    widgets.add(Center(child: Text(invoiceItem.customer!.phone)));
    widgets.add(Center(child: Divider()));
  }
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
                  child: Text(GlobalUtils.dateFormat.format(
                      DateTime.fromMillisecondsSinceEpoch(
                          invoiceItem.invoice.date)))),
              Text("التاريخ"),
            ]),
            TableRow(children: [
              Center(
                  child: Text(GlobalUtils.timeFormat.format(
                      DateTime.fromMillisecondsSinceEpoch(
                          invoiceItem.invoice.date)))),
              Text("الوقت"),
            ]),
            TableRow(children: [
              Center(
                  child: Text(
                      invoiceItem.inoviceMaterialsItems.length.toString())),
              Text("عدد المواد"),
            ]),
          ])));
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
    rows.add(TableRow(children: [
      Padding(
          padding: const EdgeInsets.all(4),
          child: Center(
              child: Column(children: [
            FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(
                    GlobalUtils.getMoney(
                        invoiceMaterialItem.invoiceMaterial.quantity *
                            invoiceMaterialItem.material.salePrice),
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
                child: Text("${invoiceMaterialItem.invoiceMaterial.quantity} ",
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
                child: Text(
                    GlobalUtils.getMoney(
                        invoiceMaterialItem.material.salePrice),
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
  }
  // TODO offers
  widgets.add(Table(
      border: TableBorder.all(color: PdfColors.black, width: 1),
      columnWidths: {
        0: const FlexColumnWidth(),
        1: const FlexColumnWidth(),
        2: const FlexColumnWidth(),
        3: const FlexColumnWidth(1.5),
      },
      children: rows));
  // TODO make sure to get the price from audit table if the invoice is old
  widgets.add(Center(child: Text("الأجمالي")));
  Map<String, double> currenciesTotals = {};
  for (var materialItem in invoiceItem.inoviceMaterialsItems) {
    var material = materialItem.material;
    currenciesTotals[material.currency] =
        (currenciesTotals[material.currency] ?? 0.0) +
            (materialItem.material.salePrice *
                materialItem.invoiceMaterial.quantity);
  }
  double totalInMainCurrency = 0;
  for (var currency in currenciesTotals.keys) {
    double rateExchange = 0.0;
    for (var currency2 in mainController.currencies.value) {
      if (currency2.name == currency) {
        rateExchange = currency2.exchangeRate;
        break;
      }
    }
    totalInMainCurrency += rateExchange * currenciesTotals[currency]!;
  }

  for (var currency in currenciesTotals.keys) {
    widgets.add(Row(children: [
      Expanded(child: Text(GlobalUtils.getMoney(currenciesTotals[currency]))),
      Text(currency),
      SizedBox(width: 10)
    ]));
  }
  if (currenciesTotals.length > 1) {
    widgets.add(Center(
        child: Text(
            "الأجمالي بالعملة ${mainController.storeData.value!.currency}")));
    widgets.add(Row(children: [
      Expanded(child: Text(GlobalUtils.getMoney(totalInMainCurrency))),
      Text(mainController.storeData.value!.currency),
      SizedBox(width: 10)
    ]));
  }
  if ((invoiceItem.invoice.discount ?? 0.0) > 0) {
    widgets.add(Center(child: Text("الخصم")));
    widgets.add(Row(children: [
      Expanded(
          child: Text(GlobalUtils.getMoney(invoiceItem.invoice.discount!))),
      Text(mainController.storeData.value!.currency),
      SizedBox(width: 10)
    ]));
    widgets.add(Center(child: Text("الأجمالي بعد الخصم")));
    widgets.add(Row(children: [
      Expanded(
          child: Text(GlobalUtils.getMoney(
              totalInMainCurrency - invoiceItem.invoice.discount!))),
      Text(mainController.storeData.value!.currency),
      SizedBox(width: 10)
    ]));
  }
  double totalPaymentInMainCurrency = 0.0;
  if (invoiceItem.payments.isNotEmpty) {
    widgets.add(Center(child: Text("المبلغ المدفوع")));

    for (var payment in invoiceItem.payments) {
      widgets.add(Row(children: [
        Expanded(child: Text(GlobalUtils.getMoney(payment.amount))),
        Text(payment.currency),
        SizedBox(width: 10)
      ]));
      double rateExchange = 0.0;
      for (var currency2 in mainController.currencies.value) {
        if (currency2.name == payment.currency) {
          rateExchange = currency2.exchangeRate;
          break;
        }
      }
      totalPaymentInMainCurrency += (payment.amount * rateExchange);
    }
  }
  if ((totalPaymentInMainCurrency - totalInMainCurrency) > 0) {
    widgets.add(Center(child: Text("المبلغ المرتجع للعميل")));

    widgets.add(Row(children: [
      Expanded(
          child: Text(GlobalUtils.getMoney(
              totalPaymentInMainCurrency - totalInMainCurrency))),
      Text(mainController.storeData.value!.currency),
      SizedBox(width: 10)
    ]));
  }
  if (invoiceItem.debt != null) {
    widgets.add(Center(child: Text("الدين المتبقي")));

    widgets.add(Row(children: [
      Expanded(child: Text(GlobalUtils.getMoney(invoiceItem.debt!.amount))),
      Text(mainController.storeData.value!.currency),
      SizedBox(width: 10)
    ]));
  }
  if (invoiceItem.invoice.note != null) {
    widgets.add(Divider());
    widgets.add(Center(child: Text("ملاحظة")));
    widgets.add(Center(child: Text(invoiceItem.invoice.note!)));
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
  // final img = await rootBundle.load('assets/images/customers.png');TODO
  // final imageBytes = img.buffer.asUint8List();
  // PdfImage logoImage = PdfImage.file(pdf.document, bytes: imageBytes);
  List<Widget> widgets = [];
  widgets.add(Center(
      child: Directionality(
          textDirection: TextDirection.rtl,
          child: Text("فاتورة مبيعات",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)))));
  widgets.add(Center(
      child: Directionality(
          textDirection: TextDirection.rtl,
          child: Text("${invoiceItem.invoice.id!}",
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)))));
  widgets.add(SizedBox(height: 4));
  widgets.add(Directionality(
      textDirection: TextDirection.rtl,
      child: Center(
          child: Text(mainController.storeData.value!.name,
              style: TextStyle(fontWeight: FontWeight.bold)))));
  widgets.add(Center(child: Divider()));
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
                  child: Text(
                      invoiceItem.inoviceMaterialsItems.length.toString())),
              Text("عدد المواد", style: TextStyle(fontWeight: FontWeight.bold)),
              Center(
                  child: Text(GlobalUtils.timeFormat.format(
                      DateTime.fromMillisecondsSinceEpoch(
                          invoiceItem.invoice.date)))),
              Text("الوقت", style: TextStyle(fontWeight: FontWeight.bold)),
              Center(
                  child: Text(GlobalUtils.dateFormat.format(
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
    rows.add(TableRow(children: [
      Padding(
          padding: const EdgeInsets.all(4),
          child: Center(
              child: Column(children: [
            FittedBox(
                fit: BoxFit.fitWidth,
                child: Text(
                    GlobalUtils.getMoney(
                        invoiceMaterialItem.invoiceMaterial.quantity *
                            invoiceMaterialItem.material.salePrice),
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
                child: Text("${invoiceMaterialItem.invoiceMaterial.quantity} ",
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
                child: Text(
                    GlobalUtils.getMoney(
                        invoiceMaterialItem.material.salePrice),
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
  }
  // TODO offers
  widgets.add(Directionality(
      textDirection: TextDirection.rtl,
      child: Table(
          border: TableBorder.all(color: PdfColors.black, width: 1),
          columnWidths: {
            0: const FlexColumnWidth(),
            1: const FlexColumnWidth(),
            2: const FlexColumnWidth(),
            3: const FlexColumnWidth(1.5),
          },
          children: rows)));
  // TODO make sure to get the price from audit table if the invoice is old
  widgets.add(Center(
      child: Directionality(
          textDirection: TextDirection.rtl, child: Text("الأجمالي"))));
  Map<String, double> currenciesTotals = {};
  for (var materialItem in invoiceItem.inoviceMaterialsItems) {
    var material = materialItem.material;
    currenciesTotals[material.currency] =
        (currenciesTotals[material.currency] ?? 0.0) +
            (materialItem.material.salePrice *
                materialItem.invoiceMaterial.quantity);
  }
  double totalInMainCurrency = 0;
  for (var currency in currenciesTotals.keys) {
    double rateExchange = 0.0;
    for (var currency2 in mainController.currencies.value) {
      if (currency2.name == currency) {
        rateExchange = currency2.exchangeRate;
        break;
      }
    }
    totalInMainCurrency += rateExchange * currenciesTotals[currency]!;
  }

  for (var currency in currenciesTotals.keys) {
    widgets.add(Row(children: [
      SizedBox(width: 10),
      Directionality(textDirection: TextDirection.rtl, child: Text(currency)),
      Expanded(child: Text(GlobalUtils.getMoney(currenciesTotals[currency]))),
    ]));
  }
  if (currenciesTotals.length > 1) {
    widgets.add(Center(
        child: Directionality(
            textDirection: TextDirection.rtl,
            child: Text(
                "الأجمالي بالعملة ${mainController.storeData.value!.currency}"))));
    widgets.add(Row(children: [
      SizedBox(width: 10),
      Directionality(
          textDirection: TextDirection.rtl,
          child: Text(mainController.storeData.value!.currency)),
      Expanded(child: Text(GlobalUtils.getMoney(totalInMainCurrency))),
    ]));
  }
  if ((invoiceItem.invoice.discount ?? 0.0) > 0) {
    widgets.add(Center(
        child: Directionality(
            textDirection: TextDirection.rtl, child: Text("الخصم"))));
    widgets.add(Row(children: [
      SizedBox(width: 10),
      Directionality(
          textDirection: TextDirection.rtl,
          child: Text(mainController.storeData.value!.currency)),
      Expanded(
          child: Text(GlobalUtils.getMoney(invoiceItem.invoice.discount!))),
    ]));
    widgets.add(Center(
        child: Directionality(
            textDirection: TextDirection.rtl,
            child: Text("الأجمالي بعد الخصم"))));
    widgets.add(Row(children: [
      SizedBox(width: 10),
      Directionality(
          textDirection: TextDirection.rtl,
          child: Text(mainController.storeData.value!.currency)),
      Expanded(
          child: Text(GlobalUtils.getMoney(
              totalInMainCurrency - invoiceItem.invoice.discount!))),
    ]));
  }
  double totalPaymentInMainCurrency = 0.0;
  if (invoiceItem.payments.isNotEmpty) {
    widgets.add(Center(
        child: Directionality(
            textDirection: TextDirection.rtl, child: Text("المبلغ المدفوع"))));

    for (var payment in invoiceItem.payments) {
      widgets.add(Row(children: [
        SizedBox(width: 10),
        Directionality(
            textDirection: TextDirection.rtl, child: Text(payment.currency)),
        Expanded(child: Text(GlobalUtils.getMoney(payment.amount))),
      ]));
      double rateExchange = 0.0;
      for (var currency2 in mainController.currencies.value) {
        if (currency2.name == payment.currency) {
          rateExchange = currency2.exchangeRate;
          break;
        }
      }
      totalPaymentInMainCurrency += (payment.amount * rateExchange);
    }
  }
  if ((totalPaymentInMainCurrency - totalInMainCurrency) > 0) {
    widgets.add(Center(
        child: Directionality(
            textDirection: TextDirection.rtl,
            child: Text("المبلغ المرتجع للعميل"))));

    widgets.add(Row(children: [
      SizedBox(width: 10),
      Directionality(
          textDirection: TextDirection.rtl,
          child: Text(mainController.storeData.value!.currency)),
      Expanded(
          child: Text(GlobalUtils.getMoney(
              totalPaymentInMainCurrency - totalInMainCurrency))),
    ]));
  }
  if (invoiceItem.debt != null) {
    widgets.add(Directionality(
        textDirection: TextDirection.rtl,
        child: Center(child: Text("الدين المتبقي"))));

    widgets.add(Row(children: [
      SizedBox(width: 10),
      Directionality(
          textDirection: TextDirection.rtl,
          child: Text(mainController.storeData.value!.currency)),
      Expanded(child: Text(GlobalUtils.getMoney(invoiceItem.debt!.amount))),
    ]));
  }
  if (invoiceItem.invoice.note != null) {
    widgets.add(Divider());
    widgets.add(Directionality(
        textDirection: TextDirection.rtl,
        child: Center(child: Text("ملاحظة"))));
    widgets.add(Directionality(
        textDirection: TextDirection.rtl,
        child: Center(child: Text(invoiceItem.invoice.note!))));
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
