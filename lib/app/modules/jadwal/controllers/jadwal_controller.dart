import 'package:get/get.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:absenuk/app/data/models/holiday_model.dart';
import 'package:absenuk/app/data/providers/holiday_provider.dart';

class JadwalController extends GetxController {
  // Observable untuk hari yang sedang difokuskan di kalender
  var focusedDay = DateTime.now().obs;

  // Observable untuk hari yang dipilih oleh pengguna
  var selectedDay = Rx<DateTime?>(null);

  // Map untuk menyimpan data kehadiran (true: hadir, false: tidak hadir)
  // Kita buat tanggalnya tanpa informasi jam, menit, detik agar perbandingan lebih mudah
  final RxMap<DateTime, bool> attendanceData = <DateTime, bool>{}.obs;

  // Untuk data hari libur dari API
  final HolidayProvider _holidayProvider = HolidayProvider();
  var holidays = <Holiday>[].obs;
  var isLoadingHolidays = true.obs;

  @override
  void onInit() {
    super.onInit();
    selectedDay.value = focusedDay.value; // Awalnya, hari terpilih adalah hari ini
    loadInitialAttendanceData();
    _fetchHolidays(focusedDay.value.year);
  }

  void onPageChanged(DateTime focused) {
    focusedDay.value = focused;
    // Jika tahun berubah, ambil data hari libur untuk tahun yang baru
    if (holidays.isNotEmpty && focused.year != holidays.first.date.year) {
      _fetchHolidays(focused.year);
    }
  }

  Future<void> _fetchHolidays(int year) async {
    try {
      isLoadingHolidays.value = true;
      final fetchedHolidays = await _holidayProvider.getHolidays(year);
      holidays.value = fetchedHolidays;
    } catch (e) {
      Get.snackbar('Error', 'Gagal memuat data hari libur: $e');
    } finally {
      isLoadingHolidays.value = false;
    }
  }

  void onDaySelected(DateTime selected, DateTime focused) {
    if (!isSameDay(selectedDay.value, selected)) {
      selectedDay.value = selected;
      focusedDay.value = focused;
      // Di sini Anda bisa menambahkan logika jika ada aksi saat hari dipilih
      // misalnya menampilkan detail kehadiran untuk hari tersebut
    }
  }

  // Fungsi untuk mendapatkan status kehadiran untuk suatu hari
  // Mengembalikan null jika tidak ada data, true jika hadir, false jika tidak hadir
  bool? getAttendanceStatus(DateTime day) {
    // Normalisasi tanggal agar hanya membandingkan tahun, bulan, dan hari
    final normalizedDay = DateTime.utc(day.year, day.month, day.day);
    return attendanceData[normalizedDay];
  }

  // Fungsi untuk memuat data kehadiran awal (contoh)
  void loadInitialAttendanceData() {
    final today = DateTime.now();
    final normalizedToday = DateTime.utc(today.year, today.month, today.day);

    attendanceData.addAll({
      // Hadir
      DateTime.utc(normalizedToday.year, normalizedToday.month, normalizedToday.day - 7): true, 
      DateTime.utc(normalizedToday.year, normalizedToday.month, normalizedToday.day - 6): true,
      DateTime.utc(normalizedToday.year, normalizedToday.month, normalizedToday.day - 5): true,
      // Tidak Hadir
      DateTime.utc(normalizedToday.year, normalizedToday.month, normalizedToday.day - 4): false,
      DateTime.utc(normalizedToday.year, normalizedToday.month, normalizedToday.day - 3): false,
      // Hadir lagi
      DateTime.utc(normalizedToday.year, normalizedToday.month, normalizedToday.day - 2): true,
      // Hari ini (misal belum ada data)
      // DateTime.utc(normalizedToday.year, normalizedToday.month, normalizedToday.day): null,
    });
    
    // Contoh dari wireframe (November 2021)
    // Kita asumsikan tahun sekarang agar relevan, tapi polanya sama
    // Hijau: 9, 10, 11, 12, 13, 17, 18, 19, 20, 21
    // Merah: 14, 15, 16
    // Hitam (selected): 22 (kita akan handle styling selected terpisah)

    // Jika ingin meniru wireframe November 2021 (misal tahun ini)
    // final november = DateTime.utc(today.year, 11);
    // attendanceData.addAll({
    //   DateTime.utc(november.year, november.month, 9): true,
    //   DateTime.utc(november.year, november.month, 10): true,
    //   DateTime.utc(november.year, november.month, 11): true,
    //   DateTime.utc(november.year, november.month, 12): true,
    //   DateTime.utc(november.year, november.month, 13): true,
    //   DateTime.utc(november.year, november.month, 14): false,
    //   DateTime.utc(november.year, november.month, 15): false,
    //   DateTime.utc(november.year, november.month, 16): false,
    //   DateTime.utc(november.year, november.month, 17): true,
    //   DateTime.utc(november.year, november.month, 18): true,
    //   DateTime.utc(november.year, november.month, 19): true,
    //   DateTime.utc(november.year, november.month, 20): true,
    //   DateTime.utc(november.year, november.month, 21): true,
    // });
  }

  // Fungsi ini akan dipanggil oleh TableCalendar untuk mendapatkan event per hari
  // Event bisa berupa status kehadiran (bool) atau hari libur (Holiday)
  List<dynamic> getEventsForDay(DateTime day) {
    final normalizedDay = DateTime.utc(day.year, day.month, day.day);

    // Cek apakah ada data kehadiran untuk hari ini
    final status = attendanceData[normalizedDay];
    
    // Cek apakah hari ini adalah hari libur
    final holidayEvents = holidays.where((holiday) => isSameDay(holiday.date, day)).toList();

    final List<dynamic> events = [];
    if (status != null) {
      events.add(status);
    }
    events.addAll(holidayEvents);

    return events;
  }
}
