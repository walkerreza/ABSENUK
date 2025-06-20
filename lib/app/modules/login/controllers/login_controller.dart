import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:absenuk/app/routes/app_pages.dart';
import 'package:absenuk/app/data/providers/api.dart';
import 'package:get_storage/get_storage.dart';

class LoginController extends GetxController {
  // Kunci global untuk Form
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();

  // Controller untuk TextField
  late TextEditingController nimController;
  late TextEditingController passwordController;

  // Variabel untuk mengontrol visibilitas password
  var obscureText = true.obs;

  // Variabel untuk status loading (jika diperlukan nanti)
  var isLoading = false.obs;

  @override
  void onInit() {
    super.onInit();
    nimController = TextEditingController();
    passwordController = TextEditingController();
  }

  @override
  void onClose() {
    nimController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // Fungsi untuk mengubah visibilitas password
  void toggleObscureText() {
    obscureText.value = !obscureText.value;
  }

  // Fungsi untuk proses login
  void login() async {
    if (formKey.currentState!.validate()) {
      isLoading.value = true;
      try {
        final response = await http.post(
          Uri.parse('${Api.baseUrl}/mahasiswa/login'), // Endpoint yang benar
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'nim': nimController.text,
            'password': passwordController.text,
          }),
        ).timeout(const Duration(seconds: 10));

        final responseData = jsonDecode(response.body);

        if (response.statusCode == 200) {
          final data = responseData['data'];
          // Berdasarkan Postman, respons login hanya berisi token.
          if (data != null && data['token'] != null) {
            final token = data['token'];

            final box = GetStorage();
            // Simpan token dan NIM. Data user akan diambil di halaman Home.
            box.write('token', token);
            box.write('nim', nimController.text); // Menyimpan NIM
            box.write('isLoggedIn', true);
            box.write('login_time', DateTime.now().toIso8601String());

            Get.offAllNamed(Routes.HOME);
            Get.snackbar(
              'Login Berhasil',
              'Selamat datang!', // Pesan generik karena nama user belum ada
              snackPosition: SnackPosition.BOTTOM,
              backgroundColor: Colors.green,
              colorText: Colors.white,
            );
          } else {
            // Jika token tidak ditemukan dalam respons, struktur tidak valid.
            throw Exception('Struktur data respons tidak valid: token tidak ditemukan.');
          }
        } else {
          Get.snackbar(
            'Login Gagal',
            responseData['message'] ?? 'NIM atau Password salah.',
            snackPosition: SnackPosition.BOTTOM,
            backgroundColor: Colors.red,
            colorText: Colors.white,
          );
        }
      } catch (e) {
        print('Login Error: $e'); // Menampilkan error detail di console
        Get.snackbar(
          'Terjadi Kesalahan',
          'Tidak dapat terhubung ke server. Periksa koneksi Anda.',
          snackPosition: SnackPosition.BOTTOM,
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      } finally {
        isLoading.value = false;
      }
    } else {
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
