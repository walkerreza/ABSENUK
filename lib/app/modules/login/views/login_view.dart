import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/login_controller.dart';

class LoginView extends GetView<LoginController> {
  const LoginView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Menggunakan backgroundColor untuk tema gelap sederhana jika diinginkan
      // backgroundColor: Colors.grey[900],
      appBar: AppBar(
        title: const Text('Login Aplikasi'),
        centerTitle: true,
        // elevation: 0, // Menghilangkan shadow jika diinginkan
        // backgroundColor: Colors.deepPurple, // Contoh warna AppBar
      ),
      body: SingleChildScrollView(
        // Memastikan konten bisa di-scroll
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 32.0),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 500), // Batas lebar maksimum untuk tablet/web
            child: Form(
              key: controller.formKey,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  // Logo atau Judul Aplikasi (Opsional)
                  const FlutterLogo(
                    size: 80,
                  ),
                  const SizedBox(height: 24.0),
                  const Text(
                    'Selamat Datang Kembali!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 24.0,
                      fontWeight: FontWeight.bold,
                      // color: Colors.white, // Jika background gelap
                    ),
                  ),
                  const SizedBox(height: 8.0),
                  const Text(
                    'Silakan masuk untuk melanjutkan.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 16.0,
                      color: Colors.grey,
                    ),
                  ),
                  const SizedBox(height: 32.0),

                  // Email TextFormField
                  TextFormField(
                    controller: controller.emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: 'Email',
                      hintText: 'Masukkan email Anda',
                      prefixIcon: const Icon(Icons.email_outlined),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12.0),
                      ),
                      filled: true,
                      // fillColor: Colors.grey[800], // Jika background gelap
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Email tidak boleh kosong';
                      }
                      if (!GetUtils.isEmail(value)) {
                        return 'Format email tidak valid';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16.0),

                  // Password TextFormField
                  Obx(() => TextFormField(
                        controller: controller.passwordController,
                        obscureText: controller.obscureText.value,
                        decoration: InputDecoration(
                          labelText: 'Password',
                          hintText: 'Masukkan password Anda',
                          prefixIcon: const Icon(Icons.lock_outline),
                          suffixIcon: IconButton(
                            icon: Icon(
                              controller.obscureText.value
                                  ? Icons.visibility_off_outlined
                                  : Icons.visibility_outlined,
                            ),
                            onPressed: controller.toggleObscureText,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12.0),
                          ),
                          filled: true,
                          // fillColor: Colors.grey[800], // Jika background gelap
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Password tidak boleh kosong';
                          }
                          if (value.length < 6) {
                            return 'Password minimal 6 karakter';
                          }
                          return null;
                        },
                      )),
                  const SizedBox(height: 24.0),

                  // Login Button
                  Obx(() => SizedBox(
                        height: 50.0, // Tinggi tombol
                        child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.deepPurple, // Warna tombol ungu
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12.0),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 14.0),
                          ),
                          onPressed: controller.isLoading.value ? null : controller.login,
                          child: controller.isLoading.value
                              ? const SizedBox(
                                  height: 20, // Ukuran spinner
                                  width: 20,
                                  child: CircularProgressIndicator(
                                    color: Colors.white,
                                    strokeWidth: 2.0,
                                  ),
                                )
                              : const Text(
                                  'Login',
                                  style: TextStyle(
                                    fontSize: 16.0,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      )),
                  const SizedBox(height: 16.0),

                  // Lupa Password (Opsional)
                  // TextButton(
                  //   onPressed: () {
                  //     // TODO: Implementasi logika lupa password
                  //     Get.snackbar('Fitur', 'Lupa password belum diimplementasikan');
                  //   },
                  //   child: const Text(
                  //     'Lupa Password?',
                  //     style: TextStyle(color: Colors.deepPurple),
                  //   ),
                  // ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
