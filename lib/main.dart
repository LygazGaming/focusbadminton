import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focusbadminton/wrapper.dart';
import 'package:focusbadminton/auth/login_screen.dart';
import 'package:focusbadminton/auth/signup_screen.dart';
import 'package:focusbadminton/auth/forgot_pass.dart';
import 'package:focusbadminton/auth/verification_screen.dart';
import 'package:focusbadminton/screens/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/splash',
      routes: {
        '/splash': (context) => const SplashScreen(),
        '/': (context) => const Wrapper(),
        '/login': (context) => const LoginScreen(),
        '/signup': (context) => const SignupScreen(),
        '/forgot-password': (context) => const ForgotPassword(),
        '/verification': (context) => VerificationScreen(
              user: FirebaseAuth.instance.currentUser!,
            ),
      },
    );
  }
}
