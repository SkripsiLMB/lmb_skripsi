import 'package:flutter/material.dart';
import 'package:lmb_skripsi/helpers/ui/color.dart';

class LmbTextButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final Color color;

  const LmbTextButton({
    super.key, 
    required this.text, 
    required this.onTap,
    this.color = LmbColors.brand
    });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }
}