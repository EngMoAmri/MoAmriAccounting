class InvoiceMaterial {
  int? id;
  int? invoiceId;
  final int materialId;
  final double quantity;
  final double price;
  final String? note;

  InvoiceMaterial({
    this.id,
    this.invoiceId,
    required this.materialId,
    required this.quantity,
    required this.price,
    required this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoice_id': invoiceId,
      'material_id': materialId,
      'quantity': quantity,
      'price': price,
      'note': note,
    };
  }

  // get class object from map
  static InvoiceMaterial fromMap(Map<String, dynamic> map) {
    return InvoiceMaterial(
      id: map['id'] as int?,
      invoiceId: map['invoice_id'] as int,
      materialId: map['material_id'] as int,
      quantity: map['quantity'] as double,
      price: map['price'] as double,
      note: map['note'] as String,
    );
  }
}
