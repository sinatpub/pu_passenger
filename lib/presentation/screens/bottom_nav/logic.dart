import 'dart:convert';

import 'package:com.tara.passenger/core/utils/app_log.dart';
import 'package:com.tara.passenger/presentation/screens/history/view.dart';
import 'package:com.tara.passenger/presentation/screens/home/view.dart';
import 'package:com.tara.passenger/presentation/screens/profile/profile_screen.dart';
import 'package:com.tara.passenger/storages/get_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class BottomNavController extends GetxController {
  var selectedIndex = 0.obs;

  final List<Widget> pages = [
    HomeScreen(),
    HistoryScreen(),
    const ProfileScreen(),
  ];

  void changePage(int index) async {
    selectedIndex.value = index;
  }
}
