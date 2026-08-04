import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/exceptions/firebase_error_mapper.dart';
import '../../core/utils/firestore_logger.dart';
import '../../data/repositories/auth_repository.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String? _error;

  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    setState(() => _error = null);
    await Future.delayed(const Duration(milliseconds: 1500));
    if (!mounted) return;

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      FirestoreLogger.log(
        collection: 'auth',
        operation: 'routing',
        details: 'no signed-in user -> login',
      );
      Get.offAllNamed(AppRoutes.login);
      return;
    }

    // Restore the user's role so the correct dashboard opens. Do NOT fall
    // back to a guessed screen when this fails; surface the real error so
    // a broken Firestore setup is visible instead of misrouting.
    final repository = AuthRepository();
    try {
      final role = await repository.getUserRole(user.uid);
      if (!mounted) return;
      FirestoreLogger.log(
        collection: 'auth',
        operation: 'routing',
        details: 'uid=${user.uid} role=$role',
      );
      if (role == UserRole.doctor) {
        Get.offAllNamed(AppRoutes.dashboard);
      } else {
        Get.offAllNamed(AppRoutes.clientDashboard);
      }
    } catch (e) {
      FirestoreLogger.logError(
        collection: 'auth',
        operation: 'routing',
        error: e,
      );
      if (!mounted) return;
      setState(() => _error = FirebaseErrorMapper.map(e).message);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                height: 110,
                width: 110,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.medical_services_rounded,
                  size: 60,
                  color: AppColors.primary,
                ),
              ),
              const SizedBox(height: 30),
              const Text(
                'CareConnect',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Doctors & Patients, Connected',
                style: TextStyle(color: Colors.white70, fontSize: 16),
              ),
              const SizedBox(height: 60),
              if (_error == null)
                const CircularProgressIndicator(color: Colors.white)
              else ...[
                const Icon(Icons.error_outline,
                    color: Colors.white, size: 48),
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 32),
                  child: Text(
                    _error!,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white, fontSize: 14),
                  ),
                ),
                const SizedBox(height: 20),
                OutlinedButton.icon(
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Colors.white,
                    side: const BorderSide(color: Colors.white),
                  ),
                  onPressed: _navigate,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Try Again'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
