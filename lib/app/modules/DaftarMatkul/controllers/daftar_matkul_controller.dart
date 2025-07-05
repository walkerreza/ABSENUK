import 'package:get/get.dart';
import 'package:absenuk/app/data/providers/jadwal_provider.dart';
import '../matakuliah_model.dart';

class DaftarMatkulController extends GetxController {
  final JadwalProvider jadwalProvider;
  DaftarMatkulController({required this.jadwalProvider});

  final List<String> hariUntukTampil = ['Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat'];
  final RxList<MataKuliah> semuaMataKuliah = <MataKuliah>[].obs;
  final RxMap<String, List<MataKuliah>> jadwalPerHari = <String, List<MataKuliah>>{}.obs;
  
  final RxBool isLoading = true.obs;
  final RxString errorMessage = ''.obs;

  @override
  void onInit() {
    super.onInit();
    fetchJadwal();
  }

  Future<void> fetchJadwal() async {
    try {
      isLoading(true);
      errorMessage('');
      final jadwal = await jadwalProvider.getJadwal();
      semuaMataKuliah.assignAll(jadwal);
      _kelompokkanJadwal();
    } catch (e) {
      errorMessage('Gagal memuat jadwal: ${e.toString()}');
      Get.snackbar(
        'Error',
        'Tidak dapat mengambil data jadwal. Silakan coba lagi nanti.',
        snackPosition: SnackPosition.BOTTOM,
      );
    } finally {
      isLoading(false);
    }
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
    hasilKelompok.forEach((hari, listMk) {
      listMk.sort((a, b) => a.jamMulai.compareTo(b.jamMulai));
    });
    jadwalPerHari.assignAll(hasilKelompok);
  }

  List<MataKuliah> getJadwalUntukHari(String hari) {
    return jadwalPerHari[hari] ?? [];
  }
}
