import 'package:moamri_accounting/database/entities/invoice_material.dart';
import 'package:moamri_accounting/database/entities/my_material.dart';

class InvoiceMaterialItem {
  final InvoiceMaterial invoiceMaterial;
  final MyMaterial material;
  final double quantity;

  InvoiceMaterialItem(
      {required this.invoiceMaterial,
      required this.material,
      required this.quantity});
}
