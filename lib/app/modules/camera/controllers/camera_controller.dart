import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CameraViewController extends GetxController {
  late List<CameraDescription> _cameras;
  late CameraController cameraController;
  late String absenType;

  var isCameraInitialized = false.obs;
  var isPictureTaken = false.obs;
  XFile? capturedImage;

  @override
  void onInit() {
    super.onInit();
    final args = Get.arguments as Map<String, dynamic>?;
    absenType = args?['type'] ?? 'Tidak Diketahui';
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      // Gunakan kamera depan (biasanya index 1)
      cameraController = CameraController(
        _cameras.firstWhere(
          (camera) => camera.lensDirection == CameraLensDirection.front,
          orElse: () => _cameras.first, // Fallback ke kamera pertama jika tidak ada kamera depan
        ),
        ResolutionPreset.high,
      );
      await cameraController.initialize();
      isCameraInitialized.value = true;
    } catch (e) {
      Get.snackbar('Error', 'Gagal menginisialisasi kamera: ${e.toString()}');
      print('Error initializing camera: $e');
    }
  }

  void takePicture() async {
    if (!cameraController.value.isInitialized) {
      Get.snackbar('Error', 'Kamera belum siap.');
      return;
    }
    try {
      final image = await cameraController.takePicture();
      capturedImage = image;
      isPictureTaken.value = true;
    } catch (e) {
      Get.snackbar('Error', 'Gagal mengambil gambar: ${e.toString()}');
    }
  }

  void reset() {
    isPictureTaken.value = false;
    capturedImage = null;
  }

  void saveAndStop() {
    if (capturedImage != null) {
      print('Gambar disimpan di: ${capturedImage!.path}');
      // TODO: Implementasikan logika penyimpanan gambar atau pengiriman ke server di sini
      Get.back();
      Get.snackbar(
        'Berhasil',
        'Anda telah berhasil melakukan absen $absenType.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
      );
    } else {
      Get.snackbar('Error', 'Tidak ada gambar untuk disimpan.');
    }
  }

  @override
  void onClose() {
    cameraController.dispose();
    super.onClose();
  }
}
