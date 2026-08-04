import 'dart:async';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';

import '../../core/exceptions/app_exception.dart';
import '../../core/exceptions/firebase_error_mapper.dart';
import '../../core/services/notification_service.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../data/models/appointment_model.dart';
import '../../data/models/notification_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../data/repositories/client_repository.dart';
import '../../data/repositories/notification_repository.dart';

class ClientController extends GetxController {
  final ClientRepository _clientRepository;
  final NotificationRepository _notificationRepository;
  final AuthRepository _authRepository;

  ClientController(
    this._clientRepository,
    this._notificationRepository,
    this._authRepository,
  );

  String get _uid => FirebaseAuth.instance.currentUser?.uid ?? '';

  // ---- Profile ----
  final RxBool isLoadingProfile = false.obs;
  final RxString clientName = ''.obs;
  final RxString clientEmail = ''.obs;
  final RxString clientPhone = ''.obs;

  // ---- Appointments ----
  final RxBool isLoadingAppointments = false.obs;
  final RxList<AppointmentModel> appointments = <AppointmentModel>[].obs;
  final RxBool hasAppointmentsError = false.obs;
  final RxString appointmentsErrorMessage = ''.obs;

  // ---- Notifications ----
  final RxList<AppNotificationModel> notifications =
      <AppNotificationModel>[].obs;
  final RxInt unreadCount = 0.obs;

  /// Last status seen per appointment id, used to log old -> new transitions.
  final Map<String, String> _previousStatuses = {};

  final Set<String> _seenStatusEvents = {};

  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<List<AppointmentModel>>? _appointmentsSubscription;
  StreamSubscription<List<AppNotificationModel>>? _notificationsSubscription;

  @override
  void onInit() {
    super.onInit();
    debugPrint('[Realtime] ClientController.onInit uid=$_uid');

    // Keep the realtime streams bound to the signed-in user. The controller
    // is a permanent singleton, so every auth transition (login / logout /
    // account switch) must re-establish (or tear down) the listeners. This
    // also covers the case where the controller is created before Firebase
    // Auth reports the current user.
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen((user) {
      final uid = user?.uid ?? '';
      debugPrint('[Realtime] authStateChanged uid=$uid');
      if (user == null) {
        _clearClientData();
        return;
      }
      loadProfile();
      bindAppointments();
      bindNotifications();
    });
  }

  @override
  void onClose() {
    debugPrint('[Realtime] ClientController.onClose');
    _authSubscription?.cancel();
    _appointmentsSubscription?.cancel();
    _notificationsSubscription?.cancel();
    super.onClose();
  }

  /// Load the client profile.
  Future<void> loadProfile() async {
    isLoadingProfile.value = true;
    try {
      final profile = await _clientRepository.getClientProfile(_uid);
      clientName.value = profile?.name ?? 'Patient';
      clientEmail.value = profile?.email ?? '';
      clientPhone.value = profile?.phone ?? '';
    } on AppException catch (e) {
      AppSnackbar.showError(e.message);
    } catch (e) {
      AppSnackbar.showError(FirebaseErrorMapper.map(e).message);
    } finally {
      isLoadingProfile.value = false;
    }
  }

  /// Update the client's profile details.
  ///
  /// Returns whether the update succeeded and, on failure, the error message
  /// so the caller can surface it inline instead of silently failing.
  Future<({bool success, String? error})> updateProfile({
    required String name,
    required String phone,
  }) async {
    try {
      await _clientRepository.updateClientProfile(
        clientId: _uid,
        name: name,
        phone: phone,
      );
      clientName.value = name;
      clientPhone.value = phone;
      return (success: true, error: null);
    } on AppException catch (e) {
      return (success: false, error: e.message);
    } catch (e) {
      return (success: false, error: FirebaseErrorMapper.map(e).message);
    }
  }

  /// Re-establish the appointment stream after an error.
  Future<void> retryAppointments() async {
    hasAppointmentsError.value = false;
    appointmentsErrorMessage.value = '';
    isLoadingAppointments.value = true;
    bindAppointments();
  }

  /// Realtime appointment stream for the current client.
  void bindAppointments() {
    _appointmentsSubscription?.cancel();
    _appointmentsSubscription = null;

    final uid = _uid;
    if (uid.isEmpty) {
      debugPrint('[Realtime] bindAppointments skipped (no uid)');
      appointments.assignAll(const []);
      isLoadingAppointments.value = false;
      return;
    }

    debugPrint('[Realtime] bindAppointments | uid=$uid | clientId=$uid');
    _appointmentsSubscription = _clientRepository
        .listenToClientAppointments(uid)
        .listen((items) {
      _trackStatusChanges(items);
      _logStatusTransitions(items);
      appointments.assignAll(items);
      isLoadingAppointments.value = false;
      hasAppointmentsError.value = false;
      debugPrint(
        '[Realtime] Snapshot received | '
        'appointmentIds=${items.map((a) => a.id).toList()} | '
        'statuses=${items.map((a) => a.status).toList()} | '
        'RxList length=${appointments.length} | '
        'UI rebuild triggered (Obx listeners notified)',
      );
    }, onError: (Object error) {
      debugPrint('[Realtime] Stream ERROR | $error');
      isLoadingAppointments.value = false;
      hasAppointmentsError.value = true;
      appointmentsErrorMessage.value = FirebaseErrorMapper.map(error).message;
    });
  }

  /// Realtime notification stream for the current client.
  void bindNotifications() {
    _notificationsSubscription?.cancel();
    _notificationsSubscription = null;

    final uid = _uid;
    if (uid.isEmpty) {
      notifications.assignAll(const []);
      unreadCount.value = 0;
      return;
    }

    _notificationsSubscription = _notificationRepository
        .listenToNotifications(uid)
        .listen((items) {
      notifications.assignAll(items);
      unreadCount.value = items.where((n) => !n.read).length;
    }, onError: (Object error) {
      // Non-blocking.
    });
  }

  /// Book an appointment with a doctor.
  Future<bool> bookAppointment({
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
      final client = await _clientRepository.getClientProfile(_uid);
      await _clientRepository.bookAppointment(
        clientId: _uid,
        clientName: client?.name ?? clientName.value,
        doctorId: doctorId,
        doctorName: doctorName,
        doctorSpecialization: doctorSpecialization,
        appointmentDate: appointmentDate,
        appointmentTime: appointmentTime,
        symptoms: symptoms,
        age: age,
        phone: phone.isEmpty ? (client?.phone ?? clientPhone.value) : phone,
      );
      await _notificationRepository.addNotification(
        userId: _uid,
        title: 'Appointment Booked',
        body:
            'Your appointment with Dr. $doctorName is pending approval.',
        type: 'booking',
      );
      AppSnackbar.showSuccess(
        'Appointment requested successfully!',
        title: 'Booking Confirmed',
      );
      return true;
    } on AppException catch (e) {
      AppSnackbar.showError(e.message);
      return false;
    } catch (e) {
      AppSnackbar.showError(FirebaseErrorMapper.map(e).message);
      return false;
    }
  }

  /// Cancel a pending appointment.
  Future<void> cancelAppointment(String appointmentId) async {
    try {
      await _clientRepository.cancelAppointment(appointmentId);
      AppSnackbar.showInfo('Appointment cancelled.');
    } on AppException catch (e) {
      AppSnackbar.showError(e.message);
    } catch (e) {
      AppSnackbar.showError(FirebaseErrorMapper.map(e).message);
    }
  }

  /// Mark a notification as read.
  Future<void> markNotificationRead(String notificationId) async {
    try {
      await _notificationRepository.markAsRead(notificationId);
    } catch (_) {}
  }

  /// Mark all notifications as read.
  Future<void> markAllNotificationsRead() async {
    try {
      await _notificationRepository.markAllAsRead(_uid);
    } catch (_) {}
  }

  /// Keep the stored FCM token in sync for push notifications.
  Future<void> syncFcmToken() async {
    try {
      final token = await NotificationService.getToken();
      if (token == null || token.isEmpty) return;
      await _authRepository.saveFcmToken(
        uid: _uid,
        role: UserRole.client,
        token: token,
      );
      NotificationService.onTokenRefresh.listen((newToken) {
        _authRepository.saveFcmToken(
          uid: _uid,
          role: UserRole.client,
          token: newToken,
        );
      });
    } catch (_) {
      // Non-blocking.
    }
  }

  /// Log the old -> new status transition for every appointment in the
  /// snapshot so live updates are observable in the console.
  void _logStatusTransitions(List<AppointmentModel> items) {
    for (final appointment in items) {
      final oldStatus = _previousStatuses[appointment.id];
      final newStatus = appointment.status;
      if (oldStatus != newStatus) {
        debugPrint(
          '[Realtime] Status change | '
          'appointmentId=${appointment.id} | '
          'old=${oldStatus ?? 'none'} | new=$newStatus',
        );
        _previousStatuses[appointment.id] = newStatus;
      }
    }
    final currentIds = items.map((a) => a.id).toSet();
    _previousStatuses.removeWhere((id, _) => !currentIds.contains(id));
  }

  /// Turn status changes into in-app notifications (once per event).
  void _trackStatusChanges(List<AppointmentModel> items) {
    for (final appointment in items) {
      final eventKey = '${appointment.id}:${appointment.status}';
      if (_seenStatusEvents.contains(eventKey)) continue;

      if (appointment.isAccepted) {
        _seenStatusEvents.add(eventKey);
        _notificationRepository.addNotification(
          userId: _uid,
          title: 'Appointment Accepted',
          body:
              'Dr. ${appointment.doctorName} accepted your appointment. You can now join the video call.',
          type: 'accepted',
          appointmentId: appointment.id,
        );
      } else if (appointment.isRejected) {
        _seenStatusEvents.add(eventKey);
        _notificationRepository.addNotification(
          userId: _uid,
          title: 'Appointment Rejected',
          body:
              'Unfortunately, Dr. ${appointment.doctorName} rejected your appointment.',
          type: 'rejected',
          appointmentId: appointment.id,
        );
      } else if (appointment.isCompleted) {
        _seenStatusEvents.add(eventKey);
        _notificationRepository.addNotification(
          userId: _uid,
          title: 'Consultation Completed',
          body:
              'Your consultation with Dr. ${appointment.doctorName} has been completed.',
          type: 'completed',
          appointmentId: appointment.id,
        );
      }
    }
  }

  /// Tear down all realtime streams and reset state when the user logs out.
  void _clearClientData() {
    _appointmentsSubscription?.cancel();
    _appointmentsSubscription = null;
    _notificationsSubscription?.cancel();
    _notificationsSubscription = null;

    appointments.assignAll(const []);
    notifications.assignAll(const []);
    unreadCount.value = 0;
    _previousStatuses.clear();
    _seenStatusEvents.clear();
    clientName.value = '';
    clientEmail.value = '';
    clientPhone.value = '';
  }
}
