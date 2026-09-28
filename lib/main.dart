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

  Future<void> showAppointmentDialog({int? index}) async {
    final isEditing = index != null;

    final controller = TextEditingController(
      text: isEditing ? appointments[index!].title : '',
    );

    DateTime selectedDate =
        isEditing ? appointments[index!].date : DateTime.now();

    TimeOfDay selectedTime =
        isEditing ? appointments[index!].time : TimeOfDay.now();

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text(
                isEditing ? 'تعديل الموعد' : 'إضافة موعد',
              ),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    TextField(
                      controller: controller,
                      textDirection: TextDirection.rtl,
                      decoration: const InputDecoration(
                        labelText: 'اسم الموعد',
                        hintText: 'مثال: موعد الطبيب',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.edit),
                      ),
                    ),

                    const SizedBox(height: 16),

                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.calendar_month),
                      title: const Text('التاريخ'),
                      subtitle: Text(
                        '${selectedDate.day}/${selectedDate.month}/${selectedDate.year}',
                      ),
                      onTap: () async {
                        final date = await showDatePicker(
                          context: context,
                          initialDate: selectedDate,
                          firstDate: DateTime(2020),
                          lastDate: DateTime(2100),
                        );

                        if (date != null) {
                          setDialogState(() {
                            selectedDate = date;
                          });
                        }
                      },
                    ),

                    ListTile(
                      contentPadding: EdgeInsets.zero,
                      leading: const Icon(Icons.access_time),
                      title: const Text('الساعة'),
                      subtitle: Text(
                        selectedTime.format(context),
                      ),
                      onTap: () async {
                        final time = await showTimePicker(
                          context: context,
                          initialTime: selectedTime,
                        );

                        if (time != null) {
                          setDialogState(() {
                            selectedTime = time;
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

                ElevatedButton.icon(
                  onPressed: () {
                    final title = controller.text.trim();

                    if (title.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text('اكتب اسم الموعد أولاً'),
                        ),
                      );
                      return;
                    }

                    setState(() {
                      if (isEditing) {
                        appointments[index!].title = title;
                        appointments[index].date = selectedDate;
                        appointments[index].time = selectedTime;
                      } else {
                        appointments.add(
                          Appointment(
                            title: title,
                            date: selectedDate,
                            time: selectedTime,
                          ),
                        );
                      }
                    });

                    Navigator.pop(dialogContext);
                  },
                  icon: const Icon(Icons.save),
                  label: Text(
                    isEditing ? 'حفظ التعديل' : 'حفظ',
                  ),
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
    final deletedTitle = appointments[index].title;

    setState(() {
      appointments.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('تم حذف "$deletedTitle"'),
        action: SnackBarAction(
          label: 'تراجع',
          onPressed: () {
            setState(() {
              appointments.insert(
                index,
                Appointment(
                  title: deletedTitle,
                  date: DateTime.now(),
                  time: TimeOfDay.now(),
                ),
              );
            });
          },
        ),
      ),
    );
  }

  String formatDate(DateTime date) {
    return '${date.day}/${date.month}/${date.year}';
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'موعدي',
            style: TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),

        body: appointments.isEmpty
            ? _emptyState()
            : ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: appointments.length,
                itemBuilder: (context, index) {
                  final appointment = appointments[index];

                  return Card(
                    margin: const EdgeInsets.only(bottom: 12),
                    child: ListTile(
                      contentPadding: const EdgeInsets.all(12),

                      leading: const CircleAvatar(
                        radius: 25,
                        child: Icon(Icons.event),
                      ),

                      title: Text(
                        appointment.title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      subtitle: Padding(
                        padding: const EdgeInsets.only(top: 8),
                        child: Text(
                          '${formatDate(appointment.date)}  •  ${appointment.time.format(context)}',
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                        ),
                      ),

                      trailing: PopupMenuButton<String>(
                        onSelected: (value) {
                          if (value == 'edit') {
                            showAppointmentDialog(index: index);
                          }

                          if (value == 'delete') {
                            deleteAppointment(index);
                          }
                        },
                        itemBuilder: (context) => const [
                          PopupMenuItem(
                            value: 'edit',
                            child: Row(
                              children: [
                                Icon(Icons.edit),
                                SizedBox(width: 10),
                                Text('تعديل'),
                              ],
                            ),
                          ),
                          PopupMenuItem(
                            value: 'delete',
                            child: Row(
                              children: [
                                Icon(Icons.delete),
                                SizedBox(width: 10),
                                Text('حذف'),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),

        floatingActionButton: FloatingActionButton.extended(
          onPressed: () {
            showAppointmentDialog();
          },
          icon: const Icon(Icons.add),
          label: const Text('إضافة موعد'),
        ),
      ),
    );
  }

  Widget _emptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.calendar_month,
              size: 100,
            ),

            const SizedBox(height: 20),

            const Text(
              'مرحبا بك في موعدي',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            const Text(
              'نظّم مواعيدك بسهولة',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton.icon(
              onPressed: () {
                showAppointmentDialog();
              },
              icon: const Icon(Icons.add),
              label: const Text('إضافة أول موعد'),
            ),
          ],
        ),
      ),
    );
  }
}
