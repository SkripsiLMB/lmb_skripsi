import 'package:flutter/material.dart';
import 'package:lmb_skripsi/components/button.dart';
import 'package:lmb_skripsi/components/text_button.dart';

class LmbDialog extends StatelessWidget {
  final String title;
  final String description;
  final String primaryText;
  final VoidCallback onPrimary;
  final String? secondaryText;
  final VoidCallback? onSecondary;
  final Color color;

  const LmbDialog({
    super.key,
    required this.title,
    required this.description,
    required this.primaryText,
    required this.onPrimary,
    this.secondaryText,
    this.onSecondary,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge,
      ),
      content: Text(
        description,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
      actionsPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      actionsAlignment: MainAxisAlignment.center,
      actions: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            if (secondaryText != null)
              Expanded(
                child: Center(
                  child: LmbTextButton(
                    text: secondaryText!,
                    color: color,
                    onTap: () {
                      Navigator.of(context).pop();
                      if (onSecondary != null) {
                        onSecondary!();
                      }
                    },
                  ),
                )
              ),
            if (secondaryText != null)
              const SizedBox(width: 12), // Add spacing only if both buttons are shown
            Expanded(
              child: LmbPrimaryButton(
                text: primaryText,
                isSmallSize: true,
                isFullWidth: true,
                color: color,
                onPressed: () {
                  Navigator.of(context).pop();
                  onPrimary();
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}