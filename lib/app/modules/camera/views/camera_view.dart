import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/camera_controller.dart';
import '../widgets/face_painter.dart';

class CameraView extends GetView<CameraViewController> {
  const CameraView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Pindai Wajah'),
        centerTitle: true,
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => controller.switchCamera(),
        child: Obx(() => Icon(
              controller.cameraLensDirection.value == CameraLensDirection.front
                  ? Icons.camera_rear
                  : Icons.camera_front,
            )),
      ),
      body: Obx(() {
        if (!controller.isCameraInitialized.value) {
          return const Center(child: CircularProgressIndicator());
        }

        // Widget untuk menampilkan stream kamera dengan overlay deteksi wajah
        return Stack(
          fit: StackFit.expand,
          children: [
            CameraPreview(controller.cameraController),

            // Overlay untuk menggambar kotak di sekitar wajah.
            // Kita gunakan Obx lagi di sini agar hanya painter yang di-rebuild
            // saat wajah terdeteksi, bukan seluruh Stack, untuk performa lebih baik.
            Obx(() {
                            if (controller.imageSize.value != null &&
                  controller.detectedFaces.isNotEmpty) {
                return CustomPaint(
                  painter: FacePainter(
                                        imageSize: controller.imageSize.value!,
                    faces: controller.detectedFaces,
                    cameraLensDirection:
                        controller.cameraController.description.lensDirection,
                  ),
                );
              } else {
                return const SizedBox.shrink();
              }
            }),

            // Pesan panduan untuk pengguna
            Positioned(
              bottom: 50,
              left: 0,
              right: 0,
              child: Container(
                padding:
                    const EdgeInsets.symmetric(vertical: 12, horizontal: 20),
                color: Colors.black.withOpacity(0.6),
                child: const Text(
                  'Posisikan wajah Anda di tengah kamera',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        );
      }),
    );
  }
}