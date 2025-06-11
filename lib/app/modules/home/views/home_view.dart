import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    // Warna sekarang diambil dari Theme.of(context) atau Get.theme

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor, // Menggunakan warna dari tema
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              // Header Kustom
              _buildHeader(context, controller),
              const SizedBox(height: 30.0),

              // Judul Bagian Menu
              Text(
                'Menu Utama',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),

              // Grid Menu
              _buildMenuGrid(context, controller),
              const SizedBox(height: 30.0),

              // Judul Bagian Event
              Text(
                'Informasi & Acara',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),

              // Bagian Event (Placeholder)
              _buildEventSection(context),
              const SizedBox(height: 20.0),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, HomeController controller) {
    return Container(
      padding: const EdgeInsets.all(20.0),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).primaryColor,
            Theme.of(context).primaryColor.withAlpha(200),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(16.0),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).primaryColor.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 5),
          )
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: <Widget>[
          Obx(() => Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Selamat Datang,',
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.white.withOpacity(0.9),
                      ),
                    ),
                    Text(
                      controller.userName.value,
                      style: const TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              )),
          Row(
            children: <Widget>[
              // Avatar Profil Pengguna
              Obx(() {
                return GestureDetector(
                  onTap: controller.goToProfile,
                  child: CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.white,
                    child: CircleAvatar(
                      radius: 22,
                      backgroundColor: Theme.of(context).primaryColor,
                      backgroundImage: controller.photoUrl.value.isNotEmpty
                          ? (controller.photoUrl.value.startsWith('http')
                              ? NetworkImage(controller.photoUrl.value)
                              : FileImage(File(controller.photoUrl.value)) as ImageProvider)
                          : null,
                      child: controller.photoUrl.value.isEmpty
                          ? const Icon(
                              Icons.person_outline,
                              size: 28,
                              color: Colors.white,
                            )
                          : null,
                    ),
                  ),
                );
              }),
              const SizedBox(width: 8),
              // Tombol Pengaturan
              IconButton(
                icon: const Icon(Icons.settings_outlined, color: Colors.white, size: 28),
                onPressed: controller.goToSettings,
                tooltip: 'Pengaturan',
              ),
            ],
          ),
        ],
      ),
    );
  }


  Widget _buildMenuGrid(BuildContext context, HomeController controller) {
    final menuItems = [
      {'icon': Icons.login_outlined, 'label': 'Absen Masuk', 'action': controller.goToAbsenMasuk},
      {'icon': Icons.logout_outlined, 'label': 'Absen Keluar', 'action': controller.goToAbsenKeluar},
      {'icon': Icons.calendar_today_outlined, 'label': 'Jadwal Presensi', 'action': controller.goToJadwalPresensi},
      {'icon': Icons.book_outlined, 'label': 'Daftar Mata Kuliah', 'action': controller.goToDaftarMatkul},
    ];

    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(), // Agar tidak scroll di dalam SingleChildScrollView
      crossAxisCount: 2,
      crossAxisSpacing: 16.0,
      mainAxisSpacing: 16.0,
      childAspectRatio: 1.1, // Sesuaikan rasio aspek kartu
      children: menuItems.map((item) {
        return _buildMenuItem(
          context,
          item['icon'] as IconData,
          item['label'] as String,
          item['action'] as VoidCallback,
        );
      }).toList(),
    );
  }

  Widget _buildMenuItem(BuildContext context, IconData icon, String label, VoidCallback onTap) {
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16.0),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Icon(icon, size: 36, color: Theme.of(context).primaryColor),
              const Spacer(),
              Text(
                label,
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEventSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: <Widget>[
        Text(
          'Info & Event Terbaru',
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: Theme.of(context).primaryColor,
          ),
        ),
        const SizedBox(height: 12.0),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          height: 150, // Tinggi placeholder event
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: Colors.grey[300]!)
            // boxShadow: [
            //   BoxShadow(
            //     color: Colors.grey.withOpacity(0.1),
            //     spreadRadius: 1,
            //     blurRadius: 5,
            //     offset: const Offset(0, 2),
            //   ),
            // ],
          ),
          child: Center(
            child: Text(
              'Belum ada event saat ini.',
              style: TextStyle(color: Colors.grey[600], fontSize: 15.0),
            ),
          ),
        ),
      ],
    );
  }
}

