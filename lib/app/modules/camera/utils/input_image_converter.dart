import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_face_detection/google_mlkit_face_detection.dart';

InputImage? inputImageFromCameraImage(
    CameraImage image, CameraDescription camera) {
  final WriteBuffer allBytes = WriteBuffer();
  for (final Plane plane in image.planes) {
    allBytes.putUint8List(plane.bytes);
  }
  final bytes = allBytes.done().buffer.asUint8List();

  final imageSize = Size(image.width.toDouble(), image.height.toDouble());

  final imageRotation =
      InputImageRotationValue.fromRawValue(camera.sensorOrientation);
  if (imageRotation == null) return null;

  final inputImageFormat =
      InputImageFormatValue.fromRawValue(image.format.raw);
  if (inputImageFormat == null) return null;

  final metadata = InputImageMetadata(
    size: imageSize,
    rotation: imageRotation,
    format: inputImageFormat,
    bytesPerRow: image.planes[0].bytesPerRow,
  );

  return InputImage.fromBytes(bytes: bytes, metadata: metadata);
}
