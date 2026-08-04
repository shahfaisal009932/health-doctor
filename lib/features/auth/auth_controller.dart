import 'package:firebase_auth/firebase_auth.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/exceptions/app_exception.dart';
import '../../core/exceptions/firebase_error_mapper.dart';
import '../../core/services/auth_service.dart';
import '../../core/services/notification_service.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../data/repositories/auth_repository.dart';

class AuthController extends GetxController {
  final AuthRepository _repository;
  final AuthService _authService;

  AuthController(this._repository, this._authService);

  final RxBool _isLoading = false.obs;
  bool get isLoading => _isLoading.value;

  final Rx<User?> user = Rx<User?>(null);
  bool get isLoggedIn => user.value != null;

  final RxString _role = ''.obs;
  String get role => _role.value;
  bool get isDoctor => _role.value == UserRole.doctor;
  bool get isClient => _role.value == UserRole.client;

  @override
  void onInit() {
    super.onInit();
    user.value = _authService.currentUser;
    _authService.authStateChanges.listen((value) {
      user.value = value;
    });
  }

  /// Resolve and cache the current user's role.
  ///
  /// Throws (mapped) when the role cannot be read so callers can decide how
  /// to react instead of being silently misrouted.
  Future<String> getUserRole() async {
    final uid = user.value?.uid ?? '';
    if (uid.isEmpty) {
      _role.value = '';
      return _role.value;
    }
    final role = await _repository.getUserRole(uid);
    _role.value = role;
    return role;
  }

  /// Navigate to the correct home screen based on the user's role.
  ///
  /// Returns `false` (and stays on the current screen with a visible error)
  /// when the role cannot be determined, so a broken Firestore setup never
  /// lands the user on the wrong dashboard.
  Future<bool> routeByRole() async {
    try {
      final role = await getUserRole();
      if (role == UserRole.doctor) {
        Get.offAllNamed(AppRoutes.dashboard);
        return true;
      }
      if (role == UserRole.client) {
        Get.offAllNamed(AppRoutes.clientDashboard);
        return true;
      }
      AppSnackbar.showError(
        'Unable to determine your account type. Please log in again.',
      );
      return false;
    } on AppException catch (e) {
      AppSnackbar.showError(e.message);
      return false;
    } catch (e) {
      AppSnackbar.showError(FirebaseErrorMapper.map(e).message);
      return false;
    }
  }

  /// Log in and show feedback to the user.
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading.value = true;
    try {
      await _repository.login(email: email, password: password);
      await _syncFcmToken();
      AppSnackbar.showSuccess('Login successful. Welcome back!');
      return true;
    } on AppException catch (e) {
      AppSnackbar.showError(e.message);
      return false;
    } catch (e) {
      AppSnackbar.showError(FirebaseErrorMapper.map(e).message);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Register a new account with a role, save the profile, then route.
  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String phone = '',
    String role = UserRole.doctor,
  }) async {
    _isLoading.value = true;
    try {
      await _repository.register(email: email, password: password);

      final user = _authService.currentUser;
      if (user != null) {
        await user.updateDisplayName(name);
        await _repository.saveProfile(
          uid: user.uid,
          role: role,
          name: name,
          email: email,
          phone: phone,
        );
      }

      await _repository.logout();

      AppSnackbar.showSuccess('Account created successfully. Please log in.');
      Get.offAllNamed(AppRoutes.login);
      return true;
    } on AppException catch (e) {
      AppSnackbar.showError(e.message);
      return false;
    } catch (e) {
      AppSnackbar.showError(FirebaseErrorMapper.map(e).message);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Send a password reset email.
  Future<bool> forgotPassword({required String email}) async {
    _isLoading.value = true;
    try {
      await _repository.forgotPassword(email: email);
      AppSnackbar.showSuccess(
        'Password reset link sent to your email.',
        title: 'Check your inbox',
      );
      return true;
    } on AppException catch (e) {
      AppSnackbar.showError(e.message);
      return false;
    } catch (e) {
      AppSnackbar.showError(FirebaseErrorMapper.map(e).message);
      return false;
    } finally {
      _isLoading.value = false;
    }
  }

  /// Log out the current user.
  Future<void> logout() async {
    try {
      await _repository.logout();
      Get.offAllNamed(AppRoutes.login);
    } on AppException catch (e) {
      AppSnackbar.showError(e.message);
    } catch (e) {
      AppSnackbar.showError(FirebaseErrorMapper.map(e).message);
    }
  }

  /// Keep the stored FCM token in sync with the logged-in profile.
  Future<void> _syncFcmToken() async {
    try {
      final uid = user.value?.uid ?? '';
      if (uid.isEmpty) return;
      await getUserRole();
      if (_role.value.isEmpty) return;
      final token = await NotificationService.getToken();
      if (token == null || token.isEmpty) return;
      await _repository.saveFcmToken(
        uid: uid,
        role: _role.value,
        token: token,
      );
    } catch (_) {
      // Token sync must never break the login flow.
    }
  }
}
