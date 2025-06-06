import 'package:flutter/material.dart';

class LmbCard extends StatelessWidget {
  Widget child;
  bool usePadding;
  
  LmbCard({
    super.key,
    required this.child,
    this.usePadding = true
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadiusGeometry.circular(8),
      child: Container(
        width: double.infinity,
        color: Theme.of(context).cardColor,
        padding: usePadding ? EdgeInsets.symmetric(horizontal: 16, vertical: 12) : null,
        child: child
      )
    );
  }
}