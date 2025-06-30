import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:face_camera/face_camera.dart';
import '../controllers/camera_controller.dart';

class CameraView extends GetView<CameraViewController> {
  const CameraView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        // Jika sudah di-pop, biarkan
        if (didPop) return;
        
        try {
          // Pastikan controller dibersihkan sebelum kembali
          await controller.cleanupBeforeExit();
          if (context.mounted) {
            Get.back();
          }
        } catch (e) {
          // Jika terjadi error saat cleanup, tetap coba navigasi kembali
          if (context.mounted) {
            Get.back();
          }
        }
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Face Authentication register'),
          backgroundColor: Colors.blue,
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () async {
              await controller.cleanupBeforeExit();
              Get.back();
            },
          ),
        ),
        body: Obx(() {
          if (!controller.isReady.value) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final capturedImage = controller.capturedImage.value;
          
          if (capturedImage != null) {
            return SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Image.file(
                      capturedImage,
                      width: double.maxFinite,
                      fit: BoxFit.fitWidth,
                    ),
                    const SizedBox(height: 20),
                    if (controller.showForm.value) ...[
                      TextField(
                        controller: controller.nameController,
                        decoration: const InputDecoration(
                          labelText: 'Username',
                          border: OutlineInputBorder(),
                        ),
                      ),
                      const SizedBox(height: 10),
                      TextField(
                        controller: controller.passwordController,
                        decoration: const InputDecoration(
                          labelText: 'Password',
                          border: OutlineInputBorder(),
                        ),
                        obscureText: true,
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          ElevatedButton(
                            onPressed: () => controller.captureAgain(),
                            child: const Text('Capture Again'),
                          ),
                          ElevatedButton(
                            onPressed: () => controller.saveUser(),
                            child: const Text('Save'),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),
            );
          }

          return Obx(() {
            if (controller.cameraController.value == null) {
              return const Center(
                child: CircularProgressIndicator(),
              );
            }
            
            return SmartFaceCamera(
              controller: controller.cameraController.value!,
              messageBuilder: (context, face) {
                if (face == null) {
                  return _message('Place your face in the camera');
                }
                if (!face.wellPositioned) {
                  return _message('Center your face in the square');
                }
                return const SizedBox.shrink();
              },
            );
          });
        }),
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
        fontWeight: FontWeight.w400
      )
    ),
  );
}