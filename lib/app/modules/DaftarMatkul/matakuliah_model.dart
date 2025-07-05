class MataKuliah {
  final String namaMatkul;
  final String jamMulai;
  final String jamSelesai;
  final String ruangan;
  final String dosen;
  final String hari;

  MataKuliah({
    required this.namaMatkul,
    required this.jamMulai,
    required this.jamSelesai,
    required this.ruangan,
    required this.dosen,
    required this.hari,
  });

  factory MataKuliah.fromJson(Map<String, dynamic> json) {
    return MataKuliah(
      namaMatkul: json['nama_matkul'] ?? 'Tanpa Nama',
      jamMulai: json['jam_mulai'] ?? '',
      jamSelesai: json['jam_selesai'] ?? '',
      ruangan: json['ruangan'] ?? 'N/A',
      dosen: json['dosen'] ?? 'N/A',
      hari: json['hari'] ?? '',
    );
  }
}
