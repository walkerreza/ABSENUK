import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/introduction_controller.dart';

class IntroductionView extends GetView<IntroductionController> {
  const IntroductionView({super.key});

  @override
  Widget build(BuildContext context) {
    final double screenHeight = MediaQuery.of(context).size.height;
    final double screenWidth = MediaQuery.of(context).size.width;

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Color(0xFF31053B), // Ungu Sangat Gelap
            Color(0xFF881246), // Merah Gelap
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  const Spacer(flex: 2),
                  // Logo Aplikasi
                  Image.asset(
                    'assets/icon/ABSENUK.png',
                    height: 120,
                    width: 120,
                  ),
                  const SizedBox(height: 20),
                  // Nama Aplikasi
                  const Text(
                    'ABSENUK',
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      letterSpacing: 2,
                    ),
                  ),
                  const Spacer(flex: 3),
                  // Tombol Get Started dengan Efek Glassmorphism
                  ClipRRect(
                    borderRadius: BorderRadius.circular(30.0),
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        width: screenWidth * 0.8,
                        height: 55.0,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(30.0),
                          border: Border.all(
                            width: 1.5,
                            color: Colors.white.withOpacity(0.3),
                          ),
                        ),
                        child: TextButton.icon(
                          onPressed: controller.navigateToLogin,
                          icon: const Icon(
                            Icons.arrow_forward_ios,
                            size: 18.0,
                            color: Colors.white,
                          ),
                          label: const Text(
                            'Get Started',
                            style: TextStyle(
                              fontSize: 18.0,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: screenHeight * 0.05),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

