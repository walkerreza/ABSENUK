import 'package:get/get.dart';
import 'package:absenuk/app/data/providers/jadwal_provider.dart';
import '../controllers/daftar_matkul_controller.dart';

class DaftarMatkulBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<JadwalProvider>(
      () => JadwalProvider(),
    );
    Get.lazyPut<DaftarMatkulController>(
      () => DaftarMatkulController(jadwalProvider: Get.find()),
    );
  }
}

