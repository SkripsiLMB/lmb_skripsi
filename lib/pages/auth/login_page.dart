import 'package:flutter/material.dart';
import 'package:lmb_skripsi/components/base_element.dart';
import 'package:lmb_skripsi/components/button.dart';
import 'package:lmb_skripsi/components/checkbox.dart';
import 'package:lmb_skripsi/components/text_button.dart';
import 'package:lmb_skripsi/components/textfield.dart';
import 'package:lmb_skripsi/helpers/logic/authenticator_service.dart';
import 'package:lmb_skripsi/helpers/ui/color.dart';
import 'package:lmb_skripsi/pages/auth/register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool rememberMe = false;
  
  final authService = AuthenticatorService();

  @override
  Widget build(BuildContext context) {
    return LmbBaseElement(
      isScrollable: false,
      showNavbar: false,
      children: [
        // NOTE: Bagian header
        const Text(
          'Sign In',
          style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: LmbColors.brand),
          textAlign: TextAlign.center,
        ),
        const Text('Welcome back! Please sign in to continue.'),
        const SizedBox(height: 48),

        // NOTE: Bagian form utama
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

        // NOTE: Bagian form tambahan
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            LmbCheckbox.label(
              value: rememberMe,
              onChanged: (val) => setState(() => rememberMe = val ?? false),
              label: 'Remember me',
            ),
            LmbTextButton(
              text: 'Forgot Password ?',
              onTap: () {
                
              },
            ),
          ],
        ),
        const SizedBox(height: 128),

        // NOTE: Bagian tombol login dan navigasi ke Register
        LmbPrimaryButton(
          text: 'Login',
          onPressed: () {
            authService.handleLogin(context, emailController.text, passwordController.text);
          },
        ),
        const SizedBox(height: 16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Don\'t have account? '),
            LmbTextButton(
              text: 'Sign Up',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const RegisterPage()),
                );
              },
            ),
          ],
        ),
      ]
    );
  }
}