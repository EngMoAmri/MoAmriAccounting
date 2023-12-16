import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_side_menu/flutter_side_menu.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';

import '../controllers/main_controller.dart';
import 'inventory_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PageController pageController = PageController();
  int selectedPage = 0;

  @override
  Widget build(BuildContext context) {
    // final HomeController controller = Get.put(HomeController());
    final MainController mainController = Get.find();
    WindowOptions windowOptions = const WindowOptions(
      // size: Size(800, 600),
      minimumSize: Size(800, 600),
      center: true,
      backgroundColor: Colors.white,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
      windowManager.maximize();
    });

    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: DragToMoveArea(
          child: Row(
            children: [
              Text(
                mainController.storeData.value?.name ?? "",
                style: const TextStyle(color: Colors.black),
              ),
            ],
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
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: IconButton(
              onPressed: () async {
                await windowManager.setMinimumSize(Size.zero);
                await windowManager.minimize();
              },
              icon: const Icon(Icons.minimize),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 5),
            child: IconButton(
              onPressed: () async {
                if (await windowManager.isMaximized()) {
                  await windowManager.setMaximumSize(const Size(800, 600));
                } else {
                  await windowManager.setMaximumSize(Size.infinite);
                }
                await windowManager.maximize();
              },
              icon: const Icon(
                Icons.crop_square,
                color: Colors.green,
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(0, 0, 20, 0),
            child: IconButton(
              onPressed: () {
                exit(0);
              },
              icon: const Icon(
                Icons.close,
                color: Colors.red,
              ),
            ),
          ),
        ],
      ),
      body: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          SideMenu(
            mode: SideMenuMode.open,
            hasResizerToggle: false,
            maxWidth: 150,
            builder: (data) => SideMenuData(
              items: [
                SideMenuItemDataTile(
                  isSelected: selectedPage == 0,
                  title: 'Inventory',
                  onTap: () {
                    pageController.jumpToPage(0);
                    setState(() {
                      selectedPage = 0;
                    });
                  },
                  icon: Image.asset('assets/images/inventory.png'),
                ),
                SideMenuItemDataTile(
                  isSelected: selectedPage == 1,
                  title: 'Purchases',
                  onTap: () {
                    pageController.jumpToPage(1);
                    setState(() {
                      selectedPage = 1;
                    });
                  },
                  icon: Image.asset('assets/images/purchases.png'),
                ),
                SideMenuItemDataTile(
                  isSelected: selectedPage == 2,
                  title: 'Suppliers',
                  onTap: () {
                    pageController.jumpToPage(2);
                    setState(() {
                      selectedPage = 2;
                    });
                  },
                  icon: Image.asset('assets/images/supplier.png'),
                ),
                SideMenuItemDataTile(
                  isSelected: selectedPage == 3,
                  title: 'Sale',
                  onTap: () {
                    pageController.jumpToPage(3);
                    setState(() {
                      selectedPage = 3;
                    });
                  },
                  icon: Image.asset('assets/images/cart.png'),
                ),
                SideMenuItemDataTile(
                  isSelected: selectedPage == 4,
                  title: 'Sales',
                  onTap: () {
                    pageController.jumpToPage(4);
                    setState(() {
                      selectedPage = 4;
                    });
                  },
                  icon: Image.asset('assets/images/sales.png'),
                ),
                SideMenuItemDataTile(
                  isSelected: selectedPage == 5,
                  title: 'Customers',
                  onTap: () {
                    pageController.jumpToPage(5);
                    setState(() {
                      selectedPage = 5;
                    });
                  },
                  icon: Image.asset('assets/images/customers.png'),
                ),
                SideMenuItemDataTile(
                  isSelected: selectedPage == 6,
                  title: 'Expenses',
                  onTap: () {
                    pageController.jumpToPage(6);
                    setState(() {
                      selectedPage = 6;
                    });
                  },
                  icon: Image.asset('assets/images/expenses.png'),
                ),
                SideMenuItemDataTile(
                  isSelected: selectedPage == 7,
                  title: 'Reports',
                  onTap: () {
                    pageController.jumpToPage(7);
                    setState(() {
                      selectedPage = 7;
                    });
                  },
                  icon: Image.asset('assets/images/reports.png'),
                ),
                SideMenuItemDataTile(
                  isSelected: selectedPage == 8,
                  title: 'Notes',
                  onTap: () {
                    pageController.jumpToPage(8);
                    setState(() {
                      selectedPage = 8;
                    });
                  },
                  icon: Image.asset('assets/images/alarm.png'),
                ),
                SideMenuItemDataTile(
                  isSelected: selectedPage == 9,
                  title: 'Users',
                  onTap: () {
                    pageController.jumpToPage(9);
                    setState(() {
                      selectedPage = 9;
                    });
                  },
                  icon: Image.asset('assets/images/users.png'),
                ),
                SideMenuItemDataTile(
                  isSelected: selectedPage == 10,
                  title: 'Settings',
                  onTap: () {
                    pageController.jumpToPage(10);
                    setState(() {
                      selectedPage = 10;
                    });
                  },
                  icon: Image.asset('assets/images/settings.png'),
                ),
              ],
            ),
          ),
          Expanded(
            child: PageView(
              controller: pageController,
              children: [
                const Row(
                  children: [
                    Expanded(child: InventoryPage()),
                  ],
                ),
                Container(
                  child: Center(
                    child: Text('Materials Management'),
                  ),
                ),
                Container(
                  child: Center(
                    child: Text('Purchases'),
                  ),
                ),
                Container(
                  child: Center(
                    child: Text('Add Material'),
                  ),
                ),
                Container(
                  child: Center(
                    child: Text('Materials Management'),
                  ),
                ),
                Container(
                  child: Center(
                    child: Text('Purchases'),
                  ),
                ),
                Container(
                  child: Center(
                    child: Text('Add Material'),
                  ),
                ),
                Container(
                  child: Center(
                    child: Text('Materials Management'),
                  ),
                ),
                Container(
                  child: Center(
                    child: Text('Purchases'),
                  ),
                ),
                Container(
                  child: Center(
                    child: Text('Add Material'),
                  ),
                ),
                Container(
                  child: Center(
                    child: Text('Materials Management'),
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
