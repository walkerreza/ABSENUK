import 'package:get/get.dart';
import 'package:absenuk/app/routes/app_pages.dart'; // Pastikan import ini ada dan benar

class HomeController extends GetxController {
  //TODO: Implement HomeController

  // Contoh nama pengguna, bisa diambil dari data login nantinya
  final RxString userName = 'RAGIL'.obs;

  // Fungsi navigasi
  void goToProfile() {
    Get.toNamed(Routes.PROFILE); // Asumsi Routes.PROFILE sudah ada
  }

  void goToSettings() {
    Get.toNamed(Routes.SETTINGS);
  }

  void goToAbsenMasuk() {
    Get.snackbar('Informasi', 'Fitur Absen Masuk belum diimplementasikan.');
    // Contoh: Get.toNamed(Routes.ABSEN_MASUK);
  }

  void goToAbsenKeluar() {
    Get.snackbar('Informasi', 'Fitur Absen Keluar belum diimplementasikan.');
    // Contoh: Get.toNamed(Routes.ABSEN_KELUAR);
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
