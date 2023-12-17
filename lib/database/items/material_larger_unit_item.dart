import 'package:moamri_accounting/database/entities/my_material.dart';

class MaterialLargerUnitItem {
  final MyMaterial material;
  final MyMaterial largerMaterial;
  final int suppliedQuantity;
  MaterialLargerUnitItem(
      {required this.material,
      required this.largerMaterial,
      required this.suppliedQuantity});
}
