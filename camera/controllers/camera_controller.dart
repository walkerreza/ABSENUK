// import 'dart:io';
// import 'dart:typed_data';
// import 'package:flutter/material.dart';
// import 'package:get/get.dart';
// import 'package:face_camera/face_camera.dart';
// import 'package:image/image.dart' as img;
// import 'package:google_ml_kit/google_ml_kit.dart';
// import 'package:face_detection/app/data/database/local_db.dart';
// import 'package:face_detection/app/routes/app_pages.dart';
// import 'package:face_detection/app/services/ml_service.dart';

// class CameraViewController extends GetxController {
//   final isReady = false.obs;
//   final cameraController = Rxn<FaceCameraController>();
//   final capturedImage = Rxn<File>();
//   final showForm = false.obs;
//   final isProcessing = false.obs;
//   final faceDetector = FaceDetector(
//     options: FaceDetectorOptions(
//       enableLandmarks: true,
//       enableClassification: true,
//       enableTracking: true,
//       minFaceSize: 0.15,
//       performanceMode: FaceDetectorMode.accurate,
//     ),
//   );
  
//   // Form controllers
//   final nameController = TextEditingController();
//   final passwordController = TextEditingController();

//   @override
//   void onInit() {
//     super.onInit();
//     _initCamera();

//     // Cek apakah ini mode login dan belum ada data user
//     if (Get.arguments?['isLogin'] == true && !LocalDB.hasUserData()) {
//       Get.snackbar(
//         'Perhatian',
//         'Anda belum terdaftar. Silakan register terlebih dahulu.',
//         duration: const Duration(seconds: 3),
//         snackPosition: SnackPosition.BOTTOM,
//       );
      
//       // Tunggu snackbar selesai lalu kembali ke home
//       Future.delayed(const Duration(seconds: 3), () {
//         Get.offAllNamed(Routes.HOME);
//       });
//     }
//   }

//   Future<void> _initCamera() async {
//     try {
//       // Pastikan kamera sebelumnya sudah di-dispose dengan benar
//       await cleanupBeforeExit();
      
//       await FaceCamera.initialize();
      
//       // Tunggu sebentar sebelum membuat controller baru
//       await Future.delayed(const Duration(milliseconds: 100));
      
//       cameraController.value = FaceCameraController(
//         orientation: CameraOrientation.landscapeLeft,
//         enableAudio: false,
//         autoCapture: true,
//         defaultCameraLens: CameraLens.front,
//         onCapture: (File? image) async {
//           if (image != null) {
//             isProcessing.value = true;
//             try {
//               // Rotasi gambar
//               File rotatedImage = await rotateImage(image);
              
//               // Deteksi wajah dengan ML Kit
//               final inputImage = InputImage.fromFile(rotatedImage);
//               final faces = await faceDetector.processImage(inputImage);
              
//               if (faces.isEmpty) {
//                 Get.snackbar(
//                   'Error',
//                   'Tidak ada wajah terdeteksi',
//                   snackPosition: SnackPosition.BOTTOM,
//                 );
//                 return;
//               }

//               final face = faces.first;
//               // Cek rotasi wajah (euler angles)
//               final double? angleY = face.headEulerAngleY;
//               final double? angleZ = face.headEulerAngleZ;
              
//               if (angleY == null || angleZ == null || 
//                   angleY.abs() > 10 || angleZ.abs() > 10) {
//                 Get.snackbar(
//                   'Error',
//                   'Posisikan wajah Anda menghadap ke depan',
//                   snackPosition: SnackPosition.BOTTOM,
//                 );
//                 return;
//               }

//               // Simpan gambar yang berhasil diambil
//               capturedImage.value = rotatedImage;
//               showForm.value = true;

//             } finally {
//               isProcessing.value = false;
//             }
//           }
//         },
//         onFaceDetected: (Face? face) {
//           // Handle face detection if needed
//         },
//       );

//       isReady.value = true;
//     } catch (e) {
//       Get.snackbar(
//         'Error',
//         'Gagal menginisialisasi kamera: ${e.toString()}',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//     }
//   }

//   Future<File> rotateImage(File imageFile) async {
//     List<int> bytes = await imageFile.readAsBytes();
//     Uint8List imageBytes = Uint8List.fromList(bytes);
//     img.Image? originalImage = img.decodeImage(imageBytes);

//     if (originalImage != null) {
//       img.Image rotatedImage = img.copyRotate(originalImage, angle: 270);
//       String path = imageFile.path;
//       File rotatedFile = File(path);
//       await rotatedFile.writeAsBytes(img.encodeJpg(rotatedImage));
//       return rotatedFile;
//     }
//     return imageFile;
//   }

//   Future<void> captureAgain() async {
//     try {
//       capturedImage.value = null;
//       showForm.value = false;
//       nameController.clear();
//       passwordController.clear();
      
//       if (cameraController.value != null) {
//         await cameraController.value!.startImageStream();
//       } else {
//         // Jika controller null, coba inisialisasi ulang
//         await _initCamera();
//       }
//     } catch (e) {
//       Get.log('Error saat capture lagi: $e');
//     }
//   }

//   Future<void> saveUser() async {
//     if (nameController.text.isEmpty || passwordController.text.isEmpty || capturedImage.value == null) {
//       Get.snackbar(
//         'Error',
//         'Mohon lengkapi semua data',
//         snackPosition: SnackPosition.BOTTOM,
//       );
//       return;
//     }

//     try {
//       // Deteksi wajah untuk mendapatkan array
//       final inputImage = InputImage.fromFile(capturedImage.value!);
//       final faces = await faceDetector.processImage(inputImage);
      
//       if (faces.isEmpty) {
//         Get.snackbar(
//           'Error',
//           'Tidak ada wajah terdeteksi',
//           snackPosition: SnackPosition.BOTTOM,
//         );
//         return;
//       }

//       // Dapatkan array wajah dari ML Service
//       final mlService = Get.find<MLService>();
//       final user = await mlService.predict(
//         capturedImage.value!,
//         faces.first,
//         false, // isLogin = false untuk registrasi
//         nameController.text,
//       );

//       if (user == null) {
//         Get.snackbar(
//           'Error',
//           'Gagal memproses wajah',
//           snackPosition: SnackPosition.BOTTOM,
//         );
//         return;
//       }

//       // Update password dari form
//       user.password = passwordController.text;
      
//       // Simpan ke local DB
//       try {
//         await LocalDB.addUser(user);
        
//         Get.snackbar(
//           'Sukses',
//           'Registrasi berhasil!\nUsername: ${user.name}\nPassword: ${user.password}\nSilakan login untuk melanjutkan.',
//           duration: const Duration(seconds: 3),
//           snackPosition: SnackPosition.BOTTOM,
//         );
        
//         // Tunggu snackbar selesai
//         await Future.delayed(const Duration(seconds: 3));
        
//         // Bersihkan resource sebelum navigasi
//         await cleanupBeforeExit();
        
//         // Kembali ke halaman home
//         Get.offAllNamed(Routes.HOME);
        
//       } catch (dbError) {
//         String errorMessage = 'Gagal menyimpan data';
        
//         if (dbError.toString().contains('Username sudah digunakan')) {
//           errorMessage = 'Username sudah digunakan, silakan gunakan username lain';
//         } else if (dbError.toString().contains('Gagal verifikasi')) {
//           errorMessage = 'Gagal verifikasi data, silakan coba lagi';
//         }
        
//         Get.snackbar(
//           'Error',
//           errorMessage,
//           duration: const Duration(seconds: 3),
//           snackPosition: SnackPosition.BOTTOM,
//         );
//       }
      
//     } catch (e) {
//       String errorMessage = 'Terjadi kesalahan saat registrasi';
      
//       if (e.toString().contains('Wajah sudah terdaftar')) {
//         errorMessage = 'Wajah sudah terdaftar dengan user lain';
//       }
      
//       Get.snackbar(
//         'Error',
//         errorMessage,
//         duration: const Duration(seconds: 3),
//         snackPosition: SnackPosition.BOTTOM,
//       );
//     }
//   }

//   Future<void> cleanupBeforeExit() async {
//     try {
//       final controller = cameraController.value;
//       if (controller != null) {
//         // Hentikan stream terlebih dahulu
//         await controller.stopImageStream();
//         // Tunggu sebentar untuk memastikan stream benar-benar berhenti
//         await Future.delayed(const Duration(milliseconds: 100));
//         // Baru dispose controller
//         await controller.dispose();
//         // Set controller ke null
//         cameraController.value = null;
//       }
//     } catch (e) {
//       printError(info: 'Error saat cleanup camera: $e');
//     }
//   }

//   @override
//   void onClose() {
//     nameController.dispose();
//     passwordController.dispose();
//     cleanupBeforeExit();
//     super.onClose();
//   }
// }