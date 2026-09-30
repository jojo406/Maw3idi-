import 'package:flutter/material.dart';
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

  String serialize() {
    return [
      id,
      title,
      date.toIso8601String(),
      time.hour,
      time.minute,
      type,
      person,
      phone,
      location,
      notes,
      reminderMinutes,
      completed,
    ].join('|');
  }

  static Appointment deserialize(String value) {
    final parts = value.split('|');

    return Appointment(
      id: parts.isNotEmpty ? parts[0] : DateTime.now().toString(),
      title: parts.length > 1 ? parts[1] : '',
      date: parts.length > 2
          ? DateTime.tryParse(parts[2]) ?? DateTime.now()
          : DateTime.now(),
      time: TimeOfDay(
        hour: parts.length > 3 ? int.tryParse(parts[3]) ?? 0 : 0,
        minute: parts.length > 4 ? int.tryParse(parts[4]) ?? 0 : 0,
      ),
      type: parts.length > 5 ? parts[5] : 'عام',
      person: parts.length > 6 ? parts[6] : '',
      phone: parts.length > 7 ? parts[7] : '',
      location: parts.length > 8 ? parts[8] : '',
      notes: parts.length > 9 ? parts[9] : '',
      reminderMinutes:
          parts.length > 10 ? int.tryParse(parts[10]) ?? -1 : -1,
      completed:
          parts.length > 11 ? parts[11].toLowerCase() == 'true' : false,
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
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'موعدي',
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.light,
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
        brightness: Brightness.dark,
      ),
      home: HomePage(
        onThemeChanged: () {
          setState(() {
            darkMode = !darkMode;
          });
        },
      ),
    );
  }
}

// ============================================================
// HOME PAGE
// ============================================================

class HomePage extends StatefulWidget {
  final VoidCallback onThemeChanged;

  const HomePage({
    super.key,
    required this.onThemeChanged,
  });

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  List<Appointment> appointments = [];

  String searchText = '';
  String selectedFilter = 'الكل';

  final List<String> appointmentTypes = [
    'طبيب',
    'مستشفى',
    'عمل',
    'دراسة',
    'إدارة',
    'عائلي',
    'عام',
  ];

  @override
  void initState() {
    super.initState();
    loadAppointments();
  }

  // ==========================================================
  // STORAGE
  // ==========================================================

  Future<void> loadAppointments() async {
    final prefs = await SharedPreferences.getInstance();

    final saved = prefs.getStringList('appointments') ?? [];

    setState(() {
      appointments = saved
          .map((item) => Appointment.deserialize(item))
          .toList();
    });
  }

  Future<void> saveAppointments() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setStringList(
      'appointments',
      appointments.map((e) => e.serialize()).toList(),
    );
  }

  // ==========================================================
  // DATE / TIME
  // ==========================================================

  DateTime appointmentDateTime(Appointment appointment) {
    return DateTime(
      appointment.date.year,
      appointment.date.month,
      appointment.date.day,
      appointment.time.hour,
      appointment.time.minute,
    );
  }

  // ==========================================================
  // NOTIFICATIONS
  // ==========================================================

  Future<void> scheduleNotification(Appointment appointment) async {
    await notificationsPlugin.cancel(
      appointment.id.hashCode.abs(),
    );

    if (appointment.reminderMinutes < 0) {
      return;
    }

    final appointmentDateTimeValue =
        appointmentDateTime(appointment);

    final scheduledDate = tz.TZDateTime.from(
      appointmentDateTimeValue,
      tz.local,
    ).subtract(
      Duration(minutes: appointment.reminderMinutes),
    );

    if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
      return;
    }

    const notificationDetails = NotificationDetails(
      android: AndroidNotificationDetails(
        'maw3idi_reminders',
        'تذكيرات موعدي',
        channelDescription: 'تنبيهات المواعيد',
        importance: Importance.high,
        priority: Priority.high,
      ),
    );

    await notificationsPlugin.zonedSchedule(
      id: appointment.id.hashCode.abs(),
      title: 'تذكير بموعدك 🔔',
      body: appointment.title,
      scheduledDate: scheduledDate,
      notificationDetails: notificationDetails,
      androidScheduleMode:
          AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  Future<void> cancelNotification(Appointment appointment) async {
    await notificationsPlugin.cancel(
      appointment.id.hashCode.abs(),
    );
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
        appointment?.date ?? DateTime.now();

    TimeOfDay selectedTime =
        appointment?.time ??
            TimeOfDay.now();

    String selectedType =
        appointment?.type ?? appointmentTypes.first;

    int selectedReminder =
        appointment?.reminderMinutes ?? 15;

    final formKey = GlobalKey<FormState>();

    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                appointment == null
                    ? 'إضافة موعد'
                    : 'تعديل الموعد',
              ),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Form(
                    key: formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: titleController,
                          decoration: const InputDecoration(
                            labelText: 'عنوان الموعد',
                            prefixIcon:
                                Icon(Icons.event),
                          ),
                          validator: (value) {
                            if (value == null ||
                                value.trim().isEmpty) {
                              return 'اكتب عنوان الموعد';
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
                                Icon(Icons.category),
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
                            if (value != null) {
                              setDialogState(() {
                                selectedType = value;
                              });
                            }
                          },
                        ),

                        const SizedBox(height: 12),

                        ListTile(
                          leading:
                              const Icon(Icons.calendar_month),
                          title: const Text('التاريخ'),
                          subtitle: Text(
                            '${selectedDate.day}/'
                            '${selectedDate.month}/'
                            '${selectedDate.year}',
                          ),
                          onTap: () async {
                            final picked =
                                await showDatePicker(
                              context: context,
                              initialDate: selectedDate,
                              firstDate: DateTime(2020),
                              lastDate: DateTime(2100),
                            );

                            if (picked != null) {
                              setDialogState(() {
                                selectedDate = picked;
                              });
                            }
                          },
                        ),

                        ListTile(
                          leading:
                              const Icon(Icons.access_time),
                          title: const Text('الساعة'),
                          subtitle:
                              Text(selectedTime.format(context)),
                          onTap: () async {
                            final picked =
                                await showTimePicker(
                              context: context,
                              initialTime: selectedTime,
                            );

                            if (picked != null) {
                              setDialogState(() {
                                selectedTime = picked;
                              });
                            }
                          },
                        ),

                        TextFormField(
                          controller: personController,
                          decoration:
                              const InputDecoration(
                            labelText: 'الشخص',
                            prefixIcon:
                                Icon(Icons.person),
                          ),
                        ),

                        const SizedBox(height: 12),

                        TextFormField(
                          controller: phoneController,
                          keyboardType:
                              TextInputType.phone,
                          decoration:
                              const InputDecoration(
                            labelText: 'رقم الهاتف',
                            prefixIcon:
                                Icon(Icons.phone),
                          ),
                        ),

                        const SizedBox(height: 12),

                        TextFormField(
                          controller: locationController,
                          decoration:
                              const InputDecoration(
                            labelText: 'المكان',
                            prefixIcon:
                                Icon(Icons.location_on),
                          ),
                        ),

                        const SizedBox(height: 12),

                        TextFormField(
                          controller: notesController,
                          maxLines: 3,
                          decoration:
                              const InputDecoration(
                            labelText: 'ملاحظات',
                            prefixIcon:
                                Icon(Icons.notes),
                          ),
                        ),

                        const SizedBox(height: 12),

                        DropdownButtonFormField<int>(
                          initialValue: selectedReminder,
                          decoration:
                              const InputDecoration(
                            labelText: 'التذكير',
                            prefixIcon:
                                Icon(Icons.notifications),
                          ),
                          items: const [
                            DropdownMenuItem(
                              value: -1,
                              child: Text('بدون تذكير'),
                            ),
                            DropdownMenuItem(
                              value: 0,
                              child: Text(
                                'وقت الموعد',
                              ),
                            ),
                            DropdownMenuItem(
                              value: 5,
                              child: Text(
                                'قبل 5 دقائق',
                              ),
                            ),
                            DropdownMenuItem(
                              value: 15,
                              child: Text(
                                'قبل 15 دقيقة',
                              ),
                            ),
                            DropdownMenuItem(
                              value: 30,
                              child: Text(
                                'قبل 30 دقيقة',
                              ),
                            ),
                            DropdownMenuItem(
                              value: 60,
                              child: Text(
                                'قبل ساعة',
                              ),
                            ),
                            DropdownMenuItem(
                              value: 1440,
                              child: Text(
                                'قبل يوم',
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setDialogState(() {
                                selectedReminder = value;
                              });
                            }
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context, false);
                  },
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (formKey.currentState!.validate()) {
                      Navigator.pop(context, true);
                    }
                  },
                  child: Text(
                    appointment == null
                        ? 'إضافة'
                        : 'حفظ',
                  ),
                ),
              ],
            );
          },
        );
      },
    );

    if (result != true) return;

    final newAppointment = Appointment(
      id: appointment?.id ??
          DateTime.now().microsecondsSinceEpoch.toString(),
      title: titleController.text.trim(),
      date: selectedDate,
      time: selectedTime,
      type: selectedType,
      person: personController.text.trim(),
      phone: phoneController.text.trim(),
      location: locationController.text.trim(),
      notes: notesController.text.trim(),
      reminderMinutes: selectedReminder,
      completed: appointment?.completed ?? false,
    );

    setState(() {
      if (appointment == null) {
        appointments.add(newAppointment);
      } else {
        final index =
            appointments.indexWhere(
          (item) => item.id == appointment.id,
        );

        if (index != -1) {
          appointments[index] = newAppointment;
        }
      }
    });

    await saveAppointments();
    await scheduleNotification(newAppointment);

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          appointment == null
              ? 'تمت إضافة الموعد ✅'
              : 'تم تعديل الموعد ✅',
        ),
      ),
    );
  }

  // ==========================================================
  // DELETE
  // ==========================================================

  Future<void> deleteAppointment(
    Appointment appointment,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('حذف الموعد'),
          content: Text(
            'هل تريد حذف "${appointment.title}"؟',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context, false);
              },
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context, true);
              },
              child: const Text('حذف'),
            ),
          ],
        );
      },
    );

    if (confirmed != true) return;

    await cancelNotification(appointment);

    setState(() {
      appointments.remove(appointment);
    });

    await saveAppointments();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم حذف الموعد'),
      ),
    );
  }

  // ==========================================================
  // COMPLETE
  // ==========================================================

  Future<void> toggleCompleted(
    Appointment appointment,
  ) async {
    setState(() {
      appointment.completed =
          !appointment.completed;
    });

    await saveAppointments();

    if (appointment.completed) {
      await cancelNotification(appointment);
    } else {
      await scheduleNotification(appointment);
    }
  }

  // ==========================================================
  // FILTER / SEARCH
  // ==========================================================

  List<Appointment> get filteredAppointments {
    final query = searchText.toLowerCase();

    final result = appointments.where(
      (appointment) {
        final matchesSearch =
            appointment.title
                    .toLowerCase()
                    .contains(query) ||
                appointment.person
                    .toLowerCase()
                    .contains(query) ||
                appointment.location
                    .toLowerCase()
                    .contains(query) ||
                appointment.type
                    .toLowerCase()
                    .contains(query);

        final matchesFilter =
            selectedFilter == 'الكل' ||
                appointment.type == selectedFilter;

        return matchesSearch && matchesFilter;
      },
    ).toList();

    result.sort(
      (a, b) {
        final aDate =
            appointmentDateTime(a);

        final bDate =
            appointmentDateTime(b);

        return aDate.compareTo(bDate);
      },
    );

    return result;
  }

  // ==========================================================
  // STATISTICS
  // ==========================================================

  int get todayCount {
    final now = DateTime.now();

    return appointments.where(
      (appointment) {
        return appointment.date.year == now.year &&
            appointment.date.month == now.month &&
            appointment.date.day == now.day;
      },
    ).length;
  }

  int get completedCount {
    return appointments
        .where((appointment) => appointment.completed)
        .length;
  }

  int get reminderCount {
    return appointments
        .where(
          (appointment) =>
              appointment.reminderMinutes >= 0,
        )
        .length;
  }

  Appointment? get nextAppointment {
    final now = DateTime.now();

    final upcoming = appointments.where(
      (appointment) {
        return !appointment.completed &&
            appointmentDateTime(appointment)
                .isAfter(now);
      },
    ).toList();

    upcoming.sort(
      (a, b) =>
          appointmentDateTime(a)
              .compareTo(
                appointmentDateTime(b),
              ),
    );

    if (upcoming.isEmpty) return null;

    return upcoming.first;
  }

  // ==========================================================
  // STATISTICS DIALOG
  // ==========================================================

  Future<void> showStatistics() async {
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('إحصائيات موعدي'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _statRow(
                Icons.event,
                'كل المواعيد',
                appointments.length.toString(),
              ),
              _statRow(
                Icons.today,
                'مواعيد اليوم',
                todayCount.toString(),
              ),
              _statRow(
                Icons.check_circle,
                'المكتملة',
                completedCount.toString(),
              ),
              _statRow(
                Icons.notifications_active,
                'التنبيهات',
                reminderCount.toString(),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: const Text('إغلاق'),
            ),
          ],
        );
      },
    );
  }

  Widget _statRow(
    IconData icon,
    String title,
    String value,
  ) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title),
      trailing: Text(
        value,
        style: const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  // ==========================================================
  // CALENDAR
  // ==========================================================

  Future<void> showCalendar() async {
    DateTime selectedDate = DateTime.now();

    await showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            final dayAppointments =
                appointments.where(
              (appointment) {
                return appointment.date.year ==
                        selectedDate.year &&
                    appointment.date.month ==
                        selectedDate.month &&
                    appointment.date.day ==
                        selectedDate.day;
              },
            ).toList();

            return AlertDialog(
              title: const Text('📅 التقويم'),
              content: SizedBox(
                width: double.maxFinite,
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CalendarDatePicker(
                        initialDate: selectedDate,
                        firstDate: DateTime(2020),
                        lastDate: DateTime(2100),
                        onDateChanged: (date) {
                          setDialogState(() {
                            selectedDate = date;
                          });
                        },
                      ),
                      const Divider(),
                      if (dayAppointments.isEmpty)
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'ماكانش مواعيد في هذا اليوم',
                          ),
                        )
                      else
                        ...dayAppointments.map(
                          (appointment) => ListTile(
                            leading: Icon(
                              appointment.completed
                                  ? Icons.check_circle
                                  : Icons.event,
                            ),
                            title: Text(
                              appointment.title,
                            ),
                            subtitle: Text(
                              '${appointment.time.hour.toString().padLeft(2, '0')}:'
                              '${appointment.time.minute.toString().padLeft(2, '0')}'
                              ' • ${appointment.type}',
                            ),
                            onTap: () {
                              Navigator.pop(context);

                              showAppointmentDetails(
                                appointment,
                              );
                            },
                          ),
                        ),
                    ],
                  ),
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
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
  // DETAILS
  // ==========================================================

  Future<void> showAppointmentDetails(
    Appointment appointment,
  ) async {
    await showModalBottomSheet(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    appointment.title,
                    style: const TextStyle(
                      fontSize: 25,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 18),

                  _detailRow(
                    Icons.category,
                    'النوع',
                    appointment.type,
                  ),

                  _detailRow(
                    Icons.calendar_month,
                    'التاريخ',
                    '${appointment.date.day}/'
                    '${appointment.date.month}/'
                    '${appointment.date.year}',
                  ),

                  _detailRow(
                    Icons.access_time,
                    'الوقت',
                    appointment.time.format(context),
                  ),

                  if (appointment.person.isNotEmpty)
                    _detailRow(
                      Icons.person,
                      'الشخص',
                      appointment.person,
                    ),

                  if (appointment.phone.isNotEmpty)
                    _detailRow(
                      Icons.phone,
                      'الهاتف',
                      appointment.phone,
                    ),

                  if (appointment.location.isNotEmpty)
                    _detailRow(
                      Icons.location_on,
                      'المكان',
                      appointment.location,
                    ),

                  if (appointment.notes.isNotEmpty)
                    _detailRow(
                      Icons.notes,
                      'ملاحظات',
                      appointment.notes,
                    ),

                  _detailRow(
                    Icons.notifications,
                    'التذكير',
                    reminderText(
                      appointment.reminderMinutes,
                    ),
                  ),

                  _detailRow(
                    Icons.check_circle,
                    'الحالة',
                    appointment.completed
                        ? 'مكتمل'
                        : 'غير مكتمل',
                  ),

                  const SizedBox(height: 15),

                  Row(
                    children: [
                      Expanded(
                        child: OutlinedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);

                            showAppointmentDialog(
                              appointment: appointment,
                            );
                          },
                          icon: const Icon(Icons.edit),
                          label: const Text('تعديل'),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: ElevatedButton.icon(
                          onPressed: () {
                            Navigator.pop(context);

                            toggleCompleted(
                              appointment,
                            );
                          },
                          icon: Icon(
                            appointment.completed
                                ? Icons.undo
                                : Icons.check,
                          ),
                          label: Text(
                            appointment.completed
                                ? 'غير مكتمل'
                                : 'مكتمل',
                          ),
                        ),
                      ),
                    ],
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: RichText(
              text: TextSpan(
                style: DefaultTextStyle.of(context)
                    .style,
                children: [
                  TextSpan(
                    text: '$title: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: value),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String reminderText(int minutes) {
    switch (minutes) {
      case -1:
        return 'بدون تذكير';
      case 0:
        return 'وقت الموعد';
      case 5:
        return 'قبل 5 دقائق';
      case 15:
        return 'قبل 15 دقيقة';
      case 30:
        return 'قبل 30 دقيقة';
      case 60:
        return 'قبل ساعة';
      case 1440:
        return 'قبل يوم';
      default:
        return 'مخصص';
    }
  }

  // ==========================================================
  // APPOINTMENT CARD
  // ==========================================================

  Widget appointmentCard(
    Appointment appointment,
  ) {
    final isCompleted = appointment.completed;

    return Card(
      margin: const EdgeInsets.fromLTRB(
        12,
        5,
        12,
        5,
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          child: Icon(
            isCompleted
                ? Icons.check
                : Icons.event,
          ),
        ),
        title: Text(
          appointment.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration: isCompleted
                ? TextDecoration.lineThrough
                : null,
          ),
        ),
        subtitle: Text(
          '${appointment.date.day}/'
          '${appointment.date.month}/'
          '${appointment.date.year}'
          ' • '
          '${appointment.time.format(context)}',
        ),
        trailing: PopupMenuButton<String>(
          onSelected: (value) {
            if (value == 'edit') {
              showAppointmentDialog(
                appointment: appointment,
              );
            }

            if (value == 'delete') {
              deleteAppointment(
                appointment,
              );
            }

            if (value == 'complete') {
              toggleCompleted(
                appointment,
              );
            }
          },
          itemBuilder: (context) {
            return [
              PopupMenuItem(
                value: 'edit',
                child: Row(
                  children: const [
                    Icon(Icons.edit),
                    SizedBox(width: 8),
                    Text('تعديل'),
                  ],
                ),
              ),
              PopupMenuItem(
                value: 'complete',
                child: Row(
                  children: [
                    Icon(
                      isCompleted
                          ? Icons.undo
                          : Icons.check,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      isCompleted
                          ? 'غير مكتمل'
                          : 'مكتمل',
                    ),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'delete',
                child: Row(
                  children: [
                    Icon(Icons.delete),
                    SizedBox(width: 8),
                    Text('حذف'),
                  ],
                ),
              ),
            ];
          },
        ),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(
              16,
              0,
              16,
              16,
            ),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  appointment.type,
                  style: TextStyle(
                    color: Theme.of(context)
                        .colorScheme
                        .primary,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                if (appointment.person.isNotEmpty)
                  _smallInfo(
                    Icons.person,
                    appointment.person,
                  ),

                if (appointment.phone.isNotEmpty)
                  _smallInfo(
                    Icons.phone,
                    appointment.phone,
                  ),

                if (appointment.location.isNotEmpty)
                  _smallInfo(
                    Icons.location_on,
                    appointment.location,
                  ),

                if (appointment.notes.isNotEmpty)
                  _smallInfo(
                    Icons.notes,
                    appointment.notes,
                  ),

                _smallInfo(
                  Icons.notifications,
                  reminderText(
                    appointment.reminderMinutes,
                  ),
                ),

                const SizedBox(height: 8),

                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () {
                          showAppointmentDialog(
                            appointment: appointment,
                          );
                        },
                        icon: const Icon(Icons.edit),
                        label: const Text('تعديل'),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {
                          toggleCompleted(
                            appointment,
                          );
                        },
                        icon: Icon(
                          isCompleted
                              ? Icons.undo
                              : Icons.check,
                        ),
                        label: Text(
                          isCompleted
                              ? 'إلغاء الإكمال'
                              : 'تم الموعد',
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _smallInfo(
    IconData icon,
    String text,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        top: 8,
      ),
      child: Row(
        children: [
          Icon(
            icon,
            size: 18,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(text),
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

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'موعدي',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'الإحصائيات',
            icon: const Icon(Icons.bar_chart),
            onPressed: showStatistics,
          ),

          IconButton(
            tooltip: 'التقويم',
            icon: const Icon(Icons.calendar_month),
            onPressed: showCalendar,
          ),

          IconButton(
            tooltip: 'الوضع الليلي',
            icon: Icon(
              Theme.of(context).brightness ==
                      Brightness.dark
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: widget.onThemeChanged,
          ),
        ],
      ),

      body: RefreshIndicator(
        onRefresh: loadAppointments,
        child: ListView(
          padding: const EdgeInsets.only(
            bottom: 100,
          ),
          children: [
            // ==================================================
            // DASHBOARD
            // ==================================================

            Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: [
                  Expanded(
                    child: _dashboardCard(
                      Icons.event,
                      appointments.length
                          .toString(),
                      'كل المواعيد',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _dashboardCard(
                      Icons.today,
                      todayCount.toString(),
                      'اليوم',
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _dashboardCard(
                      Icons.check_circle,
                      completedCount.toString(),
                      'مكتملة',
                    ),
                  ),
                ],
              ),
            ),

            // ==================================================
            // NEXT APPOINTMENT
            // ==================================================

            if (next != null)
              Card(
                margin: const EdgeInsets.fromLTRB(
                  12,
                  0,
                  12,
                  12,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(
                            Icons.notifications_active,
                          ),
                          SizedBox(width: 8),
                          Text(
                            'أقرب موعد',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight:
                                  FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        next.title,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        '${next.date.day}/'
                        '${next.date.month}/'
                        '${next.date.year}'
                        ' • '
                        '${next.time.format(context)}',
                      ),
                      const SizedBox(height: 6),
                      Text(
                        next.type,
                        style: TextStyle(
                          color: Theme.of(context)
                              .colorScheme
                              .primary,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // ==================================================
            // SEARCH
            // ==================================================

            Padding(
              padding: const EdgeInsets.fromLTRB(
                12,
                4,
                12,
                8,
              ),
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'ابحث عن موعد...',
                  prefixIcon:
                      const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(16),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                  });
                },
              ),
            ),

            // ==================================================
            // FILTERS
            // ==================================================

            SizedBox(
              height: 52,
              child: ListView(
                scrollDirection:
                    Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                children: [
                  'الكل',
                  ...appointmentTypes,
                ].map(
                  (filter) {
                    final selected =
                        selectedFilter == filter;

                    return Padding(
                      padding:
                          const EdgeInsets.only(
                        right: 8,
                      ),
                      child: ChoiceChip(
                        label: Text(filter),
                        selected: selected,
                        onSelected: (_) {
                          setState(() {
                            selectedFilter =
                                filter;
                          });
                        },
                      ),
                    );
                  },
                ).toList(),
              ),
            ),

            const SizedBox(height: 8),

            // ==================================================
            // APPOINTMENTS
            // ==================================================

            if (filteredAppointments.isEmpty)
              const Padding(
                padding: EdgeInsets.all(40),
                child: Column(
                  children: [
                    Icon(
                      Icons.event_busy,
                      size: 60,
                    ),
                    SizedBox(height: 12),
                    Text(
                      'لا توجد مواعيد',
                      style: TextStyle(
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'اضغط + لإضافة أول موعد',
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

      floatingActionButton:
          FloatingActionButton.extended(
        onPressed: () {
          showAppointmentDialog();
        },
        icon: const Icon(Icons.add),
        label: const Text(
          'إضافة موعد',
        ),
      ),
    );
  }

  Widget _dashboardCard(
    IconData icon,
    String value,
    String label,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 14,
          horizontal: 6,
        ),
        child: Column(
          children: [
            Icon(icon),
            const SizedBox(height: 5),
            Text(
              value,
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
