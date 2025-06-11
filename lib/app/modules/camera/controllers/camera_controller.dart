import 'package:flutter/material.dart';
import 'package:get/get.dart';

class CameraController extends GetxController {
  // Variabel untuk menyimpan tipe absen ('Masuk' atau 'Keluar')
  late String absenType;

  //TODO: Implement CameraController

  final count = 0.obs;

  // Variabel untuk mengontrol state UI
  // false = Tampilan sebelum scan
  // true = Tampilan setelah scan
    var isPictureTaken = false.obs;

  @override
  void onInit() {
    super.onInit();
    // Mengambil argumen yang dikirim dari halaman sebelumnya
    final args = Get.arguments as Map<String, dynamic>?;
    absenType = args?['type'] ?? 'Tidak Diketahui'; // Default value jika argumen null
  }

  // Fungsi untuk mensimulasikan pengambilan gambar
  void takePicture() {
    print('Mengambil gambar...');
    isPictureTaken.value = true;
  }

  // Fungsi untuk kembali ke state awal
  void reset() {
    print('Mereset kamera...');
    isPictureTaken.value = false;
  }

  // Fungsi untuk jeda (placeholder)
  void pause() {
    print('Proses dijeda.');
    // Logika jeda bisa ditambahkan di sini
  }

  // Fungsi untuk menyimpan dan keluar
  void saveAndStop() {
    print('Menyimpan gambar untuk absen $absenType');
    // TODO: Implementasikan logika penyimpanan gambar atau pengiriman ke server di sini

    Get.back(); // Kembali ke halaman home

    // Tampilkan notifikasi sukses
    Get.snackbar(
      'Berhasil',
      'Anda telah berhasil melakukan absen $absenType.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.green,
      colorText: Colors.white,
      margin: const EdgeInsets.all(10),
    );
  }

  void increment() => count.value++;
}
