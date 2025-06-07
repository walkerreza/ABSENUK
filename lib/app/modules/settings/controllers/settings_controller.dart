import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:absenuk/app/routes/app_pages.dart'; // Untuk navigasi saat logout

class SettingsController extends GetxController {
  final GetStorage _storageBox = GetStorage();
  final String _themeKey = 'themeSetting';

  // Tema Aplikasi
  late Rx<ThemeMode> currentThemeMode;

  // Info Aplikasi
  RxString appVersion = ''.obs;

  @override
  void onInit() {
    super.onInit();
    _loadThemeSetting();
    _loadAppVersion();
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
        themeMode = ThemeMode.system;
    }
    currentThemeMode = themeMode.obs;
    // Tunda pemanggilan Get.changeThemeMode hingga setelah build selesai
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Get.changeThemeMode(themeMode);
    });
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

  // === Logout ===
  void logout() {
    // Di sini Anda bisa menambahkan logika pembersihan data sesi,
    // seperti menghapus token, data user dari GetStorage, dll.
    // Contoh:
    // _storageBox.remove('user_token');
    // _storageBox.remove('user_data');

    // Navigasi ke halaman login dan hapus semua halaman sebelumnya dari stack
    Get.offAllNamed(Routes.LOGIN); 
  }
}
