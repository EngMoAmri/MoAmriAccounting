import 'package:easy_sidemenu/easy_sidemenu.dart';
import 'package:flutter/material.dart';

class HomePage extends StatelessWidget {
// PageController pageController = PageController();
// SideMenuController sideMenu = SideMenuController();

// List<SideMenuItem> items = [
//   SideMenuItem(
//     title: 'Dashboard',
//     onTap: (index, _) {
//       sideMenu.changePage(index);
//     },
//     icon: Icon(Icons.home),
//     badgeContent: Text(
//       '3',
//       style: TextStyle(color: Colors.white),
//     ),
//   ),
//   SideMenuItem(
//     title: 'Settings',
//     onTap: (index, _) {
//       sideMenu.changePage(index);
//     },
//     icon: Icon(Icons.settings),
//   ),
//   SideMenuItem(
//     title: 'Exit',
//     onTap: () {},
//     icon: Icon(Icons.exit_to_app),
//   ),
// ];

  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Column(children: [
          OutlinedButton(onPressed: () {}, child: Text("المستودع و الأصناف")),
          OutlinedButton(onPressed: () {}, child: Text("فواتير المشتريات")),
          OutlinedButton(
              onPressed: () {}, child: Text("إدارة مرتجع المشتريات")),
          OutlinedButton(onPressed: () {}, child: Text("إدارة الموريدين")),
          OutlinedButton(onPressed: () {}, child: Text("شاشة الاستعلام ")),
          OutlinedButton(onPressed: () {}, child: Text("البيع والاسترجاع")),
          OutlinedButton(
              onPressed: () {}, child: Text("جرد وإدارة المستودع أو الأصناف")),
          OutlinedButton(
              onPressed: () {}, child: Text("جرد وإدارة المستودع أو الأصناف")),
          OutlinedButton(
              onPressed: () {}, child: Text("جرد وإدارة المستودع أو الأصناف")),
          OutlinedButton(
              onPressed: () {}, child: Text("جرد وإدارة المستودع أو الأصناف")),
          OutlinedButton(
              onPressed: () {}, child: Text("جرد وإدارة المستودع أو الأصناف")),
          OutlinedButton(
              onPressed: () {}, child: Text("جرد وإدارة المستودع أو الأصناف")),
          OutlinedButton(
              onPressed: () {}, child: Text("جرد وإدارة المستودع أو الأصناف")),
        ])
      ],
    );
  }
}
