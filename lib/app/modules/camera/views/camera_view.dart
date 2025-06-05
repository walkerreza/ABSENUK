import 'package:flutter/material.dart';

import 'package:get/get.dart';

import '../controllers/camera_controller.dart';

class CameraView extends GetView<CameraController> {
  const CameraView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('CameraView'),
        centerTitle: true,
      ),
      body: const Center(
        child: Text(
          'CameraView is working',
          style: TextStyle(fontSize: 20),
        ),
      ),
    );
  }
}
