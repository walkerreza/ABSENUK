import 'package:get/get.dart';

import '../controllers/permission_editor_controller.dart';

class PermissionEditorBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PermissionEditorController>(
      () => PermissionEditorController(),
    );
  }
}
