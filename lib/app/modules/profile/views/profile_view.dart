import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/profile_controller.dart';

class ProfileView extends GetView<ProfileController> {
  const ProfileView({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Colors.deepPurple; // Sesuaikan dengan tema aplikasi

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profil Saya'),
        backgroundColor: primaryColor,
        elevation: 0,
      ),
      body: Form(
        // key: controller.formKey, // Jika Anda menambahkan GlobalKey<FormState> di controller
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              _buildProfileImagePicker(context, controller, primaryColor),
              const SizedBox(height: 24.0),
              _buildTextField(
                controller: controller.nameController,
                labelText: 'Nama Lengkap',
                icon: Icons.person_outline,
              ),
              const SizedBox(height: 16.0),
              _buildTextField(
                controller: controller.nimController,
                labelText: 'NIM (Nomor Induk Mahasiswa)',
                icon: Icons.badge_outlined,
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 16.0),
              _buildTextField(
                controller: controller.prodiController,
                labelText: 'Program Studi / Jurusan',
                icon: Icons.school_outlined,
              ),
              const SizedBox(height: 16.0),
              _buildSemesterDropdown(controller, primaryColor),
              const SizedBox(height: 16.0),
              _buildPasswordField(controller, primaryColor),
              const SizedBox(height: 32.0),
              _buildSaveButton(controller, primaryColor),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileImagePicker(BuildContext context, ProfileController controller, Color primaryColor) {
    return Center(
      child: Stack(
        alignment: Alignment.bottomRight,
        children: [
          Obx(() => CircleAvatar(
                radius: 60,
                backgroundColor: Colors.grey[300],
                backgroundImage: controller.profileImage.value != null
                    ? FileImage(controller.profileImage.value!)
                    : null,
                child: controller.profileImage.value == null
                    ? Icon(Icons.person, size: 60, color: Colors.grey[600])
                    : null,
              )),
          Material(
            color: primaryColor,
            shape: const CircleBorder(),
            elevation: 2,
            child: InkWell(
              onTap: () => _showImageSourceDialog(context, controller),
              customBorder: const CircleBorder(),
              child: const Padding(
                padding: EdgeInsets.all(8.0),
                child: Icon(Icons.camera_alt, color: Colors.white, size: 20),
              ),
            ),
          )
        ],
      ),
    );
  }

  void _showImageSourceDialog(BuildContext context, ProfileController controller) {
    Get.defaultDialog(
      title: 'Pilih Sumber Gambar',
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library_outlined),
            title: const Text('Galeri'),
            onTap: () {
              controller.pickImage(ImageSource.gallery);
              Get.back(); // Tutup dialog
            },
          ),
          ListTile(
            leading: const Icon(Icons.camera_alt_outlined),
            title: const Text('Kamera'),
            onTap: () {
              controller.pickImage(ImageSource.camera);
              Get.back(); // Tutup dialog
            },
          ),
        ],
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String labelText,
    required IconData icon,
    TextInputType keyboardType = TextInputType.text,
    bool obscureText = false,
    Widget? suffixIcon,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      obscureText: obscureText,
      decoration: InputDecoration(
        labelText: labelText,
        prefixIcon: Icon(icon),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
        filled: true,
        fillColor: Colors.white,
        suffixIcon: suffixIcon,
      ),
      validator: (value) {
        if (value == null || value.isEmpty) {
          return '$labelText tidak boleh kosong';
        }
        return null;
      },
    );
  }

  Widget _buildSemesterDropdown(ProfileController controller, Color primaryColor) {
    return Obx(() => DropdownButtonFormField<int>(
          value: controller.selectedSemester.value,
          items: controller.semesters.map((int semester) {
            return DropdownMenuItem<int>(
              value: semester,
              child: Text('Semester $semester'),
            );
          }).toList(),
          onChanged: (int? newValue) {
            if (newValue != null) {
              controller.selectedSemester.value = newValue;
            }
          },
          decoration: InputDecoration(
            labelText: 'Semester Saat Ini',
            prefixIcon: const Icon(Icons.format_list_numbered_outlined),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12.0),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
          validator: (value) => value == null ? 'Pilih semester' : null,
        ));
  }

  Widget _buildPasswordField(ProfileController controller, Color primaryColor) {
    return Obx(() => _buildTextField(
          controller: controller.passwordController,
          labelText: 'Password',
          icon: Icons.lock_outline,
          obscureText: controller.obscurePassword.value,
          suffixIcon: IconButton(
            icon: Icon(
              controller.obscurePassword.value
                  ? Icons.visibility_off_outlined
                  : Icons.visibility_outlined,
              color: primaryColor,
            ),
            onPressed: controller.toggleObscurePassword,
          ),
        ));
  }

  Widget _buildSaveButton(ProfileController controller, Color primaryColor) {
    return Align(
      alignment: Alignment.centerRight, // Sesuai wireframe
      child: Obx(() => ElevatedButton.icon(
            icon: controller.isLoading.value
                ? Container(
                    width: 20,
                    height: 20,
                    padding: const EdgeInsets.all(2.0),
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                : const Icon(Icons.save_outlined, size: 18),
            label: Text(controller.isLoading.value ? 'Menyimpan...' : 'Simpan'),
            onPressed: controller.isLoading.value ? null : controller.saveProfile,
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryColor,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              textStyle: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8.0),
              ),
            ),
          )),
    );
  }
}

