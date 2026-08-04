/// Central route name definitions.
class AppRoutes {
  AppRoutes._();

  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';

  // Doctor module
  static const dashboard = '/dashboard';
  static const appointment = '/appointment';
  static const notes = '/notes';
  static const addNote = '/add-note';

  // Client module
  static const clientDashboard = '/client-dashboard';
  static const clientSearch = '/client/doctor-search';
  static const doctorDetail = '/client/doctor-detail';

  // Video consultation
  static const videoCall = '/video-call';
  static const videoCallHistory = '/video-call-history';
  static const incomingCall = '/incoming-call';
}
