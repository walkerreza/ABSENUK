import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/settings_controller.dart';

class SettingsView extends GetView<SettingsController> {
  const SettingsView({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor;
    // final SettingsController controller = Get.find(); // Controller sudah di-inject oleh GetView

    return Scaffold(
      appBar: AppBar(
        title: const Text('Pengaturan'),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(vertical: 16.0),
        children: <Widget>[
          // Pengaturan Tema
          _buildSectionTitle(context, 'Tampilan'),
          Obx(() => RadioListTile<ThemeMode>(
                title: const Text('Mode Terang'),
                value: ThemeMode.light,
                groupValue: controller.currentThemeMode.value,
                onChanged: controller.changeTheme,
                activeColor: primaryColor,
              )),
          Obx(() => RadioListTile<ThemeMode>(
                title: const Text('Mode Gelap'),
                value: ThemeMode.dark,
                groupValue: controller.currentThemeMode.value,
                onChanged: controller.changeTheme,
                activeColor: primaryColor,
              )),
          Obx(() => RadioListTile<ThemeMode>(
                title: const Text('Sesuai Sistem'),
                value: ThemeMode.system,
                groupValue: controller.currentThemeMode.value,
                onChanged: controller.changeTheme,
                activeColor: primaryColor,
              )),
          const Divider(height: 32, indent: 16, endIndent: 16),

          // Notifikasi
          _buildSectionTitle(context, 'Notifikasi'),
          Obx(() => SwitchListTile(
                title: const Text('Pengingat Absen Harian'),
                subtitle: const Text('Pagi (08:00) dan Siang (13:00)'),
                value: controller.isReminderEnabled.value,
                onChanged: controller.toggleReminder,
                activeColor: primaryColor,
              )),

          // Pintasan Kampus
          _buildSectionTitle(context, 'Pintasan Kampus'),
          ListTile(
            leading: Icon(Icons.public, color: primaryColor),
            title: const Text('Portal Kampus'),
            subtitle: const Text('https://akb.ac.id/'),
            onTap: () => controller.launchURL('https://akb.ac.id/'),
          ),
          ListTile(
            leading: Icon(Icons.school, color: primaryColor),
            title: const Text('Sistem Informasi Akademik'),
            subtitle: const Text('https://student.akb.ac.id/'),
            onTap: () => controller.launchURL('https://student.akb.ac.id/'),
          ),
          ListTile(
            leading: Icon(Icons.book, color: primaryColor),
            title: const Text('LMS'),
            subtitle: const Text('https://lms.akb.ac.id/'),
            onTap: () => controller.launchURL('https://lms.akb.ac.id/'),
          ),
          const Divider(height: 32, indent: 16, endIndent: 16),

          // Pengaturan Akun
          _buildSectionTitle(context, 'Akun'),
          ListTile(
            leading: Icon(Icons.logout, color: Theme.of(context).colorScheme.error),
            title: Text('Logout', style: TextStyle(color: Theme.of(context).colorScheme.error)),
            onTap: () {
              _showLogoutConfirmationDialog(context, controller, primaryColor);
            },
          ),
          const Divider(height: 32, indent: 16, endIndent: 16),

          // Tentang Aplikasi
          _buildSectionTitle(context, 'Tentang Aplikasi'),
          Obx(() => ListTile(
                leading: const Icon(Icons.info_outline),
                title: const Text('Versi Aplikasi'),
                subtitle: Text(controller.appVersion.value.isNotEmpty 
                                ? controller.appVersion.value 
                                : 'Memuat...'),
                onTap: () {}, // Bisa ditambahkan aksi jika diperlukan
              )),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(
        title.toUpperCase(),
        style: TextStyle(
          fontWeight: FontWeight.bold,
          color: Theme.of(context).colorScheme.primary, // Menggunakan warna dari ColorScheme
          fontSize: 14,
        ),
      ),
    );
  }

  void _showLogoutConfirmationDialog(BuildContext context, SettingsController controller, Color primaryColor) {
    Get.defaultDialog(
      title: 'Konfirmasi Logout',
      titleStyle: TextStyle(color: primaryColor, fontWeight: FontWeight.bold),
      middleText: 'Apakah Anda yakin ingin keluar dari akun ini?',
      middleTextStyle: const TextStyle(fontSize: 16),
      confirm: ElevatedButton(
        style: ElevatedButton.styleFrom(backgroundColor: primaryColor),
        onPressed: () {
          Get.back(); // Tutup dialog
          controller.logout();
        },
        child: const Text('Logout', style: TextStyle(color: Colors.white)),
      ),
      cancel: OutlinedButton(
        onPressed: () => Get.back(), // Tutup dialog
        child: Text('Batal', style: TextStyle(color: primaryColor)),
      ),
      radius: 8.0,
    );
  }
}
