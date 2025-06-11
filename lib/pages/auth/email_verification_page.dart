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
import 'package:lmb_skripsi/helpers/ui/window_provider.dart';
import 'package:lmb_skripsi/pages/main/main_page.dart';

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
  Timer? verificationCheckTimer;
  int secondsLeft = 0;

  @override
  void initState() {
    super.initState();
    _loadEmail();
    _startEmailVerificationCheck();
  }

  @override
  void dispose() {
    cooldownTimer?.cancel();
    verificationCheckTimer?.cancel();
    super.dispose();
  }

  Future<void> _loadEmail() async {
    final rawEmail = await LmbLocalStorage.getValue<String>("email");
    setState(() {
      filteredEmail = ValueFormatter.maskEmail(
        rawEmail ?? AuthenticatorService.instance.currentUser?.email ?? "null",
      );
    });
  }

  void startCooldown() {
    cooldownEndTime = DateTime.now().add(const Duration(minutes: 3));
    cooldownTimer?.cancel();

    cooldownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final now = DateTime.now();
      final diff = cooldownEndTime!.difference(now).inSeconds;

      if (diff <= 0) {
        setState(() {
          secondsLeft = 0;
        });
        timer.cancel();
      } else {
        setState(() {
          secondsLeft = diff;
        });
      }
    });
  }

  void _startEmailVerificationCheck() {
    verificationCheckTimer = Timer.periodic(const Duration(seconds: 3), (timer) async {
      final user = AuthenticatorService.instance.currentUser;
      await user?.reload();
      if (user?.emailVerified ?? false) {
        timer.cancel();
        if (context.mounted) {
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => MainPage()));
        }
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isCooldown = secondsLeft > 0;
    final minutes = secondsLeft ~/ 60;
    final seconds = (secondsLeft % 60).toString().padLeft(2, '0');
    final descriptionText = isCooldown
        ? 'You need to wait $minutes:$seconds before sending another verification link.'
        : 'Please verify that $filteredEmail is your email to continue.';

    return LmbBaseElement(
      isScrollable: false,
      isCentered: true,
      showAppbar: false,
      children: [
        const Text(
          'Verify your email',
          style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: LmbColors.brand),
        ),
        Text(descriptionText),
        const SizedBox(height: 48),

        LmbPrimaryButton(
          text: 'Send Verification Link',
          isLoading: isActionLoading,
          isFullWidth: true,
          isDisabled: isCooldown,
          onPressed: () async {
            setState(() => isActionLoading = true);
            final success = await AuthenticatorService.instance.handleEmailVerification(context);
            if (success) {
              WindowProvider.toastSuccess(context, 'Verification link sent to $filteredEmail');
              startCooldown();
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
      ],
    );
  }
}