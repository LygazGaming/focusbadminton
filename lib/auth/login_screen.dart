import 'package:focusbadminton/auth/auth_service.dart';
import 'package:focusbadminton/auth/forgot_pass.dart';
import 'package:focusbadminton/auth/signup_screen.dart';
import 'package:flutter/material.dart';
import 'dart:developer';
import 'package:google_sign_in/google_sign_in.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = AuthService();
  bool isLoading = false;
  bool _obscurePassword = true;

  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(10),
        ),
      ),
    );
  }

  Future<void> _login() async {
    if (_email.text.isEmpty || _password.text.isEmpty) {
      _showError("Vui lòng điền đầy đủ thông tin");
      return;
    }

    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_email.text)) {
      _showError("Email không hợp lệ");
      return;
    }

    setState(() => isLoading = true);

    try {
      final user = await _auth.loginUserWithEmailAndPassword(
        _email.text.trim(),
        _password.text,
      );

      if (!mounted) return;

      if (user != null) {
        if (!user.emailVerified) {
          await _auth.signout();
          _showError("Vui lòng xác thực email trước khi đăng nhập");
          return;
        }
        // Xóa toàn bộ navigation stack và chuyển đến màn hình chính
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/home', (route) => false);
      }
    } on AuthException catch (e) {
      _showError(e.message);
    } catch (e) {
      _showError("Đã xảy ra lỗi không xác định");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  Future<void> _loginWithGoogle() async {
    setState(() => isLoading = true);

    try {
      // Kiểm tra xem còn trạng thái đăng nhập Google không
      final googleSignIn = GoogleSignIn();
      if (await googleSignIn.isSignedIn()) {
        log('Phát hiện đã đăng nhập Google, đang đăng xuất trước...');
        await googleSignIn.signOut();
      }

      // Tiến hành đăng nhập
      final userCredential = await _auth.loginWithGoogle();
      if (!mounted) return;

      if (userCredential?.user != null) {
        log('Đăng nhập Google thành công: ${userCredential!.user?.email}');
        // Xóa toàn bộ navigation stack và chuyển đến màn hình chính
        Navigator.of(context)
            .pushNamedAndRemoveUntil('/home', (route) => false);
      }
    } on AuthException catch (e) {
      log('Lỗi đăng nhập Google: ${e.message}');
      _showError(e.message);
    } catch (e) {
      log('Lỗi không xác định khi đăng nhập Google: $e');
      _showError("Đã xảy ra lỗi khi đăng nhập với Google");
    } finally {
      if (mounted) {
        setState(() => isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF102667),
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
                  const SizedBox(height: 50),
                  // Logo
                  Container(
                    constraints: const BoxConstraints(
                      minWidth: 200,
                      maxWidth: 240,
                    ),
                    child: Image.asset(
                      'assets/images/logo.png',
                      fit: BoxFit.fitWidth,
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
                  const SizedBox(height: 60),

                  // Email field
                  _buildTextField(
                    label: "Email",
                    hint: "Nhập Email",
                    icon: Icons.person_outline,
                    controller: _email,
                  ),

                  const SizedBox(height: 20),

                  // Password field
                  _buildTextField(
                    label: "Password",
                    hint: "Nhập mật khẩu",
                    icon: Icons.lock_outline,
                    controller: _password,
                    isPassword: true,
                  ),

                  const SizedBox(height: 15),

                  // Forgot password
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const ForgotPassword(),
                          ),
                        );
                      },
                      style: TextButton.styleFrom(
                        minimumSize: Size.zero,
                        padding: const EdgeInsets.symmetric(
                            vertical: 8, horizontal: 5),
                        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      ),
                      child: const Text(
                        "Quên mật khẩu",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 30),

                  // Login button
                  SizedBox(
                    width: 150,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: isLoading ? null : _login,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF33B2F7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      child: isLoading
                          ? const SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                color: Colors.white,
                                strokeWidth: 2,
                              ),
                            )
                          : const Text(
                              "Đăng nhập",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                            ),
                    ),
                  ),

                  const SizedBox(height: 15),

                  // Social login
                  if (!isLoading) ...[
                    const Text(
                      "Đăng nhập với",
                      style: TextStyle(
                        color: Color(0xFFFFC107),
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Google icon
                        InkWell(
                          onTap: _loginWithGoogle,
                          child: SizedBox(
                            width: 40,
                            height: 40,
                            child: Center(
                              child: SizedBox(
                                width: 30,
                                height: 30,
                                child: CustomPaint(
                                  painter: GoogleLogoExactPainter(),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],

                  const SizedBox(height: 20),

                  // Sign up link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Bạn chưa có tài khoản? ",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => const SignupScreen(),
                            ),
                          );
                        },
                        child: const Text(
                          "Đăng ký",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                            fontSize: 12,
                          ),
                        ),
                      )
                    ],
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField({
    required String label,
    required String hint,
    required IconData icon,
    required TextEditingController controller,
    bool isPassword = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 5, bottom: 4),
          child: Text(
            label,
            style: const TextStyle(
              color: Color(0xFFFFC107),
              fontSize: 14,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.grey.shade200,
            borderRadius: BorderRadius.circular(25),
          ),
          child: TextField(
            controller: controller,
            obscureText: isPassword ? _obscurePassword : false,
            style: const TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle: TextStyle(color: Colors.grey.shade500),
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
              border: InputBorder.none,
              prefixIcon: Icon(
                icon,
                color: Colors.grey.shade600,
              ),
              suffixIcon: isPassword
                  ? IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off
                            : Icons.visibility,
                        color: Colors.grey.shade600,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    )
                  : null,
              isDense: true,
            ),
          ),
        ),
      ],
    );
  }
}

class GoogleLogoExactPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final double w = size.width;
    final double h = size.height;

    // Paths for Google logo
    // Red part
    final redPath = Path()
      ..moveTo(w * 0.5, h * 0.198)
      ..cubicTo(
          w * 0.5735, h * 0.198, w * 0.6396, h * 0.2233, w * 0.6917, h * 0.2729)
      ..lineTo(w * 0.8344, h * 0.1302)
      ..cubicTo(w * 0.7479, h * 0.0497, w * 0.6348, h * 0, w * 0.5, h * 0)
      ..cubicTo(
          w * 0.3042, h * 0, w * 0.1356, h * 0.1121, w * 0.0533, h * 0.2754)
      ..lineTo(w * 0.22, h * 0.4042)
      ..cubicTo(
          w * 0.259, h * 0.2858, w * 0.3696, h * 0.198, w * 0.5, h * 0.198)
      ..close();

    // Blue part
    final bluePath = Path()
      ..moveTo(w * 0.9787, h * 0.5115)
      ..cubicTo(
          w * 0.9787, h * 0.4787, w * 0.9756, h * 0.447, w * 0.9708, h * 0.4167)
      ..lineTo(w * 0.5, h * 0.4167)
      ..lineTo(w * 0.5, h * 0.6042)
      ..lineTo(w * 0.7696, h * 0.6042)
      ..cubicTo(w * 0.7575, h * 0.6658, w * 0.7225, h * 0.7185, w * 0.6701,
          h * 0.7537)
      ..lineTo(w * 0.831, h * 0.8787)
      ..cubicTo(
          w * 0.925, h * 0.7917, w * 0.9787, h * 0.6625, w * 0.9787, h * 0.5115)
      ..close();

    // Yellow part
    final yellowPath = Path()
      ..moveTo(w * 0.2194, h * 0.5948)
      ..cubicTo(
          w * 0.2094, h * 0.5646, w * 0.2042, h * 0.5323, w * 0.2042, h * 0.5)
      ..cubicTo(w * 0.2042, h * 0.4677, w * 0.2094, h * 0.4354, w * 0.2194,
          h * 0.4052)
      ..lineTo(w * 0.0527, h * 0.2765)
      ..cubicTo(w * 0.0192, h * 0.3429, w * 0, h * 0.4198, w * 0, h * 0.5)
      ..cubicTo(w * 0, h * 0.58, w * 0.0192, h * 0.6571, w * 0.0533, h * 0.7233)
      ..lineTo(w * 0.2194, h * 0.5948)
      ..close();

    // Green part
    final greenPath = Path()
      ..moveTo(w * 0.5, h * 1)
      ..cubicTo(
          w * 0.635, h * 1, w * 0.7485, h * 0.9556, w * 0.8352, h * 0.8788)
      ..lineTo(w * 0.6744, h * 0.7538)
      ..cubicTo(
          w * 0.6296, h * 0.7842, w * 0.5677, h * 0.8021, w * 0.5, h * 0.8021)
      ..cubicTo(
          w * 0.3696, h * 0.8021, w * 0.259, h * 0.7144, w * 0.22, h * 0.5958)
      ..lineTo(w * 0.0533, h * 0.7246)
      ..cubicTo(w * 0.1356, h * 0.888, w * 0.3042, h * 1, w * 0.5, h * 1)
      ..close();

    // Drawing with the Google logo colors
    canvas.drawPath(redPath, Paint()..color = const Color(0xFFEA4335));
    canvas.drawPath(bluePath, Paint()..color = const Color(0xFF4285F4));
    canvas.drawPath(yellowPath, Paint()..color = const Color(0xFFFBBC05));
    canvas.drawPath(greenPath, Paint()..color = const Color(0xFF34A853));
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}
