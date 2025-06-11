import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:absenuk/app/routes/app_pages.dart';

class HomeController extends GetxController {
  //TODO: Implement HomeController

  final RxString userName = ''.obs;
  final RxString photoUrl = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
  }

  void _loadUserData() {
    final box = GetStorage();
    final userData = box.read<Map<String, dynamic>>('user');
    if (userData != null) {
      userName.value = userData['name'] ?? 'Pengguna';
      photoUrl.value = userData['photoUrl'] ?? '';
    }
  }

  // Fungsi navigasi
  void goToProfile() {
    Get.toNamed(Routes.PROFILE); // Asumsi Routes.PROFILE sudah ada
  }

  void goToSettings() {
    Get.toNamed(Routes.SETTINGS);
  }

  void goToAbsenMasuk() {
    Get.toNamed(Routes.CAMERA, arguments: {'type': 'Masuk'});
  }

  void goToAbsenKeluar() {
    Get.toNamed(Routes.CAMERA, arguments: {'type': 'Keluar'});
  }

  void goToJadwalPresensi() {
    Get.toNamed(Routes.JADWAL); // Menggunakan konstanta rute yang sudah ada
  }

  void goToDaftarMatkul() {
    Get.toNamed(Routes.DAFTAR_MATKUL);
  }

  // final count = 0.obs; // Hapus atau komentari jika tidak digunakan
  // void increment() => count.value++; // Hapus atau komentari jika tidak digunakan
}
