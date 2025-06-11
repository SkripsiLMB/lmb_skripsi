// ignore_for_file: use_build_context_synchronously

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lmb_skripsi/components/base_element.dart';
import 'package:lmb_skripsi/components/button.dart';
import 'package:lmb_skripsi/components/checkbox.dart';
import 'package:lmb_skripsi/components/text_button.dart';
import 'package:lmb_skripsi/components/text_field.dart';
import 'package:lmb_skripsi/helpers/logic/authenticator_service.dart';
import 'package:lmb_skripsi/helpers/logic/input_validator.dart';
import 'package:lmb_skripsi/helpers/ui/color.dart';
import 'package:lmb_skripsi/helpers/ui/window_provider.dart';
import 'package:lmb_skripsi/pages/auth/children/legal_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final nameController = TextEditingController();
  final nikController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmPasswordController = TextEditingController();
  bool termPolicyAgreement = false;
  bool isActionLoading = false;

  @override
  Widget build(BuildContext context) {
    return LmbBaseElement(
      isScrollable: false,
      isCentered: true,
      showAppbar: false,
      children: [
        // NOTE: Bagian header
        const Text(
          'Sign Up',
          style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: LmbColors.brand),
        ),
        const Text('Join our cooperative community now.'),
        const SizedBox(height: 48),

        // NOTE: Bagian form utama
        LmbTextField(
          hint: 'Name',
          controller: nameController,
          inputType: TextInputType.name,
        ),
        const SizedBox(height: 16),
        LmbTextField(
          hint: 'NIK',
          controller: nikController,
          inputType: TextInputType.number,
        ),
        const SizedBox(height: 16),
        LmbTextField(
          hint: 'Email',
          controller: emailController,
          inputType: TextInputType.emailAddress,
        ),
        const SizedBox(height: 16),
        LmbTextField(
          hint: 'Password',
          controller: passwordController,
          isPassword: true,
        ),
        const SizedBox(height: 16),
        LmbTextField(
          hint: 'Confirm Password',
          controller: confirmPasswordController,
          isPassword: true,
        ),
        const SizedBox(height: 16),

        // NOTE: Bagian checkbox TOS dan PP
        LmbCheckbox.element(
          value: termPolicyAgreement,
          onChanged: (val) => setState(() => termPolicyAgreement = val ?? false),
          element: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyMedium,
              children: [
                const TextSpan(text: 'I agree to '),
                TextSpan(
                  text: 'Terms of Service',
                  style: const TextStyle(
                    color: LmbColors.brand,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LegalPage()),
                    );
                  },
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: const TextStyle(
                    color: LmbColors.brand,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const LegalPage()),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 128),

        // NOTE: Bagian tombol Register dan navigasi ke login
        LmbPrimaryButton(
          text: 'Create Account',
          isLoading: isActionLoading,
          isFullWidth: true,
          onPressed: () async {
            final name = nameController.text.trim();
            final nameError = InputValidator.empty(name, "Name", minLen: 4, maxLen: 64);
            if (nameError != null) {
              WindowProvider.toastError(context, nameError);
              return;
            }

            final nik = nikController.text.trim();
            final nikError = InputValidator.number(nik, "NIK", minLen: 16, maxLen: 16);
            if (nikError != null) {
              WindowProvider.toastError(context, nikError);
              return;
            }

            final email = emailController.text.trim();
            final emailError = InputValidator.email(email);
            if (emailError != null) {
              WindowProvider.toastError(context, emailError);
              return;
            }

            final password = passwordController.text;
            final passwordError = InputValidator.password(password);
            if (passwordError != null) {
              WindowProvider.toastError(context, passwordError);
              return;
            }

            final confirmPassword = confirmPasswordController.text;
            if (password != confirmPassword) {
              WindowProvider.toastError(context, 'Passwords do not match');
              return;
            }

            if (!termPolicyAgreement) {
              WindowProvider.toastError(context, 'You must agree to Terms of Service and Privacy Policy');
              return;
            }
            
            setState(() => isActionLoading = true);
            User? user = await AuthenticatorService.instance.handleRegister(context, name, nik, email, password);
            setState(() => isActionLoading = false);
            if (user != null) {
              Navigator.pop(context);
            }
          },
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Already have an account? '),
            LmbTextButton(
              text: 'Sign in',
              onTap: () {
                  Navigator.pop(context);
              },
            ),
          ],
        ),
      ],
    );
  }
}