import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:get_storage/get_storage.dart'; // Import GetStorage

import 'app/routes/app_pages.dart';

// --- Konfigurasi Font Outline ---
// Untuk outline di tema gelap (teks putih, outline hitam tipis)
const List<Shadow> darkTextOutlineShadows = [
  Shadow(offset: Offset(-0.5, -0.5), color: Colors.black54),
  Shadow(offset: Offset(0.5, -0.5), color: Colors.black54),
  Shadow(offset: Offset(-0.5, 0.5), color: Colors.black54),
  Shadow(offset: Offset(0.5, 0.5), color: Colors.black54),
];

// Untuk outline di tema terang (teks default/hitam, outline putih/abu-abu sangat tipis)
const List<Shadow> lightTextOutlineShadows = [
  Shadow(offset: Offset(-0.5, -0.5), color: Color(0x33FFFFFF)), // Putih lebih transparan
  Shadow(offset: Offset(0.5, -0.5), color: Color(0x33FFFFFF)),
  Shadow(offset: Offset(-0.5, 0.5), color: Color(0x33FFFFFF)),
  Shadow(offset: Offset(0.5, 0.5), color: Color(0x33FFFFFF)),
];

// Fungsi helper untuk menerapkan TextStyle kustom ke TextTheme
TextTheme applyCustomTextStyle(TextTheme base, TextStyle styleWithShadowAndColor) {
  return base.copyWith(
    displayLarge: base.displayLarge?.merge(styleWithShadowAndColor),
    displayMedium: base.displayMedium?.merge(styleWithShadowAndColor),
    displaySmall: base.displaySmall?.merge(styleWithShadowAndColor),
    headlineLarge: base.headlineLarge?.merge(styleWithShadowAndColor),
    headlineMedium: base.headlineMedium?.merge(styleWithShadowAndColor),
    headlineSmall: base.headlineSmall?.merge(styleWithShadowAndColor),
    titleLarge: base.titleLarge?.merge(styleWithShadowAndColor),
    titleMedium: base.titleMedium?.merge(styleWithShadowAndColor),
    titleSmall: base.titleSmall?.merge(styleWithShadowAndColor),
    bodyLarge: base.bodyLarge?.merge(styleWithShadowAndColor),
    bodyMedium: base.bodyMedium?.merge(styleWithShadowAndColor),
    bodySmall: base.bodySmall?.merge(styleWithShadowAndColor),
    labelLarge: base.labelLarge?.merge(styleWithShadowAndColor),
    labelMedium: base.labelMedium?.merge(styleWithShadowAndColor),
    labelSmall: base.labelSmall?.merge(styleWithShadowAndColor),
  );
}
// --- Akhir Konfigurasi Font Outline ---

void main() async { // Ubah menjadi async
  WidgetsFlutterBinding.ensureInitialized(); // Pastikan binding Flutter siap
  await initializeDateFormatting('id_ID', null); // Inisialisasi untuk locale Indonesia
  await GetStorage.init(); // Inisialisasi GetStorage

  // Ambil instance SettingsController untuk mendapatkan themeMode awal
  // Ini perlu dilakukan setelah GetStorage.init() dan sebelum runApp
  // Kita akan inject SettingsController secara manual di sini jika belum ada
  // atau kita bisa mengandalkan GetMaterialApp untuk mengambilnya dari binding
  // Untuk kesederhanaan, kita akan membiarkan GetMaterialApp mengambilnya dari binding
  // saat SettingsPage pertama kali dibuka atau controller diakses.
  // GetMaterialApp akan menggunakan ThemeMode.system secara default jika tidak ada yang disimpan.

  runApp(
    GetMaterialApp(
      title: "Application",
      initialRoute: AppPages.INITIAL,
      getPages: AppPages.routes,
      locale: const Locale('id', 'ID'),
      fallbackLocale: const Locale('en', 'US'),

      // Tema Terang (Light Mode)
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.deepPurple, // Warna utama untuk komponen seperti AppBar, FloatingActionButton
        primaryColor: Colors.deepPurple, // Warna utama spesifik
        // accentColor: Colors.purpleAccent, // (deprecated, gunakan colorScheme.secondary)
        colorScheme: ColorScheme.light(
          primary: Colors.deepPurple,      // Warna utama
          secondary: Colors.purpleAccent,  // Warna aksen
          surface: Colors.white,   // Warna background Scaffold
          error: Colors.red,               // Warna untuk error
          onPrimary: Colors.white,         // Warna teks/ikon di atas warna primer
          onSecondary: Colors.white,       // Warna teks/ikon di atas warna sekunder
          onSurface: Colors.black87,    // Warna teks/ikon di atas warna background
          onError: Colors.white,           // Warna teks/ikon di atas warna error
        ),
        scaffoldBackgroundColor: Colors.grey[100], // Background utama aplikasi
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.deepPurple, // Warna AppBar
          foregroundColor: Colors.white,      // Warna teks dan ikon di AppBar
          elevation: 4.0,
        ),
        buttonTheme: const ButtonThemeData(
          buttonColor: Colors.deepPurple,    // Warna default tombol
          textTheme: ButtonTextTheme.primary,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.deepPurple, 
          ),
        ),
        iconTheme: const IconThemeData(
          color: Colors.deepPurple, // Warna default ikon
        ),
        textTheme: applyCustomTextStyle(
          ThemeData.light().textTheme, // Ambil TextTheme default terang
          const TextStyle(shadows: lightTextOutlineShadows), // Warna default, hanya tambah outline
        ),
      ),

      // Tema Gelap (Dark Mode)
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.deepPurple, // Bisa sama atau beda dengan light mode
        primaryColor: Colors.deepPurple[300], // Warna utama lebih terang untuk kontras di mode gelap
        // accentColor: Colors.purpleAccent[100], // (deprecated)
        colorScheme: ColorScheme.dark(
          primary: Colors.deepPurple[300]!,    // Warna utama (lebih terang)
          secondary: Colors.purpleAccent[100]!,// Warna aksen (lebih terang)
          surface: Colors.grey[800]!,         // Warna background Scaffold
          error: Colors.redAccent,
          onPrimary: Colors.black,           // Warna teks/ikon di atas warna primer
          onSecondary: Colors.black,         // Warna teks/ikon di atas warna sekunder
          onSurface: Colors.white70,      // Warna teks/ikon di atas warna background
          onError: Colors.black,
        ),
        scaffoldBackgroundColor: Colors.grey[900], // Background utama aplikasi
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[850], // Warna AppBar lebih gelap
          foregroundColor: Colors.white,     // Warna teks dan ikon di AppBar
          elevation: 4.0,
        ),
        buttonTheme: ButtonThemeData(
          buttonColor: Colors.deepPurple[300], 
          textTheme: ButtonTextTheme.primary,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.deepPurple[300],
            foregroundColor: Colors.black,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: Colors.deepPurple[300], 
          ),
        ),
        iconTheme: IconThemeData(
          color: Colors.deepPurple[300], // Warna default ikon
        ),
        textTheme: applyCustomTextStyle(
          ThemeData.dark().textTheme, // Ambil TextTheme default gelap
          TextStyle(color: Colors.white, shadows: darkTextOutlineShadows), // Warna putih dengan outline
        ),
      ),

      // ThemeMode akan diatur oleh SettingsController melalui Get.changeThemeMode()
      // GetMaterialApp akan mendengarkan perubahan ini secara otomatis.
      // Anda bisa set themeMode awal dari GetStorage di sini jika mau, tapi SettingsController sudah melakukannya.
      // themeMode: settingsController.currentThemeMode.value, 
    ),
  );
}
