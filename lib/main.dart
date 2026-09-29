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

class Maw3idiApp extends StatelessWidget {
  const Maw3idiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'موعدي',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class Appointment {
  String title;
  DateTime date;
  TimeOfDay time;
  String type;
  String person;
  String phone;
  String location;
  String notes;

  Appointment({
    required this.title,
    required this.date,
    required this.time,
    required this.type,
    required this.person,
    required this.phone,
    required this.location,
    required this.notes,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Appointment> appointments = [];

  final List<String> appointmentTypes = [
    'طبيب',
    'إدارة',
    'عمل',
    'دراسة',
    'شخصي',
    'أخرى',
  ];

  String searchText = '';
  String selectedFilter = 'الكل';

  @override
  void initState() {
    super.initState();
    loadAppointments();
  }

  Future<void> loadAppointments() async {
    final prefs = await SharedPreferences.getInstance();
    final data = prefs.getStringList('appointments') ?? [];

    final loaded = <Appointment>[];

    for (final item in data) {
      final parts = item.split('|');

      if (parts.length >= 8) {
        final date = DateTime.tryParse(parts[1]);
        final hour = int.tryParse(parts[2]);
        final minute = int.tryParse(parts[3]);

        if (date != null && hour != null && minute != null) {
          loaded.add(
            Appointment(
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
            ),
          );
        }
      }
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
      ].join('|');
    }).toList();

    await prefs.setStringList('appointments', data);
  }

  Future<void> scheduleAllNotifications() async {
    await notificationsPlugin.cancelAll();

    for (int i = 0; i < appointments.length; i++) {
      await scheduleAppointmentNotification(
        appointments[i],
        i + 1,
      );
    }
  }

  Future<void> scheduleAppointmentNotification(
    Appointment appointment,
    int id,
  ) async {
    final appointmentDateTime = DateTime(
      appointment.date.year,
      appointment.date.month,
      appointment.date.day,
      appointment.time.hour,
      appointment.time.minute,
    );

    final reminderDateTime =
        appointmentDateTime.subtract(const Duration(hours: 1));

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
      id: id,
      title: 'تذكير بموعدك 🔔',
      body: appointment.title,
      scheduledDate: scheduledDate,
      notificationDetails: notificationDetails,
      androidScheduleMode:
          AndroidScheduleMode.inexactAllowWhileIdle,
    );
  }

  List<Appointment> get filteredAppointments {
    final result = appointments.where((appointment) {
      final query = searchText.toLowerCase();

      final matchesSearch =
          appointment.title.toLowerCase().contains(query) ||
          appointment.person.toLowerCase().contains(query) ||
          appointment.location.toLowerCase().contains(query) ||
          appointment.type.toLowerCase().contains(query);

      final matchesFilter =
          selectedFilter == 'الكل' ||
          appointment.type == selectedFilter;

      return matchesSearch && matchesFilter;
    }).toList();

    result.sort((a, b) {
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
    });

    return result;
  }

  Future<void> addAppointment() async {
    await showAppointmentDialog();
  }

  Future<void> editAppointment(
    Appointment appointment,
  ) async {
    await showAppointmentDialog(
      appointment: appointment,
    );
  }

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

    DateTime date =
        appointment?.date ?? DateTime.now();

    TimeOfDay time =
        appointment?.time ?? TimeOfDay.now();

    String type =
        appointment?.type ?? 'شخصي';

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                appointment == null
                    ? 'إضافة موعد'
                    : 'تعديل الموعد',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: titleController,
                      decoration: const InputDecoration(
                        labelText: 'اسم الموعد',
                        prefixIcon: Icon(Icons.event),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    DropdownButtonFormField<String>(
                      initialValue: type,
                      decoration: const InputDecoration(
                        labelText: 'نوع الموعد',
                        prefixIcon: Icon(Icons.category),
                        border: OutlineInputBorder(),
                      ),
                      items: appointmentTypes.map((item) {
                        return DropdownMenuItem(
                          value: item,
                          child: Text(item),
                        );
                      }).toList(),
                      onChanged: (value) {
                        if (value != null) {
                          setDialogState(() {
                            type = value;
                          });
                        }
                      },
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: personController,
                      decoration: const InputDecoration(
                        labelText: 'اسم الطبيب / الشخص',
                        prefixIcon: Icon(Icons.person),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: phoneController,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'رقم الهاتف',
                        prefixIcon: Icon(Icons.phone),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: locationController,
                      decoration: const InputDecoration(
                        labelText: 'المكان',
                        prefixIcon: Icon(Icons.location_on),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 12),

                    TextField(
                      controller: notesController,
                      maxLines: 3,
                      decoration: const InputDecoration(
                        labelText: 'ملاحظات',
                        prefixIcon: Icon(Icons.notes),
                        border: OutlineInputBorder(),
                      ),
                    ),

                    const SizedBox(height: 8),

                    ListTile(
                      leading: const Icon(
                        Icons.calendar_month,
                      ),
                      title: const Text('التاريخ'),
                      subtitle: Text(
                        '${date.day}/${date.month}/${date.year}',
                      ),
                      onTap: () async {
                        final picked =
                            await showDatePicker(
                          context: context,
                          initialDate: date,
                          firstDate: DateTime.now(),
                          lastDate: DateTime(2100),
                        );

                        if (picked != null) {
                          setDialogState(() {
                            date = picked;
                          });
                        }
                      },
                    ),

                    ListTile(
                      leading: const Icon(
                        Icons.access_time,
                      ),
                      title: const Text('الساعة'),
                      subtitle: Text(
                        time.format(context),
                      ),
                      onTap: () async {
                        final picked =
                            await showTimePicker(
                          context: context,
                          initialTime: time,
                        );

                        if (picked != null) {
                          setDialogState(() {
                            time = picked;
                          });
                        }
                      },
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.pop(dialogContext);
                  },
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () async {
                    if (titleController.text
                        .trim()
                        .isEmpty) {
                      return;
                    }

                    if (appointment == null) {
                      setState(() {
                        appointments.add(
                          Appointment(
                            title:
                                titleController.text.trim(),
                            date: date,
                            time: time,
                            type: type,
                            person:
                                personController.text.trim(),
                            phone:
                                phoneController.text.trim(),
                            location:
                                locationController.text.trim(),
                            notes:
                                notesController.text.trim(),
                          ),
                        );
                      });
                    } else {
                      setState(() {
                        appointment.title =
                            titleController.text.trim();
                        appointment.date = date;
                        appointment.time = time;
                        appointment.type = type;
                        appointment.person =
                            personController.text.trim();
                        appointment.phone =
                            phoneController.text.trim();
                        appointment.location =
                            locationController.text.trim();
                        appointment.notes =
                            notesController.text.trim();
                      });
                    }

                    await saveAppointments();
                    await scheduleAllNotifications();

                    if (dialogContext.mounted) {
                      Navigator.pop(dialogContext);
                    }
                  },
                  child: Text(
                    appointment == null
                        ? 'حفظ'
                        : 'حفظ التعديل',
                  ),
                ),
              ],
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

  Future<void> deleteAppointment(
    Appointment appointment,
  ) async {
    setState(() {
      appointments.remove(appointment);
    });

    await saveAppointments();
    await scheduleAllNotifications();
  }

  Future<void> confirmDelete(
    Appointment appointment,
  ) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('حذف الموعد'),
          content: const Text(
            'هل أنت متأكد من حذف هذا الموعد؟',
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

    if (result == true) {
      await deleteAppointment(appointment);
    }
  }

  Widget appointmentCard(
    Appointment appointment,
  ) {
    return Card(
      margin: const EdgeInsets.symmetric(
        horizontal: 12,
        vertical: 6,
      ),
      child: ExpansionTile(
        leading: CircleAvatar(
          child: Icon(
            appointment.type == 'طبيب'
                ? Icons.local_hospital
                : appointment.type == 'عمل'
                    ? Icons.work
                    : appointment.type == 'دراسة'
                        ? Icons.school
                        : Icons.event,
          ),
        ),
        title: Text(
          appointment.title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          '${appointment.date.day}/${appointment.date.month}/${appointment.date.year}'
          ' - ${appointment.time.format(context)}',
        ),
        children: [
          if (appointment.type.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.category),
              title: const Text('النوع'),
              subtitle: Text(appointment.type),
            ),

          if (appointment.person.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text('الشخص'),
              subtitle: Text(appointment.person),
            ),

          if (appointment.phone.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.phone),
              title: const Text('الهاتف'),
              subtitle: Text(appointment.phone),
            ),

          if (appointment.location.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.location_on),
              title: const Text('المكان'),
              subtitle: Text(appointment.location),
            ),

          if (appointment.notes.isNotEmpty)
            ListTile(
              leading: const Icon(Icons.notes),
              title: const Text('ملاحظات'),
              subtitle: Text(appointment.notes),
            ),

          Padding(
            padding: const EdgeInsets.only(
              left: 12,
              right: 12,
              bottom: 12,
            ),
            child: Row(
              mainAxisAlignment:
                  MainAxisAlignment.end,
              children: [
                OutlinedButton.icon(
                  onPressed: () {
                    editAppointment(appointment);
                  },
                  icon: const Icon(Icons.edit),
                  label: const Text('تعديل'),
                ),

                const SizedBox(width: 8),

                OutlinedButton.icon(
                  onPressed: () {
                    confirmDelete(appointment);
                  },
                  icon: const Icon(Icons.delete),
                  label: const Text('حذف'),
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
    final filtered = filteredAppointments;

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('موعدي'),
          centerTitle: true,
        ),
        body: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(12),
              child: TextField(
                onChanged: (value) {
                  setState(() {
                    searchText = value;
                  });
                },
                decoration: InputDecoration(
                  hintText: 'ابحث عن موعد...',
                  prefixIcon:
                      const Icon(Icons.search),
                  suffixIcon:
                      searchText.isNotEmpty
                          ? IconButton(
                              onPressed: () {
                                setState(() {
                                  searchText = '';
                                });
                              },
                              icon: const Icon(
                                Icons.clear,
                              ),
                            )
                          : null,
                  border:
                      const OutlineInputBorder(),
                ),
              ),
            ),

            SizedBox(
              height: 50,
              child: ListView(
                scrollDirection:
                    Axis.horizontal,
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 12,
                ),
                children: [
                  filterChip('الكل'),
                  ...appointmentTypes
                      .map(filterChip),
                ],
              ),
            ),

            const SizedBox(height: 8),

            Expanded(
              child: filtered.isEmpty
                  ? const Center(
                      child: Column(
                        mainAxisSize:
                            MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.event_busy,
                            size: 70,
                          ),
                          SizedBox(height: 12),
                          Text(
                            'لا توجد مواعيد',
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                        ],
                      ),
                    )
                  : ListView.builder(
                      itemCount: filtered.length,
                      itemBuilder:
                          (context, index) {
                        return appointmentCard(
                          filtered[index],
                        );
                      },
                    ),
            ),
          ],
        ),
        floatingActionButton:
            FloatingActionButton.extended(
          onPressed: addAppointment,
          icon: const Icon(Icons.add),
          label: const Text('إضافة موعد'),
        ),
      ),
    );
  }

  Widget filterChip(String filter) {
    return Padding(
      padding: const EdgeInsets.only(left: 6),
      child: ChoiceChip(
        label: Text(filter),
        selected:
            selectedFilter == filter,
        onSelected: (selected) {
          if (selected) {
            setState(() {
              selectedFilter = filter;
            });
          }
        },
      ),
    );
  }
}
