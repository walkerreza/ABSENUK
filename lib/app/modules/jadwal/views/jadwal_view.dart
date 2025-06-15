import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart'; // Untuk format tanggal
import 'package:table_calendar/table_calendar.dart';
import 'package:absenuk/app/data/models/holiday_model.dart';
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
                  onPageChanged: controller.onPageChanged,
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
                    markerBuilder: (context, day, events) {
                      if (events.isEmpty) return const SizedBox.shrink();
                      return Positioned(
                        bottom: 1,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: events.map((event) {
                            Color dotColor = Colors.grey;
                            if (event is bool) {
                              dotColor = event ? hadirColor : tidakHadirColor;
                            } else if (event is Holiday) {
                              dotColor = Colors.amber.shade700;
                            }
                            return Container(
                              margin: const EdgeInsets.symmetric(horizontal: 1.5),
                              width: 7,
                              height: 7,
                              decoration: BoxDecoration(
                                color: dotColor,
                                shape: BoxShape.circle,
                              ),
                            );
                          }).toList(),
                        ),
                      );
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
              const SizedBox(height: 16),
              _buildLegend(hadirColor, tidakHadirColor, Colors.amber.shade700),
              const SizedBox(height: 16),
              const Text(
                'Detail Hari Terpilih',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Divider(),
              Obx(() => _buildEventList(controller.getEventsForDay(controller.selectedDay.value ?? DateTime.now()))),
            ],
          ),
        );
      }),
    );
  }

  Widget _buildEventList(List<dynamic> events) {
    if (events.isEmpty) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(16.0),
          child: Text('Tidak ada data untuk hari ini.', style: TextStyle(color: Colors.grey)),
        ),
      );
    }
    return ListView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: events.length,
      itemBuilder: (context, index) {
        final event = events[index];
        if (event is Holiday) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            child: ListTile(
              leading: Icon(Icons.celebration_rounded, color: Colors.amber.shade700),
              title: Text(event.name, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Hari Libur Nasional'),
            ),
          );
        } else if (event is bool) {
          return Card(
            margin: const EdgeInsets.symmetric(vertical: 4.0),
            child: ListTile(
              leading: Icon(
                event ? Icons.check_circle_outline_rounded : Icons.highlight_off_rounded,
                color: event ? Colors.green.shade400 : Colors.red.shade400,
              ),
              title: Text(event ? 'Hadir' : 'Tidak Hadir', style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('Status Kehadiran'),
            ),
          );
        }
        return const SizedBox.shrink();
      },
    );
  }

  // Helper widget untuk legenda
  Widget _buildLegend(Color hadirColor, Color tidakHadirColor, Color holidayColor) {
    return Wrap(
      spacing: 16.0,
      runSpacing: 8.0,
      alignment: WrapAlignment.center,
      children: [
        _legendItem(hadirColor, 'Hadir'),
        _legendItem(tidakHadirColor, 'Tidak Hadir'),
        _legendItem(holidayColor, 'Hari Libur'),
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
