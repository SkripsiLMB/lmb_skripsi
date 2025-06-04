import 'package:flutter/material.dart';
import 'package:lmb_skripsi/helpers/logic/firebase/firebase_handler.dart';
import 'package:lmb_skripsi/helpers/ui/theme.dart';
import 'package:lmb_skripsi/pages/auth/login_page.dart';

void main() {
  initFirebase();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Lumbung Makmur Bersama',
      debugShowCheckedModeBanner: false,
      theme: lmbLightTheme,
      darkTheme: lmbDarkTheme,
      themeMode: ThemeMode.system,
      home: const LoginPage(),
    );
  }
}