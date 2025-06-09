import 'package:flutter/material.dart';

class LmbDropdownField extends StatelessWidget {
  final String hint;
  final String? value;
  final List<String> items;
  final ValueChanged<String?> onChanged;
  final bool useLabel;

  const LmbDropdownField({
    super.key,
    required this.hint,
    required this.value,
    required this.items,
    required this.onChanged,
    this.useLabel = false
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        if (useLabel) Text(
          hint,
          style: Theme.of(context).textTheme.labelMedium,
        ),

        DropdownButtonFormField<String>(
          value: value,
          items: items
              .map((item) => DropdownMenuItem<String>(
                    value: item,
                    child: Text(item),
                  ))
              .toList(),
          onChanged: onChanged,
          icon: const Icon(Icons.keyboard_arrow_down_rounded),
          decoration: InputDecoration(
            hintText: useLabel ? null : hint,
            contentPadding: const EdgeInsets.all(12),
          ),
          menuMaxHeight: 300,
          borderRadius: BorderRadius.circular(12),
        ),
      ],
    );
  }
}