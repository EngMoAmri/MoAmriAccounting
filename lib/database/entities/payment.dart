class Payment {
  int? id;
  // here one of invoice_id of customerid must not be null
  int? invoiceId;
  final int? customerId;
  final int date;
  final double amount;
  // the same invoice can have multiple payments with differenet currencies
  final String currency;
  final double exchangeRate;
  final String? note;

  Payment({
    this.id,
    this.invoiceId,
    this.customerId,
    required this.date,
    required this.amount,
    required this.currency,
    required this.exchangeRate,
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
      'exchange_rate': exchangeRate,
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
      currency: map['currency'] as String,
      exchangeRate: map['exchange_rate'] as double,
      note: map['note'] as String?,
    );
  }
}
