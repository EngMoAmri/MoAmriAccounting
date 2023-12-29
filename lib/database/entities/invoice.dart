class Invoice {
  int? id;
  final String type;
  final int? customerId;
  final double? discount;
  final String? note;
  Invoice(
      {this.id, this.customerId, required this.type, this.discount, this.note});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'type': type,
      'discount': discount,
      'note': note
    };
  }

  // get class object from map
  static Invoice fromMap(Map<String, dynamic> map) {
    return Invoice(
        id: map['id'] as int?,
        customerId: map['customer_id'] as int?,
        type: map['type'] as String,
        discount: map['discount'] as double?,
        note: map['note'] as String?);
  }
}
