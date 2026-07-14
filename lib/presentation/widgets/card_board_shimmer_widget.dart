import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';


class ShimmerCardBoardWidget extends StatelessWidget {
  const ShimmerCardBoardWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 310,
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        border: Border.all(
          color: const Color(0xFFD9D9D9),
          width: .4,
        ),
        borderRadius:const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
          bottomLeft: Radius.circular(18),
          bottomRight: Radius.circular(18),
        ),
      ),
      child: Shimmer.fromColors(
        baseColor: Colors.grey[300]!,
        highlightColor: Colors.grey[100]!,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Shimmer for image container
            Container(
              height: 160,
              width: double.infinity,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(18),
              ),
            ),
            const SizedBox(height: 8,),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 4),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Colors.white,
                          shape: BoxShape.circle,
                        ),
                      ),
                       const SizedBox(width: 8,),
                      Container(
                        width: 100,
                        height: 14,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  const SizedBox(height: 8,),
                  Container(
                    width: 200,
                    height: 20,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 8,),
                  _buildShimmerRow(),
                  _buildShimmerRow(),
                  _buildShimmerRow(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildShimmerRow() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 80,
            height: 14,
            color: Colors.white,
          ),
          Container(
            width: 60,
            height: 14,
            color: Colors.white,
          ),
        ],
      ),
    );
  }
}
