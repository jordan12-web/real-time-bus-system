import 'package:flutter/material.dart';

import 'polished_button.dart';

class PrimaryButton extends StatelessWidget {
  final Key? buttonKey;
  final String text;
  final bool isLoading;
  final VoidCallback? onPressed;
  final IconData? icon;

  const PrimaryButton({
    this.buttonKey,
    required this.text,
    this.isLoading = false,
    required this.onPressed,
    this.icon,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return PolishedButton(
      buttonKey: buttonKey,
      label: text,
      onPressed: onPressed,
      isLoading: isLoading,
      icon: icon,
    );
  }
}