import 'package:flutter/material.dart';
import 'package:get/get.dart';

Future<dynamic> showCategoryDialog(
    List<dynamic> categoriesList, int selectedCategory) async {
  var category = selectedCategory; // this is to be return
  // var scrollController = ScrollController();
  return await showDialog(
      context: Get.context!,
      builder: (BuildContext context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
          child: Directionality(
            textDirection: TextDirection.rtl,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxHeight: 400, maxWidth: 250),
              child: StatefulBuilder(builder: (context, setState) {
                return Column(
                  children: [
                    const SizedBox(
                      height: 10,
                    ),
                    const Center(
                      child: Text(
                        "الصنف",
                        style: TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Divider(),
                    Expanded(
                      child: SingleChildScrollView(
                        // controller: scrollController,
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            ListView.builder(
                                shrinkWrap: true,
                                physics: const NeverScrollableScrollPhysics(),
                                itemBuilder: (context, position) {
                                  return RadioListTile(
                                    activeColor: Colors.blue,
                                    title: Text(categoriesList[position]),
                                    value: position,
                                    groupValue: category,
                                    onChanged: (value) {
                                      setState(() {
                                        category = value!;
                                      });
                                    },
                                  );
                                },
                                itemCount: categoriesList.length),
                          ],
                        ),
                      ),
                    ),
                    const Divider(),
                    ElevatedButton(
                        onPressed: () {
                          Navigator.pop(Get.context!, category);
                        },
                        style: ButtonStyle(
                          backgroundColor:
                              MaterialStateProperty.all(Colors.blue),
                          foregroundColor:
                              MaterialStateProperty.all(Colors.white),
                          shape:
                              MaterialStateProperty.all(RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          )),
                        ),
                        child: const Text("تم")),
                    const SizedBox(
                      height: 10,
                    )
                  ],
                );
              }),
            ),
          ),
        );
      });
}
