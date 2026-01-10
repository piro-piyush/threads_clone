import 'package:flutter/material.dart';

class SearchLoadingWidget extends StatelessWidget {
  const SearchLoadingWidget({super.key, this.itemCount = 6});

  final int itemCount;

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      shrinkWrap: true,
      itemCount: itemCount,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemBuilder: (_, _) => const _UserTileSkeleton(),
    );
  }
}

class _UserTileSkeleton extends StatelessWidget {
  const _UserTileSkeleton();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color baseColor = isDark ? Colors.grey.shade800 : Colors.grey.shade300;

    return ListTile(
      leading: Padding(
        padding: const EdgeInsets.only(top: 5),
        child: _SkeletonCircle(size: 56, color: baseColor),
      ),
      titleAlignment: ListTileTitleAlignment.top,
      title: _SkeletonBox(
        height: 14,
        width: MediaQuery.of(context).size.width * 0.45,
        color: baseColor,
      ),
      subtitle: Padding(
        padding: const EdgeInsets.only(top: 6),
        child: _SkeletonBox(height: 12, width: 12, color: baseColor),
      ),
      trailing: _SkeletonBox(
        height: 32,
        width: 90,
        radius: 16,
        color: baseColor,
      ),
    );
  }
}

class _SkeletonBox extends StatelessWidget {
  const _SkeletonBox({
    required this.height,
    required this.width,
    required this.color,
    this.radius = 8,
  });

  final double height;
  final double width;
  final double radius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(radius),
      ),
    );
  }
}

class _SkeletonCircle extends StatelessWidget {
  const _SkeletonCircle({required this.size, required this.color});

  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: size,
      width: size,
      decoration: BoxDecoration(color: color, shape: BoxShape.circle),
    );
  }
}
