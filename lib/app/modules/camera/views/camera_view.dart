import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/camera_controller.dart';

class CameraView extends GetView<CameraController> {
  const CameraView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Obx(() => Scaffold(
          appBar: AppBar(
            title: Text(controller.isPictureTaken.value ? 'Scan Face' : 'Scan'),
            centerTitle: true,
            backgroundColor: theme.scaffoldBackgroundColor,
            elevation: 0,
            leading: IconButton(
              icon: Icon(Icons.arrow_back, color: theme.iconTheme.color),
              onPressed: () => Get.back(),
            ),
          ),
          body: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // Top bar placeholder
                Container(
                  padding: const EdgeInsets.all(8.0),
                  decoration: BoxDecoration(
                    color: theme.cardColor,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.language, size: 20),
                          SizedBox(width: 4), 
                          Text('En'),
                          SizedBox(width: 8),
                          Icon(Icons.volume_up_outlined, size: 20),
                          SizedBox(width: 8),
                          Icon(Icons.text_fields_outlined, size: 20),
                        ],
                      ),
                      if (controller.isPictureTaken.value)
                        const Text('Man', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Camera/Image Area
                Expanded(
                  child: buildCameraArea(context),
                ),
                const SizedBox(height: 20),

                // Bottom Buttons Area
                buildButtonArea(context),
              ],
            ),
          ),
        ));
  }

  Widget buildCameraArea(BuildContext context) {
    if (controller.isPictureTaken.value) {
      // Tampilan setelah gambar diambil
      return ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Placeholder untuk gambar yang diambil
            Image.network(
              'https://t4.ftcdn.net/jpg/02/99/04/20/360_F_299042079_vGBD7wIlSeNl7vOevWHiL93G4koMM967.jpg',
              fit: BoxFit.cover,
            ),
            // Placeholder untuk face mesh overlay
            Image.network(
              'https://i.ibb.co/28K02K1/face-mesh-transparent.png',
              fit: BoxFit.contain,
            ),
            // Placeholder untuk corner brackets
            const Center(
              child: Icon(
                Icons.crop_free,
                color: Colors.white70,
                size: 250,
              ),
            ),
          ],
        ),
      );
    } else {
      // Tampilan sebelum scan
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[300],
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }

  Widget buildButtonArea(BuildContext context) {
    final theme = Theme.of(context);
    final buttonStyle = ElevatedButton.styleFrom(
      backgroundColor: theme.primaryColor,
      foregroundColor: Colors.white,
      minimumSize: const Size(double.infinity, 50),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      textStyle: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );

    if (controller.isPictureTaken.value) {
      // Tombol setelah gambar diambil
      return Column(
        children: [
          ElevatedButton(
            style: buttonStyle,
            onPressed: controller.pause,
            child: const Text('Jeda'),
          ),
          const SizedBox(height: 12),
          ElevatedButton(
            style: buttonStyle,
            onPressed: controller.saveAndStop,
            child: const Text('Henti dan Simpan'),
          ),
        ],
      );
    } else {
      // Tombol sebelum scan
      return ElevatedButton(
        style: buttonStyle,
        onPressed: controller.takePicture,
        child: const Text('Mulai Scan'),
      );
    }
  }
}
