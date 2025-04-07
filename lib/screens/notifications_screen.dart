import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/intl.dart';
import 'package:focusbadminton/screens/product_detail_screen.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = true;
  List<Map<String, dynamic>> _notifications = [];

  @override
  void initState() {
    super.initState();
    _loadNotifications();
  }

  // Tải danh sách thông báo
  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        setState(() {
          _isLoading = false;
          _notifications = [];
        });
        return;
      }

      final querySnapshot = await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .get();

      final notifications = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();

      setState(() {
        _notifications = notifications;
        _isLoading = false;
      });
    } catch (e) {
      print('Error loading notifications: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  // Đánh dấu thông báo đã đọc
  Future<void> _markAsRead(String notificationId) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .doc(notificationId)
          .update({'isRead': true});

      // Cập nhật trạng thái đã đọc trong danh sách
      setState(() {
        final index = _notifications.indexWhere((n) => n['id'] == notificationId);
        if (index != -1) {
          _notifications[index]['isRead'] = true;
        }
      });
    } catch (e) {
      print('Error marking notification as read: $e');
    }
  }

  // Xử lý khi nhấn vào thông báo
  void _handleNotificationTap(Map<String, dynamic> notification) {
    // Đánh dấu thông báo đã đọc
    _markAsRead(notification['id']);

    // Xử lý điều hướng dựa trên loại thông báo
    final String notificationType = notification['type'] ?? 'general';
    final Map<String, dynamic> data = notification['data'] ?? {};
    final String? productId = data['product_id'];

    switch (notificationType) {
      case 'new_product':
        if (productId != null) {
          // Điều hướng đến trang chi tiết sản phẩm
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ProductDetailScreen(
                productId: productId,
              ),
            ),
          );
        }
        break;
      case 'order_update':
        // Điều hướng đến trang đơn hàng
        Navigator.pushNamed(context, '/orders');
        break;
      case 'promotion':
        // Điều hướng đến trang khuyến mãi
        Navigator.pushNamed(
          context,
          '/category',
          arguments: {'category': 'Tất cả', 'filter': 'deal'},
        );
        break;
      default:
        // Không làm gì
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadNotifications,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _notifications.isEmpty
              ? _buildEmptyState()
              : _buildNotificationsList(),
    );
  }

  // Hiển thị khi không có thông báo
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.notifications_off,
            size: 80,
            color: Colors.grey[400],
          ),
          const SizedBox(height: 16),
          Text(
            'Bạn chưa có thông báo nào',
            style: TextStyle(
              fontSize: 18,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  // Hiển thị danh sách thông báo
  Widget _buildNotificationsList() {
    return ListView.builder(
      itemCount: _notifications.length,
      itemBuilder: (context, index) {
        final notification = _notifications[index];
        final bool isRead = notification['isRead'] ?? false;
        final Timestamp? timestamp = notification['createdAt'];
        final DateTime? dateTime = timestamp?.toDate();
        final String timeString = dateTime != null
            ? DateFormat('dd/MM/yyyy HH:mm').format(dateTime)
            : '';

        return InkWell(
          onTap: () => _handleNotificationTap(notification),
          child: Container(
            color: isRead ? null : Colors.blue[50],
            padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildNotificationIcon(notification['type']),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        notification['title'] ?? 'Thông báo mới',
                        style: TextStyle(
                          fontWeight: isRead ? FontWeight.normal : FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        notification['message'] ?? '',
                        style: TextStyle(
                          color: Colors.grey[700],
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        timeString,
                        style: TextStyle(
                          color: Colors.grey[500],
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                if (!isRead)
                  Container(
                    width: 10,
                    height: 10,
                    decoration: BoxDecoration(
                      color: Colors.blue,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Hiển thị biểu tượng thông báo dựa trên loại
  Widget _buildNotificationIcon(String? type) {
    IconData iconData;
    Color iconColor;

    switch (type) {
      case 'new_product':
        iconData = Icons.new_releases;
        iconColor = Colors.orange;
        break;
      case 'order_update':
        iconData = Icons.local_shipping;
        iconColor = Colors.blue;
        break;
      case 'promotion':
        iconData = Icons.local_offer;
        iconColor = Colors.green;
        break;
      case 'price_drop':
        iconData = Icons.trending_down;
        iconColor = Colors.red;
        break;
      default:
        iconData = Icons.notifications;
        iconColor = Colors.grey;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: iconColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        iconData,
        color: iconColor,
        size: 24,
      ),
    );
  }
}
