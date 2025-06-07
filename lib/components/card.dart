import 'package:flutter/material.dart';

class LmbCard extends StatelessWidget {
  Widget child;
  bool usePadding;
  bool isFullWidth;
  
  LmbCard({
    super.key,
    required this.child,
    this.usePadding = true,
    this.isFullWidth = false
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadiusGeometry.circular(8),
      child: Container(
        width: isFullWidth ? double.infinity : null,
        color: Theme.of(context).cardColor,
        padding: usePadding ? EdgeInsets.symmetric(horizontal: 16, vertical: 12) : null,
        child: child
      )
    );
  }
}