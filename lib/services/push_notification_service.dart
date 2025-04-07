import 'dart:convert';
import 'dart:developer';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class PushNotificationService {
  static final PushNotificationService _instance =
      PushNotificationService._internal();
  factory PushNotificationService() => _instance;
  PushNotificationService._internal();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;
  final FlutterLocalNotificationsPlugin _localNotifications =
      FlutterLocalNotificationsPlugin();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Khởi tạo thông báo
  Future<void> initialize(BuildContext context) async {
    // Yêu cầu quyền thông báo
    await _requestPermission();

    // Khởi tạo local notifications
    await _initializeLocalNotifications();

    // Xử lý thông báo khi ứng dụng đang chạy
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);

    // Xử lý thông báo khi nhấn vào thông báo
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      _handleNotificationTap(message, context);
    });

    // Lưu token thiết bị vào Firestore
    await _saveDeviceToken();
  }

  // Yêu cầu quyền thông báo
  Future<void> _requestPermission() async {
    NotificationSettings settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    log('User granted permission: ${settings.authorizationStatus}');
  }

  // Khởi tạo local notifications
  Future<void> _initializeLocalNotifications() async {
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _localNotifications.initialize(
      initSettings,
      onDidReceiveNotificationResponse: (NotificationResponse response) {
        // Xử lý khi nhấn vào thông báo local
        final payload = response.payload;
        if (payload != null) {
          final data = json.decode(payload);
          // Xử lý dữ liệu từ payload
          log('Local notification payload: $data');
        }
      },
    );
  }

  // Xử lý thông báo khi ứng dụng đang chạy
  Future<void> _handleForegroundMessage(RemoteMessage message) async {
    log('Got a message whilst in the foreground!');
    log('Message data: ${message.data}');

    if (message.notification != null) {
      log('Message also contained a notification: ${message.notification}');

      // Kiểm tra cài đặt thông báo của người dùng
      final prefs = await SharedPreferences.getInstance();
      final String notificationType = message.data['type'] ?? 'general';

      bool shouldShow = true;

      // Kiểm tra từng loại thông báo
      switch (notificationType) {
        case 'order_update':
          shouldShow = prefs.getBool('notification_order_updates') ?? true;
          break;
        case 'promotion':
          shouldShow = prefs.getBool('notification_promotions') ?? true;
          break;
        case 'new_product':
          shouldShow = prefs.getBool('notification_new_products') ?? true;
          break;
        case 'price_drop':
          shouldShow = prefs.getBool('notification_price_drops') ?? true;
          break;
        default:
          shouldShow = true;
          break;
      }

      if (shouldShow) {
        // Hiển thị thông báo local
        await _showLocalNotification(
          id: message.hashCode,
          title: message.notification!.title ?? 'Thông báo mới',
          body: message.notification!.body ?? '',
          payload: json.encode(message.data),
        );

        // Lưu thông báo vào Firestore
        await _saveNotificationToFirestore(message);
      }
    }
  }

  // Hiển thị thông báo local
  Future<void> _showLocalNotification({
    required int id,
    required String title,
    required String body,
    String? payload,
  }) async {
    const AndroidNotificationDetails androidDetails =
        AndroidNotificationDetails(
      'focus_badminton_channel',
      'Focus Badminton Notifications',
      channelDescription: 'Thông báo từ ứng dụng Focus Badminton',
      importance: Importance.max,
      priority: Priority.high,
      showWhen: true,
    );

    const NotificationDetails notificationDetails = NotificationDetails(
      android: androidDetails,
      iOS: DarwinNotificationDetails(
        presentAlert: true,
        presentBadge: true,
        presentSound: true,
      ),
    );

    await _localNotifications.show(
      id,
      title,
      body,
      notificationDetails,
      payload: payload,
    );
  }

  // Xử lý khi nhấn vào thông báo
  void _handleNotificationTap(RemoteMessage message, BuildContext context) {
    log('Notification tapped: ${message.data}');

    // Xử lý điều hướng dựa trên loại thông báo
    final String notificationType = message.data['type'] ?? 'general';
    final String? productId = message.data['product_id'];

    switch (notificationType) {
      case 'new_product':
        if (productId != null) {
          // Điều hướng đến trang chi tiết sản phẩm
          Navigator.pushNamed(
            context,
            '/product-detail',
            arguments: {'productId': productId},
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
        // Điều hướng đến trang chủ
        Navigator.pushNamed(context, '/home');
        break;
    }
  }

  // Lưu token thiết bị vào Firestore
  Future<void> _saveDeviceToken() async {
    try {
      // Lấy token thiết bị
      String? token = await _messaging.getToken();

      if (token != null) {
        log('FCM Token: $token');

        // Lấy ID người dùng hiện tại
        String? userId = _auth.currentUser?.uid;

        if (userId != null) {
          // Lưu token vào Firestore
          await _firestore.collection('users').doc(userId).update({
            'fcmTokens': FieldValue.arrayUnion([token]),
            'lastUpdated': FieldValue.serverTimestamp(),
          });

          log('Token saved to Firestore');
        } else {
          log('User not logged in, token not saved');
        }
      }
    } catch (e) {
      log('Error saving token: $e');
    }
  }

  // Lưu thông báo vào Firestore
  Future<void> _saveNotificationToFirestore(RemoteMessage message) async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) return;

      final notification = {
        'title': message.notification?.title ?? 'Thông báo mới',
        'message': message.notification?.body ?? '',
        'imageUrl': message.notification?.android?.imageUrl,
        'type': message.data['type'] ?? 'general',
        'data': message.data,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      };

      await _firestore
          .collection('users')
          .doc(userId)
          .collection('notifications')
          .add(notification);

      log('Notification saved to Firestore');
    } catch (e) {
      log('Error saving notification to Firestore: $e');
    }
  }
}
