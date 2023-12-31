class Invoice {
  int? id;
  final String type;
  final int? customerId;
  final int date;
  final double? discount; // this will be with the main currency
  final double total; // this will be with the main currency
  final String? note;
  Invoice(
      {this.id,
      this.customerId,
      required this.date,
      required this.type,
      this.discount,
      required this.total,
      this.note});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer_id': customerId,
      'type': type,
      'discount': discount,
      'total': total,
      'date': date,
      'note': note
    };
  }

  // get class object from map
  static Invoice fromMap(Map<String, dynamic> map) {
    return Invoice(
        id: map['id'] as int?,
        customerId: map['customer_id'] as int?,
        date: map['date'] as int,
        type: map['type'] as String,
        discount: map['discount'] as double?,
        total: map['total'] as double,
        note: map['note'] as String?);
  }
}
