// ignore_for_file: use_build_context_synchronously

import 'package:flutter/material.dart';
import 'package:lmb_skripsi/components/base_element.dart';
import 'package:lmb_skripsi/components/button.dart';
import 'package:lmb_skripsi/components/text_field.dart';
import 'package:lmb_skripsi/helpers/logic/authenticator_service.dart';
import 'package:lmb_skripsi/helpers/logic/input_validator.dart';
import 'package:lmb_skripsi/helpers/ui/window_provider.dart';

class ChangeEmailPage extends StatefulWidget {
  final String currentEmail;

  const ChangeEmailPage({
    super.key, 
    required this.currentEmail
  });

  @override
  State<ChangeEmailPage> createState() => _ChangeEmailPageState();
}

class _ChangeEmailPageState extends State<ChangeEmailPage> {
  final emailController = TextEditingController();
  final newEmailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isActionLoading = false;

  @override
  void initState() {
    super.initState();
    emailController.text = widget.currentEmail;
  }

  @override
  Widget build(BuildContext context) {
    return LmbBaseElement(
      isScrollable: true,
      title: "Change Email",
      children: [
        // NOTE: Bagian header
        const Text('For account safety, please use an active email.'),
        const SizedBox(height: 16),
        LmbTextField(
          hint: 'Current Email',
          controller: emailController,
          isDisabled: true,
          inputType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),

        // NOTE: Bagian form utama
        const Text('We will send a verification link to your new email. If you incorrectly entered your password you will be logged out.'),
        const SizedBox(height: 16),
        LmbTextField(
          hint: 'New Email',
          controller: newEmailController,
          inputType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        LmbTextField(
          hint: 'Password',
          controller: passwordController,
          isPassword: true,
          inputType: TextInputType.text,
        ),
        const SizedBox(height: 32),

        // NOTE: Bagian tombol
        LmbPrimaryButton(
          text: 'Confirm',
          isLoading: isActionLoading,
          isFullWidth: true,
          onPressed: () async {
            final email = newEmailController.text.trim();
            final emailError = InputValidator.email(email);
            if (emailError != null) {
              WindowProvider.toastError(context, emailError);
              return;
            }

            setState(() => isActionLoading = true);
            if (await AuthenticatorService.instance.handleChangeEmail(context, email, passwordController.text)) {
              WindowProvider.toastSuccess(context, 'Please check your email inbox');
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