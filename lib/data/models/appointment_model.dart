import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';

/// Appointment statuses used across the app.
class AppointmentStatus {
  AppointmentStatus._();

  static const pending = 'Pending';
  static const accepted = 'Accepted';
  static const rejected = 'Rejected';
  static const completed = 'Completed';
  static const cancelled = 'Cancelled';
}

/// Payment statuses.
class PaymentStatus {
  PaymentStatus._();

  static const unpaid = 'Unpaid';
  static const paid = 'Paid';
}

class AppointmentModel {
  final String id;
  final String doctorId;
  final String doctorName;
  final String doctorSpecialization;
  final String clientId;
  final String clientName;
  final int age;
  final String phone;
  final String symptoms;
  final DateTime? appointmentDate;
  final String appointmentTime;
  final String status;
  final String paymentStatus;
  final DateTime? createdAt;
  final String? callId;

  const AppointmentModel({
    required this.id,
    required this.doctorId,
    required this.doctorName,
    required this.clientId,
    required this.clientName,
    this.doctorSpecialization = '',
    this.age = 0,
    this.phone = '',
    this.symptoms = '',
    this.appointmentDate,
    this.appointmentTime = '',
    this.status = AppointmentStatus.pending,
    this.paymentStatus = PaymentStatus.unpaid,
    this.createdAt,
    this.callId,
  });

  factory AppointmentModel.fromMap(String id, Map<String, dynamic> map) {
    DateTime? parsedDate;
    final value = map['appointmentDate'];
    if (value is Timestamp) {
      parsedDate = value.toDate();
    } else if (value is String && value.isNotEmpty) {
      parsedDate = DateTime.tryParse(value);
    }

    DateTime? parsedCreated;
    final created = map['createdAt'];
    if (created is Timestamp) {
      parsedCreated = created.toDate();
    } else if (created is String && created.isNotEmpty) {
      parsedCreated = DateTime.tryParse(created);
    }

    return AppointmentModel(
      id: id,
      doctorId: map['doctorId'] ?? '',
      doctorName: map['doctorName'] ?? '',
      doctorSpecialization: map['doctorSpecialization'] ?? '',
      clientId: map['clientId'] ?? '',
      clientName: map['clientName'] ?? map['patientName'] ?? '',
      age: (map['age'] is num) ? (map['age'] as num).toInt() : 0,
      phone: map['phone'] ?? '',
      symptoms: map['symptoms'] ?? '',
      appointmentDate: parsedDate,
      appointmentTime: map['appointmentTime'] ?? '',
      status: map['status'] ?? AppointmentStatus.pending,
      paymentStatus: map['paymentStatus'] ?? PaymentStatus.unpaid,
      createdAt: parsedCreated,
      callId: map['callId'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'doctorId': doctorId,
      'doctorName': doctorName,
      'doctorSpecialization': doctorSpecialization,
      'clientId': clientId,
      'clientName': clientName,
      'age': age,
      'phone': phone,
      'symptoms': symptoms,
      'appointmentDate': appointmentDate != null
          ? Timestamp.fromDate(appointmentDate!)
          : FieldValue.serverTimestamp(),
      'appointmentTime': appointmentTime,
      'status': status,
      'paymentStatus': paymentStatus,
      'createdAt': FieldValue.serverTimestamp(),
      'callId': callId,
    };
  }

  String get formattedDate {
    if (appointmentDate == null) return 'Not scheduled';
    return DateFormat('dd MMM yyyy').format(appointmentDate!);
  }

  String get formattedDateTime {
    if (appointmentDate == null) return 'Not scheduled';
    return '$formattedDate • $appointmentTime';
  }

  bool get isPending => status == AppointmentStatus.pending;
  bool get isAccepted => status == AppointmentStatus.accepted;
  bool get isRejected => status == AppointmentStatus.rejected;
  bool get isCompleted => status == AppointmentStatus.completed;
  bool get isCancelled => status == AppointmentStatus.cancelled;
}
