import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

/// Styled brand header with "Guzo" script lettering and bus icon badge.
class GuzoLogo extends StatelessWidget {
  final double size;
  final bool showTagline;
  final bool compact;

  const GuzoLogo({
    super.key,
    this.size = 32,
    this.showTagline = true,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? DesignTokens.darkPrimary : DesignTokens.primary;
    final accent = isDark ? DesignTokens.darkAccent : DesignTokens.accent;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: EdgeInsets.all(compact ? 6 : 10),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [primary, accent],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(DesignTokens.radiusGlobal),
                boxShadow: [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.3),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Icon(
                Icons.directions_bus_rounded,
                size: compact ? 22 : size * 0.9,
                color: Colors.white,
              ),
            ),
            const SizedBox(width: DesignTokens.spaceSm),
            ShaderMask(
              shaderCallback: (bounds) => LinearGradient(
                colors: [primary, accent],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ).createShader(bounds),
              child: Text(
                'Guzo',
                style: TextStyle(
                  fontFamily: DesignTokens.fontFamily,
                  fontFamilyFallback: DesignTokens.fontFamilyFallback,
                  fontSize: size,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        if (showTagline && !compact) ...[
          const SizedBox(height: DesignTokens.spaceXs),
          Text(
            'Smart Intercity Bus Travel',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: isDark ? Colors.white70 : const Color(0xFF64748B),
              letterSpacing: 0.2,
            ),
          ),
        ],
      ],
    );
  }
}
