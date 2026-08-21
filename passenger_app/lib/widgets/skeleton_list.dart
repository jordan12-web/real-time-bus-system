import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

/// Lightweight shimmer placeholder without external packages.
class _ShimmerBox extends StatefulWidget {
  final Widget child;

  const _ShimmerBox({required this.child});

  @override
  State<_ShimmerBox> createState() => _ShimmerBoxState();
}

class _ShimmerBoxState extends State<_ShimmerBox>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          blendMode: BlendMode.srcATop,
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment(-1 - _controller.value * 2, 0),
              end: Alignment(1 - _controller.value * 2, 0),
              colors: const [
                Color(0x00FFFFFF),
                Color(0x55FFFFFF),
                Color(0x00FFFFFF),
              ],
            ).createShader(bounds);
          },
          child: child,
        );
      },
      child: widget.child,
    );
  }
}

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

    return ListView.separated(
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      separatorBuilder: (context, index) => const SizedBox(height: DesignTokens.spaceSm),
      itemBuilder: (context, index) => _ShimmerBox(
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

    return _ShimmerBox(
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
