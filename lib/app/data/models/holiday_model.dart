import 'dart:convert';

class Holiday {
  final DateTime date;
  final String name;
  final bool isNationalHoliday;

  Holiday({
    required this.date,
    required this.name,
    required this.isNationalHoliday,
  });

  factory Holiday.fromJson(Map<String, dynamic> json) {
    try {
      final dateParts = json['holiday_date'].split('-').map((part) => int.parse(part)).toList();
      return Holiday(
        // Menggunakan DateTime.utc untuk menghindari masalah timezone
        date: DateTime.utc(dateParts[0], dateParts[1], dateParts[2]),
        name: json['holiday_name'],
        isNationalHoliday: json['is_national_holiday'],
      );
    } catch (e) {
      // Jika ada format yang benar-benar tidak terduga, lempar error yang lebih jelas
      throw FormatException('Gagal mem-parsing tanggal: ${json['holiday_date']}', e);
    }
  }
}

List<Holiday> holidayFromJson(String str) => List<Holiday>.from(
    json.decode(str).map((x) => Holiday.fromJson(x))
);
