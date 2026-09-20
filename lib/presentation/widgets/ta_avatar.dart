import 'package:flutter/material.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/theme/ta_shadow.dart';

import 'ta_pressable.dart';

/// Circular avatar with initials or image (`.davatar` / `.havatar` /
/// `.avatar-pick`) — component spec §12.
class TaAvatar extends StatelessWidget {
  const TaAvatar({
    super.key,
    required this.variant,
    this.initials,
    this.imageUrl,
    this.onCameraTap,
  });

  final TaAvatarVariant variant;
  final String? initials;
  final String? imageUrl;
  final VoidCallback? onCameraTap;

  double get _size {
    switch (variant) {
      case TaAvatarVariant.driver:
        return 52;
      case TaAvatarVariant.history:
        return 44;
      case TaAvatarVariant.profile:
        return 48;
      case TaAvatarVariant.register:
        return 120;
    }
  }

  @override
  Widget build(BuildContext context) {
    if (variant == TaAvatarVariant.register) {
      return _buildRegister();
    }

    final gradient = variant == TaAvatarVariant.driver
        ? const [Color(0xFF2F6BFF), Color(0xFF7A5CFF)]
        : const [Color(0xFFFF6A00), Color(0xFFB73CFF)];

    return Container(
      width: _size,
      height: _size,
      alignment: Alignment.center,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: gradient,
        ),
        shape: BoxShape.circle,
      ),
      child: imageUrl != null
          ? ClipOval(
              child: Image.network(
                imageUrl!,
                width: _size,
                height: _size,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => _initialsText(),
              ),
            )
          : _initialsText(),
    );
  }

  Widget _initialsText() {
    if (initials == null || initials!.isEmpty) {
      return Icon(
        Icons.person,
        color: Colors.white.withValues(alpha: 0.9),
        size: _size * 0.5,
      );
    }
    return Text(
      initials!,
      style: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w800,
        fontSize: variant == TaAvatarVariant.driver ? 18 : 15,
      ),
    );
  }

  Widget _buildRegister() {
    return SizedBox(
      width: _size,
      height: _size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: _size,
            height: _size,
            decoration: BoxDecoration(
              color: TaColors.surface,
              shape: BoxShape.circle,
              boxShadow: TaShadows.shadowMd,
            ),
            child: imageUrl != null
                ? ClipOval(
                    child: Image.network(
                      imageUrl!,
                      width: _size,
                      height: _size,
                      fit: BoxFit.cover,
                    ),
                  )
                : const Icon(
                    Icons.person,
                    size: 56,
                    color: TaColors.textMuted,
                  ),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: TaPressable(
              onTap: onCameraTap,
              child: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: TaColors.primary,
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: TaColors.primary.withValues(alpha: 0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.camera_alt,
                  color: Colors.white,
                  size: 18,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

enum TaAvatarVariant { driver, history, profile, register }