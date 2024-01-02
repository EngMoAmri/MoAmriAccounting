class MyMaterial {
  int? id;
  final String name;
  final String barcode;
  final String category;
  final String unit;
  final String currency;
  double quantity;
  final double costPrice;
  final double salePrice;
  final String? note;
  final int? largerMaterialID;
  final double? quantitySupplied;

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
    required this.note,
    this.largerMaterialID,
    this.quantitySupplied,
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
      'note': note,
      'larger_material_id': largerMaterialID,
      'larger_quantity_supplied': quantitySupplied
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
      quantity: map['quantity'] as double,
      costPrice: map['cost_price'] as double,
      salePrice: map['sale_price'] as double,
      note: map['note'] as String?,
      largerMaterialID: map['larger_material_id'] as int?,
      quantitySupplied: map['larger_quantity_supplied'] as double?,
    );
  }
}
