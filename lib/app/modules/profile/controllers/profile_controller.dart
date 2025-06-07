import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

class ProfileController extends GetxController {
  // TextEditingControllers untuk input fields
  late TextEditingController nameController;
  late TextEditingController nimController;
  late TextEditingController prodiController;
  late TextEditingController passwordController;

  // Variabel reaktif
  final Rx<File?> profileImage = Rx<File?>(null);
  final Rx<int?> selectedSemester = Rx<int?>(null); // Default null, atau bisa diisi nilai awal
  final RxBool obscurePassword = true.obs;
  final RxBool isLoading = false.obs;

  // Instance ImagePicker
  final ImagePicker _picker = ImagePicker();

  // Daftar semester untuk Dropdown
  final List<int> semesters = [1, 2, 3, 4]; // Sesuai permintaan USER

  @override
  void onInit() {
    super.onInit();
    // Inisialisasi controllers
    nameController = TextEditingController();
    nimController = TextEditingController();
    prodiController = TextEditingController();
    passwordController = TextEditingController();

    // TODO: Muat data profil yang sudah ada jika ada (misalnya dari SharedPreferences atau API)
    // Contoh data dummy:
    nameController.text = 'Mahasiswa Keren';
    nimController.text = '12345001';
    prodiController.text = 'Teknik Informatika';
    selectedSemester.value = 1;
    passwordController.text = 'password123';
  }

  @override
  void onClose() {
    // Dispose controllers untuk menghindari memory leaks
    nameController.dispose();
    nimController.dispose();
    prodiController.dispose();
    passwordController.dispose();
    super.onClose();
  }

  // Fungsi untuk memilih gambar dari galeri atau kamera
  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        profileImage.value = File(pickedFile.path);
      } else {
        Get.snackbar('Batal', 'Tidak ada gambar yang dipilih.');
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengambil gambar: $e');
    }
  }

  // Fungsi untuk mengubah visibilitas password
  void toggleObscurePassword() {
    obscurePassword.value = !obscurePassword.value;
  }

  // Fungsi untuk menyimpan perubahan profil
  void saveProfile() {
    isLoading.value = true;
    // Validasi sederhana (bisa ditambahkan validasi lebih detail)
    if (nameController.text.isEmpty ||
        nimController.text.isEmpty ||
        prodiController.text.isEmpty ||
        passwordController.text.isEmpty ||
        selectedSemester.value == null) {
      Get.snackbar('Error', 'Semua field harus diisi.',
          snackPosition: SnackPosition.BOTTOM);
      isLoading.value = false;
      return;
    }

    // Simulasi proses penyimpanan
    Future.delayed(const Duration(seconds: 2), () {
      isLoading.value = false;
      // Di sini nantinya akan ada logika untuk menyimpan data ke backend atau local storage
      print('Data Profil Disimpan:');
      print('Nama: ${nameController.text}');
      print('NIM: ${nimController.text}');
      print('Prodi: ${prodiController.text}');
      print('Semester: ${selectedSemester.value}');
      print('Password: ${passwordController.text}');
      if (profileImage.value != null) {
        print('Path Foto Profil: ${profileImage.value!.path}');
      }

      Get.snackbar('Berhasil', 'Profil berhasil diperbarui.',
          snackPosition: SnackPosition.BOTTOM);
    });
  }
}

