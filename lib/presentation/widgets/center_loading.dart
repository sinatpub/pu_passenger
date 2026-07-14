import 'package:com.tara.passenger/core/theme/colors.dart';
import 'package:flutter/material.dart';

class CenterLoading extends StatelessWidget {
  const CenterLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: CircularProgressIndicator(
        color: AppColors.main,
      ),
    );
  }
}
