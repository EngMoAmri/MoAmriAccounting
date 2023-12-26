import 'dart:typed_data';

class Store {
  int? id;
  final String name;
  final String branch;
  final Uint8List? image;
  final String address;
  final String phone;
  final String currency;
  final int updatedDate;
  Store({
    this.id,
    required this.name,
    required this.branch,
    this.image,
    required this.address,
    required this.phone,
    required this.currency,
    required this.updatedDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'branch': branch,
      'image': image,
      'address': address,
      'phone': phone,
      'currency': currency,
      'updated_at': updatedDate
    };
  }

  // get class object from map
  static Store fromMap(Map<String, dynamic> map) {
    return Store(
      id: map['id'] as int?,
      name: map['name'] as String,
      branch: map['branch'] as String,
      image: map['image'] as Uint8List?,
      address: map['address'] as String,
      phone: map['phone'] as String,
      currency: map['currency'] as String,
      updatedDate: map['updated_at'] as int,
    );
  }
}
