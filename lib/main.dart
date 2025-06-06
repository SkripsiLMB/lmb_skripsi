import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:lmb_skripsi/helpers/logic/authenticator_service.dart';
import 'package:lmb_skripsi/helpers/logic/shared_preferences.dart';
import 'package:lmb_skripsi/helpers/logic/theme_notifier.dart';
import 'package:lmb_skripsi/helpers/ui/theme.dart';
import 'package:lmb_skripsi/pages/auth/email_verification_page.dart';
import 'package:lmb_skripsi/pages/auth/login_page.dart';
import 'package:lmb_skripsi/pages/main/main_page.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  if (await LmbLocalStorage.getValue<bool>("remember_me") ?? false) {
    await AuthenticatorService.instance.handleLogout();
  }

  runApp(
    ChangeNotifierProvider(
      create: (_) => ThemeNotifier(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeNotifier>(
      builder: (context, themeNotifier, _) {
        return MaterialApp(
          title: 'Lumbung Makmur Bersama',
          debugShowCheckedModeBanner: false,
          theme: lmbLightTheme,
          darkTheme: lmbDarkTheme,
          themeMode: themeNotifier.themeMode,
          home: const AuthRedirectorGate(),
        );
      },
    );
  }
}

// NOTE: Mengatur starting poin awal yang akan ditemui user
class AuthRedirectorGate extends StatelessWidget {
  const AuthRedirectorGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: AuthenticatorService.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final user = snapshot.data;

        if (user == null) {
          return const LoginPage();
        }

        return FutureBuilder(
          future: user.reload().then((_) => FirebaseAuth.instance.currentUser),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            final refreshedUser = snapshot.data;
            if (refreshedUser != null && !refreshedUser.emailVerified) {
              return const EmailVerificationPage();
            }

            return MainPage();
          },
        );
      },
    );
  }
}