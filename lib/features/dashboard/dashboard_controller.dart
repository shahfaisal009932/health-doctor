import 'dart:async';

import 'package:get/get.dart';

import '../../core/exceptions/app_exception.dart';
import '../../core/exceptions/firebase_error_mapper.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../data/models/appointment_model.dart';
import '../../data/repositories/dashboard_repository.dart';

class DashboardController extends GetxController {
  final DashboardRepository _repository;

  DashboardController(this._repository);

  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final RxString _doctorName = ''.obs;
  String get doctorName => _doctorName.value;

  final RxString _doctorEmail = ''.obs;
  String get doctorEmail => _doctorEmail.value;

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
    loadDashboard();
    _bindAppointments();
  }

  @override
  void onClose() {
    _appointmentsSubscription?.cancel();
    super.onClose();
  }

  /// Load the doctor profile once.
  Future<void> loadDashboard() async {
    _isLoading.value = true;
    _hasError.value = false;
    _errorMessage.value = '';
    try {
      final profile = await _repository.getDoctorProfile();
      _doctorName.value = profile?.name ?? 'Doctor';
      _doctorEmail.value = profile?.email ?? '';
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

  /// Realtime appointment stream for the current doctor.
  void _bindAppointments() {
    _appointmentsSubscription?.cancel();
    _appointmentsSubscription =
        _repository.listenToAppointments().listen(
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
      await _repository.updateAppointmentStatus(
        appointmentId,
        AppointmentStatus.accepted,
      );
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
      await _repository.updateAppointmentStatus(
        appointmentId,
        AppointmentStatus.rejected,
      );
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
      await _repository.updateAppointmentStatus(
        appointmentId,
        AppointmentStatus.completed,
      );
      AppSnackbar.showSuccess('Appointment marked as completed.');
    } on AppException catch (e) {
      AppSnackbar.showError(e.message);
    } catch (e) {
      AppSnackbar.showError(FirebaseErrorMapper.map(e).message);
    }
  }

  String get greeting {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good Morning';
    if (hour < 17) return 'Good Afternoon';
    return 'Good Evening';
  }
}
