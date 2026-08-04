import 'package:get/get.dart';

import '../../core/exceptions/app_exception.dart';
import '../../core/exceptions/firebase_error_mapper.dart';
import '../../core/widgets/app_snackbar.dart';
import '../../data/models/doctor_model.dart';
import '../../data/repositories/client_repository.dart';

class DoctorSearchController extends GetxController {
  final ClientRepository _repository;

  DoctorSearchController(this._repository);

  final RxBool isLoading = false.obs;
  final RxBool hasError = false.obs;
  final RxString errorMessage = ''.obs;
  final RxList<DoctorModel> doctors = <DoctorModel>[].obs;
  final RxList<String> specializations = <String>[].obs;

  final RxString query = ''.obs;
  final RxString selectedSpecialization = ''.obs;
  final RxBool onlyAvailable = false.obs;

  @override
  void onInit() {
    super.onInit();
    loadDoctors();
    loadSpecializations();
  }

  /// Load doctors with the current filters applied.
  Future<void> loadDoctors() async {
    isLoading.value = true;
    hasError.value = false;
    errorMessage.value = '';
    try {
      doctors.value = await _repository.searchDoctors(
        query: query.value,
        specialization: selectedSpecialization.value.isEmpty
            ? null
            : selectedSpecialization.value,
        onlyAvailable: onlyAvailable.value,
      );
    } on AppException catch (e) {
      hasError.value = true;
      errorMessage.value = e.message;
    } catch (e) {
      hasError.value = true;
      errorMessage.value = FirebaseErrorMapper.map(e).message;
    } finally {
      isLoading.value = false;
    }
  }

  /// Load the list of specializations for the filter dropdown.
  Future<void> loadSpecializations() async {
    try {
      specializations.value = await _repository.getSpecializations();
    } on AppException catch (e) {
      AppSnackbar.showError(e.message);
    } catch (e) {
      AppSnackbar.showError(FirebaseErrorMapper.map(e).message);
    }
  }

  /// Apply the current search + filter state.
  void applyFilters() {
    loadDoctors();
  }

  void clearFilters() {
    query.value = '';
    selectedSpecialization.value = '';
    onlyAvailable.value = false;
    loadDoctors();
  }
}
