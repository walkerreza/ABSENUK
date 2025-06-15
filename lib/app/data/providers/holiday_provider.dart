import 'package:http/http.dart' as http;
import 'package:absenuk/app/data/models/holiday_model.dart';

class HolidayProvider {
  final String _baseUrl = 'https://api-harilibur.vercel.app/api';

  Future<List<Holiday>> getHolidays(int year) async {
    try {
      final response = await http.get(Uri.parse('$_baseUrl?year=$year'));

      if (response.statusCode == 200) {
        final List<Holiday> allHolidays = holidayFromJson(response.body);
        // Filter untuk hanya mengambil hari libur nasional
        final List<Holiday> nationalHolidays = allHolidays
            .where((holiday) => holiday.isNationalHoliday)
            .toList();
        return nationalHolidays;
      } else {
        // Jika server tidak merespons dengan OK, lempar error.
        throw Exception('Gagal memuat data hari libur');
      }
    } catch (e) {
      // Menangkap error koneksi atau lainnya
      throw Exception('Terjadi kesalahan: $e');
    }
  }
}
