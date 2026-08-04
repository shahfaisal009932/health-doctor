import 'package:cloud_firestore/cloud_firestore.dart';

class CallHistoryModel {
  final String id;
  final String appointmentId;
  final String doctorId;
  final String clientId;
  final DateTime startedAt;
  final DateTime? endedAt;
  final int durationSeconds;

  const CallHistoryModel({
    required this.id,
    required this.appointmentId,
    required this.doctorId,
    required this.clientId,
    required this.startedAt,
    this.endedAt,
    this.durationSeconds = 0,
  });

  factory CallHistoryModel.fromMap(String id, Map<String, dynamic> map) {
    return CallHistoryModel(
      id: id,
      appointmentId: map['appointmentId'] ?? '',
      doctorId: map['doctorId'] ?? '',
      clientId: map['clientId'] ?? '',
      startedAt:
          (map['startedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      endedAt: (map['endedAt'] as Timestamp?)?.toDate(),
      durationSeconds:
          (map['durationSeconds'] is num) ? (map['durationSeconds'] as num).toInt() : 0,
    );
  }
}
