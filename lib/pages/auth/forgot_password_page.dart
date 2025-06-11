// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:lmb_skripsi/components/base_element.dart';
import 'package:lmb_skripsi/components/button.dart';
import 'package:lmb_skripsi/components/text_field.dart';
import 'package:lmb_skripsi/helpers/logic/authenticator_service.dart';
import 'package:lmb_skripsi/helpers/logic/input_validator.dart';
import 'package:lmb_skripsi/helpers/ui/color.dart';
import 'package:lmb_skripsi/helpers/ui/window_provider.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();
  bool isActionLoading = false;

  @override
  Widget build(BuildContext context) {
    return LmbBaseElement(
      isScrollable: false,
      isCentered: true,
      title: "Reset Password",
      children: [
        // NOTE: Bagian header
        const Text(
          'No worries!',
          style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: LmbColors.brand),
        ),
        const Text('We\'ll send you an email to reset your password.'),
        const SizedBox(height: 48),

        // NOTE: Bagian form utama
        LmbTextField(
          hint: 'Email',
          controller: emailController,
          inputType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),

        // NOTE: Bagian tombol login dan navigasi ke Register
        LmbPrimaryButton(
          text: 'Send Email',
          isLoading: isActionLoading,
          isFullWidth: true,
          onPressed: () async {
            final email = emailController.text.trim();
            final emailError = InputValidator.email(email);
            if (emailError != null) {
              WindowProvider.toastError(context, emailError);
              return;
            }

            setState(() {
              FocusScope.of(context).unfocus();
              isActionLoading = true;
            });
            if (await AuthenticatorService.instance.handleForgotPassword(context, email)) {
              WindowProvider.toastSuccess(context, 'Email sent to $email');
              Navigator.pop(context);
            }
            setState(() => isActionLoading = false);
          },
        ),

        const SizedBox(height: 128),
      ]
    );
  }
}