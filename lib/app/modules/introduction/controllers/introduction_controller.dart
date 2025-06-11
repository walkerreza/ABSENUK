import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:absenuk/app/routes/app_pages.dart';

class IntroductionController extends GetxController {
  //TODO: Implement IntroductionController

    // final count = 0.obs; // Tidak digunakan, bisa dihapus atau dikomentari

  // @override
  // void onInit() {
  //   super.onInit();
  // }

  @override
  void onReady() {
    super.onReady();
    _checkLoginStatus();
  }

  void _checkLoginStatus() {
    final box = GetStorage();
    final user = box.read('user');
    final loginTimeStr = box.read('login_time');

    if (user != null && loginTimeStr != null) {
      final loginTime = DateTime.parse(loginTimeStr);
      final currentTime = DateTime.now();
      final difference = currentTime.difference(loginTime);

      // Cek apakah sesi masih valid (kurang dari 10 menit)
      if (difference.inMinutes < 10) {
        // Langsung ke halaman utama, lewati introduction dan login
        Get.offAllNamed(Routes.HOME);
      }
      // Jika sesi tidak valid, tetap di halaman introduction
    }
    // Jika tidak ada data login, tetap di halaman introduction
  }

  // @override
  // void onClose() {
  //   super.onClose();
  // }

  // void increment() => count.value++; // Tidak digunakan

  void navigateToLogin() {
    Get.offNamed(Routes.LOGIN); // Navigasi ke halaman login dan hapus halaman saat ini dari stack
  }
}
