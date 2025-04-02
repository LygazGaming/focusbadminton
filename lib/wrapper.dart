import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focusbadminton/auth/login_screen.dart' as auth;
import 'package:focusbadminton/auth/verification_screen.dart';
import 'package:focusbadminton/home_screen.dart';
import 'package:google_sign_in/google_sign_in.dart';

class Wrapper extends StatefulWidget {
  const Wrapper({super.key});

  @override
  State<Wrapper> createState() => _WrapperState();
}

class _WrapperState extends State<Wrapper> {
  @override
  void initState() {
    super.initState();
    // Đảm bảo Google Sign In đã đăng xuất khi vào ứng dụng
    _ensureGoogleSignOut();
  }

  Future<void> _ensureGoogleSignOut() async {
    try {
      final googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        log('Phát hiện Google Sign In còn hoạt động, đang đăng xuất...');
        await googleSignIn.signOut();
        log('Đã đăng xuất khỏi Google Sign In');
      }
    } catch (e) {
      log('Lỗi khi kiểm tra trạng thái Google Sign In: $e');
    }
  }

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
                  child: Text("Đã xảy ra lỗi: ${snapshot.error}"),
                );
              } else {
                if (snapshot.data == null) {
                  log('No user logged in, showing login screen');
                  return const auth.LoginScreen();
                } else {
                  log('User logged in: ${snapshot.data!.email}');
                  log('Email verified: ${snapshot.data!.emailVerified}');

                  // Nếu đăng nhập bằng Google, tự động xác minh email
                  final isGoogleProvider = snapshot.data!.providerData
                      .any((provider) => provider.providerId == 'google.com');

                  if (snapshot.data!.emailVerified || isGoogleProvider) {
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
