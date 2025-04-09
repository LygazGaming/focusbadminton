import 'package:cloud_firestore/cloud_firestore.dart';

class NotificationModel {
  final String id;
  final String title;
  final String message;
  final String? imageUrl;
  final DateTime createdAt;
  final bool isRead;
  final String? type;

  NotificationModel({
    required this.id,
    required this.title,
    required this.message,
    this.imageUrl,
    required this.createdAt,
    this.isRead = false,
    this.type,
  });

  factory NotificationModel.fromMap(Map<String, dynamic> map, String id) {
    return NotificationModel(
      id: id,
      title: map['title'] ?? '',
      message: map['message'] ?? '',
      imageUrl: map['imageUrl'],
      createdAt: (map['createdAt'] as Timestamp).toDate(),
      isRead: map['isRead'] ?? false,
      type: map['type'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'message': message,
      'imageUrl': imageUrl,
      'createdAt': Timestamp.fromDate(createdAt),
      'isRead': isRead,
      'type': type,
    };
  }

  NotificationModel copyWith({
    String? title,
    String? message,
    String? imageUrl,
    DateTime? createdAt,
    bool? isRead,
    String? type,
  }) {
    return NotificationModel(
      id: id,
      title: title ?? this.title,
      message: message ?? this.message,
      imageUrl: imageUrl ?? this.imageUrl,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      type: type ?? this.type,
    );
  }
}
