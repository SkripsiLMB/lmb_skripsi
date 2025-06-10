import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_svg/svg.dart';
import 'package:lmb_skripsi/helpers/logic/authenticator_service.dart';
import 'package:lmb_skripsi/helpers/logic/midtrans_service.dart';
import 'package:lmb_skripsi/helpers/logic/remote_config_service.dart';
import 'package:lmb_skripsi/helpers/logic/shared_preferences.dart';
import 'package:lmb_skripsi/helpers/logic/supabase_service.dart';
import 'package:lmb_skripsi/helpers/logic/theme_notifier.dart';
import 'package:lmb_skripsi/helpers/ui/theme.dart';
import 'package:lmb_skripsi/helpers/ui/window_provider.dart';
import 'package:lmb_skripsi/pages/auth/email_verification_page.dart';
import 'package:lmb_skripsi/pages/auth/login_page.dart';
import 'package:lmb_skripsi/pages/main/main_page.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp();
  await RemoteConfigService.instance.initialize();
  await SupabaseService.initializeApp();
  await MidTransService.initialize();

  final isRemembered = await LmbLocalStorage.getValue<bool>("remember_me") ?? false;
  final isLoggedIn = FirebaseAuth.instance.currentUser != null;
  if (!isRemembered && isLoggedIn) {
    await AuthenticatorService.instance.handleLogout();
  }

  runApp(
    RestartWidget(
      child: ChangeNotifierProvider(
        create: (_) => ThemeNotifier(),
        child: const MyApp(),
      ),
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
          title: 'Lumbung Makmur',
          debugShowCheckedModeBanner: false,
          theme: lmbLightTheme,
          darkTheme: lmbDarkTheme,
          themeMode: themeNotifier.themeMode,
          home: const AcessRedirectorGate(),
        );
      },
    );
  }
}

// NOTE: Mengatur apa yang akan ditampilkan pertama kali
class AcessRedirectorGate extends StatefulWidget {
  const AcessRedirectorGate({super.key});

  @override
  State<AcessRedirectorGate> createState() => _AcessRedirectorGateState();
}

class _AcessRedirectorGateState extends State<AcessRedirectorGate> {
  late Future<bool> isAppDisabledFuture;

  @override
  void initState() {
    super.initState();
    _loadAppDisabledStatus();
  }

  void _loadAppDisabledStatus() {
    isAppDisabledFuture = RemoteConfigService.instance.get<bool>(
      'is_app_disabled_config',
      (json) => json as bool
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: isAppDisabledFuture,
      builder: (context, snapshot) {
        // NOTE: Loading config
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            body: Center(
              child: ClipRRect(
                borderRadius: BorderRadiusGeometry.circular(12),
                child: Image(
                  image: AssetImage("assets/app_icon.png"),
                  width: 80,
                  height: 80,
                  fit: BoxFit.cover,
                ),
              ),
            ),
          );
        }

        // NOTE: Jika config dimatikan
        if ((snapshot.data ?? false) || snapshot.hasError) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final title = snapshot.hasError ? "Config Malfunction" : "Application Disabled";
            const description = "This application has been temporarily disabled by the developer for internal reasons. Please contact the developer for further information or assistance.";            WindowProvider.showDialogBox(
            context: context,
            isBarrierDismissable: false,
            title: title,
            description: description,
            content: GestureDetector(
              onLongPress: () async {
                await RemoteConfigService.instance.forceRefetch();
                setState(() {
                  _loadAppDisabledStatus();
                  Navigator.of(context).pop();
                });
              },
              child: SvgPicture.asset(
                "assets/warning_illustration_icon.svg",
                width: 120,
                height: 120,
                fit: BoxFit.contain,
                alignment: Alignment.center,
              ),
            ),
            primaryText: "Close Application",
            onPrimary: () {
              if (Platform.isAndroid) {
                SystemNavigator.pop();
              } else if (Platform.isIOS) {
                exit(0);
              }
            });
          });
        }

        // NOTE: Mengatur page mana yang akan ditampilkan pertama kali
        return StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            // NOTE: Loading login
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // NOTE: Belum login
            if (snapshot.data == null) {
              return const LoginPage();
            }

            return FutureBuilder(
              future: snapshot.data?.reload().then((_) => FirebaseAuth.instance.currentUser),
              builder: (context, snapshot) {
                // NOTE: Loading verif
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Scaffold(
                    body: Center(child: CircularProgressIndicator()),
                  );
                }

                // NOTE: Belum verif
                if (!(snapshot.data?.emailVerified ?? true)) {
                  return const EmailVerificationPage();
                }

                // NOTE: Sudah verif dan login
                return const MainPage();
              },
            );
          },
        );
      },
    );
  }
}

// NOTE: Helper elemen untuk bantuin force hot restart
class RestartWidget extends StatefulWidget {
  final Widget child;

  const RestartWidget({super.key, required this.child});

  static void restartApp(BuildContext context) {
    final state = context.findAncestorStateOfType<_RestartWidgetState>();
    state?.restartApp();
  }

  @override
  State<RestartWidget> createState() => _RestartWidgetState();
}

class _RestartWidgetState extends State<RestartWidget> {
  Key key = UniqueKey();

  void restartApp() {
    setState(() {
      key = UniqueKey();
    });
  }

  @override
  Widget build(BuildContext context) {
    return KeyedSubtree(
      key: key,
      child: widget.child,
    );
  }
}