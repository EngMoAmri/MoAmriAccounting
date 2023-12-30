import 'package:moamri_accounting/database/entities/invoice.dart';

import '../entities/audit.dart';
import '../entities/customer.dart';
import '../entities/debt.dart';
import '../entities/payment.dart';
import 'invoice_material_item.dart';
import 'invoice_offer_item.dart';

class InvoiceItem {
  final Invoice invoice;
  final List<Payment> payments;
  final List<Debt> debts;
  final Customer? customer;
  final List<InvoiceMaterialItem> inoviceMaterialsItems;
  final List<InvoiceOfferItem> invoiceOffersItems;
  InvoiceItem({
    required this.invoice,
    required this.payments,
    required this.debts,
    required this.customer,
    required this.inoviceMaterialsItems,
    required this.invoiceOffersItems,
  });
  Map<String, dynamic> toAuditMap() {
    Map<String, dynamic> auditMap = {
      'invoices': Audit.mapToString(invoice.toMap())
    };
    for (var invoiceMaterialItem in inoviceMaterialsItems) {
      auditMap['invoices_materials']
              ['${inoviceMaterialsItems.indexOf(invoiceMaterialItem)}'] =
          Audit.mapToString(invoiceMaterialItem.invoiceMaterial.toMap());
    }
    for (var invoiceOfferItem in invoiceOffersItems) {
      auditMap['invoices_offers']
              ['${invoiceOffersItems.indexOf(invoiceOfferItem)}'] =
          Audit.mapToString(invoiceOfferItem.invoiceOffer.toMap());
    }
    for (var payment in payments) {
      auditMap['payments']['${payments.indexOf(payment)}'] =
          Audit.mapToString(payment.toMap());
    }
    for (var debt in debts) {
      auditMap['debts']['${debts.indexOf(debt)}'] =
          Audit.mapToString(debt.toMap());
    }
    return auditMap;
  }
}
