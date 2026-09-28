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
  bool important;
  bool completed;

  Appointment({
    required this.title,
    required this.date,
    required this.time,
    this.important = false,
    this.completed = false,
  });
}

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<Appointment> appointments = [];

  String search = '';
  String filter = 'الكل';

  List<Appointment> get filteredAppointments {
    return appointments.where((a) {
      final matchesSearch =
          a.title.toLowerCase().contains(search.toLowerCase());

      final matchesFilter =
          filter == 'الكل' ||
          (filter == 'القادمة' && !a.completed) ||
          (filter == 'المكتملة' && a.completed);

      return matchesSearch && matchesFilter;
    }).toList();
  }

  Future<void> addOrEditAppointment({int? index}) async {
    final editing = index != null;

    final old = editing ? appointments[index] : null;

    final titleController = TextEditingController(
      text: old?.title ?? '',
    );

    DateTime selectedDate = old?.date ?? DateTime.now();
    TimeOfDay selectedTime = old?.time ?? TimeOfDay.now();
    bool important = old?.important ?? false;

    await showDialog(
      context: context,
      builder: (dialogContext) {
        return StatefulBuilder(
         
