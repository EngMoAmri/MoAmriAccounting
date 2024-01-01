import 'package:moamri_accounting/database/entities/my_material.dart';

class MyMaterialItem {
  final MyMaterial material;
  final MyMaterialItem? largerMaterial;

  MyMaterialItem({required this.material, required this.largerMaterial});
}
