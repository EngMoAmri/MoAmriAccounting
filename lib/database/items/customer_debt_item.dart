import 'package:moamri_accounting/database/entities/customer.dart';

class CustomerDebtItem {
  final Customer customer;
  final String
      debt; // this is in String coz the debts may contains differenet currencies

  CustomerDebtItem({required this.customer, required this.debt});
}
