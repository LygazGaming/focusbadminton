import 'package:flutter/material.dart';
import 'package:focusbadminton/auth/auth_service.dart';
import 'package:focusbadminton/auth/login_screen.dart';
import 'package:focusbadminton/widgets/button.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _auth = AuthService();
  bool _isLoading = false;

  Future<void> _signOut() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _auth.signout();
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginScreen()),
          (route) => false,
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Lỗi: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tài khoản'),
        actions: [
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              // TODO: Navigate to settings screen
            },
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                children: [
                  // Profile header
                  Container(
                    padding: const EdgeInsets.all(16),
                    color: Colors.blue[900],
                    child: Column(
                      children: [
                        const CircleAvatar(
                          radius: 50,
                          backgroundImage:
                              AssetImage('assets/images/avatar.png'),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'Nguyễn Văn A',
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'example@email.com',
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.white.withOpacity(0.8),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Profile sections
                  _buildSection(
                    title: 'Đơn hàng',
                    children: [
                      _buildMenuItem(
                        icon: Icons.shopping_bag,
                        title: 'Đơn hàng của tôi',
                        onTap: () {
                          // TODO: Navigate to orders screen
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.favorite,
                        title: 'Sản phẩm yêu thích',
                        onTap: () {
                          // TODO: Navigate to favorites screen
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.location_on,
                        title: 'Địa chỉ giao hàng',
                        onTap: () {
                          // TODO: Navigate to addresses screen
                        },
                      ),
                    ],
                  ),

                  _buildSection(
                    title: 'Tài khoản',
                    children: [
                      _buildMenuItem(
                        icon: Icons.person,
                        title: 'Thông tin cá nhân',
                        onTap: () {
                          // TODO: Navigate to personal info screen
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.lock,
                        title: 'Đổi mật khẩu',
                        onTap: () {
                          // TODO: Navigate to change password screen
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.notifications,
                        title: 'Cài đặt thông báo',
                        onTap: () {
                          // TODO: Navigate to notification settings screen
                        },
                      ),
                    ],
                  ),

                  _buildSection(
                    title: 'Khác',
                    children: [
                      _buildMenuItem(
                        icon: Icons.help,
                        title: 'Trung tâm trợ giúp',
                        onTap: () {
                          // TODO: Navigate to help center
                        },
                      ),
                      _buildMenuItem(
                        icon: Icons.info,
                        title: 'Về ứng dụng',
                        onTap: () {
                          // TODO: Navigate to about screen
                        },
                      ),
                    ],
                  ),

                  // Sign out button
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: CustomButton(
                      label: 'Đăng xuất',
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      onPressed: _signOut,
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        ...children,
      ],
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }
}
