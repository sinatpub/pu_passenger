import 'package:flutter/material.dart';
import 'package:com.tara.passenger/core/theme/text_styles.dart';
import 'package:get/get.dart';

import 'logic.dart';

class SplashScreen extends StatelessWidget {
  SplashScreen({super.key});

  final SplashLogic splashLogic = Get.put(SplashLogic());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Image(
              image: AssetImage("assets/logo_app.png"),
              width: 120,
            ),
            const SizedBox(
              height: 10,
            ),
            Text(
              "TAARRAA Taxi",
              style: AppTextStyles.heading
                  .copyWith(color: Theme.of(context).primaryColor),
            ),
            SizedBox(
              height: Get.height * .3,
            ),
          ],
        ),
      ),
    );
  }
}
