import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
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

  Appointment({
    required this.title,
    required this.date,
    required this.time,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Appointment> appointments = [];
Future<void> saveAppointments() async {
  final prefs = await SharedPreferences.getInstance();

  final data = appointments.map((appointment) {
    return '${appointment.title}|'
        '${appointment.date.toIso8601String()}|'
        '${appointment.time.hour}|'
        '${appointment.time.minute}';
  }).toList();

  await prefs.setStringList('appointments', data);
}
  Future<void> addAppointment() async {
    final controller = TextEditingController();
    DateTime date = DateTime.now();
    TimeOfDay time = TimeOfDay.now();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('إضافة موعد'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'اسم الموعد',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    leading: const Icon(Icons.calendar_month),
                    title: const Text('التاريخ'),
                    subtitle: Text(
                      '${date.day}/${date.month}/${date.year}',
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
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
                    leading: const Icon(Icons.access_time),
                    title: const Text('الساعة'),
                    subtitle: Text(time.format(context)),
                    onTap: () async {
                      final picked = await showTimePicker(
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
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (controller.text.trim().isEmpty) {
                      return;
                    }

                    setState(() {
                      appointments.add(
                        Appointment(
                          title: controller.text.trim(),
                          date: date,
                          time: time,
                        ),
                      );
                    });

                    Navigator.pop(dialogContext);
                  },
                  child: const Text('حفظ'),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
  }

  Future<void> editAppointment(int index) async {
    final appointment = appointments[index];
    final controller = TextEditingController(
      text: appointment.title,
    );

    DateTime date = appointment.date;
    TimeOfDay time = appointment.time;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: const Text('تعديل الموعد'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: controller,
                    decoration: const InputDecoration(
                      labelText: 'اسم الموعد',
                      border: OutlineInputBorder(),
                    ),
                  ),
                  const SizedBox(height: 10),
                  ListTile(
                    leading: const Icon(Icons.calendar_month),
                    title: const Text('التاريخ'),
                    subtitle: Text(
                      '${date.day}/${date.month}/${date.year}',
                    ),
                    onTap: () async {
                      final picked = await showDatePicker(
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
                    leading: const Icon(Icons.access_time),
                    title: const Text('الساعة'),
                    subtitle: Text(time.format(context)),
                    onTap: () async {
                      final picked = await showTimePicker(
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
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(dialogContext),
                  child: const Text('إلغاء'),
                ),
                ElevatedButton(
                  onPressed: () {
                    if (controller.text.trim().isEmpty) {
                      return;
                    }

                    setState(() {
                      appointment.title = controller.text.trim();
                      appointment.date = date;
                      appointment.time = time;
                    });

                    Navigator.pop(dialogContext);
                  },
                  child: const Text('حفظ التعديل'),
                ),
              ],
            );
          },
        );
      },
    );

    controller.dispose();
  }

  void deleteAppointment(int index) {
    setState(() {
      appointments.removeAt(index);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('موعدي'),
          centerTitle: true,
        ),
        body: appointments.isEmpty
            ? const Center(
                child: Text(
                  'لا توجد مواعيد',
                  style: TextStyle(fontSize: 24),
                ),
              )
            : ListView.builder(
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final appointment = appointments[index];

                  return Card(
                    child: ListTile(
                      title: Text(appointment.title),
                      subtitle: Text(
                        '${appointment.date.day}/${appointment.date.month}/${appointment.date.year}'
                        ' - ${appointment.time.format(context)}',
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.edit),
                            onPressed: () {
                              editAppointment(index);
                            },
                          ),
                          IconButton(
                            icon: const Icon(Icons.delete),
                            onPressed: () {
                              deleteAppointment(index);
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: addAppointment,
          icon: const Icon(Icons.add),
          label: const Text('إضافة موعد'),
        ),
      ),
    );
  }
}
