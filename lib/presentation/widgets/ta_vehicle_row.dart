import 'package:flutter/material.dart';

import 'package:com.tara.passenger/core/theme/ta_colors.dart';
import 'package:com.tara.passenger/core/theme/ta_shadow.dart';

import 'ta_pressable.dart';

/// Vehicle selection row (`.veh` / `.veh-mini`) — component spec §20.
class TaVehicleRow extends StatelessWidget {
  const TaVehicleRow({
    super.key,
    required this.vehicle,
    this.isSelected = false,
    this.onTap,
    this.compact = false,
    this.onTariffTap,
  });

  final VehicleData vehicle;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool compact;
  final VoidCallback? onTariffTap;

  @override
  Widget build(BuildContext context) {
    if (compact) {
      return _buildCompact(context);
    }
    return TaPressable(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? TaColors.primaryBg : TaColors.surface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected ? TaColors.primary : Colors.transparent,
            width: 1.5,
          ),
          boxShadow: TaShadows.shadowMd,
        ),
        child: Row(
          children: [
            _VehicleArt(size: const Size(84, 52), art: vehicle.art),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    vehicle.name,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w800,
                      color: TaColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${vehicle.seats} · ${vehicle.pricePerKm}',
                    style: const TextStyle(fontSize: 12, color: TaColors.textSecondary),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  vehicle.priceFrom,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: TaColors.primaryDark,
                  ),
                ),
                Row(
                  children: [
                    const Icon(Icons.access_time, size: 13, color: TaColors.textSecondary),
                    const SizedBox(width: 2),
                    Text(
                      vehicle.eta,
                      style: const TextStyle(
                        fontSize: 12,
                        color: TaColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompact(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: TaColors.surface,
        borderRadius: BorderRadius.circular(14),
        boxShadow: TaShadows.shadowSm,
      ),
      child: Row(
        children: [
          _VehicleArt(size: const Size(72, 44), art: vehicle.art),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  vehicle.name,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w800,
                    color: TaColors.textPrimary,
                  ),
                ),
                Text(
                  '${vehicle.seats} · ${vehicle.eta}',
                  style: const TextStyle(fontSize: 12, color: TaColors.textSecondary),
                ),
              ],
            ),
          ),
          TaPressable(
            onTap: onTariffTap,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 9),
              decoration: BoxDecoration(
                color: TaColors.primaryBg,
                borderRadius: BorderRadius.circular(99),
              ),
              child: const Text(
                'Tariff',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w800,
                  color: TaColors.primary,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _VehicleArt extends StatelessWidget {
  const _VehicleArt({required this.size, this.art});

  final Size size;
  final Widget? art;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size.width,
      height: size.height,
      child: art ??
          Container(
            decoration: BoxDecoration(
              color: TaColors.background,
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Icon(
              Icons.directions_car,
              color: TaColors.textMuted,
              size: 30,
            ),
          ),
    );
  }
}

class VehicleData {
  const VehicleData({
    required this.name,
    required this.seats,
    required this.pricePerKm,
    required this.priceFrom,
    required this.eta,
    this.art,
  });

  final String name;
  final String seats;
  final String pricePerKm;
  final String priceFrom;
  final String eta;
  final Widget? art;
}