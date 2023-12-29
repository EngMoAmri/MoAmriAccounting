class InvoiceMaterial {
  int? id;
  final int invoiceId;
  final int materialId;
  final int quantity;

  InvoiceMaterial({
    this.id,
    required this.invoiceId,
    required this.materialId,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoice_id': invoiceId,
      'material_id': materialId,
      'count': quantity,
    };
  }

  // get class object from map
  static InvoiceMaterial fromMap(Map<String, dynamic> map) {
    return InvoiceMaterial(
        id: map['purchase_id'] as int?,
        invoiceId: map['product_id'] as int,
        materialId: map['offer_id'] as int,
        quantity: map['count'] as int);
  }
}
