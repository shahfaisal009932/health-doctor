import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/constants/app_colors.dart';
import '../../core/exceptions/app_exception.dart';
import '../../core/exceptions/firebase_error_mapper.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../core/widgets/error_view.dart';
import '../../data/models/doctor_model.dart';
import '../../data/repositories/client_repository.dart';
import 'client_controller.dart';
import 'widgets/doctor_about_card.dart';
import 'widgets/doctor_availability_card.dart';
import 'widgets/doctor_booking_card.dart';
import 'widgets/doctor_header_card.dart';

class DoctorDetailScreen extends StatefulWidget {
  const DoctorDetailScreen({super.key});

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen> {
  late final String _doctorId;

  final ClientRepository _repository = Get.find<ClientRepository>();

  DoctorModel? _doctor;
  bool _loading = true;
  bool _hasError = false;
  String _errorMessage = '';

  // Booking form state
  DateTime _selectedDate = DateTime.now();
  String? _selectedTime;
  final _symptomsController = TextEditingController();
  final _ageController = TextEditingController();
  final _phoneController = TextEditingController();
  bool _booking = false;

  @override
  void initState() {
    super.initState();
    final arg = Get.arguments;
    _doctorId = arg is String ? arg : '';
    _loadDoctor();
  }

  @override
  void dispose() {
    _symptomsController.dispose();
    _ageController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadDoctor() async {
    setState(() {
      _loading = true;
      _hasError = false;
    });
    try {
      final doctor = await _repository.getDoctorById(_doctorId);
      setState(() {
        _doctor = doctor;
        _loading = false;
        _hasError = doctor == null;
        _errorMessage = doctor == null ? 'Doctor not found.' : '';
      });
    } on AppException catch (e) {
      setState(() {
        _loading = false;
        _hasError = true;
        _errorMessage = e.message;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _hasError = true;
        _errorMessage = FirebaseErrorMapper.map(e).message;
      });
    }
  }

  Future<void> _book() async {
    final doctor = _doctor;
    if (doctor == null) return;
    if (_selectedTime == null) {
      AppSnackbar.showWarning('Please select a time slot.');
      return;
    }
    if (_symptomsController.text.trim().isEmpty) {
      AppSnackbar.showWarning('Please describe your symptoms.');
      return;
    }

    setState(() => _booking = true);
    final clientController = Get.find<ClientController>();
    final success = await clientController.bookAppointment(
      doctorId: doctor.id,
      doctorName: doctor.name,
      doctorSpecialization: doctor.specialization,
      appointmentDate: _selectedDate,
      appointmentTime: _selectedTime!,
      symptoms: _symptomsController.text.trim(),
      age: int.tryParse(_ageController.text.trim()) ?? 0,
      phone: _phoneController.text.trim(),
    );
    if (!mounted) return;
    setState(() => _booking = false);
    if (success) {
      Get.offAllNamed(AppRoutes.clientDashboard);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(title: const Text('Doctor Profile')),
      body: _buildBody(),
    );
  }

  Widget _buildBody() {
    if (_loading) {
      return const Center(child: CircularProgressIndicator());
    }
    if (_hasError) {
      return ErrorView(message: _errorMessage, onRetry: _loadDoctor);
    }
    final doctor = _doctor!;

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        DoctorHeaderCard(doctor: doctor),
        const SizedBox(height: 20),
        DoctorAboutCard(doctor: doctor),
        const SizedBox(height: 20),
        DoctorAvailabilityCard(
          doctor: doctor,
          selectedTime: _selectedTime,
          onTimeSelected: (value) {
            setState(() => _selectedTime = value);
          },
        ),
        const SizedBox(height: 20),
        DoctorBookingCard(
          selectedDate: _selectedDate,
          symptomsController: _symptomsController,
          ageController: _ageController,
          phoneController: _phoneController,
          isBooking: _booking,
          onPickDate: _pickDate,
          onBook: _book,
        ),
      ],
    );
  }

  Future<void> _pickDate() async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate.isBefore(now) ? now : _selectedDate,
      firstDate: now,
      lastDate: now.add(const Duration(days: 30)),
      helpText: 'Select appointment date',
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }
}
