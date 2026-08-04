import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/exceptions/firebase_error_mapper.dart';
import '../../core/utils/firestore_logger.dart';
import '../models/appointment_model.dart';

class AppointmentRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _appointments =>
      _firestore.collection('appointments');

  /// Realtime stream of appointments for a doctor.
  Stream<List<AppointmentModel>> listenToAppointments(String doctorId) {
    if (doctorId.isEmpty) {
      FirestoreLogger.log(
        collection: 'appointments',
        operation: 'listen',
        details: 'unauthenticated',
      );
      return Stream.value(const []);
    }

    FirestoreLogger.log(
      collection: 'appointments',
      operation: 'listen',
      details: 'doctorId=$doctorId orderBy=createdAt(desc)',
    );
    return _appointments
        .where('doctorId', isEqualTo: doctorId)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) =>
                AppointmentModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
            .toList());
  }

  /// Fetch all appointments for the current doctor (one-shot).
  Future<List<AppointmentModel>> getAppointments(String doctorId) async {
    try {
      if (doctorId.isEmpty) {
        return const [];
      }

      QuerySnapshot snapshot;
      try {
        FirestoreLogger.log(
          collection: 'appointments',
          operation: 'read',
          details: 'doctorId=$doctorId orderBy=createdAt(desc)',
        );
        snapshot = await _appointments
            .where('doctorId', isEqualTo: doctorId)
            .orderBy('createdAt', descending: true)
            .get();
      } on FirebaseException catch (e) {
        // Composite index may not exist yet; fall back to unfiltered query.
        if (e.code == 'failed-precondition') {
          FirestoreLogger.log(
            collection: 'appointments',
            operation: 'read',
            details: 'index missing -> fallback orderBy=createdAt(desc)',
          );
          snapshot = await _appointments
              .orderBy('createdAt', descending: true)
              .get();
        } else {
          rethrow;
        }
      }

      return snapshot.docs
          .map((doc) =>
              AppointmentModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } on FirebaseException catch (e) {
      FirestoreLogger.logError(
        collection: 'appointments',
        operation: 'read',
        error: e,
      );
      throw FirebaseErrorMapper.map(e);
    } catch (e) {
      FirestoreLogger.logError(
        collection: 'appointments',
        operation: 'read',
        error: e,
      );
      throw FirebaseErrorMapper.map(e);
    }
  }

  /// Update the status of an appointment (Accept / Reject / Complete).
  Future<void> updateAppointmentStatus({
    required String appointmentId,
    required String status,
  }) async {
    try {
      FirestoreLogger.log(
        collection: 'appointments',
        operation: 'update',
        details: 'doc=$appointmentId status=$status',
      );
      await _appointments.doc(appointmentId).update({
        'status': status,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      FirestoreLogger.logError(
        collection: 'appointments',
        operation: 'update',
        error: e,
      );
      throw FirebaseErrorMapper.map(e);
    } catch (e) {
      FirestoreLogger.logError(
        collection: 'appointments',
        operation: 'update',
        error: e,
      );
      throw FirebaseErrorMapper.map(e);
    }
  }

  /// Link a video-call meeting id to an appointment.
  Future<void> updateAppointmentCallId({
    required String appointmentId,
    required String callId,
  }) async {
    try {
      FirestoreLogger.log(
        collection: 'appointments',
        operation: 'update',
        details: 'doc=$appointmentId callId=$callId',
      );
      await _appointments.doc(appointmentId).update({
        'callId': callId,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      FirestoreLogger.logError(
        collection: 'appointments',
        operation: 'update',
        error: e,
      );
      throw FirebaseErrorMapper.map(e);
    } catch (e) {
      FirestoreLogger.logError(
        collection: 'appointments',
        operation: 'update',
        error: e,
      );
      throw FirebaseErrorMapper.map(e);
    }
  }

  /// Mark an appointment as completed after a consultation.
  Future<void> completeAppointment(String appointmentId) async {
    await updateAppointmentStatus(
      appointmentId: appointmentId,
      status: AppointmentStatus.completed,
    );
  }

  /// Accept an appointment.
  Future<void> acceptAppointment(String appointmentId) async {
    await updateAppointmentStatus(
      appointmentId: appointmentId,
      status: AppointmentStatus.accepted,
    );
  }

  /// Reject an appointment.
  Future<void> rejectAppointment(String appointmentId) async {
    await updateAppointmentStatus(
      appointmentId: appointmentId,
      status: AppointmentStatus.rejected,
    );
  }
}
