class InvoiceMaterial {
  int? id;
  int? invoiceId;
  final int materialId;
  final double quantity;

  InvoiceMaterial({
    this.id,
    this.invoiceId,
    required this.materialId,
    required this.quantity,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoice_id': invoiceId,
      'material_id': materialId,
      'quantity': quantity,
    };
  }

  // get class object from map
  static InvoiceMaterial fromMap(Map<String, dynamic> map) {
    return InvoiceMaterial(
        id: map['id'] as int?,
        invoiceId: map['invoice_id'] as int,
        materialId: map['material_id'] as int,
        quantity: map['quantity'] as double);
  }
}
