import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class SkeletonLoader extends StatelessWidget {
  final double width;
  final double height;
  final BorderRadius? borderRadius;

  const SkeletonLoader({
    super.key,
    required this.width,
    required this.height,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: borderRadius ?? BorderRadius.circular(8),
        ),
      ),
    );
  }
}

class ProductCardSkeleton extends StatelessWidget {
  const ProductCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [
            SkeletonLoader(
              width: 70,
              height: 70,
              borderRadius: BorderRadius.circular(12),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SkeletonLoader(width: double.infinity, height: 16),
                  const SizedBox(height: 8),
                  SkeletonLoader(width: 120, height: 12),
                  const SizedBox(height: 8),
                  SkeletonLoader(width: 80, height: 12),
                ],
              ),
            ),
            const SizedBox(width: 16),
            SkeletonLoader(width: 60, height: 30),
          ],
        ),
      ),
    );
  }
}

class GridCardSkeleton extends StatelessWidget {
  const GridCardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: SkeletonLoader(
                width: double.infinity,
                height: double.infinity,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            const SizedBox(height: 12),
            SkeletonLoader(width: double.infinity, height: 14),
            const SizedBox(height: 6),
            SkeletonLoader(width: 60, height: 12),
            const SizedBox(height: 8),
            SkeletonLoader(width: 80, height: 16),
          ],
        ),
      ),
    );
  }
}

