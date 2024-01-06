class Debt {
  int? id;
  // here one of purchaseid of customerid must not be null
  int? invoiceId;
  final int customerId;
  final int date;
  final double amount;
  final String? note;

  Debt({
    this.id,
    this.invoiceId,
    required this.customerId,
    required this.date,
    required this.amount,
    required this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoice_id': invoiceId,
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
      invoiceId: map['invoice_id'] as int?,
      customerId: map['customer_id'] as int,
      date: map['date'] as int,
      amount: map['amount'] as double,
      note: map['note'] as String?,
    );
  }
}
