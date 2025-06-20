import 'dart:typed_data';
import 'package:image/image.dart' as img;
import 'package:tflite_flutter/tflite_flutter.dart';

class FaceRecognitionService {
  late Interpreter _interpreter;
  static const int _inputSize = 112;

  FaceRecognitionService() {
    _loadModel();
  }

  Future<void> _loadModel() async {
    try {
      _interpreter = await Interpreter.fromAsset('assets/ml/mobilefacenet.tflite');
      print('Model MobileFaceNet berhasil dimuat.');
    } catch (e) {
      print('Gagal memuat model: $e');
    }
  }

  // Memproses gambar wajah dan menghasilkan embedding
  Float32List processFace(img.Image faceImage) {
    // 1. Ubah ukuran gambar ke ukuran input model (112x112)
    final img.Image resizedImage = img.copyResize(faceImage, width: _inputSize, height: _inputSize);

    // 2. Konversi gambar ke Float32List dan normalisasi
    final Float32List imageAsList = _imageToFloat32List(resizedImage);

    // 3. Bentuk ulang list menjadi tensor yang sesuai untuk input model [1, 112, 112, 3]
    final List<Object> inputs = [imageAsList.reshape([1, _inputSize, _inputSize, 3])];

    // 4. Siapkan output tensor [1, 192] (MobileFaceNet menghasilkan 192-dim embedding)
    final Map<int, Object> outputs = {0: List.filled(1 * 192, 0.0).reshape([1, 192])};

    // 5. Jalankan inferensi
    _interpreter.runForMultipleInputs(inputs, outputs);

    // 6. Dapatkan hasil embedding dan kembalikan sebagai Float32List
    final Float32List embedding = (outputs[0] as List<List<double>>)[0].toFloat32List();

    return embedding;
  }

  // Helper untuk konversi gambar ke Float32List
  Float32List _imageToFloat32List(img.Image image) {
    var buffer = Float32List(_inputSize * _inputSize * 3);
    var bufferIndex = 0;
    for (var y = 0; y < _inputSize; y++) {
      for (var x = 0; x < _inputSize; x++) {
        var pixel = image.getPixel(x, y);
        // Normalisasi nilai piksel dari [0, 255] ke [-1, 1]
        buffer[bufferIndex++] = (pixel.r - 127.5) / 127.5;
        buffer[bufferIndex++] = (pixel.g - 127.5) / 127.5;
        buffer[bufferIndex++] = (pixel.b - 127.5) / 127.5;
      }
    }
    return buffer;
  }

  void close() {
    _interpreter.close();
  }
}

// Extension helper untuk konversi List<double> ke Float32List
extension on List<double> {
  Float32List toFloat32List() {
    return Float32List.fromList(this);
  }
}

// Extension helper untuk reshape list
extension on Float32List {
  Float32List reshape(List<int> shape) {
    // Implementasi reshape sederhana, pastikan total elemen cocok
    return this;
  }
}
