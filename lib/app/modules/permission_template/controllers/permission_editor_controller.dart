import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:printing/printing.dart';

class PermissionEditorController extends GetxController {
  late final TextEditingController textController;
  final Rx<XFile?> selectedImage = Rx<XFile?>(null);
  final ImagePicker _picker = ImagePicker();

  @override
  void onInit() {
    super.onInit();
    // Ambil konten template yang dikirim dari halaman sebelumnya
    final String initialContent = Get.arguments as String? ?? 'Konten tidak ditemukan.';
    textController = TextEditingController(text: initialContent);
  }

  Future<void> pickImage() async {
    try {
      final XFile? image = await _picker.pickImage(source: ImageSource.gallery);
      if (image != null) {
        selectedImage.value = image;
      }
    } catch (e) {
      Get.snackbar('Error', 'Gagal memilih gambar: $e');
    }
  }

  Future<void> _generateAndSharePdf(String text) async {
    final pdf = pw.Document();
    final image = selectedImage.value;

    pdf.addPage(
      pw.MultiPage(
        pageFormat: PdfPageFormat.a4,
        margin: const pw.EdgeInsets.all(32),
        build: (pw.Context context) {
          return <pw.Widget>[
            pw.Header(
              level: 0,
              child: pw.Text('Surat Izin', style: pw.TextStyle(fontSize: 24, fontWeight: pw.FontWeight.bold)),
            ),
            pw.Paragraph(text: text, style: const pw.TextStyle(fontSize: 12)),
            if (image != null) pw.SizedBox(height: 20),
            if (image != null)
              pw.Center(
                child: pw.Image(
                  pw.MemoryImage(
                    File(image.path).readAsBytesSync(),
                  ),
                  fit: pw.BoxFit.contain,
                  width: 300,
                ),
              ),
          ];
        },
      ),
    );

    await Printing.sharePdf(
      bytes: await pdf.save(),
      filename: 'surat-izin.pdf',
    );
    Get.back(); // Close the bottom sheet
  }

  void showShareOptions(BuildContext context) {
    final text = textController.text;
    if (text.isEmpty) {
      Get.snackbar('Gagal', 'Pesan tidak boleh kosong.');
      return;
    }

    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).cardColor,
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: <Widget>[
              ListTile(
                leading: const FaIcon(FontAwesomeIcons.filePdf, color: Colors.redAccent),
                title: const Text('Export sebagai PDF'),
                onTap: () => _generateAndSharePdf(text),
              ),
              const Divider(height: 1),
              ListTile(
                leading: const Icon(Icons.copy_all_rounded),
                title: const Text('Salin Teks'),
                onTap: () {
                  Clipboard.setData(ClipboardData(text: text));
                  Get.back();
                  Get.snackbar('Berhasil', 'Teks berhasil disalin!');
                },
              ),
              ListTile(
                leading: const FaIcon(FontAwesomeIcons.whatsapp, color: Colors.green),
                title: const Text('Bagikan ke WhatsApp (Teks)'),
                onTap: () async {
                  final url = 'https://wa.me/?text=${Uri.encodeComponent(text)}';
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                  } else {
                    Get.snackbar('Gagal', 'Tidak dapat membuka WhatsApp.');
                  }
                  Get.back();
                },
              ),
              ListTile(
                leading: const FaIcon(FontAwesomeIcons.telegram, color: Colors.blueAccent),
                title: const Text('Bagikan ke Telegram (Teks)'),
                onTap: () async {
                  final url = 'https://t.me/share/url?url=none&text=${Uri.encodeComponent(text)}';
                  if (await canLaunchUrl(Uri.parse(url))) {
                    await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                  } else {
                    Get.snackbar('Gagal', 'Tidak dapat membuka Telegram.');
                  }
                  Get.back();
                },
              ),
              if (selectedImage.value != null)
                ListTile(
                  leading: const Icon(Icons.image_outlined),
                  title: const Text('Bagikan Teks & Gambar Mentah'),
                  onTap: () {
                    Share.shareXFiles([selectedImage.value!], text: text);
                    Get.back();
                  },
                ),
            ],
          ),
        );
      },
    );
  }

  @override
  void onClose() {
    textController.dispose();
    super.onClose();
  }
}
