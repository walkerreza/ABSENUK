import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:get_storage/get_storage.dart';

import 'app/routes/app_pages.dart';
import 'package:absenuk/app/services/notification_service.dart';

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

void main() async { 
  WidgetsFlutterBinding.ensureInitialized(); 
  await initializeDateFormatting('id_ID', null); 
  await GetStorage.init();

  // Inisialisasi Notification Service saat aplikasi dimulai
  await NotificationService().init(); 

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
      debugShowCheckedModeBanner: false,

      // Tema Terang (Light Mode)
      theme: ThemeData(
        brightness: Brightness.light,
        primarySwatch: Colors.purple,
        primaryColor: const Color(0xFF8E2DE2),
        colorScheme: const ColorScheme.light(
          primary: Color(0xFF8E2DE2),      // Ungu Modern
          secondary: Color(0xFFdd2476),  // Merah Modern
          surface: Colors.white,
          error: Colors.red,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.black87,
          onError: Colors.white,
        ),
        scaffoldBackgroundColor: Colors.grey[100],
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF8E2DE2),
          foregroundColor: Colors.white,
          elevation: 4.0,
        ),
        buttonTheme: const ButtonThemeData(
          buttonColor: Color(0xFF8E2DE2),
          textTheme: ButtonTextTheme.primary,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFF8E2DE2),
            foregroundColor: Colors.white,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFF8E2DE2),
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFF8E2DE2),
        ),
        textTheme: applyCustomTextStyle(
          ThemeData.light().textTheme,
          const TextStyle(shadows: lightTextOutlineShadows),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.black.withOpacity(0.04),
          contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: const Color(0xFF8E2DE2), width: 2.0),
          ),
          labelStyle: TextStyle(color: Colors.grey[700]),
        ),
      ),

      // Tema Gelap (Dark Mode)
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primarySwatch: Colors.purple,
        primaryColor: const Color(0xFFa531f2),
        colorScheme: ColorScheme.dark(
          primary: const Color(0xFFa531f2),      // Ungu lebih terang untuk mode gelap
          secondary: const Color(0xFFdd2476),    // Merah tetap cerah untuk aksen
          surface: Colors.grey[800]!,
          error: Colors.redAccent,
          onPrimary: Colors.white,
          onSecondary: Colors.white,
          onSurface: Colors.white70,
          onError: Colors.black,
        ),
        scaffoldBackgroundColor: Colors.grey[900],
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.grey[850],
          foregroundColor: Colors.white,
          elevation: 4.0,
        ),
        buttonTheme: const ButtonThemeData(
          buttonColor: Color(0xFFa531f2),
          textTheme: ButtonTextTheme.primary,
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xFFa531f2),
            foregroundColor: Colors.white,
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: const Color(0xFFa531f2),
          ),
        ),
        iconTheme: const IconThemeData(
          color: Color(0xFFa531f2),
        ),
        textTheme: applyCustomTextStyle(
          ThemeData.dark().textTheme,
          const TextStyle(color: Colors.white, shadows: darkTextOutlineShadows),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white.withOpacity(0.06),
          contentPadding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide(color: const Color(0xFFa531f2), width: 2.0),
          ),
          labelStyle: TextStyle(color: Colors.grey[400]),
        ),
      ),

      // ThemeMode akan diatur oleh SettingsController melalui Get.changeThemeMode()
      // GetMaterialApp akan mendengarkan perubahan ini secara otomatis.
      // Anda bisa set themeMode awal dari GetStorage di sini jika mau, tapi SettingsController sudah melakukannya.
      // themeMode: settingsController.currentThemeMode.value, 
    ),
  );
}
