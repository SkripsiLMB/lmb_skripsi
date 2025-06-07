import 'package:flutter/material.dart';
import 'package:lmb_skripsi/helpers/ui/color.dart';

class LmbTextButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;
  final double size;
  final Color color;
  final IconData? suffixIcon;

  const LmbTextButton({
    super.key, 
    required this.text, 
    required this.onTap,
    this.size = 14,
    this.color = LmbColors.brand,
    this.suffixIcon
    });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: size,
              fontWeight: FontWeight.w500,
            ),
          ),
          if (suffixIcon != null) Icon(
            suffixIcon,
            size: size,
            color: color,
          )
        ],
      ),
    );
  }
}