import 'package:flutter/material.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';

/// Optional driver note input (`.note-field`) — component spec §24.
class TaNoteField extends StatelessWidget {
  const TaNoteField({
    super.key,
    this.controller,
    this.hint,
    this.onChanged,
  });

  final TextEditingController? controller;
  final String? hint;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: TaColors.background,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          const Icon(Icons.description_outlined, size: 18, color: TaColors.textSecondary),
          const SizedBox(width: 8),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: const TextStyle(
                fontSize: 13,
                color: TaColors.textPrimary,
              ),
              decoration: InputDecoration(
                isCollapsed: true,
                border: InputBorder.none,
                hintText: hint,
                hintStyle: const TextStyle(
                  fontSize: 13,
                  color: TaColors.textSecondary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}