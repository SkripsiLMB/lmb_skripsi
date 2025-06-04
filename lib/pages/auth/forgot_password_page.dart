import 'package:flutter/material.dart';
import 'package:lmb_skripsi/components/base_element.dart';
import 'package:lmb_skripsi/components/button.dart';
import 'package:lmb_skripsi/components/textfield.dart';
import 'package:lmb_skripsi/helpers/logic/authenticator_service.dart';
import 'package:lmb_skripsi/helpers/ui/color.dart';

class ForgotPasswordPage extends StatefulWidget {
  const ForgotPasswordPage({super.key});

  @override
  State<ForgotPasswordPage> createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final emailController = TextEditingController();
  
  final authService = AuthenticatorService();

  @override
  Widget build(BuildContext context) {
    return LmbBaseElement(
      isScrollable: false,
      children: [
        // NOTE: Bagian header
        const Text(
          'Forgot Password',
          style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: LmbColors.brand),
          textAlign: TextAlign.center,
        ),
        const Text('Forgot your password? Reset it from your email.'),
        const SizedBox(height: 48),

        // NOTE: Bagian form utama
        LmbTextField(
          hint: 'Email',
          controller: emailController,
          inputType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 128),

        // NOTE: Bagian tombol login dan navigasi ke Register
        LmbPrimaryButton(
          text: 'Send Email',
          onPressed: () {
            authService.handleForgotPassword(context, emailController.text);
          },
        ),
      ]
    );
  }
}