// ignore_for_file: constant_identifier_names

import 'package:com.tara.passenger/presentation/screens/announcement/view.dart';
import 'package:com.tara.passenger/presentation/screens/announcement_detail/view.dart';
import 'package:com.tara.passenger/presentation/screens/booking_map_screen/binding.dart';
import 'package:com.tara.passenger/presentation/screens/booking_map_screen/booking_map_screen.dart';
import 'package:com.tara.passenger/presentation/screens/bottom_nav/binding.dart';
import 'package:com.tara.passenger/presentation/screens/bottom_nav/view.dart';
import 'package:com.tara.passenger/presentation/screens/calculate_fee/binding.dart';
import 'package:com.tara.passenger/presentation/screens/calculate_fee/calculate_fee_screen.dart';
import 'package:com.tara.passenger/presentation/screens/history/binding.dart';
import 'package:com.tara.passenger/presentation/screens/history_detail/view.dart';
import 'package:com.tara.passenger/presentation/screens/home/binding.dart';
import 'package:com.tara.passenger/presentation/screens/home/view.dart';
import 'package:com.tara.passenger/presentation/screens/login/binding.dart';
import 'package:com.tara.passenger/presentation/screens/login/view.dart';
import 'package:com.tara.passenger/presentation/screens/map_screen/binding.dart';
import 'package:com.tara.passenger/presentation/screens/map_screen/view.dart';
import 'package:com.tara.passenger/presentation/screens/otp/binding.dart';
import 'package:com.tara.passenger/presentation/screens/otp/view.dart';
import 'package:com.tara.passenger/presentation/screens/profile/binding.dart';
import 'package:com.tara.passenger/presentation/screens/register/binding.dart';
import 'package:com.tara.passenger/presentation/screens/splash_screen/binding.dart';
import 'package:com.tara.passenger/presentation/screens/splash_screen/view.dart';
import 'package:get/get.dart';

import '../presentation/screens/announcement/binding.dart';
import '../presentation/screens/announcement_detail/binding.dart';
import '../presentation/screens/contact_us/binding.dart';
import '../presentation/screens/contact_us/view.dart';
import '../presentation/screens/history_detail/binding.dart';
import '../presentation/screens/register/view.dart';
import '../presentation/screens/term_condition/binding.dart';
import '../presentation/screens/term_condition/view.dart';
import '../presentation/shared/map_drag/binding.dart';
import '../presentation/shared/map_drag/view.dart';

abstract class AppRoutes {
  static const SPLASH = '/splash';
  static const BOTTOMNAV = '/bottomnav';
  static const LOGIN = '/login';
  static const OTP = '/otp';
  static const REGISTER = '/register';
  static const HOME = '/home';
  static const MAP = '/map';
  static const BOOKING = '/booking';
  static const MYBOOKING = '/my_booking';
  static const CALCULATEFEE = '/calculatefee';
  static const WHERETOGO = "/wheretogo";
  static const DRAGMAP = "/dragMap";
  static const TERMCONDITION = "/termcondition";
  static const CONTACTUS = "/contactus";
  static const HISTORYDETAIL = "/historydetail";
  static const ANNOUNCEMENT = "/announcement";
  static const ANNOUNCEMENTDETAIL = "/announcement_detail";
}

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.SPLASH,
      page: () => SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.REGISTER,
      page: () => RegisterPage(),
      binding: RegisterBinding(),
    ),
    GetPage(
      name: AppRoutes.BOTTOMNAV,
      page: () => BottomNav(),
      bindings: [
        BottomNavBinding(),
        HomeBinding(),
        HistoryBinding(),
        // MyBookingBinding(),
        ProfileBinding(),
      ],
    ),
    GetPage(
        name: AppRoutes.LOGIN,
        page: () => LoginPage(),
        binding: LoginBinding()),
    GetPage(
      name: AppRoutes.OTP,
      page: () => const OtpPage(),
      binding: OTPBinding(),
    ),
    GetPage(
      name: AppRoutes.HOME,
      page: () => HomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.MAP,
      page: () => MapScreen(),
      binding: MapBinding(),
    ),
    GetPage(
      name: AppRoutes.BOOKING,
      page: () => BookingMapScreen(),
      binding: BookingMapBinding(),
    ),
    GetPage(
      name: AppRoutes.CALCULATEFEE,
      page: () => const CalculateFeeScreen(),
      binding: CalculateFeeBinding(),
    ),
    GetPage(
      name: AppRoutes.DRAGMAP,
      page: () => MapDragPage(),
      // P-05: MapDragBinding existed but was wired to nothing, so the page
      // called Get.put(MapDragLogic()) in a field initializer instead — which
      // rebuilt and re-registered the controller on every construction of the
      // widget. MapBinding stays for MapLogic, which this page also reads.
      bindings: [MapBinding(), MapDragBinding()],
    ),
    GetPage(
      name: AppRoutes.TERMCONDITION,
      page: () => TermConditionPage(),
      binding: TermConditionBinding(),
    ),
    GetPage(
      name: AppRoutes.CONTACTUS,
      page: () => ContactUsPage(),
      binding: ContactUsBinding(),
    ),
    GetPage(
      name: AppRoutes.HISTORYDETAIL,
      page: () => HistoryDetailPage(),
      binding: HistoryDetailBinding(),
    ),
    GetPage(
      name: AppRoutes.ANNOUNCEMENT,
      page: () => AnnouncementPage(),
      binding: AnnouncementBinding(),
    ),
    GetPage(
      name: AppRoutes.ANNOUNCEMENTDETAIL,
      page: () => AnnouncementDetailPage(),
      binding: AnnouncementDetailBinding(),
    ),
  ];
}
