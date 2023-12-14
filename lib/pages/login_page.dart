import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';

import '../controllers/login_controller.dart';

class LoginPage extends StatelessWidget {
  const LoginPage({super.key});

  @override
  Widget build(BuildContext context) {
    final LoginController controller = Get.put(LoginController());
    WindowOptions windowOptions = const WindowOptions(
      size: Size(450, 300),
      maximumSize: Size(450, 300),
      minimumSize: Size(450, 300),
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
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const DragToMoveArea(
          child: Text(
            'Login',
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
                  foregroundColor: MaterialStateProperty.all(Colors.red[400])),
              icon: const Icon(Icons.close),
            ),
          ),
        ],
      ),
      body: Column(
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
                      margin: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      padding: const EdgeInsets.only(bottom: 10),
                      decoration: BoxDecoration(
                          border:
                              Border.all(color: Colors.blue[400]!, width: 1),
                          borderRadius: BorderRadius.circular(5),
                          shape: BoxShape.rectangle,
                          color: Colors.white),
                      child: SingleChildScrollView(
                        child: FocusTraversalGroup(
                          policy: OrderedTraversalPolicy(),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              const SizedBox(
                                height: 20,
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.06),
                                child: TextFormField(
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  controller: controller.usernameController,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    isDense: true,
                                    contentPadding: const EdgeInsets.all(10),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          const BorderSide(color: Colors.green),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    border: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(8.0)),
                                    ),
                                    counterText: "",
                                    hintText: 'Username',
                                  ),
                                  keyboardType: TextInputType.text,
                                  onFieldSubmitted: (value) async {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                    controller.logining.value = true;
                                    await controller.login();
                                    controller.logining.value = false;
                                  },
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal:
                                        MediaQuery.of(context).size.width *
                                            0.06),
                                child: TextFormField(
                                  textCapitalization:
                                      TextCapitalization.sentences,
                                  controller: controller.passwordController,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: Colors.white,
                                    isDense: true,
                                    contentPadding: const EdgeInsets.all(10),
                                    focusedBorder: OutlineInputBorder(
                                      borderSide:
                                          const BorderSide(color: Colors.green),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    border: const OutlineInputBorder(
                                      borderRadius: BorderRadius.all(
                                          Radius.circular(8.0)),
                                    ),
                                    counterText: "",
                                    hintText: 'Password',
                                  ),
                                  keyboardType: TextInputType.text,
                                  obscureText: true,
                                  onFieldSubmitted: (value) async {
                                    FocusManager.instance.primaryFocus
                                        ?.unfocus();
                                    controller.logining.value = true;
                                    await controller.login();
                                    controller.logining.value = false;
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
                      left: 30,
                      top: 12,
                      child: Container(
                        padding: const EdgeInsets.only(
                            bottom: 10, left: 10, right: 10),
                        color: Colors.white,
                        child: const Text(
                          'Login Information',
                          style: TextStyle(color: Colors.black, fontSize: 12),
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
                  () => controller.logining.value
                      ? const Padding(
                          padding: EdgeInsets.symmetric(horizontal: 30),
                          child: CircularProgressIndicator(),
                        )
                      : OutlinedButton.icon(
                          onPressed: () async {
                            FocusManager.instance.primaryFocus?.unfocus();
                            controller.logining.value = true;
                            await controller.login();
                            controller.logining.value = false;
                          },
                          style: ButtonStyle(
                              shape: MaterialStateProperty.all(
                                  RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8.0),
                              )),
                              backgroundColor:
                                  MaterialStateProperty.all(Colors.white),
                              foregroundColor:
                                  MaterialStateProperty.all(Colors.green)),
                          icon: const Icon(Icons.thumb_up),
                          label: const Padding(
                            padding: EdgeInsets.all(8.0),
                            child: Text('Login'),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
