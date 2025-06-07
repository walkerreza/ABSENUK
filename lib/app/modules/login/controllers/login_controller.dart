import 'package:flutter/material.dart';
import 'package:get/get.dart';

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
      // Jika form valid, lanjutkan proses login
      // Untuk saat ini, kita hanya print email dan password
      isLoading.value = true; // Contoh jika ada proses async
      print('Email: ${emailController.text}');
      print('Password: ${passwordController.text}');

      // TODO: Implementasikan logika login sesungguhnya di sini
      // Misalnya, panggil API, dll.

      // Contoh simulasi loading
      Future.delayed(Duration(seconds: 2), () {
        isLoading.value = false;
        // Get.offAllNamed(Routes.HOME); // Contoh navigasi setelah login sukses
        Get.snackbar(
          'Login Berhasil',
          'Selamat datang, ${emailController.text}',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
      });
    } else {
      // Jika form tidak valid, tampilkan pesan atau biarkan validator yang bekerja
      Get.snackbar(
        'Error Validasi',
        'Mohon periksa kembali input Anda.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
