import 'package:flutter/material.dart';
import 'package:flutter_side_menu/flutter_side_menu.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  Rx<PageController> pageController = Rx(PageController());
  Rx<int> selectedPage = 0.obs;
  Rx<List<SideMenuItemDataTile>> items = Rx([]);

  void refreshItems() {
    items.value = [
      SideMenuItemDataTile(
        isSelected: selectedPage.value == 0,
        title: 'Inventory',
        onTap: () {
          selectedPage.value = 0;
          pageController.value.jumpToPage(0);
          refreshItems();
        },
        icon: Image.asset('assets/images/inventory.png'),
      ),
      SideMenuItemDataTile(
        isSelected: selectedPage.value == 1,
        title: 'Purchases',
        onTap: () {
          selectedPage.value = 1;
          pageController.value.jumpToPage(1);
          refreshItems();
        },
        icon: Image.asset('assets/images/purchases.png'),
      ),
      SideMenuItemDataTile(
        isSelected: selectedPage.value == 2,
        title: 'Suppliers',
        onTap: () {
          selectedPage.value = 2;
          pageController.value.jumpToPage(2);
          refreshItems();
        },
        icon: Image.asset('assets/images/supplier.png'),
      ),
      SideMenuItemDataTile(
        isSelected: selectedPage.value == 3,
        title: 'Sale',
        onTap: () {
          selectedPage.value = 3;
          pageController.value.jumpToPage(3);
          refreshItems();
        },
        icon: Image.asset('assets/images/cart.png'),
      ),
      SideMenuItemDataTile(
        isSelected: selectedPage.value == 4,
        title: 'Sales',
        onTap: () {
          selectedPage.value = 4;
          pageController.value.jumpToPage(4);
          refreshItems();
        },
        icon: Image.asset('assets/images/sales.png'),
      ),
      SideMenuItemDataTile(
        isSelected: selectedPage.value == 5,
        title: 'Customers',
        onTap: () {
          selectedPage.value = 5;
          pageController.value.jumpToPage(5);
          refreshItems();
        },
        icon: Image.asset('assets/images/customers.png'),
      ),
      SideMenuItemDataTile(
        isSelected: selectedPage.value == 6,
        title: 'Expenses',
        onTap: () {
          selectedPage.value = 6;
          pageController.value.jumpToPage(6);
          refreshItems();
        },
        icon: Image.asset('assets/images/expenses.png'),
      ),
      SideMenuItemDataTile(
        isSelected: selectedPage.value == 7,
        title: 'Reports',
        onTap: () {
          selectedPage.value = 7;
          pageController.value.jumpToPage(7);
          refreshItems();
        },
        icon: Image.asset('assets/images/reports.png'),
      ),
      SideMenuItemDataTile(
        isSelected: selectedPage.value == 8,
        title: 'Notes',
        onTap: () {
          selectedPage.value = 8;
          pageController.value.jumpToPage(8);
          refreshItems();
        },
        icon: Image.asset('assets/images/alarm.png'),
      ),
      SideMenuItemDataTile(
        isSelected: selectedPage.value == 9,
        title: 'Users',
        onTap: () {
          selectedPage.value = 9;
          pageController.value.jumpToPage(9);
          refreshItems();
        },
        icon: Image.asset('assets/images/users.png'),
      ),
      SideMenuItemDataTile(
        isSelected: selectedPage.value == 10,
        title: 'Settings',
        onTap: () {
          selectedPage.value = 10;
          pageController.value.jumpToPage(10);
          refreshItems();
        },
        icon: Image.asset('assets/images/settings.png'),
      ),
    ];
    items.refresh();
  }

  @override
  void onInit() {
    refreshItems();
    super.onInit();
  }
}
