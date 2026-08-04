import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../core/exceptions/app_exception.dart';
import '../../core/exceptions/firebase_error_mapper.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../data/models/appointment_model.dart';
import '../../data/repositories/appointment_repository.dart';

class AppointmentController extends GetxController {
  final AppointmentRepository _repository;

  AppointmentController(this._repository);

  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final RxList<AppointmentModel> _appointments = <AppointmentModel>[].obs;
  List<AppointmentModel> get appointments => _appointments;

  final RxBool _hasError = false.obs;
  bool get hasError => _hasError.value;

  final RxString _errorMessage = ''.obs;
  String get errorMessage => _errorMessage.value;

  StreamSubscription<List<AppointmentModel>>? _appointmentsSubscription;

  @override
  void onInit() {
    super.onInit();
    _bindAppointments();
  }

  @override
  void onClose() {
    _appointmentsSubscription?.cancel();
    super.onClose();
  }

  /// Re-establish the appointment stream after an error.
  void retry() {
    _hasError.value = false;
    _errorMessage.value = '';
    _isLoading.value = true;
    _bindAppointments();
  }

  /// Realtime stream of the current doctor's appointments.
  void _bindAppointments() {
    final doctorId = FirebaseAuth.instance.currentUser?.uid ?? '';
    _appointmentsSubscription?.cancel();
    _appointmentsSubscription =
        _repository.listenToAppointments(doctorId).listen(
      (items) {
        _appointments.assignAll(items);
        _isLoading.value = false;
        _hasError.value = false;
      },
      onError: (Object error) {
        _isLoading.value = false;
        _hasError.value = true;
        _errorMessage.value = FirebaseErrorMapper.map(error).message;
      },
    );
  }

  /// Accept a pending appointment.
  Future<void> acceptAppointment(String appointmentId) async {
    try {
      await _repository.acceptAppointment(appointmentId);
      AppSnackbar.showSuccess('Appointment accepted.');
    } on AppException catch (e) {
      AppSnackbar.showError(e.message);
    } catch (e) {
      AppSnackbar.showError(FirebaseErrorMapper.map(e).message);
    }
  }

  /// Reject a pending appointment.
  Future<void> rejectAppointment(String appointmentId) async {
    try {
      await _repository.rejectAppointment(appointmentId);
      AppSnackbar.showInfo('Appointment rejected.');
    } on AppException catch (e) {
      AppSnackbar.showError(e.message);
    } catch (e) {
      AppSnackbar.showError(FirebaseErrorMapper.map(e).message);
    }
  }

  /// Mark an accepted appointment as completed after the consultation.
  Future<void> completeAppointment(String appointmentId) async {
    try {
      await _repository.completeAppointment(appointmentId);
      AppSnackbar.showSuccess('Appointment marked as completed.');
    } on AppException catch (e) {
      AppSnackbar.showError(e.message);
    } catch (e) {
      AppSnackbar.showError(FirebaseErrorMapper.map(e).message);
    }
  }
}
