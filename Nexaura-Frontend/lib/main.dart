import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:nexaura/features/app/splash_screen/splash_screen.dart';
import 'package:nexaura/features/app/screen/home_page.dart';
import 'package:nexaura/features/user_auth/presentation/pages/login_page.dart';
import 'package:nexaura/features/user_auth/presentation/pages/sign_up_page.dart';
import 'package:nexaura/theme/theme.dart';

Future main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const Nexaura());
}

class Nexaura extends StatefulWidget {
  const Nexaura({super.key});

  @override
  State<Nexaura> createState() => _NexauraUI();
}

class _NexauraUI extends State<Nexaura> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Firebase',
      theme: lightMode,
      routes: {
        '/': (context) => const SplashScreen(),
        '/login': (context) => const LoginPage(),
        '/signUp': (context) => const SignUpPage(),
        '/home': (context) => const HomePage(),
      },
    );
  }
}
