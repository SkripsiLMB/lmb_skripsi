import 'package:flutter/material.dart';
import 'package:lmb_skripsi/helpers/ui/color.dart';

class LmbSnackbar {
  static void onSuccess(BuildContext context, String message) {
    _showSnackbar(context, message, LmbColors.success);
  }

  static void onError(BuildContext context, String message) {
    _showSnackbar(context, message, LmbColors.error);
  }

  static void onInfo(BuildContext context, String message) {
    _showSnackbar(context, message, LmbColors.brand);
  }

  static void _showSnackbar(BuildContext context, String message, Color color) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}