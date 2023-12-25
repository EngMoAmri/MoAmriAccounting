import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomeController extends GetxController {
  Rx<PageController> pageController = Rx(PageController());
  Rx<int> selectedPage = 0.obs;
}
