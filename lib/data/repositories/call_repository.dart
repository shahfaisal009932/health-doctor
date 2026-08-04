import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_webrtc/flutter_webrtc.dart';

import '../../core/exceptions/app_exception.dart';
import '../../core/exceptions/firebase_error_mapper.dart';
import '../../core/utils/firestore_logger.dart';
import '../models/appointment_model.dart';
import '../models/call_history_model.dart';

/// Lifecycle statuses of a call document.
class CallStatus {
  CallStatus._();

  static const ringing = 'ringing';
  static const active = 'active';
  static const rejected = 'rejected';
  static const missed = 'missed';
  static const ended = 'ended';
}

class CallRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get calls => _firestore.collection('calls');
  CollectionReference get _callHistory =>
      _firestore.collection('call_history');

  /// Create a new call document and return its ID.
  ///
  /// When an [appointmentId] is provided the call is linked to an
  /// appointment and only the assigned doctor/client may join.
  ///
  /// The caller-side SDP [offer] is written in the SAME document so the
  /// offer is guaranteed present and no post-create update can race the
  /// create being committed to the server.
  Future<String> createCall({
    String? appointmentId,
    String? doctorId,
    String? clientId,
    RTCSessionDescription? offer,
  }) async {
    try {
      final doc = appointmentId != null
          ? calls.doc(appointmentId)
          : calls.doc();
      FirestoreLogger.log(
        collection: 'calls',
        operation: 'set',
        details: 'doc=${doc.id} doctorId=$doctorId clientId=$clientId'
            '${offer != null ? ' withOffer' : ''}',
      );
      await doc.set({
        'appointmentId': appointmentId,
        'doctorId': doctorId ?? FirebaseAuth.instance.currentUser?.uid,
        'clientId': clientId,
        'status': CallStatus.ringing,
        'createdAt': FieldValue.serverTimestamp(),
        if (offer != null)
          'offer': {'type': offer.type, 'sdp': offer.sdp},
      });
      return doc.id;
    } on FirebaseException catch (e) {
      FirestoreLogger.logError(
        collection: 'calls',
        operation: 'set',
        error: e,
      );
      throw FirebaseErrorMapper.map(e);
    } catch (e) {
      FirestoreLogger.logError(
        collection: 'calls',
        operation: 'set',
        error: e,
      );
      throw FirebaseErrorMapper.map(e);
    }
  }

  /// Fetch a call document by ID.
  Future<DocumentSnapshot?> getCallById(String callId) async {
    try {
      FirestoreLogger.log(
        collection: 'calls',
        operation: 'read',
        details: 'doc=$callId',
      );
      final doc = await calls.doc(callId).get();
      return doc.exists ? doc : null;
    } on FirebaseException catch (e) {
      FirestoreLogger.logError(
        collection: 'calls',
        operation: 'read',
        error: e,
      );
      throw FirebaseErrorMapper.map(e);
    } catch (e) {
      FirestoreLogger.logError(
        collection: 'calls',
        operation: 'read',
        error: e,
      );
      throw FirebaseErrorMapper.map(e);
    }
  }

  /// Confirm the call document has been committed to the Firestore server.
  ///
  /// Reads from the server (not the local cache). While the document has not
  /// been committed server-side the rules' isCallParticipant check evaluates
  /// false and the read is denied, so a non-null/exists result proves the
  /// document is visible to the rules engine. Intended for a short polling
  /// loop; returns false (never throws) while the document is pending.
  Future<bool> callDocExistsOnServer(String callId) async {
    try {
      final doc = await calls
          .doc(callId)
          .get(const GetOptions(source: Source.server));
      return doc.exists;
    } catch (_) {
      return false;
    }
  }

  /// Verify the current user is an authorized participant of the call.
  ///
  /// If the call has both a doctor and client assigned, only those users
  /// may join. Otherwise (adhoc calls) any authenticated user can join.
  Future<void> verifyAccess(String callId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) {
      throw const AppException('Please log in to join this call.');
    }

    final doc = await getCallById(callId);
    if (doc == null) {
      throw const AppException('Call not found. Check the meeting ID and try again.');
    }

    final data = doc.data() as Map<String, dynamic>? ?? {};
    final doctorId = data['doctorId']?.toString() ?? '';
    final clientId = data['clientId']?.toString() ?? '';

    if (doctorId.isEmpty && clientId.isEmpty) return;

    final isParticipant =
        uid == doctorId || (clientId.isNotEmpty && uid == clientId);
    if (!isParticipant) {
      throw const AppException(
        'You are not authorized to join this consultation.',
      );
    }
  }

  /// Verify access to an appointment-linked call, with a friendlier message
  /// when the call document has not been created yet (doctor has not started).
  Future<void> verifyAccessForAppointment(String callId) async {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? '';
    if (uid.isEmpty) {
      throw const AppException('Please log in to join this call.');
    }

    final doc = await getCallById(callId);
    if (doc == null) {
      throw const AppException(
        'The doctor has not started the consultation yet. Please try again in a moment.',
      );
    }

    final data = doc.data() as Map<String, dynamic>? ?? {};
    final doctorId = data['doctorId']?.toString() ?? '';
    final clientId = data['clientId']?.toString() ?? '';

    if (doctorId.isEmpty && clientId.isEmpty) return;

    final isParticipant =
        uid == doctorId || (clientId.isNotEmpty && uid == clientId);
    if (!isParticipant) {
      throw const AppException(
        'You are not authorized to join this consultation.',
      );
    }
  }

  /// Mark an appointment as completed after the consultation ends.
  Future<void> completeAppointment(String appointmentId) async {
    try {
      FirestoreLogger.log(
        collection: 'appointments',
        operation: 'update',
        details: 'doc=$appointmentId status=Completed',
      );
      await _firestore.collection('appointments').doc(appointmentId).update({
        'status': AppointmentStatus.completed,
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

  /// Save the SDP answer and mark the call as active (answered).
  Future<void> saveAnswer({
    required String callId,
    required RTCSessionDescription answer,
  }) async {
    try {
      FirestoreLogger.log(
        collection: 'calls',
        operation: 'update',
        details: 'doc=$callId answer',
      );
      await calls.doc(callId).update({
        'answer': {'type': answer.type, 'sdp': answer.sdp},
        'status': CallStatus.active,
      });
    } on FirebaseException catch (e) {
      FirestoreLogger.logError(
        collection: 'calls',
        operation: 'update',
        error: e,
      );
      throw FirebaseErrorMapper.map(e);
    } catch (e) {
      FirestoreLogger.logError(
        collection: 'calls',
        operation: 'update',
        error: e,
      );
      throw FirebaseErrorMapper.map(e);
    }
  }

  /// Mark the call as rejected by the client. Triggers the server-side
  /// notification that tells the doctor the patient declined.
  Future<void> markCallRejected(String callId) {
    return _updateCallStatus(callId, CallStatus.rejected);
  }

  /// Mark the call as missed (client did not answer in time). Triggers the
  /// server-side notification that tells the doctor the call was missed.
  Future<void> markCallMissed(String callId) {
    return _updateCallStatus(callId, CallStatus.missed);
  }

  Future<void> _updateCallStatus(String callId, String status) async {
    try {
      FirestoreLogger.log(
        collection: 'calls',
        operation: 'update',
        details: 'doc=$callId status=$status',
      );
      await calls.doc(callId).update({'status': status});
    } on FirebaseException catch (e) {
      FirestoreLogger.logError(
        collection: 'calls',
        operation: 'update',
        error: e,
      );
      throw FirebaseErrorMapper.map(e);
    } catch (e) {
      FirestoreLogger.logError(
        collection: 'calls',
        operation: 'update',
        error: e,
      );
      throw FirebaseErrorMapper.map(e);
    }
  }

  /// Add a caller ICE candidate.
  Future<void> addCallerCandidate({
    required String callId,
    required RTCIceCandidate candidate,
  }) async {
    try {
      FirestoreLogger.log(
        collection: 'calls/callerCandidates',
        operation: 'add',
        details: 'doc=$callId',
      );
      await calls.doc(callId).collection('callerCandidates').add({
        'candidate': candidate.candidate,
        'sdpMid': candidate.sdpMid,
        'sdpMLineIndex': candidate.sdpMLineIndex,
      });
    } on FirebaseException catch (e) {
      FirestoreLogger.logError(
        collection: 'calls/callerCandidates',
        operation: 'add',
        error: e,
      );
      throw FirebaseErrorMapper.map(e);
    } catch (e) {
      FirestoreLogger.logError(
        collection: 'calls/callerCandidates',
        operation: 'add',
        error: e,
      );
      throw FirebaseErrorMapper.map(e);
    }
  }

  /// Add a callee ICE candidate.
  Future<void> addCalleeCandidate({
    required String callId,
    required RTCIceCandidate candidate,
  }) async {
    try {
      FirestoreLogger.log(
        collection: 'calls/calleeCandidates',
        operation: 'add',
        details: 'doc=$callId',
      );
      await calls.doc(callId).collection('calleeCandidates').add({
        'candidate': candidate.candidate,
        'sdpMid': candidate.sdpMid,
        'sdpMLineIndex': candidate.sdpMLineIndex,
      });
    } on FirebaseException catch (e) {
      FirestoreLogger.logError(
        collection: 'calls/calleeCandidates',
        operation: 'add',
        error: e,
      );
      throw FirebaseErrorMapper.map(e);
    } catch (e) {
      FirestoreLogger.logError(
        collection: 'calls/calleeCandidates',
        operation: 'add',
        error: e,
      );
      throw FirebaseErrorMapper.map(e);
    }
  }

  /// Stream the call document for status/answer updates.
  Stream<DocumentSnapshot> listenCall(String callId) {
    FirestoreLogger.log(
      collection: 'calls',
      operation: 'listen',
      details: 'doc=$callId',
    );
    return calls.doc(callId).snapshots();
  }

  /// Stream caller ICE candidates.
  Stream<QuerySnapshot> callerCandidates(String callId) {
    FirestoreLogger.log(
      collection: 'calls/callerCandidates',
      operation: 'listen',
      details: 'doc=$callId',
    );
    return calls.doc(callId).collection('callerCandidates').snapshots();
  }

  /// Stream callee ICE candidates.
  Stream<QuerySnapshot> calleeCandidates(String callId) {
    FirestoreLogger.log(
      collection: 'calls/calleeCandidates',
      operation: 'listen',
      details: 'doc=$callId',
    );
    return calls.doc(callId).collection('calleeCandidates').snapshots();
  }

  /// Save a completed call into the call history collection.
  Future<void> saveCallHistory({
    required String callId,
    required String appointmentId,
    required String doctorId,
    required String clientId,
    required DateTime startedAt,
    required DateTime endedAt,
  }) async {
    try {
      final duration = endedAt.difference(startedAt).inSeconds;
      FirestoreLogger.log(
        collection: 'call_history',
        operation: 'add',
        details: 'appointmentId=$appointmentId doctorId=$doctorId '
            'clientId=$clientId',
      );
      await _callHistory.add({
        'callId': callId,
        'appointmentId': appointmentId,
        'doctorId': doctorId,
        'clientId': clientId,
        'startedAt': Timestamp.fromDate(startedAt),
        'endedAt': Timestamp.fromDate(endedAt),
        'durationSeconds': duration < 0 ? 0 : duration,
      });
    } on FirebaseException catch (e) {
      FirestoreLogger.logError(
        collection: 'call_history',
        operation: 'add',
        error: e,
      );
      throw FirebaseErrorMapper.map(e);
    } catch (e) {
      FirestoreLogger.logError(
        collection: 'call_history',
        operation: 'add',
        error: e,
      );
      throw FirebaseErrorMapper.map(e);
    }
  }

  /// Fetch call history for an appointment.
  Future<List<CallHistoryModel>> getCallHistory(String appointmentId) async {
    try {
      FirestoreLogger.log(
        collection: 'call_history',
        operation: 'read',
        details: 'appointmentId=$appointmentId orderBy=startedAt(desc)',
      );
      final snapshot = await _callHistory
          .where('appointmentId', isEqualTo: appointmentId)
          .orderBy('startedAt', descending: true)
          .get();
      return snapshot.docs
          .map((doc) => CallHistoryModel.fromMap(
              doc.id, doc.data() as Map<String, dynamic>))
          .toList();
    } on FirebaseException catch (e) {
      FirestoreLogger.logError(
        collection: 'call_history',
        operation: 'read',
        error: e,
      );
      throw FirebaseErrorMapper.map(e);
    } catch (e) {
      FirestoreLogger.logError(
        collection: 'call_history',
        operation: 'read',
        error: e,
      );
      throw FirebaseErrorMapper.map(e);
    }
  }

  /// Delete the call document and its candidate subcollections.
  ///
  /// Idempotent: if the remote side already deleted the call document, the
  /// candidate reads are denied (rule returns false) and only the call doc
  /// deletion is re-applied.
  Future<void> clearCall(String callId) async {
    try {
      final batch = _firestore.batch();

      try {
        FirestoreLogger.log(
          collection: 'calls/callerCandidates',
          operation: 'read',
          details: 'doc=$callId',
        );
        final caller =
            await calls.doc(callId).collection('callerCandidates').get();
        for (final doc in caller.docs) {
          batch.delete(doc.reference);
        }
      } catch (e) {
        debugPrint('clearCall callerCandidates skipped: $e');
      }

      try {
        FirestoreLogger.log(
          collection: 'calls/calleeCandidates',
          operation: 'read',
          details: 'doc=$callId',
        );
        final callee =
            await calls.doc(callId).collection('calleeCandidates').get();
        for (final doc in callee.docs) {
          batch.delete(doc.reference);
        }
      } catch (e) {
        debugPrint('clearCall calleeCandidates skipped: $e');
      }

      FirestoreLogger.log(
        collection: 'calls',
        operation: 'batch',
        details: 'delete doc=$callId + candidates',
      );
      batch.delete(calls.doc(callId));
      await batch.commit();
    } on FirebaseException catch (e) {
      FirestoreLogger.logError(
        collection: 'calls',
        operation: 'batch',
        error: e,
      );
      throw FirebaseErrorMapper.map(e);
    } catch (e) {
      FirestoreLogger.logError(
        collection: 'calls',
        operation: 'batch',
        error: e,
      );
      throw FirebaseErrorMapper.map(e);
    }
  }
}
