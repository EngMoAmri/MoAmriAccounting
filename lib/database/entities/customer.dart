class Customer {
  int? id;
  final String name;
  final String address;
  final String phone;
  final String description;
  Customer({
    this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.description,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'description': description
    };
  }

  // get class object from map
  static Customer fromMap(Map<String, dynamic> map) {
    return Customer(
      id: map['id'] as int?,
      name: map['name'] as String,
      address: map['address'] as String,
      phone: map['phone'] as String,
      description: map['description'] as String,
    );
  }
}
