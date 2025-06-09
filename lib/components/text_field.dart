import 'package:flutter/material.dart';

class LmbTextField extends StatefulWidget {
  final String hint;
  final TextEditingController controller;
  final TextInputType? inputType;
  final bool isPassword;
  final bool useLabel;
  final bool isDisabled;
  final double? height;
  final Widget? prefixIcon;
  final Widget? suffixIcon;

  const LmbTextField({
    super.key,
    required this.hint,
    required this.controller,
    this.inputType,
    this.isPassword = false,
    this.useLabel = false,
    this.isDisabled = false,
    this.height,
    this.prefixIcon,
    this.suffixIcon
  });

  @override
  State<LmbTextField> createState() => _LmbTextFieldState();
}

class _LmbTextFieldState extends State<LmbTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.useLabel)
          Text(
            widget.hint,
            style: Theme.of(context).textTheme.labelMedium,
          ),
        const SizedBox(height: 8),

        SizedBox(
          height: widget.height,
          child: TextField(
            controller: widget.controller,
            keyboardType: widget.inputType,
            obscureText: widget.isPassword ? _obscureText : false,
            maxLines: widget.height != null ? null : 1,
            expands: widget.height != null,
            enabled: !widget.isDisabled,
            decoration: InputDecoration(
              hintText: widget.useLabel ? null : widget.hint,
              prefixIcon: widget.prefixIcon != null 
              ? Container(
                  padding: EdgeInsets.fromLTRB(12, 12, 0, 12),
                  child: widget.prefixIcon,
                ) 
              : null,
              suffixIcon: widget.isPassword
                ? IconButton(
                    icon: Icon(
                      _obscureText ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => _obscureText = !_obscureText),
                  )
                : widget.suffixIcon != null 
                  ? Container(
                      padding: EdgeInsets.fromLTRB(12, 12, 0, 12),
                      child: widget.suffixIcon,
                    ) 
                  : null,
              contentPadding: EdgeInsets.all(12),
            ),
            textAlignVertical: TextAlignVertical.top,
            textAlign: TextAlign.start,
          ),
        ),
      ],
    );
  }
}