import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/notification.dart';

class NotificationService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Lấy stream thông báo của user hiện tại
  Stream<List<NotificationModel>> getUserNotifications() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return Stream.value([]);

    return _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => NotificationModel.fromMap(doc.data(), doc.id))
          .toList();
    });
  }

  // Đánh dấu thông báo đã đọc
  Future<void> markAsRead(String notificationId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .update({'isRead': true});
  }

  // Đánh dấu tất cả thông báo đã đọc
  Future<void> markAllAsRead() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final batch = _firestore.batch();
    final notifications = await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .where('isRead', isEqualTo: false)
        .get();

    for (var doc in notifications.docs) {
      batch.update(doc.reference, {'isRead': true});
    }

    await batch.commit();
  }

  // Xóa thông báo
  Future<void> deleteNotification(String notificationId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }

  // Tạo thông báo mới
  Future<void> createNotification({
    required String title,
    required String message,
    String? imageUrl,
    String? type,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    final notification = {
      'title': title,
      'message': message,
      'imageUrl': imageUrl,
      'type': type,
      'createdAt': FieldValue.serverTimestamp(),
      'isRead': false,
    };

    await _firestore
        .collection('users')
        .doc(userId)
        .collection('notifications')
        .add(notification);
  }
}
