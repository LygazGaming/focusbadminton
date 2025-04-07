import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class NotificationSettingsScreen extends StatefulWidget {
  const NotificationSettingsScreen({super.key});

  @override
  State<NotificationSettingsScreen> createState() =>
      _NotificationSettingsScreenState();
}

class _NotificationSettingsScreenState
    extends State<NotificationSettingsScreen> {
  bool _isLoading = true;
  bool _orderUpdates = true;
  bool _promotions = true;
  bool _newProducts = true;
  bool _priceDrops = true;

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      setState(() {
        _orderUpdates = prefs.getBool('notification_order_updates') ?? true;
        _promotions = prefs.getBool('notification_promotions') ?? true;
        _newProducts = prefs.getBool('notification_new_products') ?? true;
        _priceDrops = prefs.getBool('notification_price_drops') ?? true;
        _isLoading = false;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể tải cài đặt: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveSettings() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('notification_order_updates', _orderUpdates);
      await prefs.setBool('notification_promotions', _promotions);
      await prefs.setBool('notification_new_products', _newProducts);
      await prefs.setBool('notification_price_drops', _priceDrops);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Đã lưu cài đặt thông báo'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể lưu cài đặt: ${e.toString()}'),
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
        title: const Text('Cài đặt thông báo'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Quản lý thông báo',
                      style: TextStyle(
                        fontSize: 16,
                        color: Colors.grey[600],
                      ),
                    ),
                  ),
                  _buildSwitchTile(
                    title: 'Cập nhật đơn hàng',
                    subtitle: 'Thông báo khi trạng thái đơn hàng thay đổi',
                    value: _orderUpdates,
                    onChanged: (value) {
                      setState(() {
                        _orderUpdates = value;
                      });
                    },
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    title: 'Khuyến mãi',
                    subtitle:
                        'Thông báo về các chương trình khuyến mãi, giảm giá',
                    value: _promotions,
                    onChanged: (value) {
                      setState(() {
                        _promotions = value;
                      });
                    },
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    title: 'Sản phẩm mới',
                    subtitle: 'Thông báo khi có sản phẩm mới',
                    value: _newProducts,
                    onChanged: (value) {
                      setState(() {
                        _newProducts = value;
                      });
                    },
                  ),
                  const Divider(height: 1),
                  _buildSwitchTile(
                    title: 'Giảm giá sản phẩm',
                    subtitle: 'Thông báo khi sản phẩm yêu thích giảm giá',
                    value: _priceDrops,
                    onChanged: (value) {
                      setState(() {
                        _priceDrops = value;
                      });
                    },
                  ),
                  const SizedBox(height: 24),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: ElevatedButton(
                      onPressed: _saveSettings,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue[900],
                        foregroundColor: Colors.white,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: const Text(
                        'Lưu cài đặt',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.all(16),
                    child: Text(
                      'Lưu ý: Bạn vẫn có thể nhận được một số thông báo quan trọng liên quan đến tài khoản và giao dịch của bạn, ngay cả khi bạn đã tắt thông báo ở đây.',
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSwitchTile({
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return SwitchListTile(
      title: Text(title),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          fontSize: 14,
          color: Colors.grey[600],
        ),
      ),
      value: value,
      onChanged: onChanged,
      activeColor: Colors.blue[900],
    );
  }
}
