import 'dart:math';
import 'dart:io';
import 'dart:typed_data';

import 'package:get/get.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';
import 'package:image/image.dart' as imglib;
import 'package:tflite_flutter/tflite_flutter.dart';

class MLService extends GetxService {
  late Interpreter _interpreter;
  bool _isInitialized = false;
  final FaceDetector _faceDetector = FaceDetector(
    options: FaceDetectorOptions(
      performanceMode: FaceDetectorMode.fast,
    ),
  );

  // Threshold untuk pencocokan wajah. Nilai ini mungkin perlu disesuaikan.
  final double _matchingThreshold = 1.0;

  Future<void> initialize() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/mobilefacenet.tflite');
      print('Model FaceNet berhasil dimuat.');
      _isInitialized = true;
    } catch (e) {
      print('Gagal memuat model FaceNet: $e');
    }
  }

  /// Menghasilkan embedding 192 elemen dari gambar wajah yang sudah dipotong.
  Future<List<double>?> _getEmbedding(imglib.Image croppedFace) async {
    // Ubah ukuran gambar sesuai input model (112x112)
    final resizedImage = imglib.copyResize(croppedFace, width: 112, height: 112);
    final imageBytes = _imageToByteListFloat32(resizedImage);

    // Siapkan buffer input dan output
    final input = imageBytes.reshape([1, 112, 112, 3]);
    final output = List.filled(1 * 192, 0.0).reshape([1, 192]);

    // Jalankan inferensi
    try {
      _interpreter.run(input, output);
      return output[0].cast<double>();
    } catch (e) {
      print("Error saat menjalankan inferensi model: $e");
      return null;
    }
  }

  /// Mendeteksi satu wajah dalam file gambar dan mengembalikan embedding-nya.
    /// Mendeteksi satu wajah dalam file gambar dan mengembalikan embedding-nya.
  Future<List<double>?> getEmbeddingFromFile(File imageFile) async {
    // 1. Deteksi wajah
    final inputImage = InputImage.fromFilePath(imageFile.path);
    final List<Face> faces = await _faceDetector.processImage(inputImage);

    if (faces.isEmpty) {
      Get.snackbar('Gagal', 'Tidak ada wajah yang terdeteksi.');
      return null;
    }
    if (faces.length > 1) {
      Get.snackbar('Peringatan', 'Terdeteksi lebih dari satu wajah. Pastikan hanya ada Anda di dalam foto.');
       return null;
    }

    // 2. Potong wajah dari gambar asli
    final imageBytes = await imageFile.readAsBytes();
    final originalImage = imglib.decodeImage(imageBytes);
    if (originalImage == null) {
      Get.snackbar('Gagal', 'Gagal memproses gambar.');
      return null;
    }

    final croppedFace = _cropFace(originalImage, faces.first);

    // 3. Dapatkan embedding dari wajah yang sudah dipotong
    return await _getEmbedding(croppedFace);
  }

  /// Membandingkan dua embedding menggunakan Jarak Euclidean.
  /// Mengembalikan `true` jika jaraknya di bawah ambang batas.
  bool compareEmbeddings(List<double> dbEmbedding, List<double> currentEmbedding) {
    if (dbEmbedding.isEmpty || currentEmbedding.isEmpty) {
      return false;
    }
    final double distance = _euclideanDistance(dbEmbedding, currentEmbedding);
    print("Jarak wajah: $distance");
    return distance < _matchingThreshold;
  }

  // --- Fungsi Utilitas ---

  imglib.Image _cropFace(imglib.Image image, Face face) {
    final x = face.boundingBox.left.toInt();
    final y = face.boundingBox.top.toInt();
    final w = face.boundingBox.width.toInt();
    final h = face.boundingBox.height.toInt();
    return imglib.copyCrop(image, x: x, y: y, width: w, height: h);
  }

  double _euclideanDistance(List<double> e1, List<double> e2) {
    if (e1.length != e2.length) {
      throw Exception("Embedding harus memiliki panjang yang sama");
    }
    var sum = 0.0;
    for (int i = 0; i < e1.length; i++) {
      sum += pow(e1[i] - e2[i], 2);
    }
    return sqrt(sum);
  }

  Float32List _imageToByteListFloat32(imglib.Image image) {
    var convertedBytes = Float32List(1 * 112 * 112 * 3);
    var buffer = Float32List.view(convertedBytes.buffer);
    int pixelIndex = 0;
    for (var i = 0; i < 112; i++) {
      for (var j = 0; j < 112; j++) {
        var pixel = image.getPixel(j, i);
        // Normalisasi nilai piksel ke rentang [-1, 1]
        buffer[pixelIndex++] = (pixel.r - 128) / 128.0;
        buffer[pixelIndex++] = (pixel.g - 128) / 128.0;
        buffer[pixelIndex++] = (pixel.b - 128) / 128.0;
      }
    }
    return convertedBytes.buffer.asFloat32List();
  }

  @override
  void onInit() {
    super.onInit();
    initialize();
  }

  @override
  void onClose() {
    _faceDetector.close();
    if (_isInitialized) {
       _interpreter.close();
    }
    super.onClose();
  }
}
