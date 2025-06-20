import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:absenuk/app/routes/app_pages.dart'; // Untuk navigasi saat logout
import 'package:url_launcher/url_launcher.dart';
import 'package:absenuk/app/services/notification_service.dart';

class SettingsController extends GetxController {
  final GetStorage _storageBox = GetStorage();
  final String _themeKey = 'themeSetting';
  final String _reminderKey = 'reminderSetting';

  // Services
  final NotificationService _notificationService = NotificationService();

  // Tema Aplikasi
  late Rx<ThemeMode> currentThemeMode;
  late RxBool isReminderEnabled;

  // Info Aplikasi
  RxString appVersion = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadThemeSetting();
    _loadAppVersion();
    _loadReminderSetting();
  }

  // === Tema Aplikasi ===
  void _loadThemeSetting() {
    final storedTheme = _storageBox.read<String>(_themeKey);
    ThemeMode themeMode;
    switch (storedTheme) {
      case 'light':
        themeMode = ThemeMode.light;
        break;
      case 'dark':
        themeMode = ThemeMode.dark;
        break;
      default:
        themeMode = ThemeMode.system; // Default ke tema sistem
    }
    // Inisialisasi state controller dengan nilai dari storage,
    // tanpa memaksa perubahan tema pada seluruh aplikasi.
    currentThemeMode = themeMode.obs;
  }

  void _loadReminderSetting() {
    // Defaultnya false (tidak aktif)
    isReminderEnabled = (_storageBox.read<bool>(_reminderKey) ?? false).obs;
  }

  Future<void> toggleReminder(bool value) async {
    if (isReminderEnabled.value == value) return;

    isReminderEnabled.value = value;
    _storageBox.write(_reminderKey, value);

    if (value) {
      // Jika diaktifkan
      await _notificationService.requestPermission();
      await _notificationService.scheduleDailyReminders();
      Get.snackbar(
        'Pengingat Diaktifkan',
        'Anda akan diingatkan untuk absen pagi (08:00) dan siang (13:00).',
        snackPosition: SnackPosition.BOTTOM,
      );
    } else {
      // Jika dinonaktifkan
      await _notificationService.cancelAllNotifications();
      Get.snackbar(
        'Pengingat Dinonaktifkan',
        'Anda tidak akan lagi menerima pengingat absen.',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void changeTheme(ThemeMode? newThemeMode) {
    if (newThemeMode == null) return;
    if (currentThemeMode.value == newThemeMode) return;

    currentThemeMode.value = newThemeMode;
    Get.changeThemeMode(newThemeMode);

    String themeString;
    switch (newThemeMode) {
      case ThemeMode.light:
        themeString = 'light';
        break;
      case ThemeMode.dark:
        themeString = 'dark';
        break;
      case ThemeMode.system:
        themeString = 'system';
        break;
      // default clause removed as all ThemeMode enum values are covered
    }
    _storageBox.write(_themeKey, themeString);
  }

  // === Info Aplikasi ===
  Future<void> _loadAppVersion() async {
    try {
      PackageInfo packageInfo = await PackageInfo.fromPlatform();
      appVersion.value = 'Versi ${packageInfo.version} (${packageInfo.buildNumber})';
    } catch (e) {
      appVersion.value = 'Tidak dapat memuat versi';
      print('Error loading app version: $e');
    }
  }

  // === Pintasan Kampus ===
  Future<void> launchURL(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      Get.snackbar(
        'Gagal Membuka Tautan',
        'Tidak dapat membuka $urlString',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  // === Logout ===
  void logout() {
    // Hapus semua data sesi dari GetStorage untuk memastikan logout bersih.
    _storageBox.remove('user');
    _storageBox.remove('token');
    _storageBox.remove('isLoggedIn');

    // Navigasi ke halaman login dan hapus semua halaman sebelumnya dari stack.
    Get.offAllNamed(Routes.LOGIN); 
  }
}
