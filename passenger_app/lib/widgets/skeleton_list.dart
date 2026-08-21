import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

import '../theme/design_tokens.dart';

/// Skeleton placeholder list for loading states.
class SkeletonList extends StatelessWidget {
  final int itemCount;
  final bool showRouteLine;

  const SkeletonList({
    super.key,
    this.itemCount = 4,
    this.showRouteLine = true,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final highlight = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      separatorBuilder: (_, __) => const SizedBox(height: DesignTokens.spaceSm),
      itemBuilder: (_, __) => Shimmer.fromColors(
        baseColor: base,
        highlightColor: highlight,
        child: Container(
          height: showRouteLine ? 96 : 72,
          decoration: BoxDecoration(
            color: base,
            borderRadius: BorderRadius.circular(DesignTokens.radiusGlobal),
          ),
        ),
      ),
    );
  }
}

/// Single skeleton block for ticket/detail loading.
class SkeletonBlock extends StatelessWidget {
  final double height;
  final double? width;

  const SkeletonBlock({super.key, required this.height, this.width});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final base = isDark ? const Color(0xFF1E293B) : const Color(0xFFE2E8F0);
    final highlight = isDark ? const Color(0xFF334155) : const Color(0xFFF1F5F9);

    return Shimmer.fromColors(
      baseColor: base,
      highlightColor: highlight,
      child: Container(
        height: height,
        width: width ?? double.infinity,
        decoration: BoxDecoration(
          color: base,
          borderRadius: BorderRadius.circular(DesignTokens.radiusGlobal),
        ),
      ),
    );
  }
}
