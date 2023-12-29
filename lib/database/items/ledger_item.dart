import 'package:moamri_accounting/database/entities/invoice.dart';
import 'package:moamri_accounting/database/entities/invoice_material.dart';
import 'package:moamri_accounting/database/entities/invoice_offer.dart';

import '../entities/customer.dart';
import '../entities/debt.dart';
import '../entities/payment.dart';

class LedgerItem {
  final Invoice invoice;
  final Payment? payment;
  final Debt? debt;
  final Customer? customer;
  final List<InvoiceMaterial> inoviceMaterials;
  final List<InvoiceOffer> invoiceOffers;
  LedgerItem({
    required this.invoice,
    required this.payment,
    required this.debt,
    required this.customer,
    required this.inoviceMaterials,
    required this.invoiceOffers,
  });
}
