import 'package:flutter/material.dart';

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
  bool done;

  Appointment({
    required this.title,
    required this.date,
    required this.time,
    this.done = false,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}
class _HomePageState extends State<HomePage> {
  final List<Appointment> appointments = [];

  Future<void> addAppointment() async {
    final controller = TextEditingController();
    DateTime date = DateTime.now();
    TimeOfDay time = TimeOfDay.now();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('إضافة موعد'),
          content: TextField(
            controller: controller,
            decoration: const InputDecoration(
              labelText: 'اسم الموعد',
              border: OutlineInputBorder(),
            ),
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
                        '${appointment.date.day}/${appointment.date.month}/${appointment.date.year}',
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.delete),
                        onPressed: () {
                          deleteAppointment(index);
                        },
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
