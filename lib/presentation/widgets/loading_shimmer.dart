import 'package:com.tara.passenger/core/theme/ta_shadow.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

/// Shimmer loading placeholder (roadmap F3 re-skin).
///
/// Token-colored sheen (#EDEEF2 → #F7F7FA, 1.1s) on white cards with the
/// `shadowSm` elevation, per the skeleton spec. Public API unchanged.
class LoadingShimmer extends StatelessWidget {
  final bool isGridView;
  final int crossAxisCount;
  final double childAspectRatio;
  final int dataCount;
  final double? height;
  final double? width;
  final bool isNeedShowFullScreen;
  final Axis? scrollDirection;

  const LoadingShimmer({
    super.key,
    this.isGridView = false,
    this.dataCount = 10,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1,
    this.height,
    this.width,
    this.scrollDirection,
    this.isNeedShowFullScreen = true,
  });

  factory LoadingShimmer.list({
    int dataCount = 2,
    double width = double.infinity,
    double height = 100,
    Axis? scrollDirection = Axis.vertical,
  }) =>
      LoadingShimmer(
        dataCount: dataCount,
        isGridView: false,
        width: width,
        height: height,
        scrollDirection: scrollDirection,
      );

  factory LoadingShimmer.grid({
    int dataCount = 10,
    double childAspectRatio = 1,
    int crossAxisCount = 2,
    double width = double.infinity,
    double height = 100,
  }) =>
      LoadingShimmer(
        isGridView: true,
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        dataCount: dataCount,
        width: width,
        height: height,
      );

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: isNeedShowFullScreen ? Get.height * 0.9 : null,
      child: isGridView
          ? _buildGridView()
          : _buildListView(scrollDirection: scrollDirection),
    );
  }

  Widget _buildGridView() {
    return GridView.builder(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemCount: ((Get.height / height!) * crossAxisCount).toInt(),
      itemBuilder: (context, index) {
        return _card(
          child: Container(
            width: width,
            height: height,
            decoration: _cardDecoration,
          ),
        );
      },
    );
  }

  Widget _buildListView({Axis? scrollDirection}) {
    return ListView.separated(
      scrollDirection: scrollDirection ?? Axis.vertical,
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      padding: const EdgeInsets.all(10),
      itemCount: (Get.height / height!).toInt() - 1,
      separatorBuilder: (context, index) => scrollDirection == Axis.vertical
          ? const SizedBox(
              height: 8,
            )
          : const SizedBox(
              width: 8,
            ),
      itemBuilder: (context, index) {
        return _card(
          child: Container(
            width: width ?? double.infinity,
            height: height ?? 100.0,
            decoration: _cardDecoration,
          ),
        );
      },
    );
  }

  Widget _card({required Widget child}) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Shimmer.fromColors(
        baseColor: const Color(0xFFEDEEF2),
        highlightColor: const Color(0xFFF7F7FA),
        period: const Duration(milliseconds: 1100),
        child: child,
      ),
    );
  }

  BoxDecoration get _cardDecoration => BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: TaShadows.shadowSm,
      );
}