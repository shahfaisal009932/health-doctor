import 'package:get/get.dart';

import '../../features/appointment/appointment_binding.dart';
import '../../features/appointment/appointment_screen.dart';
import '../../features/auth/auth_binding.dart';
import '../../features/auth/forgot_password_screen.dart';
import '../../features/auth/login_screen.dart';
import '../../features/auth/register_screen.dart';
import '../../features/call/call_binding.dart';
import '../../features/call/incoming_call_screen.dart';
import '../../features/call/video_call_history_screen.dart';
import '../../features/call/video_call_screen.dart';
import '../../features/client/client_binding.dart';
import '../../features/client/client_dashboard_screen.dart';
import '../../features/client/doctor_detail_screen.dart';
import '../../features/client/doctor_search_binding.dart';
import '../../features/client/doctor_search_screen.dart';
import '../../features/dashboard/dashboard_binding.dart';
import '../../features/dashboard/dashboard_screen.dart';
import '../../features/notes/add_note_screen.dart';
import '../../features/notes/notes_binding.dart';
import '../../features/notes/notes_screen.dart';
import '../../features/splash/splash_screen.dart';
import 'app_routes.dart';

/// GetX route table with bindings for dependency injection.
class AppPages {
  AppPages._();

  static final routes = <GetPage>[
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
    ),
    GetPage(
      name: AppRoutes.login,
      page: () => const LoginScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.register,
      page: () => const RegisterScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.forgotPassword,
      page: () => const ForgotPasswordScreen(),
      binding: AuthBinding(),
    ),
    GetPage(
      name: AppRoutes.dashboard,
      page: () => const DashboardScreen(),
      binding: DashboardBinding(),
    ),
    GetPage(
      name: AppRoutes.appointment,
      page: () => const AppointmentScreen(),
      binding: AppointmentBinding(),
    ),
    GetPage(
      name: AppRoutes.videoCall,
      page: () => const VideoCallScreen(),
      binding: CallBinding(),
    ),
    GetPage(
      name: AppRoutes.videoCallHistory,
      page: () => const VideoCallHistoryScreen(),
      binding: CallBinding(),
    ),
    GetPage(
      name: AppRoutes.incomingCall,
      page: () => const IncomingCallScreen(),
    ),
    GetPage(
      name: AppRoutes.notes,
      page: () => const NotesScreen(),
      binding: NotesBinding(),
    ),
    GetPage(
      name: AppRoutes.addNote,
      page: () => const AddNoteScreen(),
      binding: NotesBinding(),
    ),
    // ---- Client module ----
    GetPage(
      name: AppRoutes.clientDashboard,
      page: () => const ClientDashboardScreen(),
      binding: ClientBinding(),
    ),
    GetPage(
      name: AppRoutes.clientSearch,
      page: () => const DoctorSearchScreen(),
      binding: DoctorSearchBinding(),
    ),
    GetPage(
      name: AppRoutes.doctorDetail,
      page: () => const DoctorDetailScreen(),
      binding: ClientBinding(),
    ),
  ];
}
