

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'package:absenuk/app/modules/home/controllers/home_controller.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:absenuk/app/data/providers/api.dart';
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';

class ProfileController extends GetxController {
  // TextEditingControllers untuk input fields
  late TextEditingController nameController;
  late TextEditingController nimController;

  late TextEditingController passwordController;

  // Variabel reaktif
  final Rx<XFile?> profileImage = Rx<XFile?>(null);
  final Rx<int?> selectedSemester = Rx<int?>(null);
  final Rx<String?> selectedProdi = Rx<String?>(null);
  final RxBool obscurePassword = true.obs;
  final RxBool isLoading = false.obs;
  final RxString existingImageUrl = ''.obs;

  // Instance ImagePicker
  final ImagePicker _picker = ImagePicker();

  // Daftar semester untuk Dropdown
  final List<int> semesters = [1, 2, 3, 4];

  // Daftar program studi untuk Dropdown
  final List<String> prodiList = [
    'ASJK (Administrasi Server dan Jaringan Komputer)',
    'OPD (Operasionalisasi Perkantoran Digital)',
    'PAV (Penyuntingan Audio Video)',
    'PHTU (Pengolahan Hasil Ternak Unggas)',
  ];

  @override
  void onInit() {
    super.onInit();
    // Inisialisasi controllers
    nameController = TextEditingController();
    nimController = TextEditingController();

    passwordController = TextEditingController();

    _loadUserProfile();
  }

  void _loadUserProfile() {
    final box = GetStorage();
    final userData = box.read<Map<String, dynamic>>('user');
    if (userData != null) {
      nameController.text = userData['nama'] ?? '';
      nimController.text = userData['nim'] ?? '';

      if (userData['semester'] != null && userData['semester'] is Map) {
        final semesterName = userData['semester']['nama'] as String?;
        if (semesterName != null) {
          try {
            // Ekstrak angka dari string, misal "Semester 4" -> 4
            final semesterNumber = int.parse(semesterName.split(' ').last);
            selectedSemester.value = semesterNumber;
          } catch (e) {
            debugPrint('Error parsing semester: $e');
            selectedSemester.value = null;
          }
        }
      }

      if (userData['prodi'] != null && userData['prodi'] is Map) {
        selectedProdi.value = userData['prodi']['nama'];
      } else {
        // Fallback untuk struktur data lama jika prodi masih string biasa
        selectedProdi.value = userData['prodi'];
      }
      passwordController.text = ''; // Password field is kept empty for security
      existingImageUrl.value = userData['image'] ?? ''; // Load existing image URL

      final prodiData = userData['prodi'] as Map<String, dynamic>?;
      if (prodiData != null) {
        final prodiName = prodiData['nama'] as String?;
        if (prodiName != null) {
          if (!prodiList.contains(prodiName)) {
            prodiList.add(prodiName);
          }
          selectedProdi.value = prodiName;
        }
      }
    }
  }

  @override
  void onClose() {
    // Dispose controllers untuk menghindari memory leaks
    nameController.dispose();
    nimController.dispose();

    passwordController.dispose();
    super.onClose();
  }

  // Fungsi untuk memilih gambar dari galeri atau kamera
  Future<void> pickImage(ImageSource source) async {
    try {
      final XFile? pickedFile = await _picker.pickImage(source: source);
      if (pickedFile != null) {
        profileImage.value = pickedFile;
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
  Future<void> saveProfile() async {
    isLoading.value = true;

    if (nameController.text.isEmpty || nimController.text.isEmpty || selectedProdi.value == null) {
      Get.snackbar('Error', 'Nama, NIM, dan Program Studi harus diisi.', snackPosition: SnackPosition.BOTTOM);
      isLoading.value = false;
      return;
    }

    final box = GetStorage();
    final token = box.read<String>('token');
    if (token == null) {
      Get.snackbar('Error', 'Sesi tidak valid. Silakan login kembali.', snackPosition: SnackPosition.BOTTOM);
      isLoading.value = false;
      return;
    }

    try {
      // Sesuai dengan route backend: PUT /mahasiswa/nim/:nim
      var request = http.MultipartRequest('PUT', Uri.parse('${Api.baseUrl}/mahasiswa/nim/${nimController.text}'));

      request.headers['Authorization'] = 'Bearer $token';
      request.fields['nama'] = nameController.text;
      request.fields['prodi'] = selectedProdi.value!;

      if (passwordController.text.isNotEmpty) {
        request.fields['password'] = passwordController.text;
      }

      if (profileImage.value != null) {
        final imageXFile = profileImage.value!;
        // Gunakan nama asli file untuk mendapatkan MIME type yang benar, bukan path sementara.
        final mimeType = lookupMimeType(imageXFile.name);

        request.files.add(
          await http.MultipartFile.fromPath(
            'image', // field name
            imageXFile.path, // path ke file di cache
            contentType: MediaType.parse(mimeType ?? 'application/octet-stream'),
            filename: imageXFile.name, // Kirim nama file asli ke server
          ),
        );
      }

      var streamedResponse = await request.send();
      final response = await http.Response.fromStream(streamedResponse);

      // Log untuk debugging
      debugPrint('Update Profile Status Code: ${response.statusCode}');
      debugPrint('Update Profile Response Body: ${response.body}');

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        final updatedUserData = responseData['data'];

        box.write('user', updatedUserData);

        final homeController = Get.find<HomeController>();
        // Perbarui data di HomeController dengan data baru dari server
        homeController.userName.value = updatedUserData['nama'] ?? '';
        final newImageUrl = updatedUserData['image'] ?? '';

        // Simpan data mentah di storage, tapi bangun URL absolut untuk UI
        if (newImageUrl.isNotEmpty && !newImageUrl.startsWith('http')) {
          final baseUrl = Api.baseUrl.replaceAll('/api', '');
          homeController.photoUrl.value = '$baseUrl$newImageUrl';
        } else {
          homeController.photoUrl.value = newImageUrl;
        }

        // Perbarui juga UI di halaman profil ini dan reset pilihan gambar
        existingImageUrl.value = homeController.photoUrl.value;
        profileImage.value = null;

        passwordController.clear(); // Kosongkan field password setelah sukses
        Get.back();
        Get.snackbar('Sukses', 'Profil berhasil diperbarui.', snackPosition: SnackPosition.BOTTOM, backgroundColor: Colors.green, colorText: Colors.white);
      } else {
        // Coba decode JSON, jika gagal, tampilkan body mentah sebagai error
        try {
          final responseData = json.decode(response.body);
          Get.snackbar('Gagal Memperbarui', responseData['message'] ?? 'Terjadi kesalahan pada server.', snackPosition: SnackPosition.BOTTOM);
        } catch (_) {
          Get.snackbar('Gagal Memperbarui', 'Server memberikan respons tidak terduga. Status: ${response.statusCode}', snackPosition: SnackPosition.BOTTOM);
        }
      }
    } catch (e) {
      // Tangani error koneksi atau parsing
      debugPrint('Save Profile Error: $e');
      Get.snackbar('Error Klien', 'Terjadi masalah saat mengirim data: $e', snackPosition: SnackPosition.BOTTOM);
    } finally {
      isLoading.value = false;
    }
  }
}
