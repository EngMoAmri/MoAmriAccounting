class Payment {
  int? id;
  // here one of invoice_id of customerid must not be null
  int? invoiceId;
  final int? customerId;
  final int date;
  final double amount;
  final String currency;
  final String? note;

  Payment({
    this.id,
    this.invoiceId,
    this.customerId,
    required this.date,
    required this.amount,
    required this.currency,
    // TODO multiple currencies
    this.note,
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
  static Payment fromMap(Map<String, dynamic> map) {
    return Payment(
      id: map['id'] as int?,
      invoiceId: map['invoice_id'] as int?,
      customerId: map['customer_id'] as int?,
      date: map['date'] as int,
      amount: map['amount'] as double,
      note: map['note'] as String?,
    );
  }
}
