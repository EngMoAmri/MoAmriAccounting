class MyMaterial {
  int? id;
  final String name;
  final String barcode;
  final String category;
  final String unit;
  final String currency;
  final int quantity;
  final double costPrice;
  final double salePrice;
  final double discount;
  final double tax;
  final String? note;
  final int addedBy;
  final int updatedBy;
  final int createdDate;
  final int updatedDate;
  MyMaterial({
    this.id,
    required this.name,
    required this.barcode,
    required this.category,
    required this.unit,
    required this.currency,
    required this.quantity,
    required this.costPrice,
    required this.salePrice,
    required this.discount,
    required this.tax,
    required this.note,
    required this.addedBy,
    required this.updatedBy,
    required this.createdDate,
    required this.updatedDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'barcode': barcode,
      'category': category,
      'unit': unit,
      'currency': currency,
      'quantity': quantity,
      'cost_price': costPrice,
      'sale_price': salePrice,
      'discount': discount,
      'tax': tax,
      'note': note,
      'added_by': addedBy,
      'updated_by': updatedBy,
      'created_at': createdDate,
      'updated_at': updatedDate
    };
  }

  // get class object from map
  static MyMaterial fromMap(Map<String, dynamic> map) {
    return MyMaterial(
      id: map['id'] as int?,
      name: map['name'] as String,
      barcode: map['barcode'] as String,
      category: map['category'] as String,
      unit: map['unit'] as String,
      currency: map['currency'] as String,
      quantity: map['quantity'] as int,
      costPrice: map['cost_price'] as double,
      salePrice: map['sale_price'] as double,
      discount: map['discount'] as double,
      tax: map['tax'] as double,
      note: map['note'] as String?,
      addedBy: map['added_by'] as int,
      updatedBy: map['updated_by'] as int,
      createdDate: map['created_at'] as int,
      updatedDate: map['updated_at'] as int,
    );
  }
}
