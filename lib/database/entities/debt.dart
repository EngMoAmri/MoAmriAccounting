class Debt {
  int? id;
  // here one of purchaseid of customerid must not be null
  int? invoiceId;
  final int? customerId;
  final int date;
  final double amount;
  // the same invoice can have multiple payments with differenet currencies
  final String currency;
  final String? note;

  Debt({
    this.id,
    this.invoiceId,
    this.customerId,
    required this.date,
    required this.amount,
    required this.currency,
    required this.note,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'invoice_id': invoiceId,
      'customer_id': customerId,
      'date': date,
      'amount': amount,
      'currency': currency,
      'note': note,
    };
  }

  // get class object from map
  static Debt fromMap(Map<String, dynamic> map) {
    return Debt(
      id: map['id'] as int?,
      invoiceId: map['invoice_id'] as int?,
      customerId: map['customer_id'] as int?,
      date: map['date'] as int,
      amount: map['amount'] as double,
      currency: map['currency'] as String,
      note: map['note'] as String?,
    );
  }
}
