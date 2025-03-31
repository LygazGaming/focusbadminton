import 'dart:async';
import 'dart:developer';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:focusbadminton/auth/auth_service.dart';
import 'package:focusbadminton/wrapper.dart';

class VerificationScreen extends StatefulWidget {
  final User user;
  const VerificationScreen({super.key, required this.user});

  @override
  State<VerificationScreen> createState() => _VerificationScreenState();
}

class _VerificationScreenState extends State<VerificationScreen> {
  final _auth = AuthService();
  late Timer timer;
  bool _isResending = false;
  int _countDown = 60;
  late Timer _countDownTimer;
  String _email = '';

  @override
  void initState() {
    super.initState();

    // Get current user email
    _email = widget.user.email ?? 'email của bạn';
    log('Màn hình xác nhận được khởi tạo cho email: $_email');

    // Gửi email xác nhận
    _auth.sendEmailVerificationLink();

    // Kiểm tra trạng thái xác nhận email mỗi 5 giây
    timer = Timer.periodic(const Duration(seconds: 5), (timer) {
      log('Đang kiểm tra trạng thái xác nhận email...');
      widget.user.reload().then((_) {
        log('Email đã xác nhận: ${widget.user.emailVerified}');
        if (widget.user.emailVerified) {
          log('Email đã xác nhận, hủy timer');
          timer.cancel();
          if (mounted) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        }
      });
    });

    // Bắt đầu đếm ngược cho nút gửi lại
    _startCountdownTimer();
  }

  void _startCountdownTimer() {
    setState(() {
      _countDown = 60;
      _isResending = true;
    });

    _countDownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countDown > 0) {
          _countDown--;
        } else {
          _isResending = false;
          timer.cancel();
        }
      });
    });
  }

  @override
  void dispose() {
    log('Đang hủy màn hình xác nhận');
    timer.cancel();
    if (_countDownTimer.isActive) {
      _countDownTimer.cancel();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF102667),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          "Xác thực email",
          style: TextStyle(color: Colors.white),
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF102667), Color(0xFF103F91)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Column(
                children: [
                  const SizedBox(height: 40),

                  // Logo thay cho biểu tượng verification
                  SizedBox(
                    height: 120,
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) => Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.sports_tennis,
                                size: 40,
                                color: Colors.orange,
                              ),
                              const SizedBox(width: 10),
                              Text(
                                "FOCUS",
                                style: TextStyle(
                                  color: Colors.grey,
                                  fontSize: 46,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          ),
                          Text(
                            "BADMINTON",
                            style: TextStyle(
                              color: Color(0xFF33B2F7),
                              fontSize: 22,
                              letterSpacing: 5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Title
                  const Text(
                    "Xác thực tài khoản",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Description
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Column(
                      children: [
                        Text(
                          "Chúng tôi đã gửi email xác thực đến:",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          _email,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Vui lòng kiểm tra hộp thư và nhấn vào liên kết xác thực. Nếu không tìm thấy, hãy kiểm tra thư mục Spam.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 40),

                  // Resend button
                  SizedBox(
                    width: 200,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: _isResending
                          ? null
                          : () {
                              _auth.sendEmailVerificationLink();
                              _startCountdownTimer();
                              _showMessage("Đã gửi lại email xác thực");
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF33B2F7),
                        disabledBackgroundColor: Colors.grey,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      child: Text(
                        _isResending
                            ? "Gửi lại sau ($_countDown s)"
                            : "Gửi lại email",
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Status indicator
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 12,
                        height: 12,
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.5),
                          shape: BoxShape.circle,
                        ),
                        child: const Padding(
                          padding: EdgeInsets.all(2.0),
                          child: CircularProgressIndicator(
                            color: Colors.green,
                            strokeWidth: 2,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        "Đang chờ xác thực...",
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.8),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Sign out option
                  TextButton(
                    onPressed: () async {
                      await _auth.signout();
                      Navigator.pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                            builder: (context) => const Wrapper()),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      "Đăng xuất và thử lại",
                      style: TextStyle(
                        color: Color(0xFFFFC107),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFF33B2F7),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }
}
