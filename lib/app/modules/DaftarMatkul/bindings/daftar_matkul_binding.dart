import 'package:get/get.dart';

import '../controllers/daftar_matkul_controller.dart';

class DaftarMatkulBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DaftarMatkulController>(
      () => DaftarMatkulController(),
    );
  }
}
