
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:lmb_skripsi/components/dialog.dart';
import 'package:lmb_skripsi/helpers/ui/color.dart';

class WindowProvider {

  static void toastSuccess(BuildContext context, String message) {
    showSnackbar(context, message, LmbColors.success);
  }

  static void toastError(BuildContext context, String message, [Object? error]) {
    if (kDebugMode) {
      print('[ERROR] $message | ${error ?? "NULL"}');
    }
    showSnackbar(context, message, LmbColors.error);
  }

  static void toastInfo(BuildContext context, String message) {
    showSnackbar(context, message, LmbColors.brand);
  }

  static void showSnackbar(BuildContext context, String message, Color color) {
    final snackBar = SnackBar(
      content: Text(message),
      backgroundColor: color,
      behavior: SnackBarBehavior.floating,
    );

    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  static void showDialogBox({
    required BuildContext context,
    required String title,
    required String description,
    Widget? content,
    required String primaryText,
    required VoidCallback onPrimary,
    String? secondaryText,
    VoidCallback? onSecondary,
    Color? customColor,
    bool isBarrierDismissable = true,
  }) {
    showDialog(
      context: context,
      barrierDismissible: isBarrierDismissable,
      builder: (BuildContext dialogContext) {
        return LmbDialog(
          title: title,
          description: description,
          content: content,
          primaryText: primaryText,
          onPrimary: onPrimary,
          secondaryText: secondaryText,
          onSecondary: onSecondary,
          color: customColor ?? LmbColors.brand
        );
      },
    );
  }
}