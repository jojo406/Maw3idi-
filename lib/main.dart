import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

const String appointmentsKey = 'appointments';
const String darkModeKey = 'dark_mode';

final Map<int, String> reminderOptions = {
  -1: 'بدون تنبيه',
  0: 'عند وقت الموعد',
  5: 'قبل 5 دقائق',
  15: 'قبل 15 دقيقة',
  30: 'قبل 30 دقيقة',
  60: 'قبل ساعة',
  1440: 'قبل يوم',
};

final List<String> appointmentTypes = [
  'طبيب',
  'إدارة',
  'عمل',
  'دراسة',
  'شخصي',
  'أخرى',
];

final Map<String, String> repeatOptions = {
  'none': 'مرة واحدة',
  'daily': 'يومي',
  'weekly': 'أسبوعي',
  'monthly': 'شهري',
};

Future<void> initializeNotifications() async {
  tz.initializeTimeZones();

  final currentTimeZone = await FlutterTimezone.getLocalTimezone();

  tz.setLocalLocation(
    tz.getLocation(currentTimeZone.identifier),
  );

  const androidSettings = AndroidInitializationSettings(
    '@mipmap/ic_launcher',
  );

  const initializationSettings = InitializationSettings(
    android: androidSettings,
  );

  await notificationsPlugin.initialize(
    settings: initializationSettings,
  );

  final androidPlugin = notificationsPlugin
      .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();

  await androidPlugin?.requestNotificationsPermission();
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await initializeNotifications();

  runApp(const Maw3idiApp());
}

class Appointment {
  String id;
  String title;
  DateTime date;
  TimeOfDay time;
  String type;
  String person;
  String phone;
  String location;
  String notes;
  int reminderMinutes;
  String repeat;
  bool completed;

  Appointment({
    required this.id,
    required this.title,
    required this.date,
    required this.time,
    required this.type,
    required this.person,
    required this.phone,
    required this.location,
    required this.notes,
    required this.reminderMinutes,
    required this.repeat,
    required this.completed,
  });
}

class Maw3idiApp extends StatefulWidget {
  const Maw3idiApp({super.key});

  @override
  State<Maw3idiApp> createState() => _Maw3idiAppState();
}

class _Maw3idiAppState extends State<Maw3idiApp> {
  bool darkMode = false;

  @override
  void initState() {
    super.initState();
    loadTheme();
  }

  Future<void> loadTheme() async {
    final prefs = await SharedPreferences.getInstance();

    if (!mounted) return;

    setState(() {
      darkMode = prefs.getBool(darkModeKey) ?? false;
    });
  }

  Future<void> changeTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(darkModeKey, value);

    if (!mounted) return;

    setState(() {
      darkMode = value;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'موعدي',
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        brightness: Brightness.dark,
      ),
      home: HomePage(
        darkMode: darkMode,
        onThemeChanged: changeTheme,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final bool darkMode;
  final Future<void> Function(bool) onThemeChanged;

  const HomePage({
    super.key,
    required this.darkMode,
    required this.onThemeChanged,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Appointment> appointments = [];

  String searchText = '';
  String selectedFilter = 'الكل';

  final List<String> appointmentTypes = [
    'طبيب',
    'إدارة',
    'عمل',
    'دراسة',
    'شخصي',
    'أخرى',
  ];

  final Map<int, String> reminderOptions = {
    -1: 'بدون تنبيه',
    0: 'عند وقت الموعد',
    5: 'قبل 5 دقائق',
    15: 'قبل 15 دقيقة',
    30: 'قبل 30 دقيقة',
    60: 'قبل ساعة',
    1440: 'قبل يوم',
  };

  final Map<String, String> repeatOptions = {
    'none': 'مرة واحدة',
    'daily': 'يومي',
    'weekly': 'أسبوعي',
    'monthly': 'شهري',
  };

  @override
  void initState() {
    super.initState();
    loadAppointments();
  }

  Future<void> loadAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList(appointmentsKey) ?? [];

    final loaded = <Appointment>[];

    for (int i = 0; i < data.length; i++) {
      final item = data[i];
      final parts = item.split('|');

      if (parts.length < 8) {
        continue;
      }

      final date = DateTime.tryParse(parts[1]);
      final hour = int.tryParse(parts[2]);
      final minute = int.tryParse(parts[3]);

      if (date == null || hour == null || minute == null) {
        continue;
      }

      int reminderMinutes = 60;

      if (parts.length >= 10) {
        reminderMinutes = int.tryParse(parts[9]) ?? 60;
      }

      String repeat = 'none';

      if (parts.length >= 11) {
        repeat = repeatOptions.containsKey(parts[10])
            ? parts[10]
            : 'none';
      }

      bool completed = false;

      if (parts.length >= 12) {
        completed = parts[11] == 'true';
      }

      loaded.add(
        Appointment(
          id: 'appointment_$i',
          title: parts[0],
          date: date,
          time: TimeOfDay(
            hour: hour,
            minute: minute,
          ),
          type: parts[4],
          person: parts[5],
          phone: parts[6],
          location: parts[7],
          notes: parts.length >= 9 ? parts[8] : '',
          reminderMinutes: reminderMinutes,
          repeat: repeat,
          completed: completed,
        ),
      );
    }

    if (!mounted) return;

    setState(() {
      appointments.clear();
      appointments.addAll(loaded);
    });

    await scheduleAllNotifications();
  }

  Future<void> saveAppointments() async {
    final prefs = await SharedPreferences.getInstance();

    final data = appointments.map((appointment) {
      return [
        appointment.title,
        appointment.date.toIso8601String(),
        appointment.time.hour.toString(),
        appointment.time.minute.toString(),
        appointment.type,
        appointment.person,
        appointment.phone,
        appointment.location,
        appointment.notes,
        appointment.reminderMinutes.toString(),
        appointment.repeat,
        appointment.completed.toString(),
      ].join('|');
    }).toList();

    await prefs.setStringList(
      appointmentsKey,
      data,
    );
  }
  int notificationId(String id) {
    return id.hashCode.abs();
  }

  Future<void> scheduleAllNotifications() async {
    await notificationsPlugin.cancelAll();

    for (final appointment in appointments) {
      await scheduleAppointmentNotification(
        appointment,
      );
    }
  }

  Future<void> scheduleAppointmentNotification(
    Appointment appointment,
  ) async {
    if (appointment.completed) {
      return;
    }

    if (appointment.reminderMinutes == -1) {
      return;
    }

    final appointmentDateTime = DateTime(
      appointment.date.year,
      appointment.date.month,
      appointment.date.day,
      appointment.time.hour,
      appointment.time.minute,
    );

    final reminderDateTime = appointmentDateTime.subtract(
      Duration(minutes: appointment.reminderMinutes),
    );

    if (!reminderDateTime.isAfter(DateTime.now())) {
      return;
    }

    final scheduledDate = tz.TZDateTime.from(
      reminderDateTime,
      tz.local,
    );

    const androidDetails = AndroidNotificationDetails(
      'appointments_channel',
      'تذكيرات المواعيد',
      channelDescription: 'تنبيهات وتذكيرات المواعيد',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const notificationDetails = NotificationDetails(
      android: androidDetails,
    );

    await notificationsPlugin.zonedSchedule(
      id: notificationId(appointment.id),
      title: 'تذكير بموعدك 🔔',
      body: appointment.title,
      scheduledDate: scheduledDate,
      notificationDetails: notificationDetails,
      androidScheduleMode:
          AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
