import 'package:cloud_firestore/cloud_firestore.dart';

import '../../core/exceptions/firebase_error_mapper.dart';
import '../../core/utils/firestore_logger.dart';
import '../models/session_note_model.dart';

class NoteRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  CollectionReference get _notes => _firestore.collection('session_notes');

  /// Add a session note.
  Future<void> addNote({
    required String appointmentId,
    required String note,
  }) async {
    try {
      FirestoreLogger.log(
        collection: 'session_notes',
        operation: 'add',
        details: 'appointmentId=$appointmentId',
      );
      await _notes.add({
        'appointmentId': appointmentId,
        'note': note,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      FirestoreLogger.logError(
        collection: 'session_notes',
        operation: 'add',
        error: e,
      );
      throw FirebaseErrorMapper.map(e);
    } catch (e) {
      FirestoreLogger.logError(
        collection: 'session_notes',
        operation: 'add',
        error: e,
      );
      throw FirebaseErrorMapper.map(e);
    }
  }

  /// Fetch notes for an appointment.
  Future<List<SessionNoteModel>> getNotes(String appointmentId) async {
    try {
      FirestoreLogger.log(
        collection: 'session_notes',
        operation: 'read',
        details: 'appointmentId=$appointmentId orderBy=createdAt(desc)',
      );
      final snapshot = await _notes
          .where('appointmentId', isEqualTo: appointmentId)
          .orderBy('createdAt', descending: true)
          .get();

      return snapshot.docs.map((doc) {
        return SessionNoteModel.fromFirestore(doc);
      }).toList();
    } on FirebaseException catch (e) {
      FirestoreLogger.logError(
        collection: 'session_notes',
        operation: 'read',
        error: e,
      );
      throw FirebaseErrorMapper.map(e);
    } catch (e) {
      FirestoreLogger.logError(
        collection: 'session_notes',
        operation: 'read',
        error: e,
      );
      throw FirebaseErrorMapper.map(e);
    }
  }

  /// Update an existing note.
  Future<void> updateNote({
    required String noteId,
    required String note,
  }) async {
    try {
      FirestoreLogger.log(
        collection: 'session_notes',
        operation: 'update',
        details: 'doc=$noteId',
      );
      await _notes.doc(noteId).update({
        'note': note,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      FirestoreLogger.logError(
        collection: 'session_notes',
        operation: 'update',
        error: e,
      );
      throw FirebaseErrorMapper.map(e);
    } catch (e) {
      FirestoreLogger.logError(
        collection: 'session_notes',
        operation: 'update',
        error: e,
      );
      throw FirebaseErrorMapper.map(e);
    }
  }

  /// Delete a note.
  Future<void> deleteNote(String noteId) async {
    try {
      FirestoreLogger.log(
        collection: 'session_notes',
        operation: 'delete',
        details: 'doc=$noteId',
      );
      await _notes.doc(noteId).delete();
    } on FirebaseException catch (e) {
      FirestoreLogger.logError(
        collection: 'session_notes',
        operation: 'delete',
        error: e,
      );
      throw FirebaseErrorMapper.map(e);
    } catch (e) {
      FirestoreLogger.logError(
        collection: 'session_notes',
        operation: 'delete',
        error: e,
      );
      throw FirebaseErrorMapper.map(e);
    }
  }
}