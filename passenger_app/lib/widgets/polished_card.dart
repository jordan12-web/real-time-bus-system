import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

/// Rounded card with elevation lift animation on press.
class PolishedCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry? margin;

  const PolishedCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(DesignTokens.spaceMd),
    this.onTap,
    this.margin,
  });

  @override
  State<PolishedCard> createState() => _PolishedCardState();
}

class _PolishedCardState extends State<PolishedCard> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).cardTheme.color ?? Theme.of(context).colorScheme.surface;

    final card = AnimatedContainer(
      duration: DesignTokens.microInteraction,
      curve: DesignTokens.easing,
      margin: widget.margin,
      transform: Matrix4.translationValues(0, _pressed ? -2 : 0, 0),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(DesignTokens.radiusGlobal),
        boxShadow: DesignTokens.cardShadow(pressed: _pressed),
      ),
      child: Padding(padding: widget.padding, child: widget.child),
    );

    if (widget.onTap == null) return card;

    return Semantics(
      button: true,
      label: 'Card action',
      child: GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap?.call();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: card,
      ),
    );
  }
}
