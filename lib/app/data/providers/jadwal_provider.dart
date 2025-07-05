import 'package:get/get.dart';
import 'package:absenuk/app/data/providers/api.dart';
import 'package:absenuk/app/modules/DaftarMatkul/matakuliah_model.dart';

class JadwalProvider extends GetConnect {
  Future<List<MataKuliah>> getJadwal() async {
    final response = await get('${Api.baseUrl}/mahasiswa/jadwal');

    if (response.status.hasError) {
      // Jika terjadi error, lempar exception
      throw Exception('Gagal mengambil data jadwal: ${response.statusText}');
    }

    if (response.body != null && response.body['data'] is List) {
      // Ambil list data dari response
      List<dynamic> listData = response.body['data'];
      // Ubah setiap item di list menjadi objek MataKuliah
      return listData.map((json) => MataKuliah.fromJson(json)).toList();
    } else {
      // Jika body kosong atau format tidak sesuai
      return [];
    }
  }
}
