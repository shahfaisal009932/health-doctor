import 'package:get/get.dart';

import '../../core/exceptions/app_exception.dart';
import '../../core/exceptions/firebase_error_mapper.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../data/models/session_note_model.dart';
import '../../data/repositories/note_repository.dart';

class NoteController extends GetxController {
  final NoteRepository _repository;

  NoteController(this._repository);

  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final RxList<SessionNoteModel> _notes = <SessionNoteModel>[].obs;
  List<SessionNoteModel> get notes => _notes;

  final RxBool _hasError = false.obs;
  bool get hasError => _hasError.value;

  final RxString _errorMessage = ''.obs;
  String get errorMessage => _errorMessage.value;

  /// Fetch notes for an appointment.
  Future<void> getNotes(String appointmentId) async {
    _isLoading.value = true;
    _hasError.value = false;
    _errorMessage.value = '';
    try {
      _notes.value = await _repository.getNotes(appointmentId);
    } on AppException catch (e) {
      _hasError.value = true;
      _errorMessage.value = e.message;
    } catch (e) {
      _hasError.value = true;
      _errorMessage.value = FirebaseErrorMapper.map(e).message;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Add a session note.
  Future<bool> addNote({
    required String appointmentId,
    required String note,
  }) async {
    try {
      await _repository.addNote(appointmentId: appointmentId, note: note);
      return true;
    } on AppException catch (e) {
      AppSnackbar.showError(e.message);
      return false;
    } catch (e) {
      AppSnackbar.showError(FirebaseErrorMapper.map(e).message);
      return false;
    }
  }

  /// Update a session note.
  Future<bool> updateNote({
    required String noteId,
    required String note,
    required String appointmentId,
  }) async {
    try {
      await _repository.updateNote(noteId: noteId, note: note);
      return true;
    } on AppException catch (e) {
      AppSnackbar.showError(e.message);
      return false;
    } catch (e) {
      AppSnackbar.showError(FirebaseErrorMapper.map(e).message);
      return false;
    }
  }

  /// Delete a session note.
  Future<bool> deleteNote({
    required String noteId,
    required String appointmentId,
  }) async {
    try {
      await _repository.deleteNote(noteId);
      return true;
    } on AppException catch (e) {
      AppSnackbar.showError(e.message);
      return false;
    } catch (e) {
      AppSnackbar.showError(FirebaseErrorMapper.map(e).message);
      return false;
    }
  }
}
