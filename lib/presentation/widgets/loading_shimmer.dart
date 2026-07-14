import 'package:com.tara.passenger/core/utils/get_decoration.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';

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
    Key? key,
    this.isGridView = false,
    this.dataCount = 10,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1,
    this.height,
    this.width,
    this.scrollDirection,
    this.isNeedShowFullScreen = true,
  }) : super(key: key);

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
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              width: width,
              height: height,
              decoration: getBoxDecoration(
                  background: Colors.white,
                  hasShadow: true,
                  borderRadius: BorderRadius.circular(10)),
            ),
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
      padding: EdgeInsets.all(10),
      itemCount: (Get.height / height!).toInt() - 1,
      separatorBuilder: (context, index) => scrollDirection == Axis.vertical
          ? const SizedBox(
              height: 8,
            )
          : const SizedBox(
              width: 8,
            ),
      itemBuilder: (context, index) {
        return ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            child: Container(
              width: width ?? double.infinity,
              height: height ?? 100.0,
              decoration: getBoxDecoration(
                background: Colors.white,
                hasShadow: true,
              ),
            ),
          ),
        );
      },
    );
  }
}
