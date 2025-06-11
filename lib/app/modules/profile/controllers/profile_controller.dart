import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:absenuk/app/modules/home/controllers/home_controller.dart';

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

    _loadUserProfile();
  }

  void _loadUserProfile() {
    final box = GetStorage();
    final userData = box.read<Map<String, dynamic>>('user');
    if (userData != null) {
      nameController.text = userData['name'] ?? '';
      // Asumsi NIM dan Prodi juga ada di data pengguna, jika tidak, biarkan kosong
      nimController.text = userData['nim'] ?? ''; 
      prodiController.text = userData['prodi'] ?? '';
      passwordController.text = userData['password'] ?? '';
      // Untuk foto, kita akan menangani path lokal, bukan URL dari dummy
      // selectedSemester.value = userData['semester']; // Jika ada
    }
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

    // Proses penyimpanan
    final box = GetStorage();
    // Ambil data lama untuk menjaga field yang tidak diubah (seperti photoUrl awal)
    Map<String, dynamic> currentUserData = box.read('user') ?? {};

    // Buat data baru
    Map<String, dynamic> updatedUserData = {
      ...currentUserData, // Salin data lama
      'name': nameController.text,
      'nim': nimController.text,
      'prodi': prodiController.text,
      'password': passwordController.text,
      // Jika ada gambar baru, simpan path lokalnya. Jika tidak, pertahankan URL lama.
      'photoUrl': profileImage.value?.path ?? currentUserData['photoUrl'] ?? '',
    };

    // Simpan data baru ke GetStorage
    box.write('user', updatedUserData);

    // Perbarui HomeController agar UI di home juga berubah
    final homeController = Get.find<HomeController>();
    homeController.userName.value = updatedUserData['name'];
    homeController.photoUrl.value = updatedUserData['photoUrl'];

    isLoading.value = false;
    Get.back(); // Kembali ke halaman home setelah menyimpan
    Get.snackbar('Sukses', 'Profil berhasil diperbarui.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white);

  }
}
