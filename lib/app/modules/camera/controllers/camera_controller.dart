import 'dart:async';
import 'dart:typed_data';

import 'package:camera/camera.dart';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:absenuk/app/modules/camera/utils/input_image_converter.dart';
import 'package:absenuk/app/services/face_recognition_service.dart';
import 'package:image/image.dart' as img;

class CameraViewController extends GetxController {
  late List<CameraDescription> _cameras;
  late CameraController cameraController;
  late String absenType;

  var isCameraInitialized = false.obs;
  var cameraLensDirection = CameraLensDirection.front.obs;
  // --- State untuk UI ---
  var isPictureTaken = false.obs; // Mungkin akan kita hapus/ganti
  var detectedFaces = <Face>[].obs;
  final Rx<Size?> imageSize = Rx<Size?>(null);
  var isProcessing = false.obs;

  // --- Services & Utilities ---
  late FaceDetector _faceDetector;
  late FaceRecognitionService _faceRecognitionService;

  // Variabel ini akan menyimpan data wajah yang dikenali
  // Map<String, dynamic>? recognizedFaceData;

  // --- Data dari Halaman Sebelumnya ---
  Position? currentPosition; // Untuk menyimpan lokasi

  @override
  void onInit() {
    super.onInit();
    // Inisialisasi semua service
    _faceRecognitionService = FaceRecognitionService();
    _faceDetector = FaceDetector(
      options: FaceDetectorOptions(
        enableContours: true,
        enableLandmarks: true,
      ),
    );

    final args = Get.arguments as Map<String, dynamic>?;
    absenType = args?['type'] ?? 'Tidak Diketahui';

    // Mulai inisialisasi kamera
    _initializeCamera();
  }

  Future<void> _initializeCamera() async {
    try {
      _cameras = await availableCameras();
      final cameraDescription = _cameras.firstWhere(
        (camera) => camera.lensDirection == cameraLensDirection.value,
        orElse: () => _cameras.first,
      );

      cameraController = CameraController(
        cameraDescription,
        ResolutionPreset.medium, // Gunakan resolusi medium untuk performa stream
        enableAudio: false,
      );

      await cameraController.initialize();
      isCameraInitialized.value = true;

      // Mulai stream gambar dari kamera
      _startImageStream();

    } catch (e) {
      Get.snackbar('Error', 'Gagal menginisialisasi kamera: ${e.toString()}');
      print('Error initializing camera: $e');
    }
  }



  Future<void> switchCamera() async {
    if (_cameras.length < 2) {
      Get.snackbar('Info', 'Hanya satu kamera yang tersedia.');
      return;
    }

    // Stop everything and show loading state
    isCameraInitialized.value = false;
    _stopImageStream();
    await cameraController.dispose();

    // Toggle direction
    cameraLensDirection.value =
        cameraLensDirection.value == CameraLensDirection.front
            ? CameraLensDirection.back
            : CameraLensDirection.front;

    // Re-run the initialization logic
    await _initializeCamera();
  }

  void _startImageStream() {
    cameraController.startImageStream((CameraImage image) {
      if (isProcessing.value) return;

      isProcessing.value = true;
      _processCameraImage(image).whenComplete(() {
        // Hanya set isProcessing ke false jika stream masih berjalan
        if (cameraController.value.isStreamingImages) {
          isProcessing.value = false;
        }
      });
    });
  }

  Future<void> _processCameraImage(CameraImage image) async {
    final inputImage =
        inputImageFromCameraImage(image, cameraController.description);
    if (inputImage == null) return;

    imageSize.value = Size(image.width.toDouble(), image.height.toDouble());

    try {
      final List<Face> faces = await _faceDetector.processImage(inputImage);
      detectedFaces.value = faces;

      if (faces.isNotEmpty) {
        // Wajah terdeteksi, hentikan stream agar bisa fokus memproses.
        _stopImageStream();

        final Face firstFace = faces.first;

        // Lakukan konversi, pemotongan, dan dapatkan embedding.
        final img.Image? fullImage = _convertCameraImage(image);
        if (fullImage == null) return;

        final img.Image croppedFace = _cropFace(fullImage, firstFace);
        final Float32List embedding =
            _faceRecognitionService.processFace(croppedFace);

        // TODO: Ganti bagian ini dengan logika perbandingan embedding dengan database.
        print('Embedding Dibuat: ${embedding.length} dimensi. Memproses absensi...');
        processAttendance();
      }
    } catch (e) {
      print("Error saat memproses gambar: $e");
    }
  }

  // --- Helper Functions untuk Image Processing ---

  img.Image? _convertCameraImage(CameraImage image) {
    if (image.format.group == ImageFormatGroup.yuv420) {
      return _convertYUV420(image);
    } else if (image.format.group == ImageFormatGroup.bgra8888) {
      return _convertBGRA8888(image);
    } else {
      print('Image format not supported: ${image.format.group}');
      return null;
    }
  }

  img.Image _convertBGRA8888(CameraImage image) {
    return img.Image.fromBytes(
      width: image.width,
      height: image.height,
      bytes: image.planes[0].bytes.buffer,
      order: img.ChannelOrder.bgra,
    );
  }

  img.Image _convertYUV420(CameraImage image) {
    final int width = image.width;
    final int height = image.height;
    final int uvRowStride = image.planes[1].bytesPerRow;
    final int? uvPixelStride = image.planes[1].bytesPerPixel;

    final imageResult = img.Image(width: width, height: height);

    for (int y = 0; y < height; y++) {
      for (int x = 0; x < width; x++) {
        final int uvIndex =
            uvPixelStride! * (x / 2).floor() + uvRowStride * (y / 2).floor();
        final int index = y * width + x;

        final yp = image.planes[0].bytes[index];
        final up = image.planes[1].bytes[uvIndex];
        final vp = image.planes[2].bytes[uvIndex];

        int r = (yp + vp * 1.402).round().clamp(0, 255);
        int g = (yp - up * 0.344 - vp * 0.714).round().clamp(0, 255);
        int b = (yp + up * 1.772).round().clamp(0, 255);

        imageResult.setPixelRgb(x, y, r, g, b);
      }
    }
    return imageResult;
  }

  img.Image _cropFace(img.Image image, Face face) {
    final x = face.boundingBox.left.toInt();
    final y = face.boundingBox.top.toInt();
    final w = face.boundingBox.width.toInt();
    final h = face.boundingBox.height.toInt();
    // Beri sedikit padding untuk memastikan seluruh wajah terambil
    final x1 = (x - 10).clamp(0, image.width - 1);
    final y1 = (y - 10).clamp(0, image.height - 1);
    final x2 = (x + w + 10).clamp(0, image.width - 1);
    final y2 = (y + h + 10).clamp(0, image.height - 1);

    return img.copyCrop(image, x: x1, y: y1, width: x2 - x1, height: y2 - y1);
  }

  // Fungsi ini tidak lagi relevan dalam mode real-time, bisa dihapus atau diubah
  void reset() {
    // Mungkin untuk memulai ulang stream jika ada error
    if (!cameraController.value.isStreamingImages) {
      _startImageStream();
    }
  }

  Future<Position?> _getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      Get.snackbar('Error', 'Layanan lokasi tidak aktif. Mohon aktifkan.');
      return null;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        Get.snackbar('Error', 'Izin lokasi ditolak.');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      Get.snackbar('Error', 'Izin lokasi ditolak secara permanen, buka pengaturan untuk mengizinkan.');
      return null;
    }

    try {
      return await Geolocator.getCurrentPosition();
    } catch (e) {
      Get.snackbar('Error', 'Gagal mendapatkan lokasi: ${e.toString()}');
      return null;
    }
  }

  // Fungsi ini akan dipanggil setelah wajah berhasil dikenali
  void processAttendance() async {
    currentPosition = await _getCurrentLocation();
    if (currentPosition != null) {
      print('Absensi diproses untuk [Nama Dikenali]');
      print('Lokasi: Lat ${currentPosition!.latitude}, Long ${currentPosition!.longitude}');
      
      Get.back(); // Kembali ke halaman sebelumnya
      Get.snackbar(
        'Berhasil',
        'Absen $absenType berhasil untuk [Nama Dikenali]!',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        margin: const EdgeInsets.all(10),
      );
    } else {
      Get.snackbar('Gagal', 'Tidak dapat melanjutkan tanpa data lokasi.');
    }
  }

  void _stopImageStream() {
    if (cameraController.value.isStreamingImages) {
      cameraController.stopImageStream();
    }
  }

  @override
  void onClose() {
    _stopImageStream();
    _faceDetector.close();
    _faceRecognitionService.close();
    cameraController.dispose();
    super.onClose();
  }
}
