import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

import '../routes/app_pages.dart';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  Future<void> init() async {
    // Inisialisasi pengaturan untuk Android
    const AndroidInitializationSettings initializationSettingsAndroid =
        AndroidInitializationSettings('notification_icon'); // Menggunakan ikon kustom

    // Inisialisasi pengaturan untuk iOS (opsional, tapi baik untuk disertakan)
    const DarwinInitializationSettings initializationSettingsIOS = DarwinInitializationSettings();

    const InitializationSettings initializationSettings = InitializationSettings(
      android: initializationSettingsAndroid,
      iOS: initializationSettingsIOS,
    );

    // Inisialisasi Timezone
    tz.initializeTimeZones();

    await _notificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: _onDidReceiveNotificationResponse,
    );
  }

  // Handler saat notifikasi diklik
  void _onDidReceiveNotificationResponse(
      NotificationResponse notificationResponse) async {
    final String? payload = notificationResponse.payload;
    if (payload != null && payload == 'ABSEN_REMINDER') {
      // Arahkan ke halaman beranda
      Get.toNamed(Routes.HOME);
    }
  }

  // Meminta izin notifikasi (wajib untuk Android 13+)
  Future<void> requestPermission() async {
    final plugin = _notificationsPlugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    if (plugin != null) {
      await plugin.requestNotificationsPermission();
    }
  }

  // Detail notifikasi (channel, dll)
  NotificationDetails _notificationDetails() {
    return const NotificationDetails(
      android: AndroidNotificationDetails(
        'absen_reminder_channel',
        'Pengingat Absen',
        channelDescription: 'Channel untuk pengingat absen harian.',
        importance: Importance.max,
        priority: Priority.high,
        ticker: 'ticker',
      ),
    );
  }

  // Fungsi untuk menjadwalkan notifikasi harian (pagi dan siang)
  Future<void> scheduleDailyReminders() async {
    // Jadwalkan notifikasi pagi
    await _notificationsPlugin.zonedSchedule(
      0, // ID unik untuk notifikasi pagi
      'Jangan Lupa Absen Pagi!',
      'Batas waktu absen pagi adalah jam 10:00. Yuk, absen sekarang!',
      _nextInstanceOfTime(const TimeOfDay(hour: 8, minute: 0)), // Jam 8:00 Pagi
      _notificationDetails(),
      payload: 'ABSEN_REMINDER',
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );

    // Jadwalkan notifikasi siang
    await _notificationsPlugin.zonedSchedule(
      1, // ID unik untuk notifikasi siang
      'Jangan Lupa Absen Siang!',
      'Batas waktu absen siang adalah jam 14:30. Yuk, absen sekarang!',
      _nextInstanceOfTime(const TimeOfDay(hour: 13, minute: 0)), // Jam 1:00 Siang
      _notificationDetails(),
      payload: 'ABSEN_REMINDER',
      androidAllowWhileIdle: true,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  // Fungsi untuk membatalkan semua notifikasi
  // Fungsi untuk membatalkan semua notifikasi
  Future<void> cancelAllNotifications() async {
    await _notificationsPlugin.cancelAll();
  }

  // Helper untuk mendapatkan instance waktu berikutnya dari jam dan menit yang diberikan
  tz.TZDateTime _nextInstanceOfTime(TimeOfDay time) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
