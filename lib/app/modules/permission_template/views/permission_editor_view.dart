import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../controllers/permission_editor_controller.dart';

class PermissionEditorView extends GetView<PermissionEditorController> {
  const PermissionEditorView({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit & Kirim Izin'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_rounded),
            tooltip: 'Bagikan',
            onPressed: () => controller.showShareOptions(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Pesan Izin',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: theme.inputDecorationTheme.fillColor ?? theme.colorScheme.surface.withOpacity(0.5),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: theme.dividerColor),
              ),
              child: TextField(
                controller: controller.textController,
                decoration: const InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Tulis pesan izin Anda di sini...',
                ),
                maxLines: 15,
                style: theme.textTheme.bodyLarge ?? const TextStyle(),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Lampiran (Opsional)',
              style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Obx(() {
              if (controller.selectedImage.value == null) {
                return OutlinedButton.icon(
                  icon: const Icon(Icons.attach_file_rounded),
                  label: const Text('Lampirkan Gambar Bukti'),
                  onPressed: controller.pickImage,
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                );
              } else {
                return Column(
                  children: [
                    Container(
                      height: 200,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        image: DecorationImage(
                          image: FileImage(File(controller.selectedImage.value!.path)),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      icon: const Icon(Icons.change_circle_outlined),
                      label: const Text('Ganti Gambar'),
                      onPressed: controller.pickImage,
                    )
                  ],
                );
              }
            }),
          ],
        ),
      ),
    );
  }
}
