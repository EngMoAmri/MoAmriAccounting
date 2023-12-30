import 'package:moamri_accounting/database/entities/invoice_offer.dart';

class InvoiceOfferItem {
  final InvoiceOffer invoiceOffer;
  final InvoiceOffer offer; // TODO change this
  final double quantity;

  InvoiceOfferItem(
      {required this.invoiceOffer,
      required this.offer,
      required this.quantity});
}
