// import 'package:flutter/material.dart';
// import 'package:flutter_typeahead/flutter_typeahead.dart';
// import 'package:get/get.dart';
// import 'package:moamri_accounting/controllers/main_controller.dart';
// import 'package:moamri_accounting/customers/dialogs/add_customer_dialog.dart';
// import 'package:moamri_accounting/database/customers_database.dart';
// import 'package:moamri_accounting/sale/controllers/sale_controller.dart';

// import '../../database/entities/customer.dart';

// Future<bool?> showSaleDialog(
//     MainController mainController, SaleController saleController) async {
//   return await showDialog(
//       context: Get.context!,
//       builder: (BuildContext context) {
//         final formKey = GlobalKey<FormState>();
//         final customerTextController = TextEditingController();
//         Customer? selectedCustomer;
//         final discountTextController = TextEditingController();

//         return Dialog(
//             shape: RoundedRectangleBorder(
//                 borderRadius: BorderRadius.circular(12.0)),
//             child: ConstrainedBox(
//               constraints: const BoxConstraints(maxWidth: 800),
//               child: StatefulBuilder(builder: (context, setState) {
//                 return FocusTraversalGroup(
//                   policy: WidgetOrderTraversalPolicy(),
//                   child: Padding(
//                     padding: const EdgeInsets.symmetric(
//                         vertical: 16.0, horizontal: 32.0),
//                     child: Obx(() => Form(
//                           key: formKey,
//                           child: Column(
//                             mainAxisSize: MainAxisSize.min,
//                             children: [
//                               Row(
//                                 children: [
//                                   const SizedBox(
//                                     width: 20,
//                                   ),
//                                   Expanded(
//                                     child: Text(
//                                       "Sale",
//                                       style: TextStyle(
//                                           color: Colors.black,
//                                           fontWeight: FontWeight.bold),
//                                     ),
//                                   ),
//                                   Padding(
//                                     padding:
//                                         const EdgeInsets.fromLTRB(20, 0, 20, 0),
//                                     child: IconButton(
//                                       onPressed: () {
//                                         Get.back();
//                                       },
//                                       icon: const Icon(
//                                         Icons.close,
//                                         color: Colors.red,
//                                       ),
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const Divider(height: 1),
//                               Row(
//                                 children: [
//                                   Expanded(
//                                     child: Column(
//                                       children: [
//                                         // const SizedBox(
//                                         //   height: 10,
//                                         // ),
//                                         Padding(
//                                           padding: const EdgeInsets.all(8),
//                                           child: Row(
//                                             children: [
//                                               Expanded(
//                                                 child: Padding(
//                                                   padding: const EdgeInsets
//                                                       .symmetric(
//                                                       horizontal: 10),
//                                                   child: TypeAheadField(
//                                                     controller:
//                                                         customerTextController,
//                                                     emptyBuilder: (context) =>
//                                                         Container(
//                                                       height: 0,
//                                                     ),
//                                                     onSelected: (value) {
//                                                       setState(() {
//                                                         customerTextController
//                                                                 .text =
//                                                             '${value.name} / Phone: ${value.phone}';
//                                                         selectedCustomer =
//                                                             value;
//                                                       });
//                                                     },
//                                                     suggestionsCallback:
//                                                         (String pattern) async {
//                                                       return await CustomersDatabase
//                                                           .getSearchedCustomers(
//                                                               0, pattern);
//                                                     },
//                                                     itemBuilder:
//                                                         (context, suggestion) {
//                                                       return ListTile(
//                                                         title: Text(
//                                                             '${suggestion.name} / Phone: ${suggestion.phone}'),
//                                                       );
//                                                     },
//                                                     builder: (context,
//                                                         controller, focusNode) {
//                                                       return TextFormField(
//                                                         textCapitalization:
//                                                             TextCapitalization
//                                                                 .sentences,
//                                                         controller:
//                                                             customerTextController,
//                                                         focusNode: focusNode,
//                                                         decoration:
//                                                             InputDecoration(
//                                                           filled: true,
//                                                           fillColor:
//                                                               Colors.white,
//                                                           isDense: true,
//                                                           contentPadding:
//                                                               const EdgeInsets
//                                                                   .all(10),
//                                                           focusedBorder:
//                                                               OutlineInputBorder(
//                                                             borderSide:
//                                                                 const BorderSide(
//                                                                     color: Colors
//                                                                         .green),
//                                                             borderRadius:
//                                                                 BorderRadius
//                                                                     .circular(
//                                                                         8),
//                                                           ),
//                                                           border:
//                                                               const OutlineInputBorder(
//                                                             borderRadius:
//                                                                 BorderRadius
//                                                                     .all(Radius
//                                                                         .circular(
//                                                                             8.0)),
//                                                           ),
//                                                           counterText: "",
//                                                           labelText: 'Customer',
//                                                         ),
//                                                         keyboardType:
//                                                             TextInputType.text,
//                                                       );
//                                                     },
//                                                   ),
//                                                 ),
//                                               ),
//                                               OutlinedButton.icon(
//                                                   style: ButtonStyle(
//                                                       shape: MaterialStateProperty
//                                                           .all(
//                                                               RoundedRectangleBorder(
//                                                         borderRadius:
//                                                             BorderRadius
//                                                                 .circular(12.0),
//                                                       )),
//                                                       foregroundColor:
//                                                           MaterialStateProperty
//                                                               .all(
//                                                                   Colors.blue)),
//                                                   onPressed: () async {
//                                                     showAddCustomerDialog(
//                                                         mainController);
//                                                   },
//                                                   icon: const Icon(Icons.add),
//                                                   label: Text('Add New'.tr)),
//                                             ],
//                                           ),
//                                         ),
//                                         const SizedBox(
//                                           height: 10,
//                                         ),
//                                         Table(
//                                             border: TableBorder.all(
//                                                 color: Colors.black,
//                                                 width: 1,
//                                                 borderRadius:
//                                                     const BorderRadius.all(
//                                                         Radius.circular(10))),
//                                             children: [
//                                               const TableRow(children: [
//                                                 Padding(
//                                                     padding: EdgeInsets.all(4),
//                                                     child: Center(
//                                                         child: FittedBox(
//                                                             fit:
//                                                                 BoxFit.fitWidth,
//                                                             child: Text(
//                                                                 "Debt Amount",
//                                                                 style: TextStyle(
//                                                                     fontWeight:
//                                                                         FontWeight
//                                                                             .bold))))),
//                                               ]),
//                                               TableRow(children: [
//                                                 Padding(
//                                                     padding:
//                                                         const EdgeInsets.all(4),
//                                                     child: Center(
//                                                         child:
//                                                             Column(children: [
//                                                       FittedBox(
//                                                           fit: BoxFit.fitWidth,
//                                                           child: Text(
//                                                               (selectedCustomer
//                                                                           ?.accountBalance ??
//                                                                       0.0)
//                                                                   .toStringAsFixed(
//                                                                       2),
//                                                               textAlign:
//                                                                   TextAlign
//                                                                       .center)),
//                                                       FittedBox(
//                                                           fit: BoxFit.fitWidth,
//                                                           child: Text(
//                                                               mainController
//                                                                   .storeData
//                                                                   .value!
//                                                                 ..currency,
//                                                               textAlign:
//                                                                   TextAlign
//                                                                       .center))
//                                                     ]))),
//                                               ]),
//                                             ]),
//                                       ],
//                                     ),
//                                   ),
//                                   const SizedBox(
//                                     width: 10,
//                                   ),
//                                   Expanded(
//                                       child: Column(
//                                     children: [
//                                       Padding(
//                                         padding: const EdgeInsets.all(8),
//                                         child: Row(
//                                           children: [
//                                             Expanded(
//                                               child: Padding(
//                                                   padding: const EdgeInsets
//                                                       .symmetric(
//                                                       horizontal: 10),
//                                                   child: TextFormField(
//                                                     textCapitalization:
//                                                         TextCapitalization
//                                                             .sentences,
//                                                     controller:
//                                                         discountTextController,
//                                                     decoration: InputDecoration(
//                                                       filled: true,
//                                                       fillColor: Colors.white,
//                                                       isDense: true,
//                                                       contentPadding:
//                                                           const EdgeInsets.all(
//                                                               10),
//                                                       focusedBorder:
//                                                           OutlineInputBorder(
//                                                         borderSide:
//                                                             const BorderSide(
//                                                                 color: Colors
//                                                                     .green),
//                                                         borderRadius:
//                                                             BorderRadius
//                                                                 .circular(8),
//                                                       ),
//                                                       border:
//                                                           const OutlineInputBorder(
//                                                         borderRadius:
//                                                             BorderRadius.all(
//                                                                 Radius.circular(
//                                                                     8.0)),
//                                                       ),
//                                                       counterText: "",
//                                                       labelText: 'Discount',
//                                                     ),
//                                                     keyboardType:
//                                                         TextInputType.text,
//                                                   )),
//                                             ),
//                                           ],
//                                         ),
//                                       ),
//                                     ],
//                                   ))
//                                 ],
//                               ),
//                               const Divider(),
//                               Row(
//                                 mainAxisAlignment:
//                                     MainAxisAlignment.spaceBetween,
//                                 children: [
//                                   Expanded(
//                                     child: Table(
//                                         border: TableBorder.all(
//                                             color: Colors.black,
//                                             width: 1,
//                                             borderRadius:
//                                                 const BorderRadius.all(
//                                                     Radius.circular(10))),
//                                         children: [
//                                           const TableRow(children: [
//                                             Padding(
//                                                 padding: EdgeInsets.all(4),
//                                                 child: Center(
//                                                     child: FittedBox(
//                                                         fit: BoxFit.fitWidth,
//                                                         child: Text("Total",
//                                                             style: TextStyle(
//                                                                 fontWeight:
//                                                                     FontWeight
//                                                                         .bold))))),
//                                           ]),
//                                           TableRow(children: [
//                                             Padding(
//                                                 padding:
//                                                     const EdgeInsets.all(4),
//                                                 child: Center(
//                                                     child: Column(children: [
//                                                   FittedBox(
//                                                       fit: BoxFit.fitWidth,
//                                                       child: Text(
//                                                           (saleController.materialDialogQuantity
//                                                                           .value *
//                                                                       material
//                                                                           .salePrice +
//                                                                   saleController
//                                                                           .materialDialogQuantity
//                                                                           .value *
//                                                                       (saleController
//                                                                               .materialDialogTax
//                                                                               .value /
//                                                                           100) *
//                                                                       material
//                                                                           .salePrice)
//                                                               .toStringAsFixed(
//                                                                   2),
//                                                           textAlign: TextAlign
//                                                               .center)),
//                                                   FittedBox(
//                                                       fit: BoxFit.fitWidth,
//                                                       child: Text(
//                                                           material.currency,
//                                                           textAlign:
//                                                               TextAlign.center))
//                                                 ]))),
//                                           ]),
//                                         ]),
//                                   ),
//                                   Expanded(
//                                     flex: 2,
//                                     child: Column(
//                                       crossAxisAlignment:
//                                           CrossAxisAlignment.end,
//                                       children: [
//                                         Row(
//                                           children: [
//                                             Expanded(
//                                                 flex: 2, child: Container()),
//                                             Expanded(
//                                               child: OutlinedButton.icon(
//                                                   onPressed: () async {
//                                                     if (saleController
//                                                         .materialDialogFormKey
//                                                         .currentState!
//                                                         .validate()) {
//                                                       saleData['Quantity'] =
//                                                           saleController
//                                                               .materialDialogQuantity
//                                                               .value;
//                                                       saleData[
//                                                           'Tax'] = (saleController
//                                                               .materialDialogTaxTextController
//                                                               .text
//                                                               .isEmpty)
//                                                           ? null
//                                                           : saleController
//                                                               .materialDialogTax
//                                                               .value;
//                                                       saleData[
//                                                           'Total'] = saleController
//                                                                   .materialDialogQuantity
//                                                                   .value *
//                                                               material
//                                                                   .salePrice +
//                                                           saleController
//                                                                   .materialDialogQuantity
//                                                                   .value *
//                                                               (saleController
//                                                                       .materialDialogTax
//                                                                       .value /
//                                                                   100) *
//                                                               material
//                                                                   .salePrice;
//                                                       saleData['Note'] =
//                                                           saleController
//                                                               .materialDialogNoteTextController
//                                                               .text.trim();
//                                                       saleController
//                                                           .dataSource.value
//                                                           .notifyListeners();
//                                                       saleController
//                                                           .dataSource.value
//                                                           .calculateTotals(
//                                                               saleController);
//                                                       saleController.dataSource
//                                                           .refresh();

//                                                       Get.back();
//                                                     }
//                                                   },
//                                                   style: ButtonStyle(
//                                                     backgroundColor:
//                                                         MaterialStateProperty
//                                                             .all(Colors.white),
//                                                     foregroundColor:
//                                                         MaterialStateProperty
//                                                             .all(Colors.green),
//                                                     shape: MaterialStateProperty
//                                                         .all(
//                                                             RoundedRectangleBorder(
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                               10.0),
//                                                     )),
//                                                   ),
//                                                   label: Text("Done".tr),
//                                                   icon: const Icon(Icons.done)),
//                                             ),
//                                           ],
//                                         ),
//                                         const SizedBox(
//                                           height: 10,
//                                         ),
//                                         Row(
//                                           children: [
//                                             Expanded(
//                                                 flex: 2, child: Container()),
//                                             Expanded(
//                                               child: OutlinedButton.icon(
//                                                   onPressed: () {
//                                                     Get.back();
//                                                   },
//                                                   style: ButtonStyle(
//                                                     backgroundColor:
//                                                         MaterialStateProperty
//                                                             .all(Colors.white),
//                                                     foregroundColor:
//                                                         MaterialStateProperty
//                                                             .all(Colors.red),
//                                                     shape: MaterialStateProperty
//                                                         .all(
//                                                             RoundedRectangleBorder(
//                                                       borderRadius:
//                                                           BorderRadius.circular(
//                                                               10.0),
//                                                     )),
//                                                   ),
//                                                   label: Text("Cancel".tr),
//                                                   icon:
//                                                       const Icon(Icons.cancel)),
//                                             ),
//                                           ],
//                                         ),
//                                       ],
//                                     ),
//                                   ),
//                                 ],
//                               ),
//                               const SizedBox(
//                                 height: 5,
//                               ),
//                             ],
//                           ),
//                         )),
//                   ),
//                 );
//               }),
//             ));
//       });
// }
