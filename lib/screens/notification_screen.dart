import 'package:flutter/material.dart';
import 'package:focusbadminton/models/notification.dart';
import 'package:intl/intl.dart';
import 'package:focusbadminton/services/notification_service.dart';

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  final NotificationService _notificationService = NotificationService();
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Tiêu đề và nút đánh dấu đã đọc tất cả
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          child: Row(
            children: [
              const Expanded(
                child: Text(
                  'Thông báo',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: const Icon(Icons.done_all),
                onPressed: _markAllAsRead,
                tooltip: 'Đánh dấu tất cả đã đọc',
              ),
            ],
          ),
        ),
        // Nội dung
        Expanded(
          child: _isLoading
              ? const Center(child: CircularProgressIndicator())
              : StreamBuilder<List<NotificationModel>>(
                  stream: _notificationService.getUserNotifications(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }

                    if (snapshot.hasError) {
                      return Center(
                        child: Text('Lỗi: ${snapshot.error}'),
                      );
                    }

                    final notifications = snapshot.data ?? [];

                    if (notifications.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.notifications_none,
                              size: 64,
                              color: Colors.grey,
                            ),
                            const SizedBox(height: 16),
                            const Text(
                              'Không có thông báo',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              'Bạn sẽ nhận được thông báo khi có cập nhật mới',
                              style: TextStyle(
                                fontSize: 14,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      );
                    }

                    return ListView.builder(
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        return Dismissible(
                          key: Key(notification.id),
                          direction: DismissDirection.endToStart,
                          background: Container(
                            alignment: Alignment.centerRight,
                            padding: const EdgeInsets.only(right: 16),
                            color: Colors.red,
                            child: const Icon(
                              Icons.delete,
                              color: Colors.white,
                            ),
                          ),
                          onDismissed: (direction) {
                            _deleteNotification(notification.id);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: notification.isRead
                                  ? Colors.white
                                  : Colors.blue[50],
                              border: Border(
                                bottom: BorderSide(
                                  color: Colors.grey[200]!,
                                ),
                              ),
                            ),
                            child: ListTile(
                              leading: CircleAvatar(
                                backgroundColor: _getNotificationColor(
                                    notification.type ?? 'general'),
                                child: Icon(
                                  _getNotificationIcon(
                                      notification.type ?? 'general'),
                                  color: Colors.white,
                                ),
                              ),
                              title: Text(
                                notification.title,
                                style: TextStyle(
                                  fontWeight: notification.isRead
                                      ? FontWeight.normal
                                      : FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(notification.message),
                                  const SizedBox(height: 4),
                                  Text(
                                    DateFormat('dd/MM/yyyy HH:mm')
                                        .format(notification.createdAt),
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                ],
                              ),
                              onTap: () {
                                if (!notification.isRead) {
                                  _markAsRead(notification.id);
                                }
                              },
                            ),
                          ),
                        );
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Future<void> _markAsRead(String id) async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _notificationService.markAsRead(id);
    } catch (e) {
      debugPrint('Lỗi khi đánh dấu đã đọc: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _markAllAsRead() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await _notificationService.markAllAsRead();
    } catch (e) {
      debugPrint('Lỗi khi đánh dấu tất cả đã đọc: $e');
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _deleteNotification(String id) async {
    try {
      await _notificationService.deleteNotification(id);
    } catch (e) {
      debugPrint('Lỗi khi xóa thông báo: $e');
    }
  }

  Color _getNotificationColor(String type) {
    switch (type) {
      case 'order':
        return Colors.blue;
      case 'promotion':
        return Colors.orange;
      case 'system':
        return Colors.grey;
      default:
        return Colors.blue;
    }
  }

  IconData _getNotificationIcon(String type) {
    switch (type) {
      case 'order':
        return Icons.shopping_bag;
      case 'promotion':
        return Icons.local_offer;
      case 'system':
        return Icons.info;
      default:
        return Icons.notifications;
    }
  }
}
