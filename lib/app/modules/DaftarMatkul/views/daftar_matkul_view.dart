import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/daftar_matkul_controller.dart';
import '../matakuliah_model.dart'; // Import model MataKuliah

class DaftarMatkulView extends GetView<DaftarMatkulController> {
  const DaftarMatkulView({super.key});

  @override
  Widget build(BuildContext context) {
    final Color primaryColor = Theme.of(context).primaryColor; // Mengambil warna primer dari tema

    return Scaffold(
      appBar: AppBar(
        title: const Text('JADWAL MATKUL'),
        backgroundColor: primaryColor,
        elevation: 0, // Menghilangkan shadow jika diinginkan
        centerTitle: true, // Sesuai wireframe, judul di tengah
      ),
      body: Obx(() { // Gunakan Obx untuk reaktivitas jika data jadwal berubah
        if (controller.jadwalPerHari.isEmpty && controller.semuaMataKuliah.isNotEmpty) {
          // Ini bisa terjadi jika pengelompokan belum selesai atau ada kondisi lain
          // Atau jika semuaMataKuliah kosong setelah load awal
          return const Center(child: CircularProgressIndicator());
        } else if (controller.semuaMataKuliah.isEmpty) {
            return const Center(child: Text('Tidak ada jadwal mata kuliah.'));
        }

        return ListView.builder(
          padding: const EdgeInsets.all(16.0),
          itemCount: controller.hariUntukTampil.length,
          itemBuilder: (context, index) {
            final hari = controller.hariUntukTampil[index];
            final jadwalHariIni = controller.getJadwalUntukHari(hari);

            if (jadwalHariIni.isEmpty) {
              // Jika tidak ada jadwal untuk hari ini, bisa tampilkan pesan atau sembunyikan section
              // Untuk saat ini, kita tampilkan section hari dengan pesan kosong
              // return SizedBox.shrink(); // atau
              return _buildDaySection(hari, [], primaryColor);
            }

            return _buildDaySection(hari, jadwalHariIni, primaryColor);
          },
        );
      }),
    );
  }

  Widget _buildDaySection(String hari, List<MataKuliah> jadwal, Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            hari.toUpperCase(),
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: primaryColor, // Warna teks hari
            ),
          ),
          const SizedBox(height: 10),
          if (jadwal.isEmpty)
            Container(
              padding: const EdgeInsets.all(16.0),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8.0),
              ),
              child: const Center(
                child: Text(
                  'Tidak ada jadwal untuk hari ini.',
                  style: TextStyle(color: Colors.grey, fontStyle: FontStyle.italic),
                ),
              ),
            )
          else
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(), // Agar tidak ada scroll di dalam ListView utama
              itemCount: jadwal.length,
              itemBuilder: (context, index) {
                final mk = jadwal[index];
                return _buildMatkulCard(mk);
              },
              separatorBuilder: (context, index) => const SizedBox(height: 12),
            ),
        ],
      ),
    );
  }

  Widget _buildMatkulCard(MataKuliah mk) {
    // Placeholder abu-abu seperti di wireframe
    // Kita akan isi dengan detail mata kuliah
    return Card(
      elevation: 2.0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
      child: Container(
        // Tinggi placeholder seperti di wireframe, bisa disesuaikan
        // height: 80, 
        padding: const EdgeInsets.all(16.0),
        decoration: BoxDecoration(
          // color: Colors.grey[300], // Warna placeholder abu-abu
          borderRadius: BorderRadius.circular(8.0),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.center, // Pusatkan konten jika tinggi tetap
          children: [
            Text(
              mk.namaMatkul,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 6),
            Row(
              children: [
                const Icon(Icons.access_time_outlined, size: 16, color: Colors.black54),
                const SizedBox(width: 6),
                Text('${mk.jamMulai} - ${mk.jamSelesai}', style: const TextStyle(color: Colors.black54)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.location_on_outlined, size: 16, color: Colors.black54),
                const SizedBox(width: 6),
                Text(mk.ruangan, style: const TextStyle(color: Colors.black54)),
              ],
            ),
            const SizedBox(height: 4),
            Row(
              children: [
                const Icon(Icons.person_outline, size: 16, color: Colors.black54),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    mk.dosen,
                    style: const TextStyle(color: Colors.black54),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
