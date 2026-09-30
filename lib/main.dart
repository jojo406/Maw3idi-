import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;

final FlutterLocalNotificationsPlugin notificationsPlugin =
    FlutterLocalNotificationsPlugin();

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

// ============================================================
// MODEL
// ============================================================

class Appointment {
  String id;
  String title;
  DateTime dateTime;
  String type;
  String person;
  String phone;
  String location;
  String notes;
  int reminderMinutes;
  String recurrence;
  bool completed;

  Appointment({
    required this.id,
    required this.title,
    required this.dateTime,
    this.type = 'عام',
    this.person = '',
    this.phone = '',
    this.location = '',
    this.notes = '',
    this.reminderMinutes = 15,
    this.recurrence = 'لا يتكرر',
    this.completed = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'dateTime': dateTime.toIso8601String(),
      'type': type,
      'person': person,
      'phone': phone,
      'location': location,
      'notes': notes,
      'reminderMinutes': reminderMinutes,
      'recurrence': recurrence,
      'completed': completed,
    };
  }

  factory Appointment.fromJson(Map<String, dynamic> json) {
    return Appointment(
      id: json['id']?.toString() ?? DateTime.now().microsecondsSinceEpoch.toString(),
      title: json['title']?.toString() ?? 'موعد',
      dateTime: DateTime.tryParse(
            json['dateTime']?.toString() ?? '',
          ) ??
          DateTime.now(),
      type: json['type']?.toString() ?? 'عام',
      person: json['person']?.toString() ?? '',
      phone: json['phone']?.toString() ?? '',
      location: json['location']?.toString() ?? '',
      notes: json['notes']?.toString() ?? '',
      reminderMinutes: int.tryParse(
            json['reminderMinutes']?.toString() ?? '15',
          ) ??
          15,
      recurrence: json['recurrence']?.toString() ?? 'لا يتكرر',
      completed: json['completed'] == true,
    );
  }
}

// ============================================================
// APP
// ============================================================

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

    setState(() {
      darkMode = prefs.getBool('darkMode') ?? false;
    });
  }

  Future<void> changeTheme(bool value) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool('darkMode', value);

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
        fontFamily: 'Arial',
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xfff5f7fb),
        cardTheme: CardThemeData(
          elevation: 0,
          margin: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(15),
            borderSide: BorderSide.none,
          ),
        ),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
        cardTheme: CardThemeData(
          elevation: 0,
          margin: const EdgeInsets.symmetric(
            horizontal: 12,
            vertical: 6,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
      home: HomePage(
        darkMode: darkMode,
        onThemeChanged: changeTheme,
      ),
    );
  }
}

// ============================================================
// HOME PAGE
// ============================================================

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
  List<Appointment> appointments = [];

  String searchText = '';
  String selectedFilter = 'الكل';

  int defaultReminder = 15;

  final List<String> appointmentTypes = [
    'عام',
    'طبيب',
    'عمل',
    'دراسة',
    'اجتماع',
    'عائلي',
    'إداري',
    'سفر',
    'أخرى',
  ];

  final List<String> filters = [
    'الكل',
    'اليوم',
    'القادمة',
    'المكتملة',
    'المتأخرة',
  ];

  @override
  void initState() {
    super.initState();
    loadData();
  }

  // ==========================================================
  // STORAGE
  // ==========================================================

  Future<void> loadData() async {
    final prefs = await SharedPreferences.getInstance();

    final data = prefs.getString('appointments');

    if (data != null && data.isNotEmpty) {
      try {
        final List decoded = jsonDecode(data);

        appointments = decoded
            .map(
              (e) => Appointment.fromJson(
                Map<String, dynamic>.from(e),
              ),
            )
            .toList();
      } catch (_) {
        appointments = [];
      }
    }

    defaultReminder = prefs.getInt('defaultReminder') ?? 15;

    await refreshNotifications();

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> saveData() async {
    final prefs = await SharedPreferences.getInstance();

    final data = appointments
        .map((appointment) => appointment.toJson())
        .toList();

    await prefs.setString(
      'appointments',
      jsonEncode(data),
    );
  }

  // ==========================================================
  // NOTIFICATIONS
  // ==========================================================

  int notificationId(Appointment appointment) {
    return appointment.id.hashCode.abs();
  }

  Future<void> cancelNotification(
    Appointment appointment,
  ) async {
    await notificationsPlugin.cancel(
      id: notificationId(appointment),
    );
  }

  DateTime nextOccurrence(Appointment appointment) {
    DateTime current = appointment.dateTime;
    final now = DateTime.now();

    if (appointment.recurrence == 'يومياً') {
      while (!current.isAfter(now)) {
        current = current.add(const Duration(days: 1));
      }
    } else if (appointment.recurrence == 'أسبوعياً') {
      while (!current.isAfter(now)) {
        current = current.add(const Duration(days: 7));
      }
    } else if (appointment.recurrence == 'شهرياً') {
      while (!current.isAfter(now)) {
        int month = current.month + 1;
        int year = current.year;

        if (month > 12) {
          month = 1;
          year++;
        }

        int lastDay = DateTime(year, month + 1, 0).day;

        current = DateTime(
          year,
          month,
          current.day > lastDay ? lastDay : current.day,
          current.hour,
          current.minute,
        );
      }
    }

    return current;
  }

  Future<void> scheduleNotification(
    Appointment appointment,
  ) async {
    await cancelNotification(appointment);

    if (appointment.completed) return;

    if (appointment.reminderMinutes < 0) return;

    DateTime date = appointment.dateTime;

    if (appointment.recurrence != 'لا يتكرر') {
      date = nextOccurrence(appointment);
    }

    final scheduledDate = date.subtract(
      Duration(
        minutes: appointment.reminderMinutes,
      ),
    );

    if (scheduledDate.isBefore(DateTime.now())) {
      return;
    }

    final tzDate = tz.TZDateTime.from(
      scheduledDate,
      tz.local,
    );

    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'maw3idi_reminders',
        'تذكيرات موعدي',
        channelDescription: 'تذكيرات المواعيد',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    await notificationsPlugin.zonedSchedule(
      id: notificationId(appointment),
      title: 'تذكير بموعدك 🔔',
      body: appointment.title,
      scheduledDate: tzDate,
      notificationDetails: notificationDetails,
      androidScheduleMode:
          AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> refreshNotifications() async {
    for (final appointment in appointments) {
      await scheduleNotification(appointment);
    }
  }

  // ==========================================================
  // HELPERS
  // ==========================================================

  bool sameDay(DateTime a, DateTime b) {
    return a.year == b.year &&
        a.month == b.month &&
        a.day == b.day;
  }

  bool isToday(Appointment a) {
    return sameDay(a.dateTime, DateTime.now());
  }

  bool isOverdue(Appointment a) {
    return a.dateTime.isBefore(DateTime.now()) &&
        !a.completed;
  }

  String formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
        '${date.month.toString().padLeft(2, '0')}/'
        '${date.year}';
  }

  String formatTime(DateTime date) {
    return '${date.hour.toString().padLeft(2, '0')}:'
        '${date.minute.toString().padLeft(2, '0')}';
  }

  String weekday(DateTime date) {
    const days = [
      'الاثنين',
      'الثلاثاء',
      'الأربعاء',
      'الخميس',
      'الجمعة',
      'السبت',
      'الأحد',
    ];

    return days[date.weekday - 1];
  }

  String reminderText(int minutes) {
    if (minutes < 0) return 'بدون تذكير';
    if (minutes == 0) return 'وقت الموعد';
    if (minutes == 60) return 'قبل ساعة';
    if (minutes == 1440) return 'قبل يوم';
    return 'قبل $minutes دقيقة';
  }

  String recurrenceText(String value) {
    return value;
  }

  IconData typeIcon(String type) {
    switch (type) {
      case 'طبيب':
        return Icons.medical_services_rounded;
      case 'عمل':
        return Icons.work_rounded;
      case 'دراسة':
        return Icons.school_rounded;
      case 'اجتماع':
        return Icons.groups_rounded;
      case 'عائلي':
        return Icons.family_restroom_rounded;
      case 'إداري':
        return Icons.account_balance_rounded;
      case 'سفر':
        return Icons.flight_rounded;
      default:
        return Icons.event_rounded;
    }
  }

  Color typeColor(String type) {
    switch (type) {
      case 'طبيب':
        return Colors.red;
      case 'عمل':
        return Colors.blue;
      case 'دراسة':
        return Colors.orange;
      case 'اجتماع':
        return Colors.purple;
      case 'عائلي':
        return Colors.pink;
      case 'إداري':
        return Colors.teal;
      case 'سفر':
        return Colors.indigo;
      default:
        return Colors.green;
    }
  }

  // ==========================================================
  // FILTER
  // ==========================================================

  List<Appointment> get filteredAppointments {
    List<Appointment> result = List.from(appointments);

    if (searchText.trim().isNotEmpty) {
      final query = searchText.toLowerCase();

      result = result.where((appointment) {
        return appointment.title.toLowerCase().contains(query) ||
            appointment.person.toLowerCase().contains(query) ||
            appointment.location.toLowerCase().contains(query) ||
            appointment.type.toLowerCase().contains(query) ||
            appointment.notes.toLowerCase().contains(query);
      }).toList();
    }

    if (selectedFilter == 'اليوم') {
      result = result.where(isToday).toList();
    } else if (selectedFilter == 'القادمة') {
      result = result
          .where(
            (a) =>
                a.dateTime.isAfter(DateTime.now()) &&
                !a.completed,
          )
          .toList();
    } else if (selectedFilter == 'المكتملة') {
      result = result.where((a) => a.completed).toList();
    } else if (selectedFilter == 'المتأخرة') {
      result = result.where(isOverdue).toList();
    }

    result.sort(
      (a, b) => a.dateTime.compareTo(b.dateTime),
    );

    return result;
  }

  // ==========================================================
  // STATISTICS
  // ==========================================================

  int get todayCount {
    return appointments.where(isToday).length;
  }

  int get completedCount {
    return appointments.where((a) => a.completed).length;
  }

  int get reminderCount {
    return appointments
        .where(
          (a) =>
              !a.completed &&
              a.reminderMinutes >= 0,
        )
        .length;
  }

  int get overdueCount {
    return appointments.where(isOverdue).length;
  }

  Appointment? get nextAppointment {
    final list = appointments
        .where(
          (a) =>
              !a.completed &&
              a.dateTime.isAfter(DateTime.now()),
        )
        .toList();

    list.sort(
      (a, b) => a.dateTime.compareTo(b.dateTime),
    );

    return list.isEmpty ? null : list.first;
  }

  // ==========================================================
  // ADD / EDIT
  // ==========================================================

  Future<void> showAppointmentDialog({
    Appointment? appointment,
  }) async {
    final titleController = TextEditingController(
      text: appointment?.title ?? '',
    );

    final personController = TextEditingController(
      text: appointment?.person ?? '',
    );

    final phoneController = TextEditingController(
      text: appointment?.phone ?? '',
    );

    final locationController = TextEditingController(
      text: appointment?.location ?? '',
    );

    final notesController = TextEditingController(
      text: appointment?.notes ?? '',
    );

    DateTime selectedDate =
        appointment?.dateTime ?? DateTime.now();

    TimeOfDay selectedTime = TimeOfDay(
      hour: appointment?.dateTime.hour ??
          TimeOfDay.now().hour,
      minute: appointment?.dateTime.minute ??
          TimeOfDay.now().minute,
    );

    String selectedType =
        appointment?.type ?? 'عام';

    int selectedReminder =
        appointment?.reminderMinutes ?? defaultReminder;

    String selectedRecurrence =
        appointment?.recurrence ?? 'لا يتكرر';

    final formKey = GlobalKey<FormState>();

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context)
          .scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (sheetContext) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 18,
                right: 18,
                top: 20,
                bottom: MediaQuery.of(context)
                        .viewInsets
                        .bottom +
                    20,
              ),
              child: SingleChildScrollView(
                child: Form(
                  key: formKey,
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.stretch,
                    children: [
                      Center(
                        child: Container(
                          width: 45,
                          height: 5,
                          decoration: BoxDecoration(
                            color: Colors.grey.shade400,
                            borderRadius:
                                BorderRadius.circular(10),
                          ),
                        ),
                      ),
                      const SizedBox(height: 18),

                      Text(
                        appointment == null
                            ? 'إضافة موعد جديد'
                            : 'تعديل الموعد',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 23,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 20),

                      TextFormField(
                        controller: titleController,
                        textDirection: TextDirection.rtl,
                        decoration:
                            const InputDecoration(
                          labelText: 'عنوان الموعد *',
                          prefixIcon:
                              Icon(Icons.title_rounded),
                        ),
                        validator: (value) {
                          if (value == null ||
                              value.trim().isEmpty) {
                            return 'أدخل عنوان الموعد';
                          }
                          return null;
                        },
                      ),

                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        initialValue: selectedType,
                        decoration:
                            const InputDecoration(
                          labelText: 'نوع الموعد',
                          prefixIcon:
                              Icon(Icons.category_rounded),
                        ),
                        items: appointmentTypes
                            .map(
                              (type) =>
                                  DropdownMenuItem(
                                value: type,
                                child: Text(type),
                              ),
                            )
                            .toList(),
                        onChanged: (value) {
                          if (value == null) return;
                          setModalState(() {
                            selectedType = value;
                          });
                        },
                      ),

                      const SizedBox(height: 12),

                      Row(
                        children: [
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(
                                Icons.calendar_month_rounded,
                              ),
                              label: Text(
                                formatDate(selectedDate),
                              ),
                              onPressed: () async {
                                final picked =
                                    await showDatePicker(
                                  context: context,
                                  initialDate: selectedDate,
                                  firstDate:
                                      DateTime(2020),
                                  lastDate:
                                      DateTime(2100),
                                );

                                if (picked != null) {
                                  setModalState(() {
                                    selectedDate = DateTime(
                                      picked.year,
                                      picked.month,
                                      picked.day,
                                    );
                                  });
                                }
                              },
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: OutlinedButton.icon(
                              icon: const Icon(
                                Icons.access_time_rounded,
                              ),
                              label: Text(
                                selectedTime.format(context),
                              ),
                              onPressed: () async {
                                final picked =
                                    await showTimePicker(
                                  context: context,
                                  initialTime: selectedTime,
                                );

                                if (picked != null) {
                                  setModalState(() {
                                    selectedTime = picked;
                                  });
                                }
                              },
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 12),

                      TextFormField(
                        controller: personController,
                        textDirection: TextDirection.rtl,
                        decoration:
                            const InputDecoration(
                          labelText: 'الشخص / الجهة',
                          prefixIcon:
                              Icon(Icons.person_rounded),
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextFormField(
                        controller: phoneController,
                        keyboardType: TextInputType.phone,
                        decoration:
                            const InputDecoration(
                          labelText: 'رقم الهاتف',
                          prefixIcon:
                              Icon(Icons.phone_rounded),
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextFormField(
                        controller: locationController,
                        textDirection: TextDirection.rtl,
                        decoration:
                            const InputDecoration(
                          labelText: 'المكان',
                          prefixIcon:
                              Icon(Icons.location_on_rounded),
                        ),
                      ),

                      const SizedBox(height: 12),

                      TextFormField(
                        controller: notesController,
                        maxLines: 3,
                        textDirection: TextDirection.rtl,
                        decoration:
                            const InputDecoration(
                          labelText: 'ملاحظات',
                          alignLabelWithHint: true,
                          prefixIcon:
                              Icon(Icons.notes_rounded),
                        ),
                      ),

                      const SizedBox(height: 12),

                      DropdownButtonFormField<int>(
                        initialValue: selectedReminder,
                        decoration:
                            const InputDecoration(
                          labelText: 'التذكير',
                          prefixIcon:
                              Icon(Icons.notifications_active_rounded),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: -1,
                            child: Text('بدون تذكير'),
                          ),
                          DropdownMenuItem(
                            value: 0,
                            child: Text('وقت الموعد'),
                          ),
                          DropdownMenuItem(
                            value: 5,
                            child: Text('قبل 5 دقائق'),
                          ),
                          DropdownMenuItem(
                            value: 15,
                            child: Text('قبل 15 دقيقة'),
                          ),
                          DropdownMenuItem(
                            value: 30,
                            child: Text('قبل 30 دقيقة'),
                          ),
                          DropdownMenuItem(
                            value: 60,
                            child: Text('قبل ساعة'),
                          ),
                          DropdownMenuItem(
                            value: 1440,
                            child: Text('قبل يوم'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setModalState(() {
                            selectedReminder = value;
                          });
                        },
                      ),

                      const SizedBox(height: 12),

                      DropdownButtonFormField<String>(
                        initialValue: selectedRecurrence,
                        decoration:
                            const InputDecoration(
                          labelText: 'التكرار',
                          prefixIcon:
                              Icon(Icons.repeat_rounded),
                        ),
                        items: const [
                          DropdownMenuItem(
                            value: 'لا يتكرر',
                            child: Text('لا يتكرر'),
                          ),
                          DropdownMenuItem(
                            value: 'يومياً',
                            child: Text('يومياً'),
                          ),
                          DropdownMenuItem(
                            value: 'أسبوعياً',
                            child: Text('أسبوعياً'),
                          ),
                          DropdownMenuItem(
                            value: 'شهرياً',
                            child: Text('شهرياً'),
                          ),
                        ],
                        onChanged: (value) {
                          if (value == null) return;
                          setModalState(() {
                            selectedRecurrence = value;
                          });
                        },
                      ),

                      const SizedBox(height: 22),

                      FilledButton.icon(
                        icon: const Icon(
                          Icons.save_rounded,
                        ),
                        label: Text(
                          appointment == null
                              ? 'حفظ الموعد'
                              : 'حفظ التعديلات',
                        ),
                        style: FilledButton.styleFrom(
                          minimumSize:
                              const Size.fromHeight(55),
                          shape: RoundedRectangleBorder(
                            borderRadius:
                                BorderRadius.circular(16),
                          ),
                        ),
                        onPressed: () async {
                          if (!formKey.currentState!
                              .validate()) {
                            return;
                          }

                          final dateTime = DateTime(
                            selectedDate.year,
                            selectedDate.month,
                            selectedDate.day,
                            selectedTime.hour,
                            selectedTime.minute,
                          );

                          if (appointment == null) {
                            final newAppointment =
                                Appointment(
                              id: DateTime.now()
                                  .microsecondsSinceEpoch
                                  .toString(),
                              title:
                                  titleController.text.trim(),
                              dateTime: dateTime,
                              type: selectedType,
                              person:
                                  personController.text.trim(),
                              phone:
                                  phoneController.text.trim(),
                              location:
                                  locationController.text.trim(),
                              notes:
                                  notesController.text.trim(),
                              reminderMinutes:
                                  selectedReminder,
                              recurrence:
                                  selectedRecurrence,
                            );

                            appointments
                                .add(newAppointment);

                            await saveData();

                            await scheduleNotification(
                              newAppointment,
                            );
                          } else {
                            await cancelNotification(
                              appointment,
                            );

                            appointment.title =
                                titleController.text.trim();

                            appointment.dateTime = dateTime;
                            appointment.type =
                                selectedType;

                            appointment.person =
                                personController.text.trim();

                            appointment.phone =
                                phoneController.text.trim();

                            appointment.location =
                                locationController.text.trim();

                            appointment.notes =
                                notesController.text.trim();

                            appointment.reminderMinutes =
                                selectedReminder;

                            appointment.recurrence =
                                selectedRecurrence;

                            await saveData();

                            await scheduleNotification(
                              appointment,
                            );
                          }

                          if (mounted) {
                            setState(() {});
                          }

                          Navigator.pop(sheetContext);

                          ScaffoldMessenger.of(context)
                              .showSnackBar(
                            SnackBar(
                              content: Text(
                                appointment == null
                                    ? 'تمت إضافة الموعد بنجاح ✅'
                                    : 'تم تعديل الموعد بنجاح ✅',
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            );
          },
        );
      },
    );

    titleController.dispose();
    personController.dispose();
    phoneController.dispose();
    locationController.dispose();
    notesController.dispose();
  }

  // ==========================================================
  // DELETE
  // ==========================================================

  Future<void> deleteAppointment(
    Appointment appointment,
  ) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('حذف الموعد'),
          content: const Text(
            'هل أنت متأكد أنك تريد حذف هذا الموعد؟',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, false),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(context, true),
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    await cancelNotification(appointment);

    appointments.removeWhere(
      (a) => a.id == appointment.id,
    );

    await saveData();

    setState(() {});

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تم حذف الموعد'),
        ),
      );
    }
  }

  // ==========================================================
  // COMPLETE
  // ==========================================================

  Future<void> toggleCompleted(
    Appointment appointment,
  ) async {
    appointment.completed =
        !appointment.completed;

    if (appointment.completed) {
      await cancelNotification(appointment);
    } else {
      await scheduleNotification(appointment);
    }

    await saveData();

    setState(() {});
  }

  // ==========================================================
  // DETAILS
  // ==========================================================

  void showAppointmentDetails(
    Appointment appointment,
  ) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 45,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.grey,
                        borderRadius:
                            BorderRadius.circular(10),
                      ),
                    ),
                  ),

                  const SizedBox(height: 20),

                  CircleAvatar(
                    radius: 34,
                    backgroundColor:
                        typeColor(appointment.type)
                            .withOpacity(.15),
                    child: Icon(
                      typeIcon(appointment.type),
                      size: 34,
                      color: typeColor(
                        appointment.type,
                      ),
                    ),
                  ),

                  const SizedBox(height: 14),

                  Text(
                    appointment.title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  _detailRow(
                    Icons.calendar_month_rounded,
                    'التاريخ',
                    formatDate(
                      appointment.dateTime,
                    ),
                  ),

                  _detailRow(
                    Icons.access_time_rounded,
                    'الوقت',
                    formatTime(
                      appointment.dateTime,
                    ),
                  ),

                  _detailRow(
                    Icons.category_rounded,
                    'النوع',
                    appointment.type,
                  ),

                  if (appointment.person.isNotEmpty)
                    _detailRow(
                      Icons.person_rounded,
                      'الشخص / الجهة',
                      appointment.person,
                    ),

                  if (appointment.phone.isNotEmpty)
                    _detailRow(
                      Icons.phone_rounded,
                      'الهاتف',
                      appointment.phone,
                    ),

                  if (appointment.location.isNotEmpty)
                    _detailRow(
                      Icons.location_on_rounded,
                      'المكان',
                      appointment.location,
                    ),

                  _detailRow(
                    Icons.notifications_rounded,
                    'التذكير',
                    reminderText(
                      appointment.reminderMinutes,
                    ),
                  ),

                  _detailRow(
                    Icons.repeat_rounded,
                    'التكرار',
                    appointment.recurrence,
                  ),

                  if (appointment.notes.isNotEmpty)
                    _detailRow(
                      Icons.notes_rounded,
                      'الملاحظات',
                      appointment.notes,
                    ),

                  const SizedBox(height: 15),

                  FilledButton.icon(
                    icon: const Icon(
                      Icons.edit_rounded,
                    ),
                    label: const Text(
                      'تعديل الموعد',
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      showAppointmentDialog(
                        appointment: appointment,
                      );
                    },
                  ),

                  const SizedBox(height: 8),

                  OutlinedButton.icon(
                    icon: const Icon(
                      Icons.delete_outline_rounded,
                    ),
                    label: const Text(
                      'حذف الموعد',
                    ),
                    onPressed: () {
                      Navigator.pop(context);
                      deleteAppointment(
                        appointment,
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(
    IconData icon,
    String title,
    String value,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 7,
      ),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 22,
            color: Theme.of(context)
                .colorScheme
                .primary,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // CALENDAR
  // ==========================================================

  void showCalendar() {
    DateTime selected =
        DateTime.now();

    showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final monthAppointments =
                appointments.where(
              (a) =>
                  a.dateTime.year == selected.year &&
                  a.dateTime.month == selected.month,
            ).toList();

            return AlertDialog(
              title: Row(
                children: [
                  const Icon(
                    Icons.calendar_month_rounded,
                  ),
                  const SizedBox(width: 8),
                  const Expanded(
                    child: Text('تقويم المواعيد'),
                  ),
                ],
              ),
              content: SizedBox(
                width: 420,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    CalendarDatePicker(
                      initialDate: selected,
                      firstDate: DateTime(2020),
                      lastDate: DateTime(2100),
                      onDateChanged: (date) {
                        setDialogState(() {
                          selected = date;
                        });
                      },
                    ),

                    const Divider(),

                    Align(
                      alignment:
                          Alignment.centerRight,
                      child: Text(
                        'مواعيد هذا الشهر: ${monthAppointments.length}',
                        style: const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),

                    const SizedBox(height: 10),

                    if (monthAppointments.isEmpty)
                      const Padding(
                        padding:
                            EdgeInsets.all(15),
                        child: Text(
                          'لا توجد مواعيد هذا الشهر',
                        ),
                      )
                    else
                      SizedBox(
                        height: 170,
                        child: ListView.builder(
                          itemCount:
                              monthAppointments.length,
                          itemBuilder:
                              (context, index) {
                            final a =
                                monthAppointments[
                                    index];

                            return ListTile(
                              dense: true,
                              leading: CircleAvatar(
                                backgroundColor:
                                    typeColor(
                                      a.type,
                                    ).withOpacity(.15),
                                child: Icon(
                                  typeIcon(
                                    a.type,
                                  ),
                                  color:
                                      typeColor(
                                    a.type,
                                  ),
                                  size: 20,
                                ),
                              ),
                              title: Text(
                                a.title,
                                maxLines: 1,
                                overflow:
                                    TextOverflow
                                        .ellipsis,
                              ),
                              subtitle: Text(
                                '${formatDate(a.dateTime)} - ${formatTime(a.dateTime)}',
                              ),
                            );
                          },
                        ),
                      ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () =>
                      Navigator.pop(dialogContext),
                  child: const Text('إغلاق'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  // ==========================================================
  // STATISTICS
  // ==========================================================

  void showStatistics() {
    final total = appointments.length;

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.bar_chart_rounded),
              SizedBox(width: 8),
              Text('إحصائيات موعدي'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _statRow(
                'كل المواعيد',
                total,
                Icons.event_rounded,
              ),
              _statRow(
                'مواعيد اليوم',
                todayCount,
                Icons.today_rounded,
              ),
              _statRow(
                'القادمة',
                appointments
                    .where(
                      (a) =>
                          !a.completed &&
                          a.dateTime
                              .isAfter(DateTime.now()),
                    )
                    .length,
                Icons.upcoming_rounded,
              ),
              _statRow(
                'المكتملة',
                completedCount,
                Icons.check_circle_rounded,
              ),
              _statRow(
                'المتأخرة',
                overdueCount,
                Icons.warning_rounded,
              ),
              _statRow(
                'بتذكير',
                reminderCount,
                Icons.notifications_rounded,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context),
              child: const Text('إغلاق'),
            ),
          ],
        );
      },
    );
  }

  Widget _statRow(
    String title,
    int value,
    IconData icon,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 7,
      ),
      child: Row(
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Text(title),
          ),
          Text(
            value.toString(),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // SETTINGS
  // ==========================================================

  Future<void> showSettings() async {
    int reminder = defaultReminder;

    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text(
                      'الإعدادات',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 20),

                    SwitchListTile(
                      secondary: const Icon(
                        Icons.dark_mode_rounded,
                      ),
                      title: const Text(
                        'الوضع الليلي',
                      ),
                      value: widget.darkMode,
                      onChanged: (value) async {
                        await widget.onThemeChanged(
                          value,
                        );

                        if (mounted) {
                          setState(() {});
                        }

                        setModalState(() {});
                      },
                    ),

                    ListTile(
                      leading: const Icon(
                        Icons.notifications_active_rounded,
                      ),
                      title: const Text(
                        'التذكير الافتراضي',
                      ),
                      subtitle: Text(
                        reminderText(reminder),
                      ),
                      onTap: () async {
                        final value =
                            await showDialog<int>(
                          context: context,
                          builder: (context) {
                            return SimpleDialog(
                              title: const Text(
                                'التذكير الافتراضي',
                              ),
                              children: const [
                                SimpleDialogOption(
                                  child:
                                      Text('بدون تذكير'),
                                  value: -1,
                                ),
                                SimpleDialogOption(
                                  child:
                                      Text('وقت الموعد'),
                                  value: 0,
                                ),
                                SimpleDialogOption(
                                  child:
                                      Text('قبل 5 دقائق'),
                                  value: 5,
                                ),
                                SimpleDialogOption(
                                  child:
                                      Text('قبل 15 دقيقة'),
                                  value: 15,
                                ),
                                SimpleDialogOption(
                                  child:
                                      Text('قبل 30 دقيقة'),
                                  value: 30,
                                ),
                                SimpleDialogOption(
                                  child:
                                      Text('قبل ساعة'),
                                  value: 60,
                                ),
                                SimpleDialogOption(
                                  child:
                                      Text('قبل يوم'),
                                  value: 1440,
                                ),
                              ],
                            );
                          },
                        );

                        if (value != null) {
                          final prefs =
                              await SharedPreferences
                                  .getInstance();

                          await prefs.setInt(
                            'defaultReminder',
                            value,
                          );

                          setState(() {
                            defaultReminder = value;
                          });

                          setModalState(() {
                            reminder = value;
                          });
                        }
                      },
                    ),

                    ListTile(
                      leading: const Icon(
                        Icons.delete_sweep_rounded,
                      ),
                      title: const Text(
                        'حذف المواعيد المكتملة',
                      ),
                      onTap: () async {
                        Navigator.pop(context);
                        await clearCompleted();
                      },
                    ),

                    ListTile(
                      leading: const Icon(
                        Icons.notifications_rounded,
                      ),
                      title: const Text(
                        'تحديث التذكيرات',
                      ),
                      onTap: () async {
                        await refreshNotifications();

                        if (mounted) {
                          Navigator.pop(context);

                          ScaffoldMessenger.of(
                            this.context,
                          ).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'تم تحديث التذكيرات ✅',
                              ),
                            ),
                          );
                        }
                      },
                    ),

                    ListTile(
                      leading: const Icon(
                        Icons.backup_rounded,
                      ),
                      title: const Text(
                        'نسخ احتياطي',
                      ),
                      subtitle: const Text(
                        'نسخ المواعيد إلى الحافظة',
                      ),
                      onTap: () async {
                        await backupToClipboard();

                        if (mounted) {
                          Navigator.pop(context);

                          ScaffoldMessenger.of(
                            this.context,
                          ).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'تم نسخ النسخة الاحتياطية ✅',
                              ),
                            ),
                          );
                        }
                      },
                    ),

                    ListTile(
                      leading: const Icon(
                        Icons.restore_rounded,
                      ),
                      title: const Text(
                        'استرجاع نسخة احتياطية',
                      ),
                      subtitle: const Text(
                        'استرجاع المواعيد من الحافظة',
                      ),
                      onTap: () async {
                        Navigator.pop(context);
                        await restoreFromClipboard();
                      },
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  // ==========================================================
  // BACKUP
  // ==========================================================

  Future<void> backupToClipboard() async {
    final data = appointments
        .map((a) => a.toJson())
        .toList();

    await Clipboard.setData(
      ClipboardData(
        text: jsonEncode(data),
      ),
    );
  }

  Future<void> restoreFromClipboard() async {
    final data =
        await Clipboard.getData('text/plain');

    if (data == null ||
        data.text == null ||
        data.text!.trim().isEmpty) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'ماكانش نسخة احتياطية في الحافظة',
            ),
          ),
        );
      }
      return;
    }

    try {
      final decoded =
          jsonDecode(data.text!);

      if (decoded is! List) {
        throw Exception();
      }

      final restored = decoded
          .map(
            (e) => Appointment.fromJson(
              Map<String, dynamic>.from(e),
            ),
          )
          .toList();

      final confirm =
          await showDialog<bool>(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text(
              'استرجاع النسخة الاحتياطية',
            ),
            content: Text(
              'تم العثور على ${restored.length} موعد.\n'
              'هل تريد استبدال المواعيد الحالية؟',
            ),
            actions: [
              TextButton(
                onPressed: () =>
                    Navigator.pop(context, false),
                child: const Text('إلغاء'),
              ),
              FilledButton(
                onPressed: () =>
                    Navigator.pop(context, true),
                child: const Text('استرجاع'),
              ),
            ],
          );
        },
      );

      if (confirm != true) return;

      for (final appointment in appointments) {
        await cancelNotification(appointment);
      }

      appointments = restored;

      await saveData();
      await refreshNotifications();

      setState(() {});

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'تم استرجاع المواعيد بنجاح ✅',
            ),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'النسخة الاحتياطية غير صالحة ❌',
            ),
          ),
        );
      }
    }
  }

  // ==========================================================
  // CLEAR COMPLETED
  // ==========================================================

  Future<void> clearCompleted() async {
    final completed =
        appointments.where((a) => a.completed).toList();

    if (completed.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'ماكان حتى موعد مكتمل',
          ),
        ),
      );
      return;
    }

    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'حذف المواعيد المكتملة',
          ),
          content: Text(
            'سيتم حذف ${completed.length} موعد مكتمل.',
          ),
          actions: [
            TextButton(
              onPressed: () =>
                  Navigator.pop(context, false),
              child: const Text('إلغاء'),
            ),
            FilledButton(
              onPressed: () =>
                  Navigator.pop(context, true),
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    for (final appointment in completed) {
      await cancelNotification(appointment);
    }

    appointments.removeWhere(
      (a) => a.completed,
    );

    await saveData();

    setState(() {});
  }

  // ==========================================================
  // UI COMPONENTS
  // ==========================================================

  Widget dashboardCard({
    required String title,
    required String value,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Expanded(
      child: InkWell(
        borderRadius: BorderRadius.circular(20),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: color.withOpacity(.10),
            borderRadius:
                BorderRadius.circular(20),
            border: Border.all(
              color: color.withOpacity(.15),
            ),
          ),
          child: Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 19,
                backgroundColor:
                    color.withOpacity(.15),
                child: Icon(
                  icon,
                  color: color,
                  size: 21,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                value,
                style: TextStyle(
                  fontSize: 25,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  color: color.withOpacity(.85),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget appointmentCard(
    Appointment appointment,
  ) {
    final color = typeColor(
      appointment.type,
    );

    final overdue = isOverdue(appointment);

    return Card(
      child: InkWell(
        borderRadius:
            BorderRadius.circular(20),
        onTap: () {
          showAppointmentDetails(
            appointment,
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            children: [
              Row(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 25,
                    backgroundColor:
                        color.withOpacity(.13),
                    child: Icon(
                      typeIcon(
                        appointment.type,
                      ),
                      color: color,
                    ),
                  ),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                appointment.title,
                                maxLines: 2,
                                overflow:
                                    TextOverflow.ellipsis,
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight:
                                      FontWeight.bold,
                                  decoration:
                                      appointment
                                              .completed
                                          ? TextDecoration
                                              .lineThrough
                                          : null,
                                ),
                              ),
                            ),
                            if (appointment.completed)
                              const Icon(
                                Icons
                                    .check_circle_rounded,
                                color: Colors.green,
                                size: 22,
                              ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        Wrap(
                          spacing: 7,
                          runSpacing: 5,
                          children: [
                            _smallInfo(
                              Icons.calendar_today_rounded,
                              formatDate(
                                appointment.dateTime,
                              ),
                            ),
                            _smallInfo(
                              Icons.access_time_rounded,
                              formatTime(
                                appointment.dateTime,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 6),

                        Wrap(
                          spacing: 7,
                          runSpacing: 5,
                          children: [
                            if (appointment.person
                                .isNotEmpty)
                              _smallInfo(
                                Icons.person_rounded,
                                appointment.person,
                              ),
                            _smallInfo(
                              Icons.category_rounded,
                              appointment.type,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  PopupMenuButton<String>(
                    onSelected: (value) async {
                      if (value == 'edit') {
                        await showAppointmentDialog(
                          appointment: appointment,
                        );
                      } else if (value == 'delete') {
                        await deleteAppointment(
                          appointment,
                        );
                      } else if (value == 'complete') {
                        await toggleCompleted(
                          appointment,
                        );
                      }
                    },
                    itemBuilder: (context) {
                      return [
                        PopupMenuItem(
                          value: 'complete',
                          child: Row(
                            children: [
                              Icon(
                                appointment.completed
                                    ? Icons
                                        .undo_rounded
                                    : Icons
                                        .check_rounded,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                appointment.completed
                                    ? 'إلغاء الإكمال'
                                    : 'تم الإنجاز',
                              ),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'edit',
                          child: Row(
                            children: [
                              Icon(
                                Icons.edit_rounded,
                              ),
                              SizedBox(width: 8),
                              Text('تعديل'),
                            ],
                          ),
                        ),
                        const PopupMenuItem(
                          value: 'delete',
                          child: Row(
                            children: [
                              Icon(
                                Icons
                                    .delete_outline_rounded,
                              ),
                              SizedBox(width: 8),
                              Text('حذف'),
                            ],
                          ),
                        ),
                      ];
                    },
                  ),
                ],
              ),

              if (overdue)
                Container(
                  width: double.infinity,
                  margin: const EdgeInsets.only(
                    top: 12,
                  ),
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.red.withOpacity(.08),
                    borderRadius:
                        BorderRadius.circular(10),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.warning_rounded,
                        color: Colors.red,
                        size: 18,
                      ),
                      SizedBox(width: 7),
                      Text(
                        'هذا الموعد متأخر',
                        style: TextStyle(
                          color: Colors.red,
                          fontWeight:
                              FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),

              if (appointment.reminderMinutes >=
                      0 ||
                  appointment.recurrence !=
                      'لا يتكرر')
                Padding(
                  padding: const EdgeInsets.only(
                    top: 10,
                  ),
                  child: Row(
                    children: [
                      if (appointment
                              .reminderMinutes >=
                          0)
                        _smallInfo(
                          Icons.notifications_rounded,
                          reminderText(
                            appointment
                                .reminderMinutes,
                          ),
                        ),
                      if (appointment
                              .recurrence !=
                          'لا يتكرر') ...[
                        const SizedBox(width: 8),
                        _smallInfo(
                          Icons.repeat_rounded,
                          appointment.recurrence,
                        ),
                      ],
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _smallInfo(
    IconData icon,
    String text,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 8,
        vertical: 4,
      ),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withOpacity(.55),
        borderRadius:
            BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: const TextStyle(
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================================
  // BUILD
  // ==========================================================

  @override
  Widget build(BuildContext context) {
    final next = nextAppointment;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          title: const Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                'موعدي',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 24,
                ),
              ),
              Text(
                'نظّم وقتك بسهولة',
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.normal,
                ),
              ),
            ],
          ),
          actions: [
            IconButton(
              tooltip: 'التقويم',
              icon: const Icon(
                Icons.calendar_month_rounded,
              ),
              onPressed: showCalendar,
            ),
            IconButton(
              tooltip: 'الإحصائيات',
              icon: const Icon(
                Icons.bar_chart_rounded,
              ),
              onPressed: showStatistics,
            ),
            IconButton(
              tooltip: 'الإعدادات',
              icon: const Icon(
                Icons.settings_rounded,
              ),
              onPressed: showSettings,
            ),
          ],
        ),

        body: RefreshIndicator(
          onRefresh: () async {
            await loadData();
          },
          child: ListView(
            padding: const EdgeInsets.only(
              top: 10,
              bottom: 100,
            ),
            children: [
              // HEADER
              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 16,
                ),
                child: Container(
                  padding:
                      const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        Theme.of(context)
                            .colorScheme
                            .primary,
                        Theme.of(context)
                            .colorScheme
                            .secondary,
                      ],
                    ),
                    borderRadius:
                        BorderRadius.circular(25),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'مرحبا 👋',
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 5),
                            const Text(
                              'وش عندك اليوم؟',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 23,
                                fontWeight:
                                    FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              '${formatDate(DateTime.now())} • ${weekday(DateTime.now())}',
                              style: const TextStyle(
                                color: Colors.white70,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(
                        Icons.event_available_rounded,
                        color: Colors.white,
                        size: 65,
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 15),

              // DASHBOARD
              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                child: Row(
                  children: [
                    dashboardCard(
                      title: 'اليوم',
                      value: todayCount.toString(),
                      icon: Icons.today_rounded,
                      color: Colors.blue,
                      onTap: () {
                        setState(() {
                          selectedFilter = 'اليوم';
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    dashboardCard(
                      title: 'القادمة',
                      value: appointments
                          .where(
                            (a) =>
                                !a.completed &&
                                a.dateTime.isAfter(
                                  DateTime.now(),
                                ),
                          )
                          .length
                          .toString(),
                      icon:
                          Icons.upcoming_rounded,
                      color: Colors.green,
                      onTap: () {
                        setState(() {
                          selectedFilter = 'القادمة';
                        });
                      },
                    ),
                    const SizedBox(width: 8),
                    dashboardCard(
                      title: 'مكتملة',
                      value:
                          completedCount.toString(),
                      icon:
                          Icons.check_circle_rounded,
                      color: Colors.teal,
                      onTap: () {
                        setState(() {
                          selectedFilter =
                              'المكتملة';
                        });
                      },
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 10),

              // NEXT APPOINTMENT
              if (next != null)
                Padding(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 12,
                  ),
                  child: Card(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment:
                            CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                Icons
                                    .notifications_active_rounded,
                                color:
                                    Theme.of(context)
                                        .colorScheme
                                        .primary,
                              ),
                              const SizedBox(width: 8),
                              const Text(
                                'أقرب موعد',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                            ],
                          ),

                          const SizedBox(height: 10),

                          Text(
                            next.title,
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 8),

                          Row(
                            children: [
                              const Icon(
                                Icons
                                    .calendar_today_rounded,
                                size: 17,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                formatDate(
                                  next.dateTime,
                                ),
                              ),
                              const SizedBox(width: 15),
                              const Icon(
                                Icons
                                    .access_time_rounded,
                                size: 17,
                              ),
                              const SizedBox(width: 5),
                              Text(
                                formatTime(
                                  next.dateTime,
                                ),
                              ),
                            ],
                          ),

                          if (next.location.isNotEmpty)
                            Padding(
                              padding:
                                  const EdgeInsets.only(
                                top: 7,
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons
                                        .location_on_rounded,
                                    size: 17,
                                  ),
                                  const SizedBox(
                                    width: 5,
                                  ),
                                  Expanded(
                                    child: Text(
                                      next.location,
                                      overflow:
                                          TextOverflow
                                              .ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                        ],
                      ),
                    ),
                  ),
                ),

              const SizedBox(height: 10),

              // SEARCH
              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                child: TextField(
                  textDirection:
                      TextDirection.rtl,
                  onChanged: (value) {
                    setState(() {
                      searchText = value;
                    });
                  },
                  decoration: InputDecoration(
                    hintText:
                        'ابحث عن موعد، شخص، مكان...',
                    prefixIcon: const Icon(
                      Icons.search_rounded,
                    ),
                    suffixIcon:
                        searchText.isNotEmpty
                            ? IconButton(
                                icon: const Icon(
                                  Icons.clear_rounded,
                                ),
                                onPressed: () {
                                  setState(() {
                                    searchText = '';
                                  });
                                },
                              )
                            : null,
                  ),
                ),
              ),

              const SizedBox(height: 10),

              // FILTERS
              SizedBox(
                height: 48,
                child: ListView.separated(
                  padding:
                      const EdgeInsets.symmetric(
                    horizontal: 12,
                  ),
                  scrollDirection: Axis.horizontal,
                  itemCount: filters.length,
                  separatorBuilder:
                      (_, __) =>
                          const SizedBox(width: 7),
                  itemBuilder: (context, index) {
                    final filter =
                        filters[index];

                    final selected =
                        selectedFilter == filter;

                    return ChoiceChip(
                      label: Text(filter),
                      selected: selected,
                      onSelected: (_) {
                        setState(() {
                          selectedFilter = filter;
                        });
                      },
                    );
                  },
                ),
              ),

              const SizedBox(height: 5),

              // LIST HEADER
              Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 5,
                ),
                child: Row(
                  children: [
                    const Expanded(
                      child: Text(
                        'مواعيدك',
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '${filteredAppointments.length} موعد',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // APPOINTMENTS
              if (filteredAppointments.isEmpty)
                Padding(
                  padding:
                      const EdgeInsets.all(35),
                  child: Column(
                    children: [
                      Icon(
                        Icons
                            .event_busy_rounded,
                        size: 70,
                        color: Colors.grey.shade400,
                      ),
                      const SizedBox(height: 12),
                      Text(
                        searchText.isNotEmpty
                            ? 'ما لقيناش نتائج'
                            : 'ما عندك حتى موعد',
                        style: TextStyle(
                          color:
                              Colors.grey.shade600,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () {
                          showAppointmentDialog();
                        },
                        icon: const Icon(
                          Icons.add_rounded,
                        ),
                        label: const Text(
                          'أضف أول موعد',
                        ),
                      ),
                    ],
                  ),
                )
              else
                ...filteredAppointments.map(
                  appointmentCard,
                ),
            ],
          ),
        ),

        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            showAppointmentDialog();
          },
          icon: const Icon(
            Icons.add_rounded,
          ),
          label: const Text(
            'موعد جديد',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ),
    );
  }
}
