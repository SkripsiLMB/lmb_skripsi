import 'package:flutter/material.dart';

class LmbPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool smallSize;

  const LmbPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.smallSize = false,
  });

  @override
  Widget build(BuildContext context) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(
        minimumSize: smallSize ? const Size(120, 40) : const Size(double.infinity, 56),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: smallSize ? 12 : 16
        ),
      ),
    );
  }
}