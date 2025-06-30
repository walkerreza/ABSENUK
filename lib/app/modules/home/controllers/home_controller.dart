import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'dart:async';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:absenuk/app/data/providers/api.dart';
import '../../../routes/app_pages.dart';
import '../info_model.dart';
import 'package:absenuk/app/modules/profile/controllers/profile_controller.dart';

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
    _syncAndLoadUserData(); // Memanggil fungsi baru
    fetchInfoData();
    _startTimer(); // Memulai jam real-time
  }

  Future<void> _syncAndLoadUserData() async {
    // Pertama, coba sinkronkan data dari server secara diam-diam.
    try {
      // Kita perlu instance dari ProfileController untuk memanggil fungsi sinkronisasi.
      // Get.put() akan membuat instance baru jika belum ada, atau menemukan yang sudah ada.
      final profileController = Get.put(ProfileController());
      await profileController.syncProfileDataFromServer();
    } catch (e) {
      debugPrint('Error during background sync: $e');
      // Tidak perlu menampilkan error ke pengguna, ini proses latar belakang.
    }

    // Kedua, setelah sinkronisasi (atau jika gagal), muat data dari penyimpanan lokal.
    fetchUserProfile();
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
      print('Home Controller Error: $e'); // Menampilkan error detail di console
      // Tangani error koneksi atau timeout di sini
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

  Future<void> fetchUserProfile() async {
    final box = GetStorage();
    final token = box.read<String>('token');

    // Tampilkan data dari storage dulu untuk UI yang responsif
    final storedUser = box.read<Map<String, dynamic>>('user');
    if (storedUser != null) {
      // Gunakan key yang benar ('nama' dan 'image') sesuai dengan struktur data API
      userName.value = storedUser['nama'] ?? 'Pengguna';
      final storedImageUrl = storedUser['image'] ?? '';
      if (storedImageUrl.isNotEmpty && !storedImageUrl.startsWith('http')) {
        final baseUrl = Api.baseUrl.replaceAll('/api', '');
        photoUrl.value = '$baseUrl$storedImageUrl';
      } else {
        photoUrl.value = storedImageUrl;
      }
    }

    final nim = box.read<String>('nim');

    if (token == null || nim == null) {
      // Jika token atau NIM tidak ada, sesi tidak lengkap. Arahkan ke login.
      Get.offAllNamed(Routes.LOGIN);
      return;
    }

    try {
      // Menggunakan endpoint yang benar sesuai dokumentasi Postman
      final response = await http.get(
        Uri.parse('${Api.baseUrl}/mahasiswa/nim/$nim'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final responseData = json.decode(response.body);
        // Berdasarkan Postman terbaru, data adalah objek tunggal.
        final newUserData = responseData['data'] as Map<String, dynamic>?;
        if (newUserData != null) {
          // Perbarui data di UI dan storage
          userName.value = newUserData['nama'] ?? 'Pengguna';
          final newImageUrl = newUserData['image'] ?? '';
          // Simpan data mentah di storage, tapi bangun URL absolut untuk UI
          box.write('user', newUserData);

          if (newImageUrl.isNotEmpty && !newImageUrl.startsWith('http')) {
            final baseUrl = Api.baseUrl.replaceAll('/api', '');
            photoUrl.value = '$baseUrl$newImageUrl';
          } else {
            photoUrl.value = newImageUrl;
          }
        }
      } else if (response.statusCode == 401) {
        // Token tidak valid atau kedaluwarsa, hapus sesi dan arahkan ke login
        box.erase();
        Get.offAllNamed(Routes.LOGIN);
        Get.snackbar('Sesi Berakhir', 'Silakan login kembali.');
      }
      // Error lain bisa ditangani di sini jika perlu

    } catch (e) {
      // Tidak menampilkan snackbar agar tidak mengganggu jika hanya gagal fetch update
      print('Gagal mengambil profil terbaru: $e');
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
