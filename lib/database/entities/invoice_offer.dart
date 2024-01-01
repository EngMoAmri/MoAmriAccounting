class InvoiceOffer {
  int? id;
  int? invoiceId;
  final int offerId;
  final double quantity;
  final double price;

  InvoiceOffer({
    this.id,
    required this.invoiceId,
    required this.offerId,
    required this.quantity,
    required this.price,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoice_id': invoiceId,
      'offer_id': offerId,
      'quantity': quantity,
      'price': price,
    };
  }

  // get class object from map
  static InvoiceOffer fromMap(Map<String, dynamic> map) {
    return InvoiceOffer(
        id: map['id'] as int?,
        invoiceId: map['invoice_id'] as int,
        offerId: map['offer_id'] as int,
        quantity: map['quantity'] as double,
        price: map['price'] as double);
  }
}
