class Currency {
  final String name;
  final double
      exchangeRate; // this for the main currency which saved in store info
  Currency({
    required this.name,
    required this.exchangeRate,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'exchange_rate': exchangeRate,
    };
  }

  // get class object from map
  static Currency fromMap(Map<String, dynamic> map) {
    return Currency(
      name: map['name'] as String,
      exchangeRate: map['exchange_rate'] as double,
    );
  }
}
