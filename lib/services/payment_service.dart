import 'package:flutter/material.dart';
import 'package:flutter_paypal/flutter_paypal.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_service.dart';

class PaymentService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Tạo đơn hàng mới
  Future<String> createOrder({
    required double amount,
    required String currency,
    required List<Map<String, dynamic>> items,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('User not authenticated');

    final order = {
      'userId': userId,
      'amount': amount,
      'currency': currency,
      'items': items,
      'status': 'pending',
      'createdAt': FieldValue.serverTimestamp(),
      'paymentMethod': 'paypal',
    };

    final docRef = await _firestore.collection('orders').add(order);
    return docRef.id;
  }

  // Cập nhật trạng thái đơn hàng
  Future<void> updateOrderStatus(String orderId, String status) async {
    await _firestore.collection('orders').doc(orderId).update({
      'status': status,
      'updatedAt': FieldValue.serverTimestamp(),
    });
  }

  // Xử lý thanh toán PayPal
  Future<void> processPayPalPayment({
    required BuildContext context,
    required double amount,
    required String currency,
    required List<Map<String, dynamic>> items,
    required String orderId,
  }) async {
    try {
      // Khởi tạo PayPal
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) => UsePaypal(
            sandboxMode: true, // Set to false for production
            clientId:
                "YOUR_PAYPAL_CLIENT_ID", // Replace with your PayPal client ID
            secretKey: "YOUR_PAYPAL_SECRET", // Replace with your PayPal secret
            returnURL: "https://samplesite.com/return",
            cancelURL: "https://samplesite.com/cancel",
            transactions: [
              {
                "amount": {
                  "total": amount.toString(),
                  "currency": currency,
                },
                "description": "Thanh toán đơn hàng #$orderId",
                "item_list": {
                  "items": items
                      .map((item) => {
                            "name": item['name'],
                            "quantity": item['quantity'].toString(),
                            "price": item['price'].toString(),
                          })
                      .toList(),
                },
              }
            ],
            note: "Thanh toán đơn hàng #$orderId",
            onSuccess: (Map params) async {
              // Cập nhật trạng thái đơn hàng thành công
              await updateOrderStatus(orderId, 'completed');

              // Tạo thông báo cho người dùng
              final notificationService = NotificationService();
              await notificationService.createNotification(
                title: 'Thanh toán thành công',
                message:
                    'Đơn hàng #$orderId của bạn đã được thanh toán thành công.',
                type: 'order',
              );
            },
            onError: (error) async {
              // Cập nhật trạng thái đơn hàng thất bại
              await updateOrderStatus(orderId, 'failed');

              // Tạo thông báo cho người dùng
              final notificationService = NotificationService();
              await notificationService.createNotification(
                title: 'Thanh toán thất bại',
                message:
                    'Có lỗi xảy ra khi thanh toán đơn hàng #$orderId. Vui lòng thử lại.',
                type: 'order',
              );
            },
            onCancel: (params) async {
              // Cập nhật trạng thái đơn hàng đã hủy
              await updateOrderStatus(orderId, 'cancelled');

              // Tạo thông báo cho người dùng
              final notificationService = NotificationService();
              await notificationService.createNotification(
                title: 'Thanh toán đã hủy',
                message: 'Bạn đã hủy thanh toán đơn hàng #$orderId.',
                type: 'order',
              );
            },
          ),
        ),
      );
    } catch (e) {
      // Xử lý lỗi
      await updateOrderStatus(orderId, 'failed');

      // Tạo thông báo cho người dùng
      final notificationService = NotificationService();
      await notificationService.createNotification(
        title: 'Lỗi thanh toán',
        message:
            'Có lỗi xảy ra khi thanh toán đơn hàng #$orderId: ${e.toString()}',
        type: 'order',
      );
    }
  }
}
