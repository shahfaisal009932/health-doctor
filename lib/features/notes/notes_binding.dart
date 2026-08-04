import 'package:get/get.dart';

import '../../data/repositories/note_repository.dart';
import 'note_controller.dart';

class NotesBinding implements Bindings {
  @override
  void dependencies() {
    Get.put<NoteRepository>(NoteRepository(), permanent: true);
    Get.lazyPut<NoteController>(
      () => NoteController(Get.find()),
    );
  }
}
