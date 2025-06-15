import 'package:get/get.dart';

class PermissionTemplate {
  final String title;
  final String content;

  PermissionTemplate({required this.title, required this.content});
}

class PermissionTemplateController extends GetxController {
  final List<PermissionTemplate> templates = [
    PermissionTemplate(
      title: 'Izin Sakit (Pesan Singkat)',
      content:
          'Yth. Bapak/Ibu [Nama Dosen],\n\nDengan hormat, saya yang bertanda tangan di bawah ini:\nNama: [Nama Lengkap Anda]\nNIM: [NIM Anda]\nKelas: [Kelas Anda]\n\nMemberitahukan bahwa saya tidak dapat mengikuti perkuliahan [Nama Mata Kuliah] pada hari ini, [Hari, Tanggal], dikarenakan sakit.\n\nAtas perhatian Bapak/Ibu, saya ucapkan terima kasih.',
    ),
    PermissionTemplate(
      title: 'Surat Izin Resmi (Tidak Hadir)',
      content:
          '[Kota], [Tanggal]\n\nPerihal: Permohonan Izin Tidak Masuk Kuliah\n\nYth.\nBapak/Ibu Dosen Pengampu Mata Kuliah [Nama Mata Kuliah]\ndi Tempat\n\nDengan hormat,\nSaya yang bertanda tangan di bawah ini:\nNama: [Nama Lengkap Anda]\nNIM: [NIM Anda]\nProgram Studi: [Program Studi Anda]\n\nDengan ini memberitahukan bahwa saya tidak dapat mengikuti kegiatan perkuliahan pada hari [Hari, Tanggal] dikarenakan [Alasan Izin].\n\nDemikian surat permohonan izin ini saya sampaikan. Atas perhatian dan izin yang diberikan, saya ucapkan terima kasih.\n\nHormat saya,\n\n[Nama Lengkap Anda]',
    ),
  ];
}
