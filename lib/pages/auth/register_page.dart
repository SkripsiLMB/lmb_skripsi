import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:lmb_skripsi/components/base_element.dart';
import 'package:lmb_skripsi/components/button.dart';
import 'package:lmb_skripsi/components/checkbox.dart';
import 'package:lmb_skripsi/components/text_button.dart';
import 'package:lmb_skripsi/components/textfield.dart';
import 'package:lmb_skripsi/helpers/ui/color.dart';

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
  bool termPolicyAgreement = false;

  @override
  Widget build(BuildContext context) {
    return LmbBaseElement(
      isScrollable: false,
      showNavbar: false,
      children: [
      // NOTE: Bagian header
        const Text(
          'Sign Up',
          style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: LmbColors.brand),
          textAlign: TextAlign.center,
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

                  },
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: const TextStyle(
                    color: LmbColors.brand,
                  ),
                  recognizer: TapGestureRecognizer()..onTap = () {

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
          onPressed: () {},
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