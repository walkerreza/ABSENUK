import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:absenuk/app/data/dummy_data.dart'; // Import data dummy
import 'package:absenuk/app/routes/app_pages.dart'; // Import rute
import 'package:get_storage/get_storage.dart';

class LoginController extends GetxController {
  // Kunci global untuk Form
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Controller untuk TextField
  late TextEditingController emailController;
  late TextEditingController passwordController;

  // Variabel untuk mengontrol visibilitas password
  var obscureText = true.obs;

  // Variabel untuk status loading (jika diperlukan nanti)
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    emailController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void onClose() {
    emailController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // Fungsi untuk mengubah visibilitas password
  void toggleObscureText() {
    obscureText.value = !obscureText.value;
  }

  // Fungsi untuk proses login
  void login() {
    // Validasi form
    if (formKey.currentState!.validate()) {
      isLoading.value = true;
      // Simulasi jeda untuk meniru panggilan jaringan
      Future.delayed(const Duration(milliseconds: 500), () {
        // Cek kredensial dengan data dummy
        if (emailController.text == DummyUser.user['email'] &&
            passwordController.text == DummyUser.user['password']) {
          // Simpan data pengguna ke GetStorage
          final box = GetStorage();
          box.write('user', DummyUser.user);
          // Simpan waktu login saat ini
          box.write('login_time', DateTime.now().toIso8601String());

          // Jika berhasil, navigasi ke halaman home
          Get.offAllNamed(Routes.HOME);
          Get.snackbar(
            'Login Berhasil',
            'Selamat datang, ${DummyUser.user['name']}',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.green,
            colorText: Colors.white,
          );
        } else {
          // Jika gagal, tampilkan pesan error
          Get.snackbar(
            'Login Gagal',
            'Email atau password salah.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
        isLoading.value = false;
      });
    } else {
      // Jika form tidak valid, tampilkan pesan atau biarkan validator yang bekerja
      Get.snackbar(
        'Input Tidak Valid',
        'Mohon periksa kembali input Anda.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
    }
  }
}
