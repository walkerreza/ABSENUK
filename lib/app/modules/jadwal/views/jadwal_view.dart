import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal
import 'package:table_calendar/table_calendar.dart';
import '../controllers/jadwal_controller.dart';

class JadwalView extends GetView<JadwalController> {
  const JadwalView({super.key});

  @override
  Widget build(BuildContext context) {
    // Mengambil warna utama dari tema aplikasi
    final Color primaryColor = Theme.of(context).primaryColor;
    final Color hadirColor = Colors.green.shade400;
    final Color tidakHadirColor = Colors.red.shade400;
    final Color selectedColor = Colors.black;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'JADWAL PRESENSI',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
        ),
        centerTitle: true,
        backgroundColor: primaryColor, // Sesuaikan dengan tema aplikasi Anda
        elevation: 0,
      ),
      body: Obx(() {
        return SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.2),
                      spreadRadius: 2,
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: TableCalendar(
                  locale: 'id_ID', // Untuk format bahasa Indonesia
                  firstDay: DateTime.utc(2020, 1, 1),
                  lastDay: DateTime.utc(2030, 12, 31),
                  focusedDay: controller.focusedDay.value,
                  selectedDayPredicate: (day) => isSameDay(controller.selectedDay.value, day),
                  onDaySelected: controller.onDaySelected,
                  onPageChanged: (focusedDay) {
                    controller.focusedDay.value = focusedDay;
                  },
                  eventLoader: controller.getEventsForDay,
                  calendarFormat: CalendarFormat.month,
                  availableCalendarFormats: const {
                    CalendarFormat.month: 'Month',
                  },
                  headerStyle: HeaderStyle(
                    titleCentered: true,
                    formatButtonVisible: false, // Sembunyikan tombol format (Month/Week/2Weeks)
                    titleTextStyle: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    leftChevronIcon: Icon(Icons.chevron_left, color: primaryColor),
                    rightChevronIcon: Icon(Icons.chevron_right, color: primaryColor),
                    titleTextFormatter: (date, locale) => DateFormat.yMMMM(locale).format(date).toUpperCase(),
                  ),
                  daysOfWeekStyle: DaysOfWeekStyle(
                    weekdayStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
                    weekendStyle: TextStyle(fontWeight: FontWeight.bold, color: Colors.black54),
                     // Mengatur format nama hari S, M, T, W, T, F, S
                    dowTextFormatter: (date, locale) => DateFormat.E(locale).format(date).substring(0,1).toUpperCase(), 
                  ),
                  calendarBuilders: CalendarBuilders(
                    // Kustomisasi tampilan tanggal default
                    defaultBuilder: (context, day, focusedDay) {
                      bool? isHadir = controller.getAttendanceStatus(day);
                      if (isHadir == null) {
                        return null; // Gunakan tampilan default jika tidak ada data
                      }
                      return _buildDayCell(day, isHadir ? hadirColor : tidakHadirColor, Colors.white);
                    },
                    // Kustomisasi tampilan tanggal yang dipilih
                    selectedBuilder: (context, day, focusedDay) {
                      return _buildDayCell(day, selectedColor, Colors.white, isSelected: true);
                    },
                    // Kustomisasi tampilan hari ini
                    todayBuilder: (context, day, focusedDay) {
                       bool? isHadir = controller.getAttendanceStatus(day);
                       Color? bgColor = isHadir == null ? null : (isHadir ? hadirColor : tidakHadirColor);
                       Color textColor = isHadir == null ? Colors.blue : Colors.white;
                       
                       // Jika hari ini juga terpilih, gunakan style selected
                       if (isSameDay(day, controller.selectedDay.value)) {
                         return _buildDayCell(day, selectedColor, Colors.white, isSelected: true, isToday: true);
                       }

                       return _buildDayCell(day, bgColor, textColor, isToday: true, isHadir: isHadir);
                    },
                    // Kustomisasi marker (titik di bawah tanggal)
                    // Kita tidak pakai marker bawaan karena sudah mewarnai cell
                    markerBuilder: (context, day, events) {
                      return const SizedBox.shrink(); // Sembunyikan marker default
                    },
                  ),
                  calendarStyle: CalendarStyle(
                    // Styling untuk hari di luar bulan yang ditampilkan
                    outsideDaysVisible: false,
                    // Styling untuk hari biasa
                    defaultTextStyle: const TextStyle(color: Colors.black87),
                    weekendTextStyle: const TextStyle(color: Colors.black87),
                    // Styling untuk hari yang dipilih (jika tidak di-override oleh selectedBuilder)
                    selectedDecoration: BoxDecoration(
                      color: selectedColor,
                      shape: BoxShape.circle,
                    ),
                    selectedTextStyle: const TextStyle(color: Colors.white),
                    // Styling untuk hari ini (jika tidak di-override oleh todayBuilder)
                    todayDecoration: BoxDecoration(
                      color: Colors.blue.withOpacity(0.3),
                      shape: BoxShape.circle,
                    ),
                    todayTextStyle: const TextStyle(color: Colors.blue),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              _buildLegend(hadirColor, tidakHadirColor, selectedColor),
            ],
          ),
        );
      }),
    );
  }

  // Helper widget untuk membangun sel tanggal
  Widget _buildDayCell(DateTime day, Color? backgroundColor, Color textColor, {bool isSelected = false, bool isToday = false, bool? isHadir}) {
    return Container(
      margin: const EdgeInsets.all(4.0),
      decoration: BoxDecoration(
        color: backgroundColor,
        shape: BoxShape.circle,
        border: isToday && !isSelected && backgroundColor == null // Hanya border biru jika today & tidak ada status & tidak selected
            ? Border.all(color: Colors.blue, width: 1.5)
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        '${day.day}',
        style: TextStyle(
          color: textColor,
          fontWeight: isSelected || isHadir != null ? FontWeight.bold : FontWeight.normal,
        ),
      ),
    );
  }

  // Helper widget untuk legenda
  Widget _buildLegend(Color hadirColor, Color tidakHadirColor, Color selectedColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _legendItem(hadirColor, 'Hadir'),
        _legendItem(tidakHadirColor, 'Tidak Hadir'),
        _legendItem(selectedColor, 'Terpilih'),
        _legendItem(Colors.blue.withOpacity(0.8), 'Hari Ini (Default)'),
      ],
    );
  }

  Widget _legendItem(Color color, String text) {
    return Row(
      children: [
        Container(
          width: 16,
          height: 16,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: color.opacity == 0.8 ? Border.all(color: Colors.blue.shade700) : null, // border untuk 'Hari Ini'
          ),
        ),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 12)),
      ],
    );
  }
}
