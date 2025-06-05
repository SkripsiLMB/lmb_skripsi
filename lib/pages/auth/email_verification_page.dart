// ignore_for_file: use_build_context_synchronously

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:lmb_skripsi/components/base_element.dart';
import 'package:lmb_skripsi/components/button.dart';
import 'package:lmb_skripsi/components/text_button.dart';
import 'package:lmb_skripsi/helpers/logic/authenticator_service.dart';
import 'package:lmb_skripsi/helpers/logic/shared_preferences.dart';
import 'package:lmb_skripsi/helpers/logic/value_formatter.dart';
import 'package:lmb_skripsi/helpers/ui/color.dart';
import 'package:lmb_skripsi/helpers/ui/snackbar_handler.dart';

class EmailVerificationPage extends StatefulWidget {
  const EmailVerificationPage({super.key});

  @override
  State<EmailVerificationPage> createState() => _EmailVerificationPageState();
}

class _EmailVerificationPageState extends State<EmailVerificationPage> {
  bool isActionLoading = false;
  String? filteredEmail;

  DateTime? cooldownEndTime;
  Timer? cooldownTimer;
  int secondsLeft = 0;

  @override
  void initState() {
    super.initState();
    _loadEmail();
  }

  @override
  void dispose() {
    cooldownTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadEmail() async {
    final rawEmail = await LmbLocalStorage.getValue<String>("email");
    setState(() {
      filteredEmail = ValueFormatter.maskEmail(rawEmail ?? AuthenticatorService.instance.currentUser?.email ?? "null");
    });
  }

  void startCooldown() {
    cooldownEndTime = DateTime.now().add(const Duration(minutes: 3));
    cooldownTimer?.cancel();

    cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      if (cooldownEndTime!.isBefore(now)) {
        setState(() {
          secondsLeft = 0;
        });
        timer.cancel();
      } else {
        setState(() {
          secondsLeft = cooldownEndTime!.difference(now).inSeconds;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isCooldown = secondsLeft > 0;
    String descriptionText = isCooldown ? 
      'You need to wait ${secondsLeft ~/ 60}:${(secondsLeft % 60).toString().padLeft(2, '0')} before sending another verification link.'
      : 'Please verify that $filteredEmail is your email to continue.';

    return LmbBaseElement(
      isScrollable: false,
      title: "Verify Your Email",
      children: [
        // NOTE: Bagian header
        const Text(
          'Verify your email',
          style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: LmbColors.brand),
        ),
        Text(descriptionText),
        const SizedBox(height: 48),

        // NOTE: Bagian tombol login dan navigasi ke Register
        LmbPrimaryButton(
          text: 'Send Verification Link',
          isLoading: isActionLoading,
          isDisabled: isCooldown,
          onPressed: () async {
            setState(() => isActionLoading = true);
            if (await AuthenticatorService.instance.handleEmailVerification(context)) {
              LmbSnackbar.onSuccess(context, 'Verification link sent to $filteredEmail');
            }
            setState(() => isActionLoading = false);
          },
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Not your account? '),
            LmbTextButton(
              text: 'Sign out',
              onTap: () {
                AuthenticatorService.instance.handleLogout();
              },
            ),
          ],
        ),
        const SizedBox(height: 128),
      ]
    );
  }
}