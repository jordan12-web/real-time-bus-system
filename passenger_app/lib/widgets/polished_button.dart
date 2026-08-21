import 'package:flutter/material.dart';

import '../theme/design_tokens.dart';

enum PolishedButtonVariant { primary, secondary }

/// Pill-shaped button with press scale + shadow lift animation.
class PolishedButton extends StatefulWidget {
  final String label;
  final VoidCallback? onPressed;
  final bool isLoading;
  final PolishedButtonVariant variant;
  final IconData? icon;
  final bool expand;

  const PolishedButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.isLoading = false,
    this.variant = PolishedButtonVariant.primary,
    this.icon,
    this.expand = true,
  });

  @override
  State<PolishedButton> createState() => _PolishedButtonState();
}

class _PolishedButtonState extends State<PolishedButton> {
  bool _pressed = false;

  bool get _enabled => !widget.isLoading && widget.onPressed != null;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final primary = isDark ? DesignTokens.darkPrimary : DesignTokens.primary;
    final accent = isDark ? DesignTokens.darkAccent : DesignTokens.accent;

    final Color background;
    final Color foreground;
    final BorderSide? border;

    if (!_enabled) {
      background = Theme.of(context).colorScheme.surfaceContainerHighest;
      foreground = Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.4);
      border = widget.variant == PolishedButtonVariant.secondary
          ? BorderSide(color: foreground.withValues(alpha: 0.3))
          : null;
    } else if (widget.variant == PolishedButtonVariant.primary) {
      background = primary;
      foreground = Colors.white;
      border = null;
    } else {
      background = Colors.transparent;
      foreground = accent;
      border = BorderSide(color: accent, width: 1.5);
    }

    final child = widget.isLoading
        ? SizedBox(
            width: 24,
            height: 24,
            child: CircularProgressIndicator(
              strokeWidth: 2,
              color: foreground,
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (widget.icon != null) ...[
                Icon(widget.icon, size: 20, color: foreground),
                const SizedBox(width: DesignTokens.spaceXs),
              ],
              Text(widget.label, style: TextStyle(color: foreground)),
            ],
          );

    return Semantics(
      button: true,
      enabled: _enabled,
      label: widget.label,
      child: GestureDetector(
        onTapDown: _enabled ? (_) => setState(() => _pressed = true) : null,
        onTapUp: _enabled
            ? (_) {
                setState(() => _pressed = false);
                widget.onPressed?.call();
              }
            : null,
        onTapCancel: _enabled ? () => setState(() => _pressed = false) : null,
        child: AnimatedScale(
          scale: _pressed ? 0.96 : 1.0,
          duration: DesignTokens.microInteraction,
          curve: DesignTokens.easing,
          child: AnimatedContainer(
            duration: DesignTokens.microInteraction,
            curve: DesignTokens.easing,
            height: DesignTokens.buttonHeight,
            width: widget.expand ? double.infinity : null,
            padding: widget.expand
                ? null
                : const EdgeInsets.symmetric(horizontal: DesignTokens.spaceLg),
            decoration: BoxDecoration(
              color: background,
              borderRadius: BorderRadius.circular(DesignTokens.radiusPill),
              border: border != null ? Border.fromBorderSide(border) : null,
              boxShadow: _enabled && widget.variant == PolishedButtonVariant.primary
                  ? DesignTokens.cardShadow(pressed: _pressed)
                  : null,
            ),
            alignment: Alignment.center,
            child: child,
          ),
        ),
      ),
    );
  }
}
