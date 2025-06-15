import 'package:get/get.dart';

import '../controllers/permission_template_controller.dart';

class PermissionTemplateBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<PermissionTemplateController>(
      () => PermissionTemplateController(),
    );
  }
}
