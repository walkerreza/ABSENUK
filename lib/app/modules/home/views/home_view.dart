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
      body: Stack(
        children: [
          // Elemen Dekoratif di Pojok Kiri Atas
          Positioned(
            top: -50,
            left: -50,
            child: Container(
              width: 200,
              height: 200,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  // Header Kustom
                  _buildHeader(context, controller),
                  const SizedBox(height: 24.0),

                  // Placeholder Logo Institusi
                  _buildLogoPlaceholder(context),
                  const SizedBox(height: 24.0),

                  // Grid Menu
                  _buildMenuGrid(context, controller),
                  const SizedBox(height: 24.0),

                  // Bagian Event (Placeholder)
                  _buildEventSection(context),
                  const SizedBox(height: 20.0),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, HomeController controller) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: <Widget>[
        Obx(() => Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Selamat Datang,',
                  style: TextStyle(
                    fontSize: 18.0,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.7),
                  ),
                ),
                Text(
                  controller.userName.value,
                  style: TextStyle(
                    fontSize: 24.0,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).primaryColor,
                  ),
                ),
              ],
            )),
        Row(
          children: <Widget>[
            IconButton(
              // Warna ikon akan diambil dari IconTheme global atau bisa diset eksplisit
              icon: Icon(Icons.person_outline, size: 28 /* color: Theme.of(context).primaryColor */),
              onPressed: controller.goToProfile,
              tooltip: 'Profil',
            ),
            IconButton(
              icon: Icon(Icons.settings_outlined, size: 28 /* color: Theme.of(context).primaryColor */),
              onPressed: controller.goToSettings,
              tooltip: 'Pengaturan',
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildLogoPlaceholder(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20.0, horizontal: 16.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor, // Menggunakan cardColor atau colorScheme.surface
        borderRadius: BorderRadius.circular(12.0),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 5,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Ganti dengan Image.asset jika punya logo
          Icon(Icons.school_outlined, size: 40, color: Theme.of(context).primaryColor),
          const SizedBox(width: 12.0),
          Flexible(
            child: Text(
              'Akademi Komunitas Negeri\nPutra Sang Fajar Blitar',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16.0,
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.onSurface, // Warna teks di atas surface/card
              ),
            ),
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
      childAspectRatio: 1.2, // Sesuaikan rasio aspek kartu
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
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12.0),
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor, // Menggunakan cardColor atau colorScheme.surface
          borderRadius: BorderRadius.circular(12.0),
          boxShadow: [
            BoxShadow(
              color: Colors.grey.withOpacity(0.15),
              spreadRadius: 1,
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Icon(icon, size: 40.0, color: Theme.of(context).primaryColor), // Ikon menggunakan primaryColor dari tema
            const SizedBox(height: 12.0),
            Text(
              label,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).colorScheme.onSurface, // Warna teks di atas surface/card
              ),
            ),
          ],
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

