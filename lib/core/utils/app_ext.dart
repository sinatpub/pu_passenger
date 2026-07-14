import 'package:com.tara.passenger/core/utils/screen_util.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

extension DateTimeStringFormatter on String {
  /// Formats a date-time string into a human-readable format.
  String formatDateString() {
    try {
      // Construct a new string with only the relevant parts of the date-time.
      var newStr = '${substring(0, 10)} ${substring(11, 19)}';

      // Parse the new string into a DateTime object.
      DateTime dt = DateTime.parse(newStr);

      // Format the DateTime object into the desired format.
      return DateFormat("EEE/d/MMM/yyyy - HH:mma").format(dt);
    } catch (e) {
      // Handle invalid date-time strings gracefully.
      return 'Invalid Date-Time';
    }
  }
}

extension ScreenUtilInt on int {
  double get d {
    final util = ScreenUtilHelper();
    var di = util.deviceDiagonal * (toDouble() / 1000);
    var ar = (util.deviceArea / 4) * (toDouble() / 100000);
    var dii = double.parse(di.roundToDouble().toStringAsFixed(2));
    return dii;
  }
}

extension ScreenUtilDouble on double {
  double get d {
    final util = ScreenUtilHelper();
    return util.deviceDiagonal * (this / 1000);
  }
}

extension MoneyFormatExtension on num {
  String toMoneyFormat({String locale = 'en_US'}) {
    final formatter = NumberFormat.decimalPattern(locale);
    return formatter.format(this);
  }
}

extension DateTimeFormatter on DateTime {
  /// Formats a DateTime object into a human-readable format.
  String formatDateTime() {
    try {
      // Use DateFormat from the intl package to format the DateTime.
      return DateFormat("EEE/d/MMM/yyyy - HH:mma").format(this);
    } catch (e) {
      // Handle any unexpected errors gracefully.
      return 'Invalid Date-Time';
    }
  }
}

extension ShimmerWidget on Widget {
  Widget get toShimmer {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10.0),
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300,
        highlightColor: Colors.grey.shade100,
        child: this,
      ),
    );
  }
}

extension StringFormattingExtensions on String {
  /// Converts time strings like "2 hours 5 mins" to "2 h 5 m"
  String toShortTimeFormat() {
    final hourRegex = RegExp(r'(\d+)\s*hour[s]?', caseSensitive: false);
    final minRegex = RegExp(r'(\d+)\s*min[s]?', caseSensitive: false);
    final secRegex = RegExp(r'(\d+)\s*secon[s]?', caseSensitive: false);

    final hourMatch = hourRegex.firstMatch(this);
    final minMatch = minRegex.firstMatch(this);
    final secMatch = secRegex.firstMatch(this);

    String hours = hourMatch != null ? hourMatch.group(1)! : '0';
    String minutes = minMatch != null ? minMatch.group(1)! : '0';
    String seconds = secMatch != null ? secMatch.group(1)! : '0';

    return '${hours == '0' ? "" : "$hours h"} '
        '${minutes == '0' ? "" : "$minutes m"} '
        '${hours == '0' || minutes == '0' ? "$seconds s" : ""}';
  }
}

String formatDateTime(String input) {
  final inputFormat = DateFormat("yyyy-MM-dd HH:mm:ss");
  final dateTime = inputFormat.parse(input);

  final outputFormat = DateFormat("EEE/dd/MMM/yyyy hh:mm a");
  return outputFormat.format(dateTime);
}
