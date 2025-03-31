import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focusbadminton/auth/login_screen.dart' as auth;
import 'package:focusbadminton/auth/verification_screen.dart';
import 'package:focusbadminton/home_screen.dart';

class Wrapper extends StatelessWidget {
  const Wrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: StreamBuilder(
            stream: FirebaseAuth.instance.authStateChanges(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (snapshot.hasError) {
                return Center(
                  child: Text("Lỗi"),
                );
              } else {
                if (snapshot.data == null) {
                  log('No user logged in, showing login screen');
                  return const auth.LoginScreen();
                } else {
                  log('User logged in: ${snapshot.data!.email}');
                  log('Email verified: ${snapshot.data!.emailVerified}');
                  if (snapshot.data!.emailVerified == true) {
                    log('Navigating to HomeScreen');
                    return const HomeScreen();
                  }
                  log('Navigating to VerificationScreen');
                  return VerificationScreen(
                    user: snapshot.data!,
                  );
                }
              }
            }));
  }
}
