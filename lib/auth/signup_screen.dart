import 'package:focusbadminton/auth/auth_service.dart';
import 'package:focusbadminton/auth/login_screen.dart';
import 'package:focusbadminton/home_screen.dart';
import 'package:flutter/material.dart';

class SignupScreen extends StatefulWidget {
  const SignupScreen({super.key});

  @override
  State<SignupScreen> createState() => _SignupScreenState();
}

class _SignupScreenState extends State<SignupScreen> {
  final _auth = AuthService();
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool isLoading = false;

  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirmPassword = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
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
                      minWidth: 150,
                      maxWidth: 180,
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
                  const SizedBox(height: 30),

                  // Email field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 5, bottom: 4),
                        child: Text(
                          "Email",
                          style: TextStyle(
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
                          controller: _email,
                          style: const TextStyle(color: Colors.black87),
                          decoration: InputDecoration(
                            hintText: "Nhập Email",
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 15),
                            border: InputBorder.none,
                            prefixIcon: Icon(
                              Icons.person_outline,
                              color: Colors.grey.shade600,
                            ),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Password field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 5, bottom: 4),
                        child: Text(
                          "Mật khẩu",
                          style: TextStyle(
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
                          controller: _password,
                          obscureText: _obscurePassword,
                          style: const TextStyle(color: Colors.black87),
                          decoration: InputDecoration(
                            hintText: "Nhập mật khẩu",
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 15),
                            border: InputBorder.none,
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: Colors.grey.shade600,
                            ),
                            suffixIcon: IconButton(
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
                            ),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 20),

                  // Confirm Password field
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Padding(
                        padding: EdgeInsets.only(left: 5, bottom: 4),
                        child: Text(
                          "Xác nhận mật khẩu",
                          style: TextStyle(
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
                          controller: _confirmPassword,
                          obscureText: _obscureConfirmPassword,
                          style: const TextStyle(color: Colors.black87),
                          decoration: InputDecoration(
                            hintText: "Nhập lại mật khẩu",
                            hintStyle: TextStyle(color: Colors.grey.shade500),
                            contentPadding:
                                const EdgeInsets.symmetric(vertical: 15),
                            border: InputBorder.none,
                            prefixIcon: Icon(
                              Icons.lock_outline,
                              color: Colors.grey.shade600,
                            ),
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscureConfirmPassword
                                    ? Icons.visibility_off
                                    : Icons.visibility,
                                color: Colors.grey.shade600,
                              ),
                              onPressed: () {
                                setState(() {
                                  _obscureConfirmPassword =
                                      !_obscureConfirmPassword;
                                });
                              },
                            ),
                            isDense: true,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // Signup button
                  SizedBox(
                    width: 150,
                    height: 45,
                    child: ElevatedButton(
                      onPressed: _signup,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF33B2F7),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(22),
                        ),
                      ),
                      child: const Text(
                        "Đăng ký",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 25),

                  // Login link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "Bạn đã có tài khoản? ",
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 12,
                        ),
                      ),
                      InkWell(
                        onTap: () => goToLogin(context),
                        child: const Text(
                          "Đăng nhập",
                          style: TextStyle(
                            color: Color(0xFFFFC107),
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

  goToLogin(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
      );

  goToHome(BuildContext context) => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );

  _signup() async {
    // Kiểm tra các trường trống
    if (_email.text.isEmpty ||
        _password.text.isEmpty ||
        _confirmPassword.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Vui lòng điền đầy đủ thông tin"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Kiểm tra định dạng email
    if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_email.text)) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email không hợp lệ"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Kiểm tra độ dài mật khẩu
    if (_password.text.length < 8) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Mật khẩu phải có ít nhất 8 ký tự"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Kiểm tra mật khẩu khớp
    if (_password.text != _confirmPassword.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Mật khẩu không khớp"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    try {
      setState(() {
        isLoading = true;
      });

      print('Bắt đầu đăng ký với email: ${_email.text.trim()}');
      final user = await _auth.createUserWithEmailAndPassword(
        _email.text.trim(),
        _password.text,
      );

      if (user != null) {
        print('Đăng ký thành công: ${user.email}');
        if (mounted) {
          Navigator.pushReplacementNamed(context, '/verification');
        }
      }
    } on AuthException catch (e) {
      print('Lỗi xác thực: ${e.message}');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(e.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    } catch (e) {
      print('Lỗi không xác định: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isLoading = false;
        });
      }
    }
  }
}
