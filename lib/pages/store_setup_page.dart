import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';

import '../controllers/store_setup_controller.dart';

class StoreSetupPage extends StatelessWidget {
  const StoreSetupPage({super.key});

  @override
  Widget build(BuildContext context) {
    final StoreSetupController controller = Get.put(StoreSetupController());
    WindowOptions windowOptions = const WindowOptions(
      size: Size(800, 500),
      maximumSize: Size(800, 500),
      minimumSize: Size(800, 500),
      center: true,
      backgroundColor: Colors.transparent,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
    windowManager.startDragging();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: DefaultTabController(
        length: 2,
        child: Scaffold(
          appBar: AppBar(
            bottom: const TabBar(
              labelColor: Colors.black,
              tabs: [
                Tab(
                  text: "إنشاء متجر جديد",
                ),
                Tab(
                  text: "استعادة من نسخة إحتياطية",
                ),
              ],
            ),
            centerTitle: true,
            title: const DragToMoveArea(
              child: Text(
                'إعداد متجرك',
                style: TextStyle(color: Colors.black),
              ),
            ),
            backgroundColor: Colors.white,
            foregroundColor: Colors.grey,
            elevation: 0,
            systemOverlayStyle: const SystemUiOverlayStyle(
                statusBarColor: Colors.white,
                systemNavigationBarColor: Colors.transparent,
                systemNavigationBarIconBrightness: Brightness.dark,
                statusBarIconBrightness: Brightness.dark,
                statusBarBrightness: Brightness.light),
            actions: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: IconButton.outlined(
                  onPressed: () {
                    exit(0);
                  },
                  style: ButtonStyle(
                      shape: MaterialStateProperty.all(RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8.0),
                      )),
                      backgroundColor: MaterialStateProperty.all(Colors.white),
                      foregroundColor:
                          MaterialStateProperty.all(Colors.red[400])),
                  icon: const Icon(Icons.close),
                ),
              ),
            ],
          ),
          body: TabBarView(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  Form(
                    key: controller.formKey,
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                            child: Stack(
                          children: <Widget>[
                            Container(
                              width: double.infinity,
                              height: 260,
                              margin: const EdgeInsets.fromLTRB(5, 20, 20, 10),
                              padding: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.blue[400]!, width: 1),
                                  borderRadius: BorderRadius.circular(5),
                                  shape: BoxShape.rectangle,
                                  color: Colors.white),
                              child: SingleChildScrollView(
                                child: FocusTraversalGroup(
                                  policy: OrderedTraversalPolicy(),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.06),
                                        child: TextFormField(
                                          textCapitalization:
                                              TextCapitalization.sentences,
                                          controller:
                                              controller.storeNameController,
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.white,
                                            isDense: true,
                                            contentPadding:
                                                const EdgeInsets.all(10),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.green),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            border: const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8.0)),
                                            ),
                                            counterText: "",
                                            hintText: 'الاسم',
                                          ),
                                          keyboardType: TextInputType.text,
                                          onFieldSubmitted: (value) async {
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                            controller.creating.value = true;
                                            await controller.createStore();
                                            controller.creating.value = false;
                                          },
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.06),
                                        child: TextFormField(
                                          textCapitalization:
                                              TextCapitalization.sentences,
                                          controller:
                                              controller.storeBranchController,
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.white,
                                            isDense: true,
                                            contentPadding:
                                                const EdgeInsets.all(10),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.green),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            border: const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8.0)),
                                            ),
                                            counterText: "",
                                            hintText: 'الفرع',
                                          ),
                                          keyboardType: TextInputType.text,
                                          onFieldSubmitted: (value) async {
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                            controller.creating.value = true;
                                            await controller.createStore();
                                            controller.creating.value = false;
                                          },
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.06),
                                        child: TextFormField(
                                          textCapitalization:
                                              TextCapitalization.sentences,
                                          controller:
                                              controller.storeAddressController,
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.white,
                                            isDense: true,
                                            contentPadding:
                                                const EdgeInsets.all(10),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.green),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            border: const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8.0)),
                                            ),
                                            counterText: "",
                                            hintText: 'العنوان',
                                          ),
                                          keyboardType: TextInputType.text,
                                          onFieldSubmitted: (value) async {
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                            controller.creating.value = true;
                                            await controller.createStore();
                                            controller.creating.value = false;
                                          },
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.06),
                                        child: TextFormField(
                                          textCapitalization:
                                              TextCapitalization.sentences,
                                          controller:
                                              controller.storePhoneController,
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.white,
                                            isDense: true,
                                            contentPadding:
                                                const EdgeInsets.all(10),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.green),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            border: const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8.0)),
                                            ),
                                            counterText: "",
                                            hintText: 'رقم الهاتف',
                                          ),
                                          keyboardType: TextInputType.text,
                                          onFieldSubmitted: (value) async {
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                            controller.creating.value = true;
                                            await controller.createStore();
                                            controller.creating.value = false;
                                          },
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.06),
                                        child: TextFormField(
                                          textCapitalization:
                                              TextCapitalization.sentences,
                                          controller: controller
                                              .storeCurrencyController,
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.white,
                                            isDense: true,
                                            contentPadding:
                                                const EdgeInsets.all(10),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.green),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            border: const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8.0)),
                                            ),
                                            counterText: "",
                                            hintText: 'العملة الرئيسية',
                                          ),
                                          keyboardType: TextInputType.text,
                                          onFieldSubmitted: (value) async {
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                            controller.creating.value = true;
                                            await controller.createStore();
                                            controller.creating.value = false;
                                          },
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 40,
                              top: 12,
                              child: Container(
                                padding: const EdgeInsets.only(
                                    bottom: 10, left: 10, right: 10),
                                color: Colors.white,
                                child: const Text(
                                  'معلومات المتجر',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        )),
                        Expanded(
                            child: Stack(
                          children: <Widget>[
                            Container(
                              width: double.infinity,
                              height: 260,
                              margin: const EdgeInsets.fromLTRB(20, 20, 5, 10),
                              padding: const EdgeInsets.only(bottom: 10),
                              decoration: BoxDecoration(
                                  border: Border.all(
                                      color: Colors.blue[400]!, width: 1),
                                  borderRadius: BorderRadius.circular(5),
                                  shape: BoxShape.rectangle,
                                  color: Colors.white),
                              child: SingleChildScrollView(
                                child: FocusTraversalGroup(
                                  policy: OrderedTraversalPolicy(),
                                  child: Column(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceEvenly,
                                    children: [
                                      const SizedBox(
                                        height: 20,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.06),
                                        child: TextFormField(
                                          textCapitalization:
                                              TextCapitalization.sentences,
                                          controller:
                                              controller.adminNameController,
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.white,
                                            isDense: true,
                                            contentPadding:
                                                const EdgeInsets.all(10),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.green),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            border: const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8.0)),
                                            ),
                                            counterText: "",
                                            hintText: 'الاسم',
                                          ),
                                          keyboardType: TextInputType.text,
                                          onFieldSubmitted: (value) async {
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                            controller.creating.value = true;
                                            await controller.createStore();
                                            controller.creating.value = false;
                                          },
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Row(children: <Widget>[
                                        Expanded(
                                            child: Divider(
                                          color: Colors.blue[400],
                                        )),
                                        const Text("معلومات تسجيل دخول المشرف"),
                                        Expanded(
                                            child: Divider(
                                          color: Colors.blue[400],
                                        )),
                                      ]),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.06),
                                        child: TextFormField(
                                          textCapitalization:
                                              TextCapitalization.sentences,
                                          controller: controller
                                              .adminUsernameController,
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.white,
                                            isDense: true,
                                            contentPadding:
                                                const EdgeInsets.all(10),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.green),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            border: const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8.0)),
                                            ),
                                            counterText: "",
                                            hintText: 'اسم المستخدم',
                                          ),
                                          keyboardType: TextInputType.text,
                                          onFieldSubmitted: (value) async {
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                            controller.creating.value = true;
                                            await controller.createStore();
                                            controller.creating.value = false;
                                          },
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: MediaQuery.of(context)
                                                    .size
                                                    .width *
                                                0.06),
                                        child: TextFormField(
                                          textCapitalization:
                                              TextCapitalization.sentences,
                                          controller: controller
                                              .adminPasswordController,
                                          decoration: InputDecoration(
                                            filled: true,
                                            fillColor: Colors.white,
                                            isDense: true,
                                            contentPadding:
                                                const EdgeInsets.all(10),
                                            focusedBorder: OutlineInputBorder(
                                              borderSide: const BorderSide(
                                                  color: Colors.green),
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                            ),
                                            border: const OutlineInputBorder(
                                              borderRadius: BorderRadius.all(
                                                  Radius.circular(8.0)),
                                            ),
                                            counterText: "",
                                            hintText: 'كلمة المرور',
                                          ),
                                          keyboardType: TextInputType.text,
                                          obscureText: true,
                                          onFieldSubmitted: (value) async {
                                            FocusManager.instance.primaryFocus
                                                ?.unfocus();
                                            controller.creating.value = true;
                                            await controller.createStore();
                                            controller.creating.value = false;
                                          },
                                        ),
                                      ),
                                      const SizedBox(
                                        height: 10,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                            Positioned(
                              right: 20,
                              top: 12,
                              child: Container(
                                padding: const EdgeInsets.only(
                                    bottom: 10, left: 10, right: 10),
                                color: Colors.white,
                                child: const Text(
                                  'معلومات المستخدم المشرف',
                                  style: TextStyle(
                                      color: Colors.black, fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        ))
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 8.0, 20, 8),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        Obx(
                          () => controller.creating.value
                              ? const Padding(
                                  padding: EdgeInsets.symmetric(horizontal: 30),
                                  child: CircularProgressIndicator(),
                                )
                              : OutlinedButton.icon(
                                  onPressed: () async {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                    controller.creating.value = true;
                                    await controller.createStore();
                                    controller.creating.value = false;
                                  },
                                  style: ButtonStyle(
                                      shape: MaterialStateProperty.all(
                                          RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(8.0),
                                      )),
                                      backgroundColor:
                                          MaterialStateProperty.all(
                                              Colors.white),
                                      foregroundColor:
                                          MaterialStateProperty.all(
                                              Colors.green)),
                                  icon: const Icon(Icons.thumb_up),
                                  label: const Padding(
                                    padding: EdgeInsets.all(8.0),
                                    child: Text('تم'),
                                  ),
                                ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const Icon(Icons.directions_bike),
            ],
          ),
        ),
      ),
    );
  }
}
