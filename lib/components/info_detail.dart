import 'package:flutter/material.dart';

class LmbInfoDetail extends StatelessWidget {
  String title;
  String value;

  LmbInfoDetail({
    super.key,
    required this.title,
    required this.value
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleSmall,
        ),
        Text(value)
      ],
    );
  }
}