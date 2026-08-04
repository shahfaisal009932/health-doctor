import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../../app/routes/app_routes.dart';
import '../../core/widgets/empty_state_widget.dart';
import '../../core/widgets/error_view.dart';
import 'doctor_card.dart';
import 'doctor_search_controller.dart';
import 'widgets/availability_chip.dart';
import 'widgets/doctor_search_bar.dart';
import 'widgets/doctor_search_filters.dart';

/// Reusable doctor search UI used as a dashboard tab and standalone screen.
class DoctorSearchBody extends GetView<DoctorSearchController> {
  const DoctorSearchBody({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
          child: Obx(
            () => DoctorSearchBar(
              query: controller.query.value,
              onChanged: (value) {
                controller.query.value = value;
                controller.applyFilters();
              },
              onClear: () {
                controller.query.value = '';
                controller.applyFilters();
              },
            ),
          ),
        ),
        Obx(
          () => DoctorSearchFilters(
            onlyAvailable: controller.onlyAvailable.value,
            selectedSpecialization: controller.selectedSpecialization.value,
            specializations: controller.specializations,
            onAvailableOnlyChanged: (value) {
              controller.onlyAvailable.value = value;
              controller.applyFilters();
            },
            onSpecializationChanged: (value) {
              controller.selectedSpecialization.value = value;
              controller.applyFilters();
            },
          ),
        ),
        Expanded(
          child: Obx(() {
            if (controller.isLoading.value) {
              return const Center(child: CircularProgressIndicator());
            }
            if (controller.hasError.value) {
              return ErrorView(
                message: controller.errorMessage.value,
                onRetry: controller.loadDoctors,
              );
            }
            if (controller.doctors.isEmpty) {
              return const EmptyStateWidget(
                icon: Icons.medical_services_outlined,
                title: 'No Doctors Found',
                subtitle: 'Try a different search or clear the filters.',
              );
            }

            return RefreshIndicator(
              onRefresh: controller.loadDoctors,
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: controller.doctors.length,
                itemBuilder: (context, index) {
                  final doctor = controller.doctors[index];
                  return DoctorCard(
                    doctor: doctor,
                    title: 'Dr. ${doctor.name}',
                    subtitle: doctor.specialization,
                    trailing: AvailabilityChip(available: doctor.isAvailable),
                    onTap: () => Get.toNamed(
                      AppRoutes.doctorDetail,
                      arguments: doctor.id,
                    ),
                  );
                },
              ),
            );
          }),
        ),
      ],
    );
  }
}
