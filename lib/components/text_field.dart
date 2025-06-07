import 'package:flutter/material.dart';

class LmbTextField extends StatefulWidget {
  final String hint;
  final TextEditingController controller;
  final TextInputType? inputType;
  final bool isPassword;
  final bool useLabel;
  final bool isDisabled;

  const LmbTextField({
    super.key,
    required this.hint,
    required this.controller,
    this.inputType,
    this.isPassword = false,
    this.useLabel = false,
    this.isDisabled = false
  });

  @override
  State<LmbTextField> createState() => _LmbTextFieldState();
}

class _LmbTextFieldState extends State<LmbTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      crossAxisAlignment: CrossAxisAlignment.start,
      spacing: 8,
      children: [
        if (widget.useLabel) Text(
          widget.hint,
          style: Theme.of(context).textTheme.labelMedium,
        ),

        TextField(
          controller: widget.controller,
          keyboardType: widget.inputType,
          obscureText: widget.isPassword ? _obscureText : false,
          enabled: !widget.isDisabled,
          decoration: InputDecoration(
            hintText: widget.useLabel ? null : widget.hint,
            suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => _obscureText = !_obscureText),
                  )
                : null,
          ),
        ),
      ],
    );
  }
}