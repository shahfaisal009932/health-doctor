import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../core/theme/app_theme.dart';
import 'app_bindings.dart';
import 'routes/app_pages.dart';
import 'routes/app_routes.dart';

class DoctorApp extends StatelessWidget {
  const DoctorApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Doctor Consultation',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.lightTheme,
      initialRoute: AppRoutes.splash,
      initialBinding: AppBindings(),
      getPages: AppPages.routes,
      unknownRoute: GetPage(
        name: AppRoutes.splash,
        page: () => const Scaffold(body: SizedBox.shrink()),
      ),
    );
  }
}

/// Helper to check whether the current user is authenticated.
class AuthGate {
  AuthGate._();

  static bool get isLoggedIn => FirebaseAuth.instance.currentUser != null;

  static String? get currentUid => FirebaseAuth.instance.currentUser?.uid;
}
