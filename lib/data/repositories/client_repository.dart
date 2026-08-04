import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/exceptions/firebase_error_mapper.dart';
import '../../core/utils/firestore_logger.dart';
import '../models/appointment_model.dart';
import '../models/client_model.dart';
import '../models/doctor_model.dart';

class ClientRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _doctors => _firestore.collection('doctors');
  CollectionReference get _clients => _firestore.collection('clients');
  CollectionReference get _appointments =>
      _firestore.collection('appointments');

  /// Search doctors by name or specialization, with an optional
  /// availability filter.
  Future<List<DoctorModel>> searchDoctors({
    String query = '',
    String? specialization,
    bool onlyAvailable = false,
  }) async {
    try {
      Query<Object?> queryRef = _doctors;

      if (specialization != null && specialization.isNotEmpty) {
        queryRef =
            queryRef.where('specialization', isEqualTo: specialization);
      }
      if (onlyAvailable) {
        queryRef = queryRef.where('isAvailable', isEqualTo: true);
      }

      FirestoreLogger.log(
        collection: 'doctors',
        operation: 'search',
        details: 'query="$query" specialization=$specialization '
            'onlyAvailable=$onlyAvailable orderBy=name(asc)',
      );
      final snapshot = await queryRef
          .orderBy('name')
          .limit(100)
          .get();

      var doctors = snapshot.docs
          .map((doc) =>
              DoctorModel.fromMap(doc.id, doc.data() as Map<String, dynamic>))
          .toList();

      final q = query.trim().toLowerCase();
      if (q.isNotEmpty) {
        doctors = doctors.where((d) {
          return d.name.toLowerCase().contains(q) ||
              d.specialization.toLowerCase().contains(q);
        }).toList();
      }

      return doctors;
    } on FirebaseException catch (e) {
      FirestoreLogger.logError(
        collection: 'doctors',
        operation: 'search',
        error: e,
      );
      throw FirebaseErrorMapper.map(e);
    } catch (e) {
      FirestoreLogger.logError(
        collection: 'doctors',
        operation: 'search',
        error: e,
      );
      throw FirebaseErrorMapper.map(e);
    }
  }

  /// Distinct specializations for the filter dropdown.
  Future<List<String>> getSpecializations() async {
    try {
      FirestoreLogger.log(
        collection: 'doctors',
        operation: 'read',
        details: 'orderBy=specialization(asc)',
      );
      final snapshot = await _doctors
          .orderBy('specialization')
          .get();
      final set = <String>{};
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        final spec = data['specialization'];
        if (spec is String && spec.isNotEmpty) {
          set.add(spec);
        }
      }
      return set.toList();
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

  /// Fetch a single doctor profile.
  Future<DoctorModel?> getDoctorById(String doctorId) async {
    try {
      FirestoreLogger.log(
        collection: 'doctors',
        operation: 'read',
        details: 'doc=$doctorId',
      );
      final doc = await _doctors.doc(doctorId).get();
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

  /// Fetch the current client profile.
  Future<ClientModel?> getClientProfile(String clientId) async {
    try {
      if (clientId.isEmpty) return null;
      FirestoreLogger.log(
        collection: 'clients',
        operation: 'read',
        details: 'doc=$clientId',
      );
      final doc = await _clients.doc(clientId).get();
      if (!doc.exists) return null;
      return ClientModel.fromMap(doc.id, doc.data() as Map<String, dynamic>);
    } on FirebaseException catch (e) {
      FirestoreLogger.logError(
        collection: 'clients',
        operation: 'read',
        error: e,
      );
      throw FirebaseErrorMapper.map(e);
    } catch (e) {
      FirestoreLogger.logError(
        collection: 'clients',
        operation: 'read',
        error: e,
      );
      throw FirebaseErrorMapper.map(e);
    }
  }

  /// Update the client profile details.
  Future<void> updateClientProfile({
    required String clientId,
    required String name,
    required String phone,
  }) async {
    try {
      FirestoreLogger.log(
        collection: 'clients',
        operation: 'update',
        details: 'doc=$clientId',
      );
      await _clients.doc(clientId).update({
        'name': name,
        'phone': phone,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      FirestoreLogger.logError(
        collection: 'clients',
        operation: 'update',
        error: e,
      );
      throw FirebaseErrorMapper.map(e);
    } catch (e) {
      FirestoreLogger.logError(
        collection: 'clients',
        operation: 'update',
        error: e,
      );
      throw FirebaseErrorMapper.map(e);
    }
  }

  /// Book an appointment for a client with a doctor.
  Future<AppointmentModel> bookAppointment({
    required String clientId,
    required String clientName,
    required String doctorId,
    required String doctorName,
    required String doctorSpecialization,
    required DateTime appointmentDate,
    required String appointmentTime,
    required String symptoms,
    required int age,
    required String phone,
  }) async {
    try {
      FirestoreLogger.log(
        collection: 'appointments',
        operation: 'set',
        details: 'create clientId=$clientId doctorId=$doctorId',
      );
      final doc = _appointments.doc();
      await doc.set({
        'doctorId': doctorId,
        'doctorName': doctorName,
        'doctorSpecialization': doctorSpecialization,
        'clientId': clientId,
        'clientName': clientName,
        'age': age,
        'phone': phone,
        'symptoms': symptoms,
        'appointmentDate': Timestamp.fromDate(appointmentDate),
        'appointmentTime': appointmentTime,
        'status': AppointmentStatus.pending,
        'paymentStatus': PaymentStatus.unpaid,
        'callId': null,
        'createdAt': FieldValue.serverTimestamp(),
      });

      return AppointmentModel(
        id: doc.id,
        doctorId: doctorId,
        doctorName: doctorName,
        doctorSpecialization: doctorSpecialization,
        clientId: clientId,
        clientName: clientName,
        age: age,
        phone: phone,
        symptoms: symptoms,
        appointmentDate: appointmentDate,
        appointmentTime: appointmentTime,
        status: AppointmentStatus.pending,
        paymentStatus: PaymentStatus.unpaid,
        createdAt: DateTime.now(),
      );
    } on FirebaseException catch (e) {
      FirestoreLogger.logError(
        collection: 'appointments',
        operation: 'set',
        error: e,
      );
      throw FirebaseErrorMapper.map(e);
    } catch (e) {
      FirestoreLogger.logError(
        collection: 'appointments',
        operation: 'set',
        error: e,
      );
      throw FirebaseErrorMapper.map(e);
    }
  }

  /// Realtime stream of the client's appointments.
  Stream<List<AppointmentModel>> listenToClientAppointments(
    String clientId,
  ) {
    if (clientId.isEmpty) {
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
      details: 'clientId=$clientId (snapshots, sorted in memory)',
    );
    // A bare where() query needs NO composite index, so realtime delivery can
    // never be silently blocked by a missing index. Ordering is applied in
    // memory (newest first) to preserve the previous UI order.
    return _appointments
        .where('clientId', isEqualTo: clientId)
        .snapshots()
        .map((snapshot) {
      final items = snapshot.docs
          .map((doc) => AppointmentModel.fromMap(
              doc.id, doc.data() as Map<String, dynamic>))
          .toList();
      items.sort((a, b) =>
          _sortTimestamp(b.createdAt).compareTo(_sortTimestamp(a.createdAt)));
      return items;
    });
  }

  /// Sort key for appointments; unresolved server timestamps sort last,
  /// mirroring Firestore's own descending orderBy behaviour.
  static DateTime _sortTimestamp(DateTime? value) =>
      value ?? DateTime.fromMillisecondsSinceEpoch(0);

  /// Realtime stream of a single appointment (status updates).
  Stream<AppointmentModel?> listenToAppointment(String appointmentId) {
    FirestoreLogger.log(
      collection: 'appointments',
      operation: 'listen',
      details: 'doc=$appointmentId',
    );
    return _appointments.doc(appointmentId).snapshots().map((doc) {
      if (!doc.exists) return null;
      return AppointmentModel.fromMap(
        doc.id,
        doc.data() as Map<String, dynamic>,
      );
    });
  }

  /// Cancel a pending appointment from the client side.
  Future<void> cancelAppointment(String appointmentId) async {
    try {
      FirestoreLogger.log(
        collection: 'appointments',
        operation: 'update',
        details: 'doc=$appointmentId status=Cancelled',
      );
      await _appointments.doc(appointmentId).update({
        'status': AppointmentStatus.cancelled,
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
}
