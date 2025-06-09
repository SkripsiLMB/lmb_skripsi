import 'package:flutter/material.dart';

class LmbCheckbox extends StatelessWidget {
  final bool value;
  final ValueChanged<bool?> onChanged;
  final String? label;
  final Widget? element;

  // NOTE: Constructor utama
  const LmbCheckbox._({
    super.key,
    required this.value,
    required this.onChanged,
    this.label,
    this.element,
  });

  // NOTE: Constructor untuk label bentuk teks
  const LmbCheckbox.label({
    Key? key,
    required bool value,
    required ValueChanged<bool?> onChanged,
    required String label,
  }) : this._(
          key: key,
          value: value,
          onChanged: onChanged,
          label: label,
        );

  // NOTE: Constructor untuk label bentuk element
  const LmbCheckbox.element({
    Key? key,
    required bool value,
    required ValueChanged<bool?> onChanged,
    required Widget element,
  }) : this._(
          key: key,
          value: value,
          onChanged: onChanged,
          element: element,
        );

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: 20,
          width: 20,
          child: Checkbox(
            visualDensity: VisualDensity.compact,
            materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            value: value,
            onChanged: onChanged,
          ),
        ),
        const SizedBox(width: 8),

        // NOTE: Cek pake element atau text
        element ??
          Text(
            label!,
            softWrap: true,
          ),
      ],
    );
  }
}