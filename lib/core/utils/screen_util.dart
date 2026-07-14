import 'dart:math';
import 'package:get/get.dart';

class ScreenUtilHelper {
  static final ScreenUtilHelper _instance = ScreenUtilHelper._internal();

  factory ScreenUtilHelper() => _instance;

  late final double deviceHeight;
  late final double deviceWidth;
  late final double deviceDiagonal;
  late final double deviceArea;

  ScreenUtilHelper._internal() {
    final context = Get.context;
    deviceHeight = (context == null) ? 812.0 : Get.height;
    deviceWidth = (context == null) ? 375.0 : Get.width;
    deviceDiagonal = sqrt(pow(deviceHeight, 2) + pow(deviceWidth, 2));
    deviceArea = deviceHeight * deviceWidth;
  }
}
