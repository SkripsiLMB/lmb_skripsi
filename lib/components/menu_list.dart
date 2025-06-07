// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:lmb_skripsi/helpers/ui/color.dart';

class MenuList extends StatelessWidget {
  Widget? trailingItem;
  IconData icon;
  String title;
  String description;
  VoidCallback onTap;
  bool isFirstItem;
  Color color;

  MenuList({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    required this.onTap,
    this.trailingItem,
    this.isFirstItem = false,
    this.color = LmbColors.brand
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Container(
        width: double.infinity,
        padding: EdgeInsetsGeometry.fromLTRB(16, isFirstItem ? 16 : 0, 16, 16),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              spacing: 12,
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadiusGeometry.circular(40),
                  child: Container(
                    width: 40,
                    height: 40,
                    color: Theme.of(context).scaffoldBackgroundColor,
                    child: Center(
                      child: Icon(
                        icon,
                        color: color,
                        size: 24,
                      ),
                    ),
                  ),
                ),

                Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        color: color == LmbColors.brand ? null : color,
                      ),
                    ),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodySmall
                    ),
                  ],
                )
              ],
            ),

            trailingItem ?? Icon(
              Icons.arrow_forward_ios_rounded,
              size: 24,
              color: Theme.of(context).textTheme.bodyMedium?.color ?? Colors.grey,
            )
          ],
        )
      ),
    );
  }
}