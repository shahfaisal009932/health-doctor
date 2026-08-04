import 'package:cloud_firestore/cloud_firestore.dart';

class SessionNoteModel {
  final String id;
  final String appointmentId;
  final String note;
  final DateTime createdAt;

  const SessionNoteModel({
    required this.id,
    required this.appointmentId,
    required this.note,
    required this.createdAt,
  });

  factory SessionNoteModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;

    return SessionNoteModel(
      id: doc.id,
      appointmentId: data['appointmentId'] ?? '',
      note: data['note'] ?? '',
      createdAt:
          (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'appointmentId': appointmentId,
      'note': note,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
