import 'dart:async';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:focusbadminton/wrapper.dart';
import 'package:focusbadminton/auth/login_screen.dart';
import 'package:focusbadminton/auth/signup_screen.dart';
import 'package:focusbadminton/auth/forgot_pass.dart';
import 'package:focusbadminton/auth/verification_screen.dart';
import 'package:focusbadminton/screens/splash_screen.dart';
import 'package:focusbadminton/home_screen.dart';
import 'package:focusbadminton/services/push_notification_service.dart';

// Xử lý thông báo khi ứng dụng đang đóng
@pragma('vm:entry-point')
Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  print('Handling a background message: ${message.messageId}');
}

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();

  // Đăng ký handler cho thông báo nền
  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  final PushNotificationService _notificationService =
      PushNotificationService();

  @override
  void initState() {
    super.initState();
    // Khởi tạo dịch vụ thông báo sau khi build hoàn tất
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeNotifications();
    });
  }

  // Khởi tạo dịch vụ thông báo
  Future<void> _initializeNotifications() async {
    await _notificationService.initialize(context);
  }

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
        '/home': (context) => const HomeScreen(),
        '/verification': (context) => VerificationScreen(
              user: FirebaseAuth.instance.currentUser!,
            ),
      },
    );
  }
}
