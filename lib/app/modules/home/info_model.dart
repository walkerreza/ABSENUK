import 'package:intl/intl.dart';

class InfoModel {
  final String imageUrl;
  final String title;
  final String date;
  final String description;
  final String link;

  InfoModel({
    required this.imageUrl,
    required this.title,
    required this.date,
    required this.description,
    required this.link,
  });

  // Factory constructor untuk membuat InfoModel dari JSON
  factory InfoModel.fromJson(Map<String, dynamic> json) {
    // Ekstrak URL gambar dengan aman, berikan gambar default jika tidak ada
    String imageUrl = 'https://via.placeholder.com/300x150.png/CCCCCC/FFFFFF?text=AKB';
    if (json['_embedded'] != null &&
        json['_embedded']['wp:featuredmedia'] != null &&
        json['_embedded']['wp:featuredmedia'].isNotEmpty) {
      imageUrl = json['_embedded']['wp:featuredmedia'][0]['source_url'];
    }

    // Ekstrak judul dengan aman
    String title = json['title']?['rendered'] ?? 'Tanpa Judul';

    // Ekstrak link berita
    String link = json['link'] ?? '';

    // Ekstrak deskripsi dan bersihkan tag HTML
    String description = json['excerpt']?['rendered'] ?? 'Tidak ada deskripsi.';
    description = description.replaceAll(RegExp(r'<[^>]*>|&[^;]+;'), ' ').trim();

    // Uraikan dan format tanggal dengan aman
    String formattedDate = 'Tanggal tidak diketahui';
    if (json['date'] != null) {
      try {
        final parsedDate = DateTime.parse(json['date']);
        // Pastikan locale 'id_ID' diinisialisasi di main.dart
        formattedDate = DateFormat('d MMMM yyyy', 'id_ID').format(parsedDate);
      } catch (e) {
        // Biarkan tanggal default jika parsing gagal
      }
    }

    return InfoModel(
      imageUrl: imageUrl,
      title: title,
      date: formattedDate,
      description: description,
      link: link,
    );
  }
}
