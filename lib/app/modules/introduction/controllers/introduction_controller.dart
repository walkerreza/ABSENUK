import 'package:get/get.dart';
import 'package:absenuk/app/routes/app_pages.dart'; // Impor untuk Routes

class IntroductionController extends GetxController {
  //TODO: Implement IntroductionController

    // final count = 0.obs; // Tidak digunakan, bisa dihapus atau dikomentari

  // @override
  // void onInit() {
  //   super.onInit();
  // }

  // @override
  // void onReady() {
  //   super.onReady();
  // }

  // @override
  // void onClose() {
  //   super.onClose();
  // }

  // void increment() => count.value++; // Tidak digunakan

  void navigateToLogin() {
    Get.offNamed(Routes.LOGIN); // Navigasi ke halaman login dan hapus halaman saat ini dari stack
  }
}
