import 'package:flutter/material.dart';

import '../../core/constants/app_colors.dart';
import 'doctor_search_body.dart';

class DoctorSearchScreen extends StatelessWidget {
  const DoctorSearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('Search Doctors'),
        centerTitle: true,
      ),
      body: const DoctorSearchBody(),
    );
  }
}
