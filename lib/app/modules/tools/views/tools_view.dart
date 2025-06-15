import 'package:flutter/material.dart';
import 'package:get/get.dart';


import '../controllers/tools_controller.dart';

class ToolsView extends GetView<ToolsController> {
  const ToolsView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Peralatan Mahasiswa'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16.0),
        children: [
          _buildToolCard(
            context,
            icon: Icons.book_outlined,
            title: 'Jurnal Digital',
            subtitle: 'Catat ide, tugas, dan refleksi harian Anda.',
            onTap: () => Get.toNamed('/journal'),
          ),
          const SizedBox(height: 16),
          _buildToolCard(
            context,
            icon: Icons.mail_outline_rounded,
            title: 'Template Izin',
            subtitle: 'Buat pesan & surat izin dengan cepat.',
            onTap: () => Get.toNamed('/permission-template'),
          ),
          // Tambahkan Card untuk tools lainnya di sini
          // Contoh:
          // _buildToolCard(
          //   context,
          //   icon: Icons.calculate,
          //   title: 'Kalkulator Vokasi',
          //   subtitle: 'Alat hitung untuk kebutuhan spesifik.',
          //   onTap: () {
          //     // Get.toNamed(Routes.VOCATIONAL_CALCULATOR);
          //   },
          // ),
        ],
      ),
    );
  }

  Widget _buildToolCard(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Card(
      elevation: 2.0,
      margin: const EdgeInsets.only(bottom: 16.0),
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            children: [
              Icon(icon, size: 40, color: Theme.of(context).primaryColor),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(color: Colors.grey[600]),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

