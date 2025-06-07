import 'package:get/get.dart';
import '../matakuliah_model.dart'; // Import model MataKuliah

class DaftarMatkulController extends GetxController {
  // Daftar hari yang akan ditampilkan
  final List<String> hariUntukTampil = [
    'Senin',
    'Selasa',
    'Rabu',
    'Kamis',
    'Jumat',
  ];

  // Data dummy mata kuliah (RxList agar reaktif jika diperlukan nanti)
  final RxList<MataKuliah> semuaMataKuliah = <MataKuliah>[].obs;

  // Jadwal yang sudah dikelompokkan berdasarkan hari (RxMap agar reaktif)
  final RxMap<String, List<MataKuliah>> jadwalPerHari = 
      <String, List<MataKuliah>>{}.obs;

  @override
  void onInit() {
    super.onInit();
    _loadJadwalDummy();
    _kelompokkanJadwal();
  }

  void _loadJadwalDummy() {
    // Contoh data dummy
    semuaMataKuliah.assignAll([
      MataKuliah(namaMatkul: 'Pemrograman Mobile', jamMulai: '08:00', jamSelesai: '10:30', ruangan: 'Lab RPL', dosen: 'Dr. Budi Santoso', hari: 'Senin'),
      MataKuliah(namaMatkul: 'Basis Data Lanjut', jamMulai: '10:45', jamSelesai: '12:15', ruangan: 'A301', dosen: 'Prof. Siti Aminah', hari: 'Senin'),
      MataKuliah(namaMatkul: 'Kecerdasan Buatan', jamMulai: '13:30', jamSelesai: '15:00', ruangan: 'C202', dosen: 'Dr. Agus Purnomo', hari: 'Senin'),
      
      MataKuliah(namaMatkul: 'Jaringan Komputer', jamMulai: '08:00', jamSelesai: '10:30', ruangan: 'Lab Jaringan', dosen: 'Dr. Retno Wulandari', hari: 'Selasa'),
      MataKuliah(namaMatkul: 'Analisis dan Desain Sistem', jamMulai: '10:45', jamSelesai: '12:15', ruangan: 'B105', dosen: 'Ir. Joko Susilo, M.Kom', hari: 'Selasa'),
      
      MataKuliah(namaMatkul: 'Struktur Data dan Algoritma', jamMulai: '09:00', jamSelesai: '11:30', ruangan: 'D401', dosen: 'Dr. Budi Santoso', hari: 'Rabu'),
      MataKuliah(namaMatkul: 'Sistem Operasi', jamMulai: '13:00', jamSelesai: '14:30', ruangan: 'A302', dosen: 'Prof. Siti Aminah', hari: 'Rabu'),

      MataKuliah(namaMatkul: 'Manajemen Proyek TI', jamMulai: '08:00', jamSelesai: '09:30', ruangan: 'C205', dosen: 'Ir. Joko Susilo, M.Kom', hari: 'Kamis'),
      MataKuliah(namaMatkul: 'Keamanan Informasi', jamMulai: '10:00', jamSelesai: '12:00', ruangan: 'Lab Keamanan', dosen: 'Dr. Agus Purnomo', hari: 'Kamis'),

      MataKuliah(namaMatkul: 'Etika Profesi TI', jamMulai: '09:30', jamSelesai: '11:00', ruangan: 'B102', dosen: 'Dr. Retno Wulandari', hari: 'Jumat'),
    ]);
  }

  void _kelompokkanJadwal() {
    final Map<String, List<MataKuliah>> hasilKelompok = {};
    for (var mk in semuaMataKuliah) {
      if (hasilKelompok.containsKey(mk.hari)) {
        hasilKelompok[mk.hari]!.add(mk);
      } else {
        hasilKelompok[mk.hari] = [mk];
      }
    }
    // Urutkan mata kuliah dalam setiap hari berdasarkan jam mulai (opsional)
    hasilKelompok.forEach((hari, listMk) {
      listMk.sort((a, b) => a.jamMulai.compareTo(b.jamMulai));
    });
    jadwalPerHari.assignAll(hasilKelompok);
  }

  // Getter untuk memudahkan akses dari View
  List<MataKuliah> getJadwalUntukHari(String hari) {
    return jadwalPerHari[hari] ?? [];
  }
}
