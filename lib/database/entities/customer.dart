class Customer {
  int? id;
  final String name;
  final String address;
  final String phone;
  final String description;
  final int addedBy;
  final int updatedBy;
  final int createdDate;
  final int updatedDate;
  Customer({
    this.id,
    required this.name,
    required this.address,
    required this.phone,
    required this.description,
    required this.addedBy,
    required this.updatedBy,
    required this.createdDate,
    required this.updatedDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'address': address,
      'phone': phone,
      'description': description,
      'added_by': addedBy,
      'updated_by': updatedBy,
      'created_at': createdDate,
      'updated_at': updatedDate
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
      addedBy: map['added_by'] as int,
      updatedBy: map['updated_by'] as int,
      createdDate: map['created_at'] as int,
      updatedDate: map['updated_at'] as int,
    );
  }
}
