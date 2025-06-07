import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/introduction_controller.dart';

class IntroductionView extends GetView<IntroductionController> {
  const IntroductionView({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      // backgroundColor: Colors.grey[100], // Warna background lembut
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: <Widget>[
                // Spacer untuk mendorong konten sedikit ke bawah dari atas
                SizedBox(height: screenHeight * 0.1),

                // Ikon Aplikasi
                // Ganti dengan Icon(Icons.nama_icon_anda, size: 100, color: Colors.deepPurple) jika punya ikon spesifik
                const FlutterLogo(
                  size: 100,
                  // style: FlutterLogoStyle.stacked,
                  // textColor: Colors.deepPurple,
                ),
                const SizedBox(height: 32.0),

                // Teks Selamat Datang
                const Text(
                  'Selamat Datang di AbsenUK!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 26.0,
                    fontWeight: FontWeight.bold,
                    // color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 12.0),
                const Text(
                  'Aplikasi absensi modern untuk kebutuhan Anda.',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 16.0,
                    color: Colors.grey,
                  ),
                ),

                // Spacer untuk mendorong tombol ke bawah
                const Spacer(),

                // Tombol Get Started dengan Animasi
                TweenAnimationBuilder<double>(
                  tween: Tween<double>(begin: 0.95, end: 1.0),
                  duration: const Duration(milliseconds: 1500),
                  curve: Curves.elasticOut, // Contoh curve untuk efek 'bouncy'
                  builder: (context, scale, child) {
                    return Transform.scale(
                      scale: scale,
                      child: child,
                    );
                  },
                  child: SizedBox(
                    width: screenWidth * 0.8, // Lebar tombol responsif
                    height: 55.0,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.deepPurple, // Warna tombol ungu
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30.0), // Tombol lebih rounded
                        ),
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                      ),
                      onPressed: () {
                        // Tambahkan sedikit delay untuk efek sebelum navigasi jika diinginkan
                        // Future.delayed(const Duration(milliseconds: 200), () {
                        //   controller.navigateToLogin();
                        // });
                        controller.navigateToLogin();
                      },
                      icon: const Icon(
                        Icons.arrow_forward_ios, // Ikon panah kanan
                        color: Colors.white,
                        size: 18.0,
                      ),
                      label: const Text(
                        'Get Started',
                        style: TextStyle(
                          fontSize: 18.0,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      // Memastikan ikon ada di kanan:
                      // Bisa juga dengan Row di dalam label jika butuh kustomisasi lebih
                    ),
                  ),
                ),
                SizedBox(height: screenHeight * 0.05), // Jarak dari bawah
              ],
            ),
          ),
        ),
      ),
    );
  }
}

