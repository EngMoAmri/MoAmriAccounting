class MaterialLargerUnit {
  int? materialID;
  final int largerMaterialID;
  final int quantitySupplied;
  MaterialLargerUnit({
    this.materialID,
    required this.largerMaterialID,
    required this.quantitySupplied,
  });

  Map<String, dynamic> toMap() {
    return {
      'material_id': materialID,
      'larger_material_id': largerMaterialID,
      'quantity_supplied': quantitySupplied
    };
  }

  // get class object from map
  static MaterialLargerUnit fromMap(Map<String, dynamic> map) {
    return MaterialLargerUnit(
      materialID: map['material_id'] as int?,
      largerMaterialID: map['larger_material_id'] as int,
      quantitySupplied: map['quantity_supplied'] as int,
    );
  }
}
