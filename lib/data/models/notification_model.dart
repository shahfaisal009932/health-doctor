import 'package:cloud_firestore/cloud_firestore.dart';

class AppNotificationModel {
  final String id;
  final String userId;
  final String title;
  final String body;
  final String type;
  final String? appointmentId;
  final bool read;
  final DateTime createdAt;

  const AppNotificationModel({
    required this.id,
    required this.userId,
    required this.title,
    required this.body,
    this.type = 'info',
    this.appointmentId,
    this.read = false,
    required this.createdAt,
  });

  factory AppNotificationModel.fromMap(
    String id,
    Map<String, dynamic> map,
  ) {
    return AppNotificationModel(
      id: id,
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      body: map['body'] ?? '',
      type: map['type'] ?? 'info',
      appointmentId: map['appointmentId'],
      read: map['read'] ?? false,
      createdAt:
          (map['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}
