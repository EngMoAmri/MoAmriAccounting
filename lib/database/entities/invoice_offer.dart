class InvoiceOffer {
  int? id;
  final int invoiceId;
  final int offerId;
  final int quantity;

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
      'count': quantity,
    };
  }

  // get class object from map
  static InvoiceOffer fromMap(Map<String, dynamic> map) {
    return InvoiceOffer(
        id: map['purchase_id'] as int?,
        invoiceId: map['product_id'] as int,
        offerId: map['offer_id'] as int,
        quantity: map['count'] as int);
  }
}
