import 'package:flutter/material.dart';

/// 5-star rating input (`.stars`) — component spec §17.
///
/// Presentational: callers own state via [rating]; optional [onChanged]
/// reports the tapped star (1-based). Includes the `pop3` bounce animation
/// (scale 1.3, 250ms) on the last selected star.
class TaStarRating extends StatefulWidget {
  const TaStarRating({
    super.key,
    this.rating = 0,
    this.onChanged,
  });

  final int rating;
  final ValueChanged<int>? onChanged;

  @override
  State<TaStarRating> createState() => _TaStarRatingState();
}

class _TaStarRatingState extends State<TaStarRating> {
  int? _popping;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        for (var i = 1; i <= 5; i++) ...[
          if (i > 1) const SizedBox(width: 10),
          _buildStar(i),
        ],
      ],
    );
  }

  Widget _buildStar(int index) {
    final lit = index <= widget.rating;
    final popping = _popping == index;
    return GestureDetector(
      onTap: widget.onChanged == null
          ? null
          : () {
              widget.onChanged!(index);
              setState(() => _popping = index);
              Future.delayed(
                const Duration(milliseconds: 300),
                () {
                  if (mounted && _popping == index) {
                    setState(() => _popping = null);
                  }
                },
              );
            },
      child: AnimatedScale(
        scale: popping ? 1.3 : 1.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOutBack,
        child: Icon(
          Icons.star,
          size: 44,
          color: lit ? const Color(0xFFF5A623) : const Color(0xFFDCDDE5),
        ),
      ),
    );
  }
}