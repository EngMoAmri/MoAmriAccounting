import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_side_menu/flutter_side_menu.dart';
import 'package:get/get.dart';
import 'package:moamri_accounting/return/pages/return_page.dart';
import 'package:moamri_accounting/sale/pages/sale_page.dart';
import 'package:window_manager/window_manager.dart';

import '../controllers/main_controller.dart';
import '../customers/pages/customers_page.dart';
import '../inventory/pages/inventory_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  PageController pageController = PageController();
  int selectedPage = 0;

  @override
  void initState() {
    WindowOptions windowOptions = const WindowOptions(
      size: Size(800, 600),
      // minimumSize: Size(800, 600), TODO
      center: true,
      backgroundColor: Colors.white,
      skipTaskbar: false,
      titleBarStyle: TitleBarStyle.hidden,
    );
    windowManager.waitUntilReadyToShow(windowOptions, () async {
      await windowManager.show();
      await windowManager.focus();
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final MainController mainController = Get.find();
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          centerTitle: true,
          automaticallyImplyLeading: false,
          title: DragToMoveArea(
            child: Row(
              children: [
                Text(
                  mainController.storeData.value?.name ?? "",
                ),
              ],
            ),
          ),
          backgroundColor: Colors.white,
          foregroundColor: Colors.black,
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
                    await windowManager.unmaximize();
                  } else {
                    await windowManager.setMaximumSize(Size.infinite);
                    windowManager.maximize();
                  }
                },
                icon: const Icon(
                  Icons.crop_square,
                  color: Colors.green,
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
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
        body: Column(
          children: [
            const Divider(
              height: 1,
            ),
            Expanded(
              child: Row(
                children: [
                  SideMenu(
                    mode: SideMenuMode.open,
                    hasResizerToggle: false,
                    hasResizer: false,
                    builder: (data) => SideMenuData(
                      header: Column(
                        children: [
                          Center(
                            child: Text(mainController.storeData.value!.branch),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          Center(
                            child: Text(mainController.storeData.value!.phone),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Center(
                            child:
                                Text(mainController.storeData.value!.address),
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                          const Divider(
                            height: 1,
                          ),
                          const SizedBox(
                            height: 10,
                          ),
                        ],
                      ),
                      items: [
                        SideMenuItemDataTile(
                          isSelected: selectedPage == 0,
                          title: 'المستودع',
                          onTap: () {
                            pageController.jumpToPage(0);
                            setState(() {
                              selectedPage = 0;
                            });
                          },
                          icon: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child:
                                  Image.asset('assets/images/inventory.png')),
                        ),
                        SideMenuItemDataTile(
                            isSelected: selectedPage == 1,
                            title: 'العملاء',
                            onTap: () {
                              pageController.jumpToPage(1);
                              setState(() {
                                selectedPage = 1;
                              });
                            },
                            icon: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: Image.asset('assets/images/customers.png'),
                            )),
                        SideMenuItemDataTile(
                            isSelected: selectedPage == 2,
                            title: 'البيع',
                            onTap: () {
                              pageController.jumpToPage(2);
                              setState(() {
                                selectedPage = 2;
                              });
                            },
                            icon: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: Image.asset('assets/images/cart.png'),
                            )),
                        SideMenuItemDataTile(
                            isSelected: selectedPage == 3,
                            title: 'المرتجع',
                            onTap: () {
                              pageController.jumpToPage(3);
                              setState(() {
                                selectedPage = 3;
                              });
                            },
                            icon: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: Image.asset('assets/images/return.png'),
                            )),
                        SideMenuItemDataTile(
                            isSelected: selectedPage == 4,
                            title: 'الموردين',
                            onTap: () {
                              // pageController.jumpToPage(4);
                              // setState(() {
                              //   selectedPage = 4;
                              // });
                            },
                            icon: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: Image.asset('assets/images/supplier.png'),
                            )),
                        SideMenuItemDataTile(
                            isSelected: selectedPage == 5,
                            title: 'فواتير المبيعات/المرتجع',
                            onTap: () {
                              // pageController.jumpToPage(5);
                              // setState(() {
                              //   selectedPage = 5;
                              // });
                            },
                            icon: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: Image.asset('assets/images/sales.png'),
                            )),
                        SideMenuItemDataTile(
                            isSelected: selectedPage == 5,
                            title: 'فواتير المشتريات/المرتجع',
                            onTap: () {
                              // pageController.jumpToPage(5);
                              // setState(() {
                              //   selectedPage = 5;
                              // });
                            },
                            icon: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: Image.asset('assets/images/purchases.png'),
                            )),
                        SideMenuItemDataTile(
                            isSelected: selectedPage == 6,
                            title: 'النفقات',
                            onTap: () {
                              // pageController.jumpToPage(6);
                              // setState(() {
                              //   selectedPage = 6;
                              // });
                            },
                            icon: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: Image.asset('assets/images/expenses.png'),
                            )),
                        SideMenuItemDataTile(
                            isSelected: selectedPage == 7,
                            title: 'التقارير',
                            onTap: () {
                              // pageController.jumpToPage(7);
                              // setState(() {
                              //   selectedPage = 7;
                              // });
                            },
                            icon: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: Image.asset('assets/images/reports.png'),
                            )),
                        SideMenuItemDataTile(
                            isSelected: selectedPage == 8,
                            title: 'الملاحظات و التنبيهات',
                            onTap: () {
                              // pageController.jumpToPage(8);
                              // setState(() {
                              //   selectedPage = 8;
                              // });
                            },
                            icon: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: Image.asset('assets/images/alarm.png'),
                            )),
                        SideMenuItemDataTile(
                            isSelected: selectedPage == 9,
                            title: 'المستخدمين',
                            onTap: () {
                              // pageController.jumpToPage(9);
                              // setState(() {
                              //   selectedPage = 9;
                              // });
                            },
                            icon: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: Image.asset('assets/images/users.png'),
                            )),
                        SideMenuItemDataTile(
                            isSelected: selectedPage == 10,
                            title: 'الإعدادات',
                            onTap: () {
                              // pageController.jumpToPage(10);
                              // setState(() {
                              //   selectedPage = 10;
                              // });
                            },
                            icon: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 5),
                              child: Image.asset('assets/images/settings.png'),
                            )),
                      ],
                    ),
                  ),
                  const VerticalDivider(
                    width: 1,
                  ),
                  Expanded(
                    child: PageView(
                      physics: const NeverScrollableScrollPhysics(),
                      pageSnapping: false,
                      controller: pageController,
                      children: [
                        Row(
                          children: [
                            Expanded(child: InventoryPage()),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(child: CustomersPage()),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(child: SalePage()),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(child: ReturnPage()),
                          ],
                        ),
                        Container(
                          child: const Center(
                            child: Text('Add Material'),
                          ),
                        ),
                        Container(
                          child: const Center(
                            child: Text('Add Material'),
                          ),
                        ),
                        Container(
                          child: const Center(
                            child: Text('Materials Management'),
                          ),
                        ),
                        Container(
                          child: const Center(
                            child: Text('Purchases'),
                          ),
                        ),
                        Container(
                          child: const Center(
                            child: Text('Add Material'),
                          ),
                        ),
                        Container(
                          child: const Center(
                            child: Text('Materials Management'),
                          ),
                        ),
                        Container(
                          child: const Center(
                            child: Text('Purchases'),
                          ),
                        ),
                        Container(
                          child: const Center(
                            child: Text('Add Material'),
                          ),
                        ),
                        Container(
                          child: const Center(
                            child: Text('Materials Management'),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
