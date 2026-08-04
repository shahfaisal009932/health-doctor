import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../core/exceptions/firebase_error_mapper.dart';
import '../../core/utils/firestore_logger.dart';
import '../models/appointment_model.dart';
import '../models/doctor_model.dart';

class DashboardRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get currentUid => _auth.currentUser?.uid ?? '';

  /// Fetch the doctor profile for the current user.
  Future<DoctorModel?> getDoctorProfile() async {
    try {
      if (currentUid.isEmpty) {
        FirestoreLogger.log(
          collection: 'doctors',
          operation: 'read',
          details: 'unauthenticated',
        );
        return null;
      }
      FirestoreLogger.log(
        collection: 'doctors',
        operation: 'read',
        details: 'doc=$currentUid',
      );
      final doc = await _firestore.collection('doctors').doc(currentUid).get();
      if (!doc.exists) return null;
      return DoctorModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    } on FirebaseException catch (e) {
      FirestoreLogger.logError(
        collection: 'doctors',
        operation: 'read',
        error: e,
      );
      throw FirebaseErrorMapper.map(e);
    } catch (e) {
      FirestoreLogger.logError(
        collection: 'doctors',
        operation: 'read',
        error: e,
      );
      throw FirebaseErrorMapper.map(e);
    }
  }

  /// Realtime stream of appointments for the current doctor.
  Stream<List<AppointmentModel>> listenToAppointments() {
    if (currentUid.isEmpty) {
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
      details: 'doctorId=$currentUid orderBy=createdAt(desc)',
    );
    return _firestore
        .collection('appointments')
        .where('doctorId', isEqualTo: currentUid)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AppointmentModel.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// Fetch appointments for the current doctor (one-shot).
  Future<List<AppointmentModel>> getAppointments() async {
    try {
      if (currentUid.isEmpty) return [];
      FirestoreLogger.log(
        collection: 'appointments',
        operation: 'read',
        details: 'doctorId=$currentUid orderBy=createdAt(desc)',
      );
      final snapshot = await _firestore
          .collection('appointments')
          .where('doctorId', isEqualTo: currentUid)
          .get();

      return snapshot.docs
          .map((doc) => AppointmentModel.fromMap(doc.id, doc.data()))
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

  /// Update appointment status (Accept / Reject / Complete).
  Future<void> updateAppointmentStatus(
    String appointmentId,
    String status,
  ) async {
    try {
      FirestoreLogger.log(
        collection: 'appointments',
        operation: 'update',
        details: 'doc=$appointmentId status=$status',
      );
      await _firestore.collection('appointments').doc(appointmentId).update({
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

  /// Update the doctor's availability status.
  Future<void> updateAvailability({
    required String doctorId,
    required bool isAvailable,
    List<String>? availability,
  }) async {
    try {
      final data = <String, dynamic>{
        'isAvailable': isAvailable,
        'updatedAt': FieldValue.serverTimestamp(),
      };
      if (availability != null) data['availability'] = availability;
      FirestoreLogger.log(
        collection: 'doctors',
        operation: 'update',
        details: 'doc=$doctorId isAvailable=$isAvailable',
      );
      await _firestore.collection('doctors').doc(doctorId).update(data);
    } on FirebaseException catch (e) {
      FirestoreLogger.logError(
        collection: 'doctors',
        operation: 'update',
        error: e,
      );
      throw FirebaseErrorMapper.map(e);
    } catch (e) {
      FirestoreLogger.logError(
        collection: 'doctors',
        operation: 'update',
        error: e,
      );
      throw FirebaseErrorMapper.map(e);
    }
  }
}
