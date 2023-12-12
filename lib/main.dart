import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/pages/store_setup_page.dart';

import 'controllers/main_controller.dart';
import 'pages/home_page.dart';
import 'pages/loading_page.dart';
import 'package:window_manager/window_manager.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Must add this line.
  await windowManager.ensureInitialized();

  runApp(
      const GetMaterialApp(debugShowCheckedModeBanner: false, home: MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final MainController controller = Get.put(MainController());
    return MaterialApp(
        title: 'MoAmri Accounting',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
        ),
        debugShowCheckedModeBanner: false,
        home: Obx(
          () => (controller.loading.isTrue)
              ? const LoadingPage()
              : ((controller.storeData.value == null)
                  ? const StoreSetupPage()
                  : const HomePage()),
        ));
  }
}
