import 'package:face_camera/face_camera.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/camera_controller.dart';

class CameraView extends GetView<CameraController> {
  const CameraView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ambil Foto Wajah'),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SmartFaceCamera(
            controller: controller.faceCameraController,
            messageBuilder: (context, face) {
              if (face == null) {
                return _message('Posisikan wajah Anda di dalam kamera');
              }
              if (!face.wellPositioned) {
                return _message('Posisikan wajah Anda di tengah kotak');
              }
              return const SizedBox.shrink();
            },
          ),
          Obx(() {
            if (controller.isMatching.value) {
              return Container(
                color: Colors.black.withOpacity(0.7),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const CircularProgressIndicator(),
                      const SizedBox(height: 20),
                      Text(
                        controller.statusMessage.value,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return const SizedBox.shrink();
          }),
        ],
      ),
    );
  }

  Widget _message(String msg) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 55, vertical: 15),
        child: Text(
          msg,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            height: 1.5,
            fontWeight: FontWeight.w400,
          ),
        ),
      );
}