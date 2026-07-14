import 'package:flutter/material.dart';
import 'package:com.tara.passenger/core/theme/text_styles.dart';
import 'package:com.tara.passenger/presentation/widgets/fbtn_widget.dart';

class CreateAccountScreen extends StatelessWidget {
  const CreateAccountScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(

          children: [
            const Expanded(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                  ),
                  SizedBox(
                    height: 10,
                  ),
                  Text("TARA PASSANGER", style: AppTextStyles.heading),
                ],
              ),
            ),
            Column(
              children: [
                FBTNWidget(
                  label: 'Click Me',
                  textColor: Colors.white,
                  // enableWidth: true,
                  onPressed: () {
                    // Your action here
                  },
                ),
                const SizedBox(
                  height: 12,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('Already have an account ?'),
                    const SizedBox(
                      height: 10,
                    ),
                    TextButton(
                      onPressed: () {},
                      child: const Text('Login'),
                    ),
                  ],
                ),
                const SizedBox(
                  height: 24,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
