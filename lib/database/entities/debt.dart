class Debt {
  int? id;
  // here one of purchaseid of customerid must not be null
  int? purchaseId;
  final int? customerId;
  final int date;
  final double amount;
  final String? note;

  Debt({
    this.id,
    this.purchaseId,
    this.customerId,
    required this.date,
    required this.amount,
    this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'purchase_id': purchaseId,
      'customer_id': customerId,
      'date': date,
      'amount': amount,
      'note': note,
    };
  }

  // get class object from map
  static Debt fromMap(Map<String, dynamic> map) {
    return Debt(
      id: map['id'] as int?,
      purchaseId: map['purchase_id'] as int?,
      customerId: map['customer_id'] as int?,
      date: map['date'] as int,
      amount: map['amount'] as double,
      note: map['note'] as String?,
    );
  }
}
