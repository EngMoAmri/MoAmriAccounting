class Currency {
  final String name;
  int? id; // this will be used with audits table
  final double
      exchangeRate; // this for the main currency which saved in store info
  Currency({
    required this.name,
    this.id,
    required this.exchangeRate,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'id': id,
      'exchange_rate': exchangeRate,
    };
  }

  // get class object from map
  static Currency fromMap(Map<String, dynamic> map) {
    return Currency(
      name: map['name'] as String,
      id: map['id'] as int?,
      exchangeRate: map['exchange_rate'] as double,
    );
  }
}
