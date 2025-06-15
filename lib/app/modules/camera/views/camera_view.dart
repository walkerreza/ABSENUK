import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:absenuk/app/modules/camera/controllers/camera_controller.dart';

class CameraView extends GetView<CameraViewController> {
  const CameraView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Obx(() => Text(controller.isPictureTaken.value ? 'Konfirmasi Foto' : 'Pindai Wajah')),
        centerTitle: true,
        backgroundColor: theme.scaffoldBackgroundColor,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
          onPressed: () => Get.back(),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Expanded(
              child: buildCameraArea(context),
            ),
            const SizedBox(height: 20),
            buildButtonArea(context),
          ],
        ),
      ),
    );
  }

  Widget buildCameraArea(BuildContext context) {
    return Obx(() {
      if (!controller.isCameraInitialized.value) {
        return const Center(child: CircularProgressIndicator());
      }

      if (controller.isPictureTaken.value && controller.capturedImage != null) {
        // Tampilan setelah gambar diambil
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Image.file(
            File(controller.capturedImage!.path),
            fit: BoxFit.cover,
          ),
        );
      } else {
        // Tampilan preview kamera
        return ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: CameraPreview(controller.cameraController),
        );
      }
    });
  }

  Widget buildButtonArea(BuildContext context) {
    final theme = Theme.of(context);
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: theme.primaryColor,
      foregroundColor: Colors.white,
      minimumSize: const Size(double.infinity, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );

    final secondaryButtonStyle = ElevatedButton.styleFrom(
      backgroundColor: theme.cardColor,
      foregroundColor: theme.textTheme.bodyLarge?.color,
      minimumSize: const Size(double.infinity, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );

    return Obx(() {
      if (controller.isPictureTaken.value) {
        // Tombol setelah gambar diambil
        return Column(
          children: [
            ElevatedButton(
              style: secondaryButtonStyle,
              onPressed: controller.reset,
              child: const Text('Ulangi'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              style: buttonStyle,
              onPressed: controller.saveAndStop,
              child: const Text('Simpan & Lanjutkan'),
            ),
          ],
        );
      } else {
        // Tombol sebelum scan
        return ElevatedButton(
          style: buttonStyle,
          onPressed: controller.takePicture,
          child: const Text('Ambil Gambar'),
        );
      }
    });
  }
}
