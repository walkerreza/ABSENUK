import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shimmer/shimmer.dart';
import '../controllers/home_controller.dart';
import '../info_model.dart';

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
              const SizedBox(height: 24.0),
              _buildToolsButton(context, controller),
              const SizedBox(height: 24.0),

              // Judul Bagian Event
              Text(
                'Informasi & Acara',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16.0),

              // Bagian Event (Dinamis)
              _buildEventSection(context, controller),
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
                    const SizedBox(height: 8),
                    Obx(() => Text(
                          controller.currentTime.value,
                          style: TextStyle(
                            fontSize: 14.0,
                            color: Colors.white.withOpacity(0.8),
                            fontWeight: FontWeight.w500,
                          ),
                        )),
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
      {'icon': Icons.logout_outlined, 'label': 'Absen Pulang', 'action': controller.goToAbsenKeluar},
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

  Widget _buildEventSection(BuildContext context, HomeController controller) {
    return Obx(() {
      if (controller.isLoading.value) {
        return _buildShimmerEffect();
      }

      if (controller.hasError.value) {
        return SizedBox(
          height: 220,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, color: Colors.red, size: 48),
                const SizedBox(height: 16),
                const Text('Gagal memuat informasi.', style: TextStyle(fontSize: 16)),
                const SizedBox(height: 8),
                ElevatedButton(
                  onPressed: () => controller.fetchInfoData(isRefresh: true),
                  child: const Text('Coba Lagi'),
                ),
              ],
            ),
          ),
        );
      }

      if (controller.infoItems.isEmpty) {
        return Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16.0),
          height: 150,
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12.0),
            border: Border.all(color: Theme.of(context).dividerColor),
          ),
          child: Center(
            child: Text(
              'Tidak ada informasi & acara saat ini.',
              style: TextStyle(color: Theme.of(context).textTheme.bodySmall?.color, fontSize: 15.0),
            ),
          ),
        );
      }

      return SizedBox(
        height: 220,
        child: ListView.builder(
          scrollDirection: Axis.horizontal,
          itemCount: controller.canLoadMore.value
              ? controller.infoItems.length + 1
              : controller.infoItems.length,
          itemBuilder: (context, index) {
            if (index < controller.infoItems.length) {
              final info = controller.infoItems[index];
              return _buildInfoCard(context, controller, info);
            } else {
              return _buildLoadMoreCard(context, controller);
            }
          },
        ),
      );
    });
  }

  Widget _buildInfoCard(BuildContext context, HomeController controller, InfoModel info) {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16.0),
      child: Card(
        elevation: 3.0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: InkWell(
          onTap: () => controller.showInfoPreview(info),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: 120,
                width: double.infinity,
                child: Image.network(
                  info.imageUrl,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return Center(
                      child: CircularProgressIndicator(
                        value: loadingProgress.expectedTotalBytes != null
                            ? loadingProgress.cumulativeBytesLoaded /
                                loadingProgress.expectedTotalBytes!
                            : null,
                      ),
                    );
                  },
                  errorBuilder: (context, error, stackTrace) {
                    return const Center(
                      child: Icon(Icons.broken_image, size: 40),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info.title,
                      style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 4.0),
                    Text(
                      info.date,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadMoreCard(BuildContext context, HomeController controller) {
    return Obx(() {
      return Container(
        width: 150,
        margin: const EdgeInsets.only(right: 16.0),
        child: Card(
          elevation: 3.0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12.0),
          ),
          child: InkWell(
            onTap: controller.isLoadingMore.value ? null : controller.fetchMoreInfoData,
            borderRadius: BorderRadius.circular(12.0),
            child: Center(
              child: controller.isLoadingMore.value
                  ? const CircularProgressIndicator()
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.arrow_forward_ios,
                          color: Theme.of(context).primaryColor,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          'Lihat Lainnya',
                          style: TextStyle(
                            color: Theme.of(context).primaryColor,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      );
    });
  }

  // Widget untuk efek shimmer loading
  Widget _buildShimmerEffect() {
    return Shimmer.fromColors(
      baseColor: Colors.grey[300]!,
      highlightColor: Colors.grey[100]!,
      child: SizedBox(
        height: 220,
        child: ListView.builder(
          physics: const NeverScrollableScrollPhysics(), // Disable scroll
          scrollDirection: Axis.horizontal,
          itemCount: 2, // Tampilkan 2 placeholder
          itemBuilder: (context, index) {
            return _buildShimmerPlaceholder();
          },
        ),
      ),
    );
  }

  // Widget untuk satu kartu placeholder shimmer
  Widget _buildShimmerPlaceholder() {
    return Container(
      width: 280,
      margin: const EdgeInsets.only(right: 16.0),
      child: Card(
        elevation: 3.0,
        clipBehavior: Clip.antiAlias,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Placeholder untuk gambar
            Container(
              height: 120,
              width: double.infinity,
              color: Colors.white, // Warna dasar shimmer
            ),
            // Placeholder untuk teks
            Padding(
              padding: const EdgeInsets.all(12.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 18, // Kira-kira setinggi text titleMedium
                    width: 220,
                    decoration: BoxDecoration(
                        color: Colors.white, borderRadius: BorderRadius.circular(4)),
                  ),
                  const SizedBox(height: 6.0),
                  Container(
                    height: 14, // Kira-kira setinggi text bodySmall
                    width: 100,
                    decoration: BoxDecoration(
                        color: Colors.white, borderRadius: BorderRadius.circular(4)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildToolsButton(BuildContext context, HomeController controller) {
    return GestureDetector(
      onTap: () => controller.goToTools(),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(12.0),
          border: Border.all(color: Theme.of(context).dividerColor),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(
              Icons.construction, // Ikon palu dan kunci pas
              color: Theme.of(context).colorScheme.primary,
              size: 28,
            ),
            const SizedBox(width: 16.0),
            Expanded(
              child: Text(
                'Peralatan Mahasiswa',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey),
          ],
        ),
      ),
    );
  }
}

