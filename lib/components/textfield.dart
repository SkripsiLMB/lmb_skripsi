import 'package:flutter/material.dart';

class LmbTextField extends StatefulWidget {
  final String hint;
  final TextEditingController controller;
  final TextInputType? inputType;
  final bool isPassword;

  const LmbTextField({
    super.key,
    required this.hint,
    required this.controller,
    this.inputType,
    this.isPassword = false,
  });

  @override
  State<LmbTextField> createState() => _LmbTextFieldState();
}

class _LmbTextFieldState extends State<LmbTextField> {
  bool _obscureText = true;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: widget.controller,
      keyboardType: widget.inputType,
      obscureText: widget.isPassword ? _obscureText : false,
      decoration: InputDecoration(
        hintText: widget.hint,
        suffixIcon: widget.isPassword
            ? IconButton(
                icon: Icon(
                  _obscureText ? Icons.visibility_off : Icons.visibility,
                ),
                onPressed: () => setState(() => _obscureText = !_obscureText),
              )
            : null,
      ),
    );
  }
}