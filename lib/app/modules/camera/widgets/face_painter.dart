import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

class FacePainter extends CustomPainter {
  final Size imageSize;
  final List<Face> faces;
  final CameraLensDirection cameraLensDirection;

  FacePainter({
    required this.imageSize,
    required this.faces,
    required this.cameraLensDirection,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..color = Colors.lightGreenAccent;

    for (final Face face in faces) {
      final Rect boundingBox = face.boundingBox;

      final double scaleX = size.width / imageSize.width;
      final double scaleY = size.height / imageSize.height;

      // Menerjemahkan dan menskalakan kotak pembatas dari sistem koordinat gambar
      // ke sistem koordinat UI.
      final Rect rect = Rect.fromLTRB(
        // Untuk kamera depan, koordinat x perlu dicerminkan (mirror).
        cameraLensDirection == CameraLensDirection.front
            ? size.width - (boundingBox.left * scaleX) - (boundingBox.width * scaleX)
            : boundingBox.left * scaleX,
        boundingBox.top * scaleY,
        cameraLensDirection == CameraLensDirection.front
            ? size.width - (boundingBox.left * scaleX)
            : boundingBox.right * scaleX,
        boundingBox.bottom * scaleY,
      );

      canvas.drawRect(rect, paint);

      // Di sini Anda bisa menambahkan kode untuk menggambar nama atau ID yang dikenali
      // di atas atau di bawah kotak jika diperlukan.
    }
  }

  @override
  bool shouldRepaint(covariant FacePainter oldDelegate) {
    return oldDelegate.imageSize != imageSize || oldDelegate.faces != faces;
  }
}
