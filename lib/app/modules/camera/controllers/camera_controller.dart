import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:absenuk/app/data/providers/api.dart';
import 'package:absenuk/app/services/ml_service.dart';
import 'package:face_camera/face_camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:http/http.dart' as http;

class CameraController extends GetxController {
  // State untuk UI
  final Rx<File?> capturedImage = Rx<File?>(null);
  final RxBool isMatching = false.obs;
  final RxString statusMessage = ''.obs;

  // Services dan Controller
  late FaceCameraController faceCameraController;
  final MLService _mlService = Get.find<MLService>();
  final GetStorage _box = GetStorage();

  @override
  void onInit() {
    super.onInit();
    faceCameraController = FaceCameraController(
      autoCapture: true,
      defaultCameraLens: CameraLens.front,
      onCapture: (File? image) {
        if (image != null) {
          capturedImage.value = image;
          faceCameraController.stopImageStream();
          _processAndMatchFace(image);
        }
      },
      onFaceDetected: (Face? face) {
        // Bisa digunakan untuk memberi feedback real-time jika diperlukan
      },
    );
  }

  Future<void> _processAndMatchFace(File image) async {
    isMatching.value = true;
    statusMessage.value = 'Menganalisis wajah...';

    // 1. Dapatkan data pengguna dan embedding yang tersimpan
    final userData = _box.read<Map<String, dynamic>>('user');
    if (userData == null || userData['face_embedding'] == null) {
      _handleError('Data wajah tidak ditemukan. Harap daftarkan wajah Anda di profil.');
      return;
    }
    final List<dynamic> rawStoredEmbedding = userData['face_embedding'];
    final List<double> storedEmbedding = rawStoredEmbedding.cast<double>().toList();

    // 2. Ekstrak embedding dari gambar yang baru ditangkap
    final List<double>? currentEmbedding = await _mlService.getEmbeddingFromFile(image);
    if (currentEmbedding == null) {
      _handleError('Wajah tidak terdeteksi dengan jelas. Coba lagi.');
      return;
    }

    // 3. Bandingkan embedding
    statusMessage.value = 'Mencocokkan wajah...';
    final bool isMatch = _mlService.compareEmbeddings(storedEmbedding, currentEmbedding);

    if (isMatch) {
      statusMessage.value = 'Wajah cocok! Mengirim data presensi...';
      await _submitAttendance(userData['nim']);
    } else {
      _handleError('Wajah tidak cocok. Pastikan Anda berada di pencahayaan yang baik.');
    }
  }

  Future<void> _submitAttendance(String nim) async {
    final token = _box.read<String>('token');
    if (token == null) {
      _handleError('Sesi berakhir. Silakan login kembali.');
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('${Api.baseUrl}/presensi/masuk'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: jsonEncode({'nim': nim}),
      );

      if (response.statusCode == 201 || response.statusCode == 200) {
        final responseData = json.decode(response.body);
        statusMessage.value = responseData['message'] ?? 'Presensi berhasil!';
        Get.snackbar('Sukses', statusMessage.value, backgroundColor: Colors.green, colorText: Colors.white);
        // Kembali ke halaman sebelumnya setelah 2 detik
        Future.delayed(const Duration(seconds: 2), () => Get.back(result: true));
      } else {
        final errorData = json.decode(response.body);
        _handleError(errorData['message'] ?? 'Gagal mengirim presensi.');
      }
    } catch (e) {
      _handleError('Terjadi kesalahan jaringan: $e');
    }
  }

  void _handleError(String message) {
    statusMessage.value = message;
    Get.snackbar('Gagal', message, backgroundColor: Colors.red, colorText: Colors.white);
    // Coba lagi setelah 3 detik
    Future.delayed(const Duration(seconds: 3), () => retakePicture());
  }

  void retakePicture() {
    capturedImage.value = null;
    isMatching.value = false;
    statusMessage.value = '';
    faceCameraController.startImageStream();
  }

  @override
  void onClose() {
    faceCameraController.dispose();
    super.onClose();
  }
}
