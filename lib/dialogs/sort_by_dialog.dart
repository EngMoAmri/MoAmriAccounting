import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<dynamic> showSortByDialog(
    List<String> orderByList, int selectedOrderBy, int selectedOrderDir) async {
  var orderBy = selectedOrderBy;
  var orderDir = selectedOrderDir;
  return await showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        final scrollController = ScrollController();

        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 400, maxWidth: 250),
            child: StatefulBuilder(builder: (context, setState) {
              return Column(
                children: [
                  const SizedBox(
                    height: 10,
                  ),
                  Center(
                    child: Text(
                      "Order By".tr,
                      style: const TextStyle(
                          fontSize: 18, fontWeight: FontWeight.bold),
                    ),
                  ),
                  const Divider(),
                  Expanded(
                    child: Scrollbar(
                      controller: scrollController,
                      thumbVisibility: true,
                      trackVisibility: true,
                      child: SingleChildScrollView(
                        controller: scrollController,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListView.builder(
                                shrinkWrap: true,
                                itemBuilder: (context, position) {
                                  return RadioListTile(
                                    activeColor: Colors.blue,
                                    title: Text(orderByList[position].tr),
                                    value: position,
                                    groupValue: orderBy,
                                    onChanged: (value) {
                                      setState(() {
                                        orderBy = value!;
                                      });
                                    },
                                  );
                                },
                                itemCount: orderByList.length),
                            const Divider(),
                            Column(
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),
                                Center(
                                  child: Text(
                                    "Order Direction".tr,
                                    style: const TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                RadioListTile(
                                  activeColor: Colors.blue,
                                  title: Text("Ascending".tr),
                                  value: 0,
                                  groupValue: orderDir,
                                  onChanged: (value) {
                                    setState(() {
                                      orderDir = value!;
                                    });
                                  },
                                ),
                                RadioListTile(
                                  activeColor: Colors.blue,
                                  title: Text("Descending".tr),
                                  value: 1,
                                  groupValue: orderDir,
                                  onChanged: (value) {
                                    setState(() {
                                      orderDir = value!;
                                    });
                                  },
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                  const Divider(),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(Get.context!, [orderBy, orderDir]);
                      },
                      style: ButtonStyle(
                        backgroundColor: MaterialStateProperty.all(Colors.blue),
                        foregroundColor:
                            MaterialStateProperty.all(Colors.white),
                        shape: MaterialStateProperty.all(RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10.0),
                        )),
                      ),
                      child: Text("OK".tr)),
                  const SizedBox(
                    height: 10,
                  )
                ],
              );
            }),
          ),
        );
      });
}
