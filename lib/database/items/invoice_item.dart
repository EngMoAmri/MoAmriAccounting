import 'package:moamri_accounting/database/entities/invoice.dart';
import 'package:moamri_accounting/database/entities/invoice_material.dart';
import 'package:moamri_accounting/database/entities/invoice_offer.dart';

import '../entities/audit.dart';
import '../entities/customer.dart';
import '../entities/debt.dart';
import '../entities/payment.dart';

class InvoiceItem {
  final Invoice invoice;
  final List<Payment> payments;
  final List<Debt> debts;
  final Customer? customer;
  final List<InvoiceMaterial> inoviceMaterials;
  final List<InvoiceOffer> invoiceOffers;
  InvoiceItem({
    required this.invoice,
    required this.payments,
    required this.debts,
    required this.customer,
    required this.inoviceMaterials,
    required this.invoiceOffers,
  });
  Map<String, dynamic> toAuditMap() {
    Map<String, dynamic> auditMap = {
      'invoices': Audit.mapToString(invoice.toMap())
    };
    for (var invoiceMaterial in inoviceMaterials) {
      auditMap['invoices_materials']
              ['${inoviceMaterials.indexOf(invoiceMaterial)}'] =
          Audit.mapToString(invoiceMaterial.toMap());
    }
    for (var invoiceOffer in invoiceOffers) {
      auditMap['invoices_offers']['${invoiceOffers.indexOf(invoiceOffer)}'] =
          Audit.mapToString(invoiceOffer.toMap());
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
