import 'package:cloud_firestore/cloud_firestore.dart';

class ClientModel {
  final String id;
  final String name;
  final String email;
  final String phone;
  final String fcmToken;
  final DateTime? createdAt;

  const ClientModel({
    required this.id,
    required this.name,
    required this.email,
    this.phone = '',
    this.fcmToken = '',
    this.createdAt,
  });

  factory ClientModel.fromMap(String id, Map<String, dynamic> map) {
    return ClientModel(
      id: id,
      name: map['name'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      fcmToken: map['fcmToken'] ?? '',
      createdAt: (map['createdAt'] as Timestamp?)?.toDate(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'email': email,
      'phone': phone,
      'fcmToken': fcmToken,
      'createdAt': createdAt != null
          ? Timestamp.fromDate(createdAt!)
          : FieldValue.serverTimestamp(),
    };
  }
}
