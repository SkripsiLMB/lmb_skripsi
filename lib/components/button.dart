import 'package:flutter/material.dart';
import 'package:lmb_skripsi/helpers/ui/color.dart';

class LmbPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final bool smallSize;
  final bool isLoading;
  final bool isDisabled;

  const LmbPrimaryButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.smallSize = false,
    this.isLoading = false,
    this.isDisabled = false
  });

  @override
  Widget build(BuildContext context) {
    final bool inactive = isLoading || isDisabled;

    return ElevatedButton(
      onPressed: (isLoading || isDisabled) ? null : onPressed,
      style: ElevatedButton.styleFrom(
        backgroundColor: inactive ? Colors.grey.shade600 : LmbColors.brand,
        foregroundColor: Colors.white,
        minimumSize: smallSize ? const Size(120, 40) : const Size(double.infinity, 56),
      ),
      child: isLoading
        ? SizedBox(
            width: smallSize ? 16 : 20,
            height: smallSize ? 16 : 20,
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            ),
          )
        : Text(
            text,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: smallSize ? 12 : 16,
            ),
          ),
    );
  }
}