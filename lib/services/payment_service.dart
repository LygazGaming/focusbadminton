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
    Map<String, dynamic>? deliveryInfo,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Người dùng chưa đăng nhập');

    try {
      final order = {
        'userId': userId,
        'amount': amount,
        'currency': currency,
        'items': items,
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'paymentMethod': 'paypal',
        'deliveryInfo': deliveryInfo,
      };

      final docRef = await _firestore.collection('orders').add(order);
      return docRef.id;
    } catch (e) {
      throw Exception('Lỗi khi tạo đơn hàng: ${e.toString()}');
    }
  }

  // Cập nhật trạng thái đơn hàng
  Future<void> updateOrderStatus(String orderId, String status) async {
    try {
      await _firestore.collection('orders').doc(orderId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Lỗi khi cập nhật trạng thái đơn hàng: ${e.toString()}');
    }
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
      // Làm tròn số tiền để tránh lỗi
      final roundedAmount = double.parse(amount.toStringAsFixed(2));

      // Lưu context reference để kiểm tra mounted
      final navigatorContext = context;

      // Khởi tạo PayPal
      await Navigator.of(context).push(
        MaterialPageRoute(
          builder: (BuildContext context) => UsePaypal(
            sandboxMode: true, // Set to false for production
            clientId:
                "AS28ztDwPRQ8xYZRAKv8wG4d8kApVH5eAAwNRMqicA3DyVHu1CikCCBsMqVNiV7nJmaYNWoj0ZPtupuH", // Replace with your PayPal client ID
            secretKey:
                "EGHaFubTA6VPrxZ4XczVa0k7A3Nt2vZM9vnOZiv2zGJRLbdi_ay41fh4xCLGk25z5KcRCZ5z25gO0JfG", // Replace with your PayPal secret
            returnURL: "https://samplesite.com/return",
            cancelURL: "https://samplesite.com/cancel",
            transactions: [
              {
                "amount": {
                  "total": roundedAmount.toString(),
                  "currency": currency,
                },
                "description": "Thanh toán đơn hàng #$orderId",
                "item_list": {
                  "items": items
                      .map((item) => {
                            "name": item['name'],
                            "quantity": item['quantity'].toString(),
                            "price": (double.parse(item['price']) / 23000)
                                .toStringAsFixed(2),
                            "currency": currency,
                          })
                      .toList(),
                },
              }
            ],
            note: "Thanh toán đơn hàng #$orderId",
            onSuccess: (Map params) async {
              try {
                print("PayPal thanh toán thành công: ${params['paymentId']}");

                // Cập nhật trạng thái đơn hàng thành công
                await updateOrderStatus(orderId, 'completed');

                // Lưu thông tin giao dịch PayPal
                await _firestore.collection('orders').doc(orderId).update({
                  'paymentDetails': params,
                  'paymentId': params['paymentId'],
                  'paymentStatus': 'completed',
                  'paidAt': FieldValue.serverTimestamp(),
                });

                // Tạo thông báo cho người dùng
                final notificationService = NotificationService();
                await notificationService.createNotification(
                  title: 'Thanh toán thành công',
                  message:
                      'Đơn hàng #$orderId của bạn đã được thanh toán thành công.',
                  type: 'order',
                );

                // Quay lại màn hình trước và giúp đóng WebView
                if (navigatorContext.mounted &&
                    Navigator.canPop(navigatorContext)) {
                  Navigator.pop(navigatorContext);
                }
              } catch (e) {
                print('Lỗi trong onSuccess PayPal: $e');
              }
            },
            onError: (error) async {
              try {
                print("PayPal lỗi: $error");

                // Cập nhật trạng thái đơn hàng thất bại
                await updateOrderStatus(orderId, 'failed');

                // Lưu thông tin lỗi
                await _firestore.collection('orders').doc(orderId).update({
                  'paymentStatus': 'failed',
                  'error': error.toString(),
                });

                // Tạo thông báo cho người dùng
                final notificationService = NotificationService();
                await notificationService.createNotification(
                  title: 'Thanh toán thất bại',
                  message:
                      'Có lỗi xảy ra khi thanh toán đơn hàng #$orderId. Vui lòng thử lại.',
                  type: 'order',
                );
              } catch (e) {
                print('Lỗi trong onError PayPal: $e');
              }
            },
            onCancel: (params) async {
              try {
                print("PayPal hủy thanh toán: $params");

                // Cập nhật trạng thái đơn hàng đã hủy
                await updateOrderStatus(orderId, 'cancelled');

                // Lưu thông tin hủy
                await _firestore.collection('orders').doc(orderId).update({
                  'paymentStatus': 'cancelled',
                  'cancelReason': 'Hủy bởi người dùng',
                });

                // Tạo thông báo cho người dùng
                final notificationService = NotificationService();
                await notificationService.createNotification(
                  title: 'Thanh toán đã hủy',
                  message: 'Bạn đã hủy thanh toán đơn hàng #$orderId.',
                  type: 'order',
                );
              } catch (e) {
                print('Lỗi trong onCancel PayPal: $e');
              }
            },
          ),
        ),
      );
    } catch (e) {
      // Xử lý lỗi
      try {
        print("Lỗi chung khi xử lý PayPal: $e");

        await updateOrderStatus(orderId, 'failed');

        // Lưu thông tin lỗi
        await _firestore.collection('orders').doc(orderId).update({
          'paymentStatus': 'failed',
          'error': e.toString(),
        });

        // Tạo thông báo cho người dùng
        final notificationService = NotificationService();
        await notificationService.createNotification(
          title: 'Lỗi thanh toán',
          message:
              'Có lỗi xảy ra khi thanh toán đơn hàng #$orderId: ${e.toString()}',
          type: 'order',
        );
      } catch (innerException) {
        print("Lỗi khi xử lý exception PayPal: $innerException");
      }

      rethrow;
    }
  }
}
