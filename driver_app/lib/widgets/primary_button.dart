import 'package:flutter/material.dart';

class PrimaryButton extends StatelessWidget {
  final Key? buttonKey;
  final String text;
  final bool isLoading;
  final VoidCallback? onPressed;

  const PrimaryButton({
    this.buttonKey,
    required this.text,
    this.isLoading = false,
    required this.onPressed,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ElevatedButton(
        key: buttonKey,
        onPressed: isLoading ? null : onPressed,
        child: isLoading
            ? const SizedBox(
                height: 20,
                width: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : Text(text),
      ),
    );
  }
}