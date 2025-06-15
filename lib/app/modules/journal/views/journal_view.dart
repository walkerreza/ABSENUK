import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';

import '../controllers/journal_controller.dart';
import '../models/note_model.dart';

class JournalView extends GetView<JournalController> {
  const JournalView({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Jurnal Digital'),
        centerTitle: true,
      ),
      body: Obx(() {
        if (controller.notes.isEmpty) {
          return const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.note_alt_outlined, size: 80, color: Colors.grey),
                SizedBox(height: 16),
                Text(
                  'Belum ada catatan.',
                  style: TextStyle(fontSize: 18, color: Colors.grey),
                ),
                SizedBox(height: 8),
                Text(
                  'Tekan tombol + untuk membuat catatan baru.',
                  style: TextStyle(color: Colors.grey),
                ),
              ],
            ),
          );
        }
        return ListView.builder(
          padding: const EdgeInsets.all(8.0),
          itemCount: controller.notes.length,
          itemBuilder: (context, index) {
            final note = controller.notes[index];
            return Card(
              margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
              child: ListTile(
                title: Text(
                  note.title,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  '${DateFormat('dd MMM yyyy, HH:mm', 'id_ID').format(note.createdAt)}\n${note.content}',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.share_outlined),
                  tooltip: 'Bagikan',
                  onPressed: () => _showShareDialog(context, note),
                ),
                onTap: () {
                  _showAddOrEditNoteDialog(context, note: note);
                },
                onLongPress: () {
                  Get.dialog(
                    AlertDialog(
                      title: const Text('Hapus Catatan'),
                      content: const Text('Apakah Anda yakin ingin menghapus catatan ini?'),
                      actions: [
                        TextButton(
                          onPressed: () => Get.back(),
                          child: const Text('Batal'),
                        ),
                        TextButton(
                          onPressed: () {
                            controller.deleteNote(note.id);
                            Get.back(); // Langsung tutup dialog tanpa snackbar
                          },
                          child: const Text('Hapus', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  );
                },
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddOrEditNoteDialog(context);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddOrEditNoteDialog(BuildContext context, {Note? note}) {
    final theme = Theme.of(context);
    final isEditing = note != null;
    final titleController = TextEditingController(text: isEditing ? note.title : '');
    final contentController = TextEditingController(text: isEditing ? note.content : '');

    Get.bottomSheet(
      FractionallySizedBox(
        heightFactor: 0.9, // Mengambil 90% dari tinggi layar
        child: Container(
          padding: const EdgeInsets.all(16.0),
          decoration: BoxDecoration(
            color: theme.cardColor, // Menggunakan warna dari tema
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Header dengan tombol aksi
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: Icon(Icons.close, color: theme.colorScheme.onSurface.withOpacity(0.6)),
                    onPressed: () => Get.back(),
                  ),
                  Text(
                    isEditing ? 'Edit Catatan' : 'Catatan Baru',
                    style: theme.textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                  ),
                  TextButton(
                    onPressed: () {
                      final title = titleController.text;
                      final content = contentController.text;

                      if (title.isNotEmpty && content.isNotEmpty) {
                        if (isEditing) {
                          controller.updateNote(note.id, title, content);
                        } else {
                          controller.addNote(title, content);
                        }
                        Get.back();
                      } else {
                        Get.snackbar(
                          'Gagal',
                          'Judul dan isi catatan tidak boleh kosong.',
                          backgroundColor: Colors.red.withOpacity(0.8),
                          colorText: Colors.white,
                          snackPosition: SnackPosition.TOP,
                          margin: const EdgeInsets.all(16),
                        );
                      }
                    },
                    child: const Text('Simpan', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  ),
                ],
              ),
              const Divider(),
              // Form input
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      TextField(
                        controller: titleController,
                        autofocus: true,
                        decoration: const InputDecoration(
                          hintText: 'Judul',
                          border: InputBorder.none,
                        ),
                        style: theme.textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.bold),
                        textCapitalization: TextCapitalization.sentences,
                      ),
                      const SizedBox(height: 8),
                      TextField(
                        controller: contentController,
                        decoration: const InputDecoration(
                          hintText: 'Mulai menulis...',
                          border: InputBorder.none,
                        ),
                        style: theme.textTheme.bodyLarge,
                        textCapitalization: TextCapitalization.sentences,
                        maxLines: null, // Memungkinkan baris tidak terbatas
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
    );
  }

  void _showShareDialog(BuildContext context, Note note) {
    final String noteTitle = note.title;
    final String noteContent = note.content;
    final String fullNoteTextForShare = '*$noteTitle*\n\n$noteContent';
    final String fullNoteTextForCopy = '$noteTitle\n\n$noteContent';

    Get.dialog(
      AlertDialog(
        title: const Text('Bagikan Catatan'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.whatsapp, color: Color(0xFF25D366)),
              title: const Text('WhatsApp'),
              onTap: () async {
                Get.back();
                // Menggunakan tautan universal wa.me yang lebih andal
                final url = 'https://wa.me/?text=${Uri.encodeComponent(fullNoteTextForShare)}';
                if (await canLaunchUrl(Uri.parse(url))) {
                  // Buka di luar aplikasi untuk penanganan tautan yang benar
                  await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                } else {
                  Get.snackbar('Gagal', 'Tidak dapat membuka WhatsApp. Pastikan aplikasi terinstall.');
                }
              },
            ),
            ListTile(
              leading: const FaIcon(FontAwesomeIcons.telegram, color: Color(0xFF2AABEE)),
              title: const Text('Telegram'),
              onTap: () async {
                Get.back();
                final url = 'https://t.me/share/url?url=&text=${Uri.encodeComponent(fullNoteTextForShare)}';
                if (await canLaunchUrl(Uri.parse(url))) {
                  await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                } else {
                  Get.snackbar('Gagal', 'Tidak dapat membuka Telegram.');
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy_all_outlined),
              title: const Text('Salin Teks'),
              onTap: () {
                Get.back();
                Clipboard.setData(ClipboardData(text: fullNoteTextForCopy));
                Get.snackbar('Berhasil', 'Catatan disalin ke clipboard.');
              },
            ),
          ],
        ),
      ),
    );
  }
}