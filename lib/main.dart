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

Future<void> initializeNotifications() async {
  tz.initializeTimeZones();

  final currentTimeZone =
      await FlutterTimezone.getLocalTimezone();

  tz.setLocalLocation(
    tz.getLocation(currentTimeZone.identifier),
  );

  const androidSettings =
      AndroidInitializationSettings('@mipmap/ic_launcher');

  const settings = InitializationSettings(
    android: androidSettings,
  );

  await notificationsPlugin.initialize(
    settings: settings,
  );

  final androidPlugin =
      notificationsPlugin
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

  Future<void> changeTheme() async {
    final prefs = await SharedPreferences.getInstance();

    final newValue = !darkMode;

    await prefs.setBool(darkModeKey, newValue);

    if (!mounted) return;

    setState(() {
      darkMode = newValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'موعدي',
      themeMode:
          darkMode ? ThemeMode.dark : ThemeMode.light,
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
        onThemeChanged: changeTheme,
      ),
    );
  }
}

class HomePage extends StatefulWidget {
  final Future<void> Function() onThemeChanged;

  const HomePage({
    super.key,
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

  @override
  void initState() {
    super.initState();
    loadAppointments();
  }

  Future<void> loadAppointments() async {
    final prefs =
        await SharedPreferences.getInstance();

    final data =
        prefs.getStringList(appointmentsKey) ?? [];

    final loaded = <Appointment>[];

    for (int i = 0; i < data.length; i++) {
      final parts = data[i].split('|');

      if (parts.length < 8) {
        continue;
      }

      final date =
          DateTime.tryParse(parts[1]);

      final hour =
          int.tryParse(parts[2]);

      final minute =
          int.tryParse(parts[3]);

      if (date == null ||
          hour == null ||
          minute == null) {
        continue;
      }

      int reminder = 60;

      if (parts.length >= 10) {
        reminder =
            int.tryParse(parts[9]) ?? 60;
      }

      bool completed = false;

      if (parts.length >= 11) {
        completed =
            parts[10] == 'true';
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
          notes:
              parts.length >= 9
                  ? parts[8]
                  : '',
          reminderMinutes: reminder,
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
    final prefs =
        await SharedPreferences.getInstance();

    final data =
        appointments.map((appointment) {
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

    final reminderDateTime =
        appointmentDateTime.subtract(
      Duration(
        minutes: appointment.reminderMinutes,
      ),
    );

    if (!reminderDateTime.isAfter(
      DateTime.now(),
    )) {
      return;
    }

    final scheduledDate =
        tz.TZDateTime.from(
      reminderDateTime,
      tz.local,
    );

    const androidDetails =
        AndroidNotificationDetails(
      'appointments_channel',
      'تذكيرات المواعيد',
      channelDescription:
          'تنبيهات وتذكيرات المواعيد',
      importance: Importance.high,
      priority: Priority.high,
      playSound: true,
      enableVibration: true,
    );

    const notificationDetails =
        NotificationDetails(
      android: androidDetails,
    );

    await notificationsPlugin.zonedSchedule(
      id: notificationId(appointment.id),
      title: 'تذكير بموعدك 🔔',
      body: appointment.title,
      scheduledDate: scheduledDate,
      notificationDetails:
          notificationDetails,
      androidScheduleMode:
          AndroidScheduleMode
              .inexactAllowWhileIdle,
    );
  }

  List<Appointment> get filteredAppointments {
    final query =
        searchText.toLowerCase();
final result = appointments.where(
  (appointment) {
    final matchesSearch =
        appointment.title.toLowerCase().contains(query) ||
        appointment.person.toLowerCase().contains(query) ||
        appointment.location.toLowerCase().contains(query) ||
        appointment.type.toLowerCase().contains(query);

    final matchesFilter =
        selectedFilter == 'الكل' ||
        appointment.type == selectedFilter;

    return matchesSearch && matchesFilter;
  },
).toList();

result.sort(
  (a, b) {
    final aDate = DateTime(
      a.date.year,
      a.date.month,
      a.date.day,
      a.time.hour,
      a.time.minute,
    );

    final bDate = DateTime(
      b.date.year,
      b.date.month,
      b.date.day,
      b.time.hour,
      b.time.minute,
    );

    return aDate.compareTo(bDate);
  },
);

return result;
        }

  Future<void> toggleCompleted(Appointment appointment) async {
    setState(() {
      appointment.completed = !appointment.completed;
    });

    await saveAppointments();
    await scheduleAllNotifications();
  }

  Future<void> deleteAppointment(Appointment appointment) async {
    setState(() {
      appointments.remove(appointment);
    });

    await saveAppointments();
    await scheduleAllNotifications();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('موعدي'),
        actions: [
          IconButton(
            icon: const Icon(Icons.dark_mode),
            onPressed: widget.onThemeChanged,
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: TextField(
              decoration: const InputDecoration(
                labelText: 'بحث عن موعد',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                setState(() {
                  searchText = value;
                });
              },
            ),
          ),
          Expanded(
            child: filteredAppointments.isEmpty
                ? const Center(
                    child: Text('لا توجد مواعيد'),
                  )
                : ListView.builder(
                    itemCount: filteredAppointments.length,
                    itemBuilder: (context, index) {
                      final appointment =
                          filteredAppointments[index];

                      return Card(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        child: ListTile(
                          leading: Icon(
                            appointment.completed
                                ? Icons.check_circle
                                : Icons.event,
                          ),
                          title: Text(
                            appointment.title,
                            style: TextStyle(
                              decoration:
                                  appointment.completed
                                      ? TextDecoration.lineThrough
                                      : null,
                            ),
                          ),
                          subtitle: Text(
                            '${appointment.type} • '
                            '${appointment.date.day}/'
                            '${appointment.date.month}/'
                            '${appointment.date.year} '
                            '${appointment.time.format(context)}',
                          ),
                          trailing: IconButton(
                            icon: Icon(
                              appointment.completed
                                  ? Icons.undo
                                  : Icons.check,
                            ),
                            onPressed: () {
                              toggleCompleted(appointment);
                            },
                          ),
                          onLongPress: () {
                            deleteAppointment(appointment);
                          },
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showAppointmentDialog();
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  Future<void> showAppointmentDialog() async {
    final titleController = TextEditingController();
    final personController = TextEditingController();
    final phoneController = TextEditingController();
    final locationController = TextEditingController();
    final notesController = TextEditingController();

    DateTime selectedDate = DateTime.now();
    TimeOfDay selectedTime = TimeOfDay.now();
    String selectedType = appointmentTypes.first;
    int selectedReminder = 60;

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('إضافة موعد'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'عنوان الموعد',
                      ),
                    ),
                    TextField(
                      controller: personController,
                      decoration: const InputDecoration(
                        labelText: 'الشخص',
                      ),
                    ),
                    TextField(
                      controller: phoneController,
                      decoration: const InputDecoration(
                        labelText: 'رقم الهاتف',
                      ),
                    ),
                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: 'المكان',
                      ),
                    ),
                    TextField(
                      controller: notesController,
                      decoration: const InputDecoration(
                        labelText: 'ملاحظات',
                      ),
                    ),
                    DropdownButtonFormField<String>(
                      initialValue: selectedType,
                      decoration: const InputDecoration(
                        labelText: 'نوع الموعد',
                      ),
                      items: appointmentTypes.map((type) {
                        return DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedType = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    DropdownButtonFormField<int>(
                      initialValue: selectedReminder,
                      decoration: const InputDecoration(
                        labelText: 'التنبيه',
                      ),
                      items: reminderOptions.entries.map((entry) {
                        return DropdownMenuItem(
                          value: entry.key,
                          child: Text(entry.value),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            selectedReminder = value;
                          });
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    ElevatedButton(
                      onPressed: () async {
                        final picked = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );

                        if (picked != null) {
                          setDialogState(() {
                            selectedDate = picked;
                          });
                        }
                      },
                      child: Text(
                        'التاريخ: ${selectedDate.day}/'
                        '${selectedDate.month}/'
                        '${selectedDate.year}',
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () async {
                        final picked = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );

                        if (picked != null) {
                          setDialogState(() {
                            selectedTime = picked;
                          });
                        }
                      },
                      child: Text(
                        'الوقت: ${selectedTime.format(context)}',
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (titleController.text.trim().isEmpty) {
                      return;
                    }

                    final appointment = Appointment(
                      id: DateTime.now()
                          .microsecondsSinceEpoch
                          .toString(),
                      title: titleController.text.trim(),
                      date: selectedDate,
                      time: selectedTime,
                      type: selectedType,
                      person: personController.text.trim(),
                      phone: phoneController.text.trim(),
                      location: locationController.text.trim(),
                      notes: notesController.text.trim(),
                      reminderMinutes: selectedReminder,
                      completed: false,
                    );

                    setState(() {
                      appointments.add(appointment);
                    });

                    await saveAppointments();
                    await scheduleAllNotifications();

                    if (context.mounted) {
                      Navigator.pop(context);
                    }
                  },
                  child: const Text('حفظ'),
                ),
              ],
            );
          },
        );
      },
    );
  }
}
