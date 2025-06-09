import 'package:flutter/material.dart';

class LmbInfoDetail extends StatelessWidget {
  String title;
  String value;
  TextStyle? titleStyle;
  TextStyle? valueStyle;

  LmbInfoDetail({
    super.key,
    required this.title,
    this.titleStyle,
    required this.value,
    this.valueStyle
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: titleStyle ?? Theme.of(context).textTheme.titleSmall,
        ),
        Text(
          value,
          style: valueStyle ?? Theme.of(context).textTheme.bodyMedium,
        )
      ],
    );
  }
}