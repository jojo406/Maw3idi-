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
    final value = !darkMode;

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
      themeMode: darkMode
          ? ThemeMode.dark
          : ThemeMode.light,
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

      if (parts.length < 8) continue;

      final date = DateTime.tryParse(parts[1]);
      final hour = int.tryParse(parts[2]);
      final minute = int.tryParse(parts[3]);

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
        completed = parts[10] == 'true';
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
    if (appointment.completed) return;
    if (appointment.reminderMinutes == -1) return;

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

    const details = NotificationDetails(
      android: androidDetails,
    );

    await notificationsPlugin.zonedSchedule(
      id: notificationId(appointment.id),
      title: 'تذكير بموعدك 🔔',
      body: appointment.title,
      scheduledDate: scheduledDate,
      notificationDetails: details,
      androidScheduleMode:
          AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }
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

  DateTime appointmentDateTime(
    Appointment appointment,
  ) {
    return DateTime(
      appointment.date.year,
      appointment.date.month,
      appointment.date.day,
      appointment.time.hour,
      appointment.time.minute,
    );
  }

  Appointment? get nextAppointment {
    final now = DateTime.now();

    final upcoming = appointments.where(
      (a) =>
          !a.completed &&
          appointmentDateTime(a).isAfter(now),
    ).toList();

    if (upcoming.isEmpty) return null;

    upcoming.sort(
      (a, b) =>
          appointmentDateTime(a)
              .compareTo(
                appointmentDateTime(b),
              ),
    );

    return upcoming.first;
  }

  int get todayCount {
    final now = DateTime.now();

    return appointments.where(
      (a) =>
          a.date.year == now.year &&
          a.date.month == now.month &&
          a.date.day == now.day,
    ).length;
  }

  int get completedCount {
    return appointments.where(
      (a) => a.completed,
    ).length;
  }

  int get reminderCount {
    return appointments.where(
      (a) =>
          !a.completed &&
          a.reminderMinutes != -1,
    ).length;
  }

  Future<void> toggleCompleted(
    Appointment appointment,
  ) async {
    setState(() {
      appointment.completed =
          !appointment.completed;
    });

    await saveAppointments();
    await scheduleAllNotifications();
  }

  Future<void> deleteAppointment(
    Appointment appointment,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('حذف الموعد'),
          content: const Text(
            'هل تريد حذف هذا الموعد؟',
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

    setState(() {
      appointments.remove(appointment);
    });

    await saveAppointments();
    await scheduleAllNotifications();
  }

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
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 8,
      ),
      child: Row(
        children: [
          Icon(icon),
          const SizedBox(width: 12),
          Expanded(
            child: Text(title),
          ),
          Text(
            value,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ],
      ),
    );
  }
      Future<void> showAppointmentDialog({
    Appointment? appointment,
  }) async {
    final isEditing = appointment != null;

    final titleController =
        TextEditingController(
      text: appointment?.title ?? '',
    );

    final personController =
        TextEditingController(
      text: appointment?.person ?? '',
    );

    final phoneController =
        TextEditingController(
      text: appointment?.phone ?? '',
    );

    final locationController =
        TextEditingController(
      text: appointment?.location ?? '',
    );

    final notesController =
        TextEditingController(
      text: appointment?.notes ?? '',
    );

    DateTime selectedDate =
        appointment?.date ?? DateTime.now();

    TimeOfDay selectedTime =
        appointment?.time ?? TimeOfDay.now();

    String selectedType =
        appointment?.type ?? appointmentTypes.first;

    int selectedReminder =
        appointment?.reminderMinutes ?? 60;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (
            context,
            setDialogState,
          ) {
            return AlertDialog(
              title: Text(
                isEditing
                    ? 'تعديل الموعد'
                    : 'إضافة موعد',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration:
                          const InputDecoration(
                        labelText:
                            'عنوان الموعد',
                        prefixIcon:
                            Icon(Icons.title),
                      ),
                    ),
                    TextField(
                      controller:
                          personController,
                      decoration:
                          const InputDecoration(
                        labelText: 'الشخص',
                        prefixIcon:
                            Icon(Icons.person),
                      ),
                    ),
                    TextField(
                      controller:
                          phoneController,
                      keyboardType:
                          TextInputType.phone,
                      decoration:
                          const InputDecoration(
                        labelText: 'رقم الهاتف',
                        prefixIcon:
                            Icon(Icons.phone),
                      ),
                    ),
                    TextField(
                      controller:
                          locationController,
                      decoration:
                          const InputDecoration(
                        labelText: 'المكان',
                        prefixIcon:
                            Icon(Icons.location_on),
                      ),
                    ),
                    TextField(
                      controller:
                          notesController,
                      maxLines: 2,
                      decoration:
                          const InputDecoration(
                        labelText: 'ملاحظات',
                        prefixIcon:
                            Icon(Icons.note),
                      ),
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<String>(
                      initialValue: selectedType,
                      decoration:
                          const InputDecoration(
                        labelText: 'نوع الموعد',
                      ),
                      items: appointmentTypes
                          .map(
                            (type) =>
                                DropdownMenuItem(
                              value: type,
                              child:
                                  Text(type),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;

                        setDialogState(() {
                          selectedType = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      initialValue:
                          selectedReminder,
                      decoration:
                          const InputDecoration(
                        labelText: 'التنبيه',
                      ),
                      items: reminderOptions
                          .entries
                          .map(
                            (entry) =>
                                DropdownMenuItem(
                              value: entry.key,
                              child:
                                  Text(entry.value),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;

                        setDialogState(() {
                          selectedReminder = value;
                        });
                      },
                    ),
                    const SizedBox(height: 12),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(
                          Icons.calendar_month,
                        ),
                        label: Text(
                          '${selectedDate.day}/'
                          '${selectedDate.month}/'
                          '${selectedDate.year}',
                        ),
                        onPressed: () async {
                          final picked =
                              await showDatePicker(
                            context: context,
                            initialDate:
                                selectedDate,
                            firstDate:
                                DateTime.now(),
                            lastDate:
                                DateTime(2100),
                          );

                          if (picked != null) {
                            setDialogState(() {
                              selectedDate =
                                  picked;
                            });
                          }
                        },
                      ),
                    ),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        icon: const Icon(
                          Icons.access_time,
                        ),
                        label: Text(
                          selectedTime
                              .format(context),
                        ),
                        onPressed: () async {
                          final picked =
                              await showTimePicker(
                            context: context,
                            initialTime:
                                selectedTime,
                          );

                          if (picked != null) {
                            setDialogState(() {
                              selectedTime =
                                  picked;
                            });
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(
                      dialogContext,
                    );
                  },
                  child:
                      const Text('إلغاء'),
                ),
                ElevatedButton.icon(
                  icon: const Icon(
                    Icons.save,
                  ),
                  label: Text(
                    isEditing
                        ? 'حفظ التعديل'
                        : 'حفظ',
                  ),
                  onPressed: () async {
                    final title =
                        titleController.text
                            .trim();

                    if (title.isEmpty) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'اكتب عنوان الموعد',
                          ),
                        ),
                      );
                      return;
                    }

                    if (isEditing) {
                      appointment!.title =
                          title;
                      appointment.person =
                          personController.text
                              .trim();
                      appointment.phone =
                          phoneController.text
                              .trim();
                      appointment.location =
                          locationController.text
                              .trim();
                      appointment.notes =
                          notesController.text
                              .trim();
                      appointment.date =
                          selectedDate;
                      appointment.time =
                          selectedTime;
                      appointment.type =
                          selectedType;
                      appointment
                              .reminderMinutes =
                          selectedReminder;
                    } else {
                      appointments.add(
                        Appointment(
                          id: DateTime.now()
                              .microsecondsSinceEpoch
                              .toString(),
                          title: title,
                          date: selectedDate,
                          time: selectedTime,
                          type: selectedType,
                          person:
                              personController
                                  .text
                                  .trim(),
                          phone:
                              phoneController
                                  .text
                                  .trim(),
                          location:
                              locationController
                                  .text
                                  .trim(),
                          notes:
                              notesController
                                  .text
                                  .trim(),
                          reminderMinutes:
                              selectedReminder,
                          completed: false,
                        ),
                      );
                    }

                    setState(() {});

                    await saveAppointments();
                    await scheduleAllNotifications();

                    if (dialogContext.mounted) {
                      Navigator.pop(
                        dialogContext,
                      );
                    }
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }

  Widget appointmentCard(
    Appointment appointment,
  ) {
    final dateText =
        '${appointment.date.day}/'
        '${appointment.date.month}/'
        '${appointment.date.year}';

    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          child: Icon(
            appointment.completed
                ? Icons.check
                : Icons.event,
          ),
        ),
        title: Text(
          appointment.title,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            decoration:
                appointment.completed
                    ? TextDecoration.lineThrough
                    : null,
          ),
        ),
        subtitle: Text(
          '$dateText • '
          '${appointment.time.format(context)}',
        ),
        children: [
          if (appointment.person.isNotEmpty)
            ListTile(
              leading:
                  const Icon(Icons.person),
              title:
                  Text(appointment.person),
            ),
          if (appointment.phone.isNotEmpty)
            ListTile(
              leading:
                  const Icon(Icons.phone),
              title:
                  Text(appointment.phone),
            ),
          if (appointment.location.isNotEmpty)
            ListTile(
              leading: const Icon(
                Icons.location_on,
              ),
              title:
                  Text(appointment.location),
            ),
          if (appointment.notes.isNotEmpty)
            ListTile(
              leading:
                  const Icon(Icons.note),
              title:
                  Text(appointment.notes),
            ),
          Padding(
            padding: const EdgeInsets.all(8),
            child: Wrap(
              spacing: 8,
              children: [
                OutlinedButton.icon(
                  icon:
                      const Icon(Icons.edit),
                  label:
                      const Text('تعديل'),
                  onPressed: () {
                    showAppointmentDialog(
                      appointment:
                          appointment,
                    );
                  },
                ),
                OutlinedButton.icon(
                  icon: Icon(
                    appointment.completed
                        ? Icons.undo
                        : Icons.check,
                  ),
                  label: Text(
                    appointment.completed
                        ? 'إلغاء الإنجاز'
                        : 'تم الموعد',
                  ),
                  onPressed: () {
                    toggleCompleted(
                      appointment,
                    );
                  },
                ),
                OutlinedButton.icon(
                  icon: const Icon(
                    Icons.delete,
                  ),
                  label:
                      const Text('حذف'),
                  onPressed: () {
                    deleteAppointment(
                      appointment,
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
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
            icon:
                const Icon(Icons.bar_chart),
            onPressed: showStatistics,
          ),
            IconButton(
  tooltip: 'التقويم',
  icon: const Icon(Icons.calendar_month),
  onPressed: () {
    showCalendar();
  },
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
          padding:
              const EdgeInsets.only(bottom: 90),
          children: [
            if (next != null)
              Card(
                margin:
                    const EdgeInsets.all(12),
                child: Padding(
                  padding:
                      const EdgeInsets.all(16),
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
                          color:
                              Theme.of(context)
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
            Padding(
              padding:
                  const EdgeInsets.fromLTRB(
                12,
                4,
                12,
                8,
              ),
              child: TextField(
                decoration:
                    InputDecoration(
                  hintText:
                      'ابحث عن موعد...',
                  prefixIcon:
                      const Icon(Icons.search),
                  border:
                      OutlineInputBorder(
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                  ),
                ),
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                  });
                },
              ),
            ),
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
                        selectedFilter ==
                            filter;

                    return Padding(
                      padding:
                          const EdgeInsets.only(
                        right: 8,
                      ),
                      child: ChoiceChip(
                        label:
                            Text(filter),
                        selected:
                            selected,
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
            if (filteredAppointments.isEmpty)
              const Padding(
                padding:
                    EdgeInsets.all(40),
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
}
