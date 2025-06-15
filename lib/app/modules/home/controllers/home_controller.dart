import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../routes/app_pages.dart';
import '../info_model.dart';

class HomeController extends GetxController {
  // State untuk jam real-time
  var currentTime = ''.obs;
  Timer? _timer;

  // State untuk data pengguna
  final RxString userName = ''.obs;
  final RxString photoUrl = ''.obs;

  // State untuk Informasi & Acara
  final RxList<InfoModel> infoItems = <InfoModel>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool hasError = false.obs;
  final RxBool isLoadingMore = false.obs;
  final RxBool canLoadMore = true.obs;
  int currentPage = 1;

  @override
  void onInit() {
    super.onInit();
    _loadUserData();
    fetchInfoData();
    _startTimer(); // Memulai jam real-time
  }

  @override
  void onClose() {
    _timer?.cancel(); // Batalkan timer untuk mencegah memory leak
    super.onClose();
  }

  void _startTimer() {
    // Atur waktu awal saat pertama kali dijalankan
    _updateTime();
    // Perbarui waktu setiap detik
    _timer = Timer.periodic(const Duration(seconds: 1), (_) => _updateTime());
  }

  void _updateTime() {
    // Format tanggal dan waktu menggunakan package intl
    // Locale 'id_ID' sudah diatur di main.dart
    final formattedTime = DateFormat('EEEE, dd MMMM yyyy | HH:mm:ss', 'id_ID').format(DateTime.now());
    currentTime.value = formattedTime;
  }

  Future<void> fetchInfoData({bool isRefresh = false}) async {
    if (isRefresh) {
      currentPage = 1;
      infoItems.clear();
      canLoadMore.value = true;
    }

    try {
      isLoading(true);
      hasError(false);

      // Ambil 5 berita per halaman
      final response = await http.get(
        Uri.parse('https://akb.ac.id/wp-json/wp/v2/posts?_embed&per_page=5&page=$currentPage'),
      ).timeout(const Duration(seconds: 15)); // Timeout 15 detik

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<InfoModel> posts = data.map((post) => InfoModel.fromJson(post)).toList();
        if (posts.length < 5) {
          canLoadMore.value = false; // Tidak ada lagi data untuk dimuat
        }
        infoItems.addAll(posts);
      } else {
        hasError(true);
        Get.snackbar('Gagal Memuat', 'Server merespon dengan kode: ${response.statusCode}');
      }
    } catch (e) {
      hasError(true);
      Get.snackbar('Gagal Memuat', 'Terjadi kesalahan jaringan atau timeout.');
    } finally {
      isLoading(false);
    }
  }

  Future<void> fetchMoreInfoData() async {
    if (isLoadingMore.value || !canLoadMore.value) return;

    try {
      isLoadingMore(true);
      currentPage++;

      final response = await http.get(
        Uri.parse('https://akb.ac.id/wp-json/wp/v2/posts?_embed&per_page=5&page=$currentPage'),
      ).timeout(const Duration(seconds: 15));

      if (response.statusCode == 200) {
        final List<dynamic> data = json.decode(response.body);
        final List<InfoModel> posts = data.map((post) => InfoModel.fromJson(post)).toList();

        if (posts.isEmpty) {
          canLoadMore.value = false; // Sudah di akhir daftar
        } else {
          infoItems.addAll(posts);
        }
      } else {
        // Tidak menampilkan snackbar agar tidak mengganggu, cukup berhenti memuat
        canLoadMore.value = false;
      }
    } catch (e) {
      // Tidak menampilkan snackbar agar tidak mengganggu
    } finally {
      isLoadingMore(false);
    }
  }

  void showInfoPreview(InfoModel info) {
    Get.dialog(
      Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        insetPadding: const EdgeInsets.symmetric(horizontal: 24),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Gambar Header
                Image.network(
                  info.imageUrl,
                  height: 180,
                  width: double.infinity,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const SizedBox(
                    height: 180,
                    child: Center(child: Icon(Icons.broken_image, size: 48)),
                  ),
                ),
                // Konten Teks dan Tombol
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        info.title,
                        textAlign: TextAlign.center,
                        style: Get.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        info.description,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        textAlign: TextAlign.center,
                        style: Get.textTheme.bodyMedium,
                      ),
                      const SizedBox(height: 24),
                      // Tombol Aksi
                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton(
                              onPressed: () => Get.back(),
                              child: const Text('Tutup'),
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: ElevatedButton(
                              onPressed: () {
                                Get.back(); // Tutup dialog dulu
                                openLink(info.link);
                              },
                              child: const Text('Baca Selengkapnya'),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
      barrierDismissible: true,
    );
  }

  Future<void> openLink(String urlString) async {
    final Uri url = Uri.parse(urlString);
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      Get.snackbar(
        'Gagal Membuka Tautan',
        'Tidak dapat membuka $urlString',
        snackPosition: SnackPosition.BOTTOM,
      );
    }
  }

  void _loadUserData() {
    final box = GetStorage();
    final userData = box.read<Map<String, dynamic>>('user');
    if (userData != null) {
      userName.value = userData['name'] ?? 'Pengguna';
      photoUrl.value = userData['photoUrl'] ?? '';
    }
  }

  // Fungsi navigasi
  void goToProfile() {
    Get.toNamed(Routes.PROFILE); // Asumsi Routes.PROFILE sudah ada
  }

  void goToSettings() {
    Get.toNamed(Routes.SETTINGS);
  }

  void goToAbsenMasuk() {
    Get.toNamed(Routes.CAMERA, arguments: {'type': 'Masuk'});
  }

  void goToAbsenKeluar() {
    Get.toNamed(Routes.CAMERA, arguments: {'type': 'Keluar'});
  }

  void goToJadwalPresensi() {
    Get.toNamed(Routes.JADWAL); // Menggunakan konstanta rute yang sudah ada
  }

  void goToDaftarMatkul() {
    Get.toNamed(Routes.DAFTAR_MATKUL);
  }

  void goToTools() {
    Get.toNamed(Routes.TOOLS);
  }

  // final count = 0.obs; // Hapus atau komentari jika tidak digunakan
  // void increment() => count.value++; // Hapus atau komentari jika tidak digunakan
}
