class InvoiceOffer {
  int? id;
  int? invoiceId;
  final int offerId;
  final double quantity;

  InvoiceOffer({
    this.id,
    required this.invoiceId,
    required this.offerId,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoice_id': invoiceId,
      'offer_id': offerId,
      'quantity': quantity,
    };
  }

  // get class object from map
  static InvoiceOffer fromMap(Map<String, dynamic> map) {
    return InvoiceOffer(
        id: map['id'] as int?,
        invoiceId: map['invoice_id'] as int,
        offerId: map['offer_id'] as int,
        quantity: map['quantity'] as double);
  }
}
