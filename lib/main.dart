import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

/// ============================================================
/// FIREBASE MESSAGING
/// ============================================================

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  await Firebase.initializeApp();
}

/// ============================================================
/// MAIN
/// ============================================================

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  FirebaseMessaging.onBackgroundMessage(
    firebaseMessagingBackgroundHandler,
  );

  try {
    await FirebaseMessaging.instance.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );
  } catch (_) {}

  runApp(const AloWaselniApp());
}

/// ============================================================
/// APP
/// ============================================================

class AloWaselniApp extends StatelessWidget {
  const AloWaselniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ألو وصلني',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        scaffoldBackgroundColor: const Color(0xfff5f7fb),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
        ),
      ),
      home: const StartPage(),
    );
  }
}

/// ============================================================
/// HELPERS
/// ============================================================

String newId() {
  return DateTime.now().microsecondsSinceEpoch.toString();
}

String serviceName(String? service) {
  if (service == 'alo_jibli') {
    return 'ألو جيبلي';
  }

  return 'ألو وصلني';
}

String vehicleName(String? vehicle) {
  if (vehicle == 'motorcycle') {
    return 'دراجة';
  }

  return 'سيارة';
}

String statusName(String? status) {
  switch (status) {
    case 'pending':
      return 'في انتظار السائق';

    case 'accepted':
      return 'تم قبول الطلب';

    case 'driver_arriving':
      return 'السائق في الطريق إليك';

    case 'driver_arrived':
      return 'السائق وصل';

    case 'completed':
      return 'تم إكمال الطلب';

    case 'cancelled':
      return 'تم إلغاء الطلب';

    default:
      return 'جاري المعالجة';
  }
}

IconData statusIcon(String? status) {
  switch (status) {
    case 'accepted':
      return Icons.check_circle;

    case 'driver_arriving':
      return Icons.navigation;

    case 'driver_arrived':
      return Icons.location_on;

    case 'completed':
      return Icons.done_all;

    case 'cancelled':
      return Icons.cancel;

    default:
      return Icons.hourglass_top;
  }
}

Future<void> callPhoneNumber(String phone) async {
  final uri = Uri.parse('tel:$phone');

  try {
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  } catch (_) {}
}

/// ============================================================
/// LOCATION
/// ============================================================

Future<LatLng?> getCurrentLocation() async {
  try {
    bool serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      return null;
    }

    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission =
          await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    final position =
        await Geolocator.getCurrentPosition(
      locationSettings:
          const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );

    return LatLng(
      position.latitude,
      position.longitude,
    );
  } catch (_) {
    return null;
  }
}

/// ============================================================
/// START PAGE
/// ============================================================

class StartPage extends StatefulWidget {
  const StartPage({super.key});

  @override
  State<StartPage> createState() => _StartPageState();
}

class _StartPageState extends State<StartPage> {
  bool loading = true;

  @override
  void initState() {
    super.initState();
    checkSavedProfile();
  }

  Future<void> checkSavedProfile() async {
    final prefs =
        await SharedPreferences.getInstance();

    final role =
        prefs.getString('last_role');

    if (!mounted) return;

    if (role == 'customer') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const CustomerPage(),
        ),
      );
      return;
    }

    if (role == 'car_driver') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const DriverPage(
            vehicleType: 'car',
          ),
        ),
      );
      return;
    }

    if (role == 'motorcycle_driver') {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const DriverPage(
            vehicleType: 'motorcycle',
          ),
        ),
      );
      return;
    }

    setState(() {
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    return const HomePage();
  }
}

/// ============================================================
/// HOME
/// ============================================================

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  Future<void> customer(BuildContext context) async {
    await ensureCustomerProfile(context);
  }

  Future<void> carDriver(BuildContext context) async {
    await ensureDriverProfile(
      context,
      'car',
    );
  }

  Future<void> motorcycleDriver(
    BuildContext context,
  ) async {
    await ensureDriverProfile(
      context,
      'motorcycle',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ألو وصلني',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Column(
            children: [
              const SizedBox(height: 20),

              const Icon(
                Icons.local_shipping,
                size: 75,
                color: Colors.blue,
              ),

              const SizedBox(height: 15),

              const Text(
                'ألو وصلني',
                style: TextStyle(
                  fontSize: 30,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              const Text(
                'خدمات التوصيل والتنقل داخل البلدية',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 35),

              Expanded(
                child: ListView(
                  children: [
                    RoleButton(
                      icon: Icons.person,
                      title: 'أنا الزبون',
                      subtitle:
                          'طلب ألو وصلني أو ألو جيبلي',
                      onTap: () => customer(context),
                    ),

                    const SizedBox(height: 15),

                    RoleButton(
                      icon: Icons.directions_car,
                      title: 'أنا سائق السيارة',
                      subtitle:
                          'استقبال طلبات الزبائن',
                      onTap: () => carDriver(context),
                    ),

                    const SizedBox(height: 15),

                    RoleButton(
                      icon: Icons.two_wheeler,
                      title: 'أنا سائق الدراجة',
                      subtitle:
                          'استقبال طلبات ألو جيبلي',
                      onTap: () =>
                          motorcycleDriver(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ============================================================
/// ROLE BUTTON
/// ============================================================

class RoleButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const RoleButton({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                radius: 29,
                child: Icon(
                  icon,
                  size: 30,
                ),
              ),

              const SizedBox(width: 15),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),

              const Icon(
                Icons.arrow_forward_ios,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ============================================================
/// CUSTOMER PROFILE
/// ============================================================

Future<void> ensureCustomerProfile(
  BuildContext context,
) async {
  final prefs =
      await SharedPreferences.getInstance();

  String? phone =
      prefs.getString('customer_phone');

  if (phone == null || phone.trim().isEmpty) {
    phone = await askPhone(context);

    if (phone == null || phone.trim().isEmpty) {
      return;
    }

    await prefs.setString(
      'customer_phone',
      phone,
    );
  }

  String? customerId =
      prefs.getString('customer_id');

  if (customerId == null) {
    customerId = newId();

    await prefs.setString(
      'customer_id',
      customerId,
    );

    await FirebaseFirestore.instance
        .collection('customers')
        .doc(customerId)
        .set({
      'id': customerId,
      'phone': phone,
      'createdAt':
          FieldValue.serverTimestamp(),
      'updatedAt':
          FieldValue.serverTimestamp(),
    });
  }

  await prefs.setString(
    'last_role',
    'customer',
  );

  if (!context.mounted) return;

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => const CustomerPage(),
    ),
  );
}

/// ============================================================
/// DRIVER PROFILE
/// ============================================================

Future<void> ensureDriverProfile(
  BuildContext context,
  String vehicleType,
) async {
  final prefs =
      await SharedPreferences.getInstance();

  final keyPhone =
      vehicleType == 'motorcycle'
          ? 'motorcycle_driver_phone'
          : 'car_driver_phone';

  final keyId =
      vehicleType == 'motorcycle'
          ? 'motorcycle_driver_id'
          : 'car_driver_id';

  String? phone =
      prefs.getString(keyPhone);

  if (phone == null || phone.trim().isEmpty) {
    phone = await askPhone(context);

    if (phone == null || phone.trim().isEmpty) {
      return;
    }

    await prefs.setString(
      keyPhone,
      phone,
    );
  }

  String? driverId =
      prefs.getString(keyId);

  if (driverId == null) {
    driverId = newId();

    await prefs.setString(
      keyId,
      driverId,
    );

    await FirebaseFirestore.instance
        .collection('drivers')
        .doc(driverId)
        .set({
      'id': driverId,
      'phone': phone,
      'vehicleType': vehicleType,
      'online': false,
      'createdAt':
          FieldValue.serverTimestamp(),
      'updatedAt':
          FieldValue.serverTimestamp(),
    });
  }

  await prefs.setString(
    'last_role',
    vehicleType == 'motorcycle'
        ? 'motorcycle_driver'
        : 'car_driver',
  );

  if (!context.mounted) return;

  Navigator.pushReplacement(
    context,
    MaterialPageRoute(
      builder: (_) => DriverPage(
        vehicleType: vehicleType,
      ),
    ),
  );
}

/// ============================================================
/// PHONE DIALOG
/// ============================================================

Future<String?> askPhone(
  BuildContext context,
) async {
  final controller =
      TextEditingController();

  return showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text(
          'رقم الهاتف',
        ),
        content: TextField(
          controller: controller,
          keyboardType:
              TextInputType.phone,
          decoration:
              const InputDecoration(
            hintText:
                'أدخل رقم هاتفك',
            border:
                OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () =>
                Navigator.pop(context),
            child: const Text(
              'إلغاء',
            ),
          ),
          FilledButton(
            onPressed: () {
              final value =
                  controller.text.trim();

              if (value.isNotEmpty) {
                Navigator.pop(
                  context,
                  value,
                );
              }
            },
            child: const Text(
              'متابعة',
            ),
          ),
        ],
      );
    },
  );
}

/// ============================================================
/// CUSTOMER PAGE
/// ============================================================

class CustomerPage extends StatelessWidget {
  const CustomerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'الزبون',
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
            ),
            onPressed: () =>
                logout(context),
          ),
        ],
      ),
      body: Padding(
        padding:
            const EdgeInsets.all(18),
        child: Column(
          children: [
            const SizedBox(height: 15),

            const Text(
              'وش تحب اليوم؟',
              style: TextStyle(
                fontSize: 25,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 25),

            Expanded(
              child: ListView(
                children: [
                  ServiceCard(
                    icon:
                        Icons.directions_car,
                    title:
                        'ألو وصلني',
                    subtitle:
                        'اطلب سيارة للتنقل',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const WaselniPage(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 18),

                  ServiceCard(
                    icon:
                        Icons.two_wheeler,
                    title:
                        'ألو جيبلي',
                    subtitle:
                        'خلي السائق يجيبلك حاجتك',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const JibliPage(),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 18),

                  ServiceCard(
                    icon:
                        Icons.history,
                    title:
                        'طلباتي',
                    subtitle:
                        'شوف الطلبات السابقة',
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const CustomerHistoryPage(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ============================================================
/// SERVICE CARD
/// ============================================================

class ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const ServiceCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: InkWell(
        onTap: onTap,
        borderRadius:
            BorderRadius.circular(18),
        child: Padding(
          padding:
              const EdgeInsets.all(22),
          child: Row(
            children: [
              CircleAvatar(
                radius: 31,
                child: Icon(
                  icon,
                  size: 32,
                ),
              ),
              const SizedBox(
                width: 18,
              ),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style:
                          const TextStyle(
                        fontSize: 21,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    Text(
                      subtitle,
                      style:
                          const TextStyle(
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ============================================================
/// ALO WASELNI
/// ============================================================

class WaselniPage extends StatefulWidget {
  const WaselniPage({super.key});

  @override
  State<WaselniPage> createState() =>
      _WaselniPageState();
}

class _WaselniPageState
    extends State<WaselniPage> {
  bool loading = false;

  Future<void> createRequest() async {
    setState(() {
      loading = true;
    });

    try {
      final prefs =
          await SharedPreferences.getInstance();

      final customerId =
          prefs.getString(
        'customer_id',
      );

      final phone =
          prefs.getString(
        'customer_phone',
      );

      if (customerId == null ||
          phone == null) {
        return;
      }

      final location =
          await getCurrentLocation();

      if (location == null) {
        if (mounted) {
          showMessage(
            'فعّل الموقع ثم حاول من جديد',
          );
        }
        return;
      }

      final requestId = newId();

      await FirebaseFirestore.instance
          .collection('requests')
          .doc(requestId)
          .set({
        'id': requestId,
        'customerId': customerId,
        'phone': phone,
        'service': 'alo_waselni',
        'vehicleType': 'car',
        'status': 'pending',
        'customerLat':
            location.latitude,
        'customerLng':
            location.longitude,
        'driverLat': null,
        'driverLng': null,
        'driverId': null,
        'driverPhone': null,
        'createdAt':
            FieldValue.serverTimestamp(),
        'updatedAt':
            FieldValue.serverTimestamp(),
      });

      await prefs.setString(
        'last_customer_request_id',
        requestId,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              CustomerTrackingPage(
            requestId: requestId,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  void showMessage(String text) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('ألو وصلني'),
      ),
      body: Center(
        child: Padding(
          padding:
              const EdgeInsets.all(25),
          child: Column(
            mainAxisAlignment:
                MainAxisAlignment.center,
            children: [
              const Icon(
                Icons.directions_car,
                size: 90,
                color: Colors.blue,
              ),

              const SizedBox(
                height: 25,
              ),

              const Text(
                'اطلب سيارة الآن',
                style: TextStyle(
                  fontSize: 25,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),

              const SizedBox(
                height: 30,
              ),

              SizedBox(
                width:
                    double.infinity,
                height: 55,
                child: FilledButton.icon(
                  onPressed:
                      loading
                          ? null
                          : createRequest,
                  icon: const Icon(
                    Icons.send,
                  ),
                  label: Text(
                    loading
                        ? 'جاري الطلب...'
                        : 'اطلب ألو وصلني',
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// ============================================================
/// ALO JIBLI
/// ============================================================

class JibliPage extends StatefulWidget {
  const JibliPage({super.key});

  @override
  State<JibliPage> createState() =>
      _JibliPageState();
}

class _JibliPageState
    extends State<JibliPage> {
  final itemController =
      TextEditingController();

  bool loading = false;

  Future<void> createRequest() async {
    final item =
        itemController.text.trim();

    if (item.isEmpty) {
      showMessage(
        'اكتب واش حاب يجيبلك السائق',
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final prefs =
          await SharedPreferences.getInstance();

      final customerId =
          prefs.getString(
        'customer_id',
      );

      final phone =
          prefs.getString(
        'customer_phone',
      );

      if (customerId == null ||
          phone == null) {
        return;
      }

      final location =
          await getCurrentLocation();

      if (location == null) {
        if (mounted) {
          showMessage(
            'فعّل الموقع ثم حاول من جديد',
          );
        }
        return;
      }

      final requestId = newId();

      await FirebaseFirestore.instance
          .collection('requests')
          .doc(requestId)
          .set({
        'id': requestId,
        'customerId': customerId,
        'phone': phone,
        'service': 'alo_jibli',
        'vehicleType': 'motorcycle',
        'item': item,
        'status': 'pending',
        'customerLat':
            location.latitude,
        'customerLng':
            location.longitude,
        'driverLat': null,
        'driverLng': null,
        'driverId': null,
        'driverPhone': null,
        'createdAt':
            FieldValue.serverTimestamp(),
        'updatedAt':
            FieldValue.serverTimestamp(),
      });

      await prefs.setString(
        'last_customer_request_id',
        requestId,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              CustomerTrackingPage(
            requestId: requestId,
          ),
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  void showMessage(String text) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(text),
      ),
    );
  }

  @override
  void dispose() {
    itemController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('ألو جيبلي'),
      ),
      body: Padding(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(
              height: 25,
            ),

            const Icon(
              Icons.two_wheeler,
              size: 85,
              color: Colors.blue,
            ),

            const SizedBox(
              height: 20,
            ),

            const Text(
              'وش حاب يجيبلك السائق؟',
              style: TextStyle(
                fontSize: 22,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            TextField(
              controller:
                  itemController,
              maxLines: 4,
              decoration:
                  const InputDecoration(
                hintText:
                    'مثال: خبز، دواء، غرض...',
                border:
                    OutlineInputBorder(),
              ),
            ),

            const SizedBox(
              height: 20,
            ),

            SizedBox(
              width:
                  double.infinity,
              height: 55,
              child: FilledButton.icon(
                onPressed:
                    loading
                        ? null
                        : createRequest,
                icon: const Icon(
                  Icons.send,
                ),
                label: Text(
                  loading
                      ? 'جاري الطلب...'
                      : 'اطلب ألو جيبلي',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// ============================================================
/// CUSTOMER TRACKING
/// ============================================================

class CustomerTrackingPage
    extends StatefulWidget {
  final String requestId;

  const CustomerTrackingPage({
    super.key,
    required this.requestId,
  });

  @override
  State<CustomerTrackingPage>
      createState() =>
          _CustomerTrackingPageState();
}

class _CustomerTrackingPageState
    extends State<CustomerTrackingPage> {
  Timer? locationTimer;

  @override
  void initState() {
    super.initState();

    locationTimer =
        Timer.periodic(
      const Duration(seconds: 5),
      (_) => updateCustomerLocation(),
    );
  }

  Future<void>
      updateCustomerLocation() async {
    try {
      final location =
          await getCurrentLocation();

      if (location == null) return;

      await FirebaseFirestore.instance
          .collection('requests')
          .doc(widget.requestId)
          .update({
        'customerLat':
            location.latitude,
        'customerLng':
            location.longitude,
        'updatedAt':
            FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  Future<void> cancelRequest() async {
    await FirebaseFirestore.instance
        .collection('requests')
        .doc(widget.requestId)
        .update({
      'status': 'cancelled',
      'updatedAt':
          FieldValue.serverTimestamp(),
    });
  }

  @override
  void dispose() {
    locationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('تتبع الطلب'),
      ),
      body: StreamBuilder<
          DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore
            .instance
            .collection('requests')
            .doc(widget.requestId)
            .snapshots(),
        builder:
            (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          final data =
              snapshot.data!.data();

          if (data == null) {
            return const Center(
              child: Text(
                'الطلب غير موجود',
              ),
            );
          }

          final status =
              data['status'] as String?;

          final customerLat =
              (data['customerLat']
                      as num?)
                  ?.toDouble();

          final customerLng =
              (data['customerLng']
                      as num?)
                  ?.toDouble();

          final driverLat =
              (data['driverLat']
                      as num?)
                  ?.toDouble();

          final driverLng =
              (data['driverLng']
                      as num?)
                  ?.toDouble();

          final customer =
              customerLat != null &&
                      customerLng != null
                  ? LatLng(
                      customerLat,
                      customerLng,
                    )
                  : null;

          final driver =
              driverLat != null &&
                      driverLng != null
                  ? LatLng(
                      driverLat,
                      driverLng,
                    )
                  : null;

          final driverPhone =
              data['driverPhone']
                  as String?;

          final vehicleType =
              data['vehicleType']
                  as String?;

          return Column(
            children: [
              Padding(
                padding:
                    const EdgeInsets.all(12),
                child: Card(
                  child: Padding(
                    padding:
                        const EdgeInsets.all(15),
                    child: Row(
                      children: [
                        CircleAvatar(
                          child: Icon(
                            statusIcon(
                              status,
                            ),
                          ),
                        ),
                        const SizedBox(
                          width: 12,
                        ),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment
                                    .start,
                            children: [
                              Text(
                                statusName(
                                  status,
                                ),
                                style:
                                    const TextStyle(
                                  fontSize: 17,
                                  fontWeight:
                                      FontWeight.bold,
                                ),
                              ),
                              const SizedBox(
                                height: 4,
                              ),
                              Text(
                                serviceName(
                                  data['service']
                                      as String?,
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

              Expanded(
                child: LocationMap(
                  customer: customer,
                  driver: driver,
                  vehicleType:
                      vehicleType,
                  autoFollowDriver:
                      true,
                ),
              ),

              if (driverPhone != null &&
                  driverPhone.isNotEmpty &&
                  status != 'completed' &&
                  status != 'cancelled')
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(
                    15,
                    10,
                    15,
                    5,
                  ),
                  child: SizedBox(
                    width:
                        double.infinity,
                    child:
                        FilledButton.icon(
                      onPressed: () =>
                          callPhoneNumber(
                        driverPhone,
                      ),
                      icon: const Icon(
                        Icons.phone,
                      ),
                      label: Text(
                        'اتصل بالسائق',
                      ),
                    ),
                  ),
                ),

              if (status == 'pending')
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(
                    15,
                    5,
                    15,
                    15,
                  ),
                  child: SizedBox(
                    width:
                        double.infinity,
                    child:
                        OutlinedButton.icon(
                      onPressed:
                          cancelRequest,
                      icon: const Icon(
                        Icons.cancel,
                      ),
                      label: const Text(
                        'إلغاء الطلب',
                      ),
                    ),
                  ),
                ),

              if (status == 'completed')
                const Padding(
                  padding:
                      EdgeInsets.all(15),
                  child: Text(
                    'تم إكمال الطلب بنجاح',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

/// ============================================================
/// DRIVER PAGE
/// ============================================================

class DriverPage extends StatefulWidget {
  final String vehicleType;

  const DriverPage({
    super.key,
    required this.vehicleType,
  });

  @override
  State<DriverPage> createState() =>
      _DriverPageState();
}

class _DriverPageState
    extends State<DriverPage> {
  bool online = false;

  Timer? locationTimer;

  String? driverId;
  String? phone;

  @override
  void initState() {
    super.initState();
    loadDriver();
  }

  Future<void> loadDriver() async {
    final prefs =
        await SharedPreferences.getInstance();

    driverId =
        widget.vehicleType == 'motorcycle'
            ? prefs.getString(
                'motorcycle_driver_id',
              )
            : prefs.getString(
                'car_driver_id',
              );

    phone =
        widget.vehicleType == 'motorcycle'
            ? prefs.getString(
                'motorcycle_driver_phone',
              )
            : prefs.getString(
                'car_driver_phone',
              );

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> setOnline(
    bool value,
  ) async {
    setState(() {
      online = value;
    });

    if (driverId == null) return;

    await FirebaseFirestore.instance
        .collection('drivers')
        .doc(driverId)
        .update({
      'online': value,
      'vehicleType':
          widget.vehicleType,
      'phone': phone,
      'updatedAt':
          FieldValue.serverTimestamp(),
    });

    if (value) {
      startLocationUpdates();
    } else {
      locationTimer?.cancel();
    }
  }

  void startLocationUpdates() {
    locationTimer?.cancel();

    locationTimer =
        Timer.periodic(
      const Duration(seconds: 5),
      (_) => updateDriverLocation(),
    );

    updateDriverLocation();
  }

  Future<void>
      updateDriverLocation() async {
    if (!online ||
        driverId == null) {
      return;
    }

    try {
      final location =
          await getCurrentLocation();

      if (location == null) return;

      await FirebaseFirestore.instance
          .collection('drivers')
          .doc(driverId)
          .update({
        'lat': location.latitude,
        'lng': location.longitude,
        'online': true,
        'vehicleType':
            widget.vehicleType,
        'phone': phone,
        'updatedAt':
            FieldValue.serverTimestamp(),
      });

      final activeRequests =
          await FirebaseFirestore.instance
              .collection('requests')
              .where(
                'driverId',
                isEqualTo: driverId,
              )
              .get();

      for (final doc
          in activeRequests.docs) {
        final data = doc.data();

        final status =
            data['status'] as String?;

        if (status != 'completed' &&
            status != 'cancelled') {
          await doc.reference.update({
            'driverLat':
                location.latitude,
            'driverLng':
                location.longitude,
            'updatedAt':
                FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (_) {}
  }

  Future<void> acceptRequest(
    DocumentSnapshot<Map<String, dynamic>>
        doc,
  ) async {
    if (driverId == null ||
        phone == null) {
      return;
    }

    await doc.reference.update({
      'status': 'accepted',
      'driverId': driverId,
      'driverPhone': phone,
      'vehicleType':
          widget.vehicleType,
      'acceptedAt':
          FieldValue.serverTimestamp(),
      'updatedAt':
          FieldValue.serverTimestamp(),
    });
  }

  Future<void> updateStatus(
    DocumentSnapshot<Map<String, dynamic>>
        doc,
    String status,
  ) async {
    await doc.reference.update({
      'status': status,
      'updatedAt':
          FieldValue.serverTimestamp(),
    });
  }

  Future<void> logout() async {
    locationTimer?.cancel();

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove(
      'last_role',
    );

    if (driverId != null) {
      try {
        await FirebaseFirestore.instance
            .collection('drivers')
            .doc(driverId)
            .update({
          'online': false,
          'updatedAt':
              FieldValue.serverTimestamp(),
        });
      } catch (_) {}
    }

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const HomePage(),
      ),
      (_) => false,
    );
  }

  @override
  void dispose() {
    locationTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isMotorcycle =
        widget.vehicleType ==
            'motorcycle';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          isMotorcycle
              ? 'سائق الدراجة'
              : 'سائق السيارة',
        ),
        actions: [
          IconButton(
            icon: const Icon(
              Icons.logout,
            ),
            onPressed: logout,
          ),
        ],
      ),
      body: Column(
        children: [
          Card(
            margin:
                const EdgeInsets.all(12),
            child: Padding(
              padding:
                  const EdgeInsets.all(15),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 27,
                    child: Icon(
                      isMotorcycle
                          ? Icons.two_wheeler
                          : Icons.directions_car,
                    ),
                  ),
                  const SizedBox(
                    width: 12,
                  ),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment
                              .start,
                      children: [
                        Text(
                          isMotorcycle
                              ? 'سائق الدراجة'
                              : 'سائق السيارة',
                          style:
                              const TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        Text(
                          online
                              ? 'متصل ويستقبل الطلبات'
                              : 'غير متصل',
                          style:
                              TextStyle(
                            color: online
                                ? Colors.green
                                : Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: online,
                    onChanged:
                        setOnline,
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: !online
                ? const Center(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                      children: [
                        Icon(
                          Icons.power_settings_new,
                          size: 70,
                          color: Colors.grey,
                        ),
                        SizedBox(
                          height: 15,
                        ),
                        Text(
                          'فعّل الاتصال لاستقبال الطلبات',
                          style: TextStyle(
                            fontSize: 17,
                          ),
                        ),
                      ],
                    ),
                  )
                : StreamBuilder<
                    QuerySnapshot<
                        Map<String,
                            dynamic>>>(
                    stream:
                        FirebaseFirestore
                            .instance
                            .collection(
                              'requests',
                            )
                            .where(
                              'vehicleType',
                              isEqualTo:
                                  widget
                                      .vehicleType,
                            )
                            .snapshots(),
                    builder:
                        (context, snapshot) {
                      if (!snapshot.hasData) {
                        return const Center(
                          child:
                              CircularProgressIndicator(),
                        );
                      }

                      final requests =
                          snapshot.data!.docs
                              .where((doc) {
                        final data =
                            doc.data();

                        final status =
                            data['status']
                                as String?;

                        return status ==
                            'pending';
                      }).toList();

                      if (requests.isEmpty) {
                        return const Center(
                          child: Column(
                            mainAxisAlignment:
                                MainAxisAlignment
                                    .center,
                            children: [
                              Icon(
                                Icons.inbox,
                                size: 70,
                                color:
                                    Colors.grey,
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              Text(
                                'لا توجد طلبات حالياً',
                                style:
                                    TextStyle(
                                  fontSize: 18,
                                ),
                              ),
                            ],
                          ),
                        );
                      }

                      return ListView.builder(
                        padding:
                            const EdgeInsets
                                .all(12),
                        itemCount:
                            requests.length,
                        itemBuilder:
                            (context, index) {
                          return DriverRequestCard(
                            doc:
                                requests[index],
                            vehicleType:
                                widget
                                    .vehicleType,
                            onAccept:
                                () =>
                                    acceptRequest(
                              requests[index],
                            ),
                            onStatus:
                                (status) =>
                                    updateStatus(
                              requests[index],
                              status,
                            ),
                          );
                        },
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

/// ============================================================
/// DRIVER REQUEST CARD
/// ============================================================

class DriverRequestCard
    extends StatelessWidget {
  final DocumentSnapshot<
      Map<String, dynamic>> doc;

  final String vehicleType;

  final VoidCallback onAccept;

  final Function(String status)
      onStatus;

  const DriverRequestCard({
    super.key,
    required this.doc,
    required this.vehicleType,
    required this.onAccept,
    required this.onStatus,
  });

  @override
  Widget build(BuildContext context) {
    final data = doc.data();

    if (data == null) {
      return const SizedBox();
    }

    final service =
        data['service'] as String?;

    final phone =
        data['phone'] as String?;

    final item =
        data['item'] as String?;

    final customerLat =
        (data['customerLat']
                as num?)
            ?.toDouble();

    final customerLng =
        (data['customerLng']
                as num?)
            ?.toDouble();

    final driverLat =
        (data['driverLat']
                as num?)
            ?.toDouble();

    final driverLng =
        (data['driverLng']
                as num?)
            ?.toDouble();

    final customer =
        customerLat != null &&
                customerLng != null
            ? LatLng(
                customerLat,
                customerLng,
              )
            : null;

    final driver =
        driverLat != null &&
                driverLng != null
            ? LatLng(
                driverLat,
                driverLng,
              )
            : null;

    final status =
        data['status'] as String?;

    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 15,
      ),
      child: Padding(
        padding:
            const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Icon(
                    service ==
                            'alo_jibli'
                        ? Icons.two_wheeler
                        : Icons.directions_car,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Text(
                    serviceName(
                      service,
                    ),
                    style:
                        const TextStyle(
                      fontSize: 19,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(
              height: 10,
            ),

            if (item != null)
              Text(
                'الغرض: $item',
                style:
                    const TextStyle(
                  fontSize: 16,
                ),
              ),

            if (phone != null &&
                phone.isNotEmpty)
              ListTile(
                contentPadding:
                    EdgeInsets.zero,
                leading: const Icon(
                  Icons.phone,
                ),
                title: Text(
                  phone,
                ),
                trailing:
                    IconButton(
                  icon: const Icon(
                    Icons.call,
                    color: Colors.green,
                  ),
                  onPressed: () =>
                      callPhoneNumber(
                    phone,
                  ),
                ),
              ),

            if (customer != null)
              SizedBox(
                height: 230,
                child: LocationMap(
                  customer: customer,
                  driver: driver,
                  vehicleType:
                      vehicleType,
                  autoFollowDriver:
                      false,
                ),
              ),

            const SizedBox(
              height: 10,
            ),

            if (status == 'pending')
              SizedBox(
                width:
                    double.infinity,
                child:
                    FilledButton.icon(
                  onPressed:
                      onAccept,
                  icon: const Icon(
                    Icons.check,
                  ),
                  label:
                      const Text(
                    'قبول الطلب',
                  ),
                ),
              ),

            if (status == 'accepted')
              SizedBox(
                width:
                    double.infinity,
                child:
                    FilledButton(
                  onPressed: () =>
                      onStatus(
                    'driver_arriving',
                  ),
                  child: const Text(
                    'أنا في الطريق',
                  ),
                ),
              ),

            if (status ==
                'driver_arriving')
              SizedBox(
                width:
                    double.infinity,
                child:
                    FilledButton(
                  onPressed: () =>
                      onStatus(
                    'driver_arrived',
                  ),
                  child: const Text(
                    'وصلت للزبون',
                  ),
                ),
              ),

            if (status ==
                'driver_arrived')
              SizedBox(
                width:
                    double.infinity,
                child:
                    FilledButton(
                  onPressed: () =>
                      onStatus(
                    'completed',
                  ),
                  child: const Text(
                    'إكمال الطلب',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

/// ============================================================
/// REAL ROAD ROUTE
/// OSRM + OPENSTREETMAP
/// ============================================================

class RouteResult {
  final List<LatLng> points;
  final double distanceMeters;
  final double durationSeconds;

  const RouteResult({
    required this.points,
    required this.distanceMeters,
    required this.durationSeconds,
  });
}

Future<RouteResult?> fetchRealRoute(
  LatLng start,
  LatLng end,
) async {
  try {
    final url = Uri.parse(
      'https://router.project-osrm.org/'
      'route/v1/driving/'
      '${start.longitude},${start.latitude};'
      '${end.longitude},${end.latitude}'
      '?overview=full'
      '&geometries=geojson'
      '&steps=false',
    );

    final response =
        await http.get(
      url,
      headers: {
        'User-Agent':
            'AlloWaselni/1.0',
      },
    ).timeout(
      const Duration(
        seconds: 10,
      ),
    );

    if (response.statusCode != 200) {
      return null;
    }

    final Map<String, dynamic>
        jsonData =
        jsonDecode(
      response.body,
    );

    if (jsonData['code'] != 'Ok') {
      return null;
    }

    final routes =
        jsonData['routes'];

    if (routes is! List ||
        routes.isEmpty) {
      return null;
    }

    final route = routes.first;

    final geometry =
        route['geometry'];

    final coordinates =
        geometry['coordinates'];

    if (coordinates is! List ||
        coordinates.isEmpty) {
      return null;
    }

    final List<LatLng> points =
        [];

    for (final coordinate
        in coordinates) {
      if (coordinate is List &&
          coordinate.length >= 2) {
        final longitude =
            (coordinate[0] as num)
                .toDouble();

        final latitude =
            (coordinate[1] as num)
                .toDouble();

        points.add(
          LatLng(
            latitude,
            longitude,
          ),
        );
      }
    }

    if (points.isEmpty) {
      return null;
    }

    final distance =
        (route['distance'] as num?)
                ?.toDouble() ??
            0;

    final duration =
        (route['duration'] as num?)
                ?.toDouble() ??
            0;

    return RouteResult(
      points: points,
      distanceMeters:
          distance,
      durationSeconds:
          duration,
    );
  } catch (_) {
    return null;
  }
}

/// ============================================================
/// LOCATION MAP
/// ============================================================

class LocationMap extends StatefulWidget {
  final LatLng? customer;
  final LatLng? driver;

  final String? vehicleType;

  final bool autoFollowDriver;

  const LocationMap({
    super.key,
    required this.customer,
    required this.driver,
    this.vehicleType,
    this.autoFollowDriver = false,
  });

  @override
  State<LocationMap> createState() =>
      _LocationMapState();
}

class _LocationMapState
    extends State<LocationMap> {
  final MapController mapController =
      MapController();

  List<LatLng> routePoints = [];

  double routeDistance = 0;

  double routeDuration = 0;

  bool routeLoading = false;

  bool mapReady = false;

  LatLng? lastRouteStart;

  LatLng? lastRouteEnd;

  Timer? routeTimer;

  @override
  void initState() {
    super.initState();

    routeTimer =
        Timer(const Duration(milliseconds: 500), () {
      updateRoute();

      if (widget.autoFollowDriver &&
          widget.driver != null &&
          mapReady) {
        followDriver(
          widget.driver!,
        );
      }
    });
  }

  @override
  void didUpdateWidget(
    covariant LocationMap oldWidget,
  ) {
    super.didUpdateWidget(
      oldWidget,
    );

    final driverChanged =
        _positionChanged(
      oldWidget.driver,
      widget.driver,
    );

    final customerChanged =
        _positionChanged(
      oldWidget.customer,
      widget.customer,
    );

    if (driverChanged ||
        customerChanged) {
      scheduleRouteUpdate();
    }

    if (widget.autoFollowDriver &&
        driverChanged &&
        widget.driver != null &&
        mapReady) {
      followDriver(
        widget.driver!,
      );
    }
  }

  bool _positionChanged(
    LatLng? a,
    LatLng? b,
  ) {
    if (a == null && b == null) {
      return false;
    }

    if (a == null || b == null) {
      return true;
    }

    final distance =
        const Distance().as(
      LengthUnit.Meter,
      a,
      b,
    );

    return distance >= 20;
  }

  void scheduleRouteUpdate() {
    routeTimer?.cancel();

    routeTimer =
        Timer(const Duration(milliseconds: 500), () {
      updateRoute();
    });
  }

  Future<void> updateRoute() async {
    final driver =
        widget.driver;

    final customer =
        widget.customer;

    if (driver == null ||
        customer == null) {
      if (mounted) {
        setState(() {
          routePoints = [];
          routeDistance = 0;
          routeDuration = 0;
        });
      }

      return;
    }

    bool shouldFetch = true;

    if (lastRouteStart != null &&
        lastRouteEnd != null) {
      final driverMovement =
          const Distance().as(
        LengthUnit.Meter,
        lastRouteStart!,
        driver,
      );

      final customerMovement =
          const Distance().as(
        LengthUnit.Meter,
        lastRouteEnd!,
        customer,
      );

      shouldFetch =
          driverMovement >= 20 ||
              customerMovement >= 20;
    }

    if (!shouldFetch &&
        routePoints.isNotEmpty) {
      return;
    }

    if (mounted) {
      setState(() {
        routeLoading = true;
      });
    }

    final result =
        await fetchRealRoute(
      driver,
      customer,
    );

    if (!mounted) return;

    if (result != null) {
      setState(() {
        routePoints =
            result.points;

        routeDistance =
            result.distanceMeters;

        routeDuration =
            result.durationSeconds;

        routeLoading = false;
      });

      lastRouteStart = driver;
      lastRouteEnd = customer;
    } else {
      setState(() {
        routeLoading = false;
      });
    }
  }

  void followDriver(
    LatLng position,
  ) {
    try {
      mapController.move(
        position,
        16,
      );
    } catch (_) {}
  }

  String formatDistance(
    double meters,
  ) {
    if (meters < 1000) {
      return '${meters.round()} م';
    }

    return '${(meters / 1000).toStringAsFixed(1)} كم';
  }

  String formatDuration(
    double seconds,
  ) {
    final minutes =
        (seconds / 60).round();

    if (minutes < 1) {
      return 'أقل من دقيقة';
    }

    if (minutes < 60) {
      return '$minutes د';
    }

    final hours =
        minutes ~/ 60;

    final remaining =
        minutes % 60;

    if (remaining == 0) {
      return '$hours س';
    }

    return '$hours س و $remaining د';
  }

  @override
  void dispose() {
    routeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final center =
        widget.driver ??
            widget.customer ??
            const LatLng(
              35.6971,
              -0.6308,
            );

    final driverIcon =
        widget.vehicleType ==
                'motorcycle'
            ? Icons.two_wheeler
            : Icons.directions_car;

    return Stack(
      children: [
        FlutterMap(
          mapController:
              mapController,
          options: MapOptions(
            initialCenter: center,
            initialZoom: 14,
            onMapReady: () {
              mapReady = true;

              if (widget
                      .autoFollowDriver &&
                  widget.driver !=
                      null) {
                followDriver(
                  widget.driver!,
                );
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName:
                  'com.example.maw3idi',
            ),

            if (routePoints.isNotEmpty)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points:
                        routePoints,
                    strokeWidth: 8,
                    color:
                        Colors.white,
                  ),
                  Polyline(
                    points:
                        routePoints,
                    strokeWidth: 5,
                    color:
                        Colors.blue,
                  ),
                ],
              ),

            MarkerLayer(
              markers: [
                if (widget.customer !=
                    null)
                  Marker(
                    point:
                        widget.customer!,
                    width: 55,
                    height: 55,
                    child:
                        Container(
                      decoration:
                          BoxDecoration(
                        color:
                            Colors.white,
                        shape:
                            BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors
                                .black
                                .withOpacity(
                              0.20,
                            ),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child:
                          const Icon(
                        Icons
                            .location_on,
                        size: 38,
                        color:
                            Colors.red,
                      ),
                    ),
                  ),

                if (widget.driver !=
                    null)
                  Marker(
                    point:
                        widget.driver!,
                    width: 58,
                    height: 58,
                    child:
                        Container(
                      decoration:
                          BoxDecoration(
                        color:
                            Colors.white,
                        shape:
                            BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors
                                .black
                                .withOpacity(
                              0.20,
                            ),
                            blurRadius: 7,
                          ),
                        ],
                      ),
                      child:
                          Icon(
                        driverIcon,
                        size: 35,
                        color:
                            Colors.blue,
                      ),
                    ),
                  ),
              ],
            ),
          ],
        ),

        if (routePoints.isNotEmpty)
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: Card(
              elevation: 4,
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.route,
                      color:
                          Colors.blue,
                    ),
                    const SizedBox(
                      width: 10,
                    ),
                    Expanded(
                      child: Text(
                        '${formatDistance(routeDistance)} • ${formatDuration(routeDuration)}',
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

        if (routeLoading)
          Positioned(
            bottom: 12,
            left: 12,
            right: 12,
            child: Card(
              child: Padding(
                padding:
                    const EdgeInsets.all(
                  10,
                ),
                child: Row(
                  mainAxisAlignment:
                      MainAxisAlignment
                          .center,
                  children: const [
                    SizedBox(
                      width: 18,
                      height: 18,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                      ),
                    ),
                    SizedBox(
                      width: 10,
                    ),
                    Text(
                      'جاري تحديث المسار...',
                    ),
                  ],
                ),
              ),
            ),
          ),

        if (widget.autoFollowDriver &&
            widget.driver != null)
          Positioned(
            right: 12,
            bottom: 12,
            child: FloatingActionButton
                .small(
              heroTag: null,
              onPressed: () {
                if (widget.driver !=
                    null) {
                  followDriver(
                    widget.driver!,
                  );
                }
              },
              child: const Icon(
                Icons.my_location,
              ),
            ),
          ),
      ],
    );
  }
}

/// ============================================================
/// CUSTOMER HISTORY
/// ============================================================

class CustomerHistoryPage
    extends StatelessWidget {
  const CustomerHistoryPage({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('طلباتي'),
      ),
      body: FutureBuilder<
          SharedPreferences>(
        future:
            SharedPreferences.getInstance(),
        builder:
            (context, prefsSnapshot) {
          if (!prefsSnapshot.hasData) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          final customerId =
              prefsSnapshot.data!
                  .getString(
            'customer_id',
          );

          if (customerId == null) {
            return const Center(
              child: Text(
                'لا يوجد حساب',
              ),
            );
          }

          return StreamBuilder<
              QuerySnapshot<
                  Map<String,
                      dynamic>>>(
            stream: FirebaseFirestore
                .instance
                .collection('requests')
                .where(
                  'customerId',
                  isEqualTo:
                      customerId,
                )
                .snapshots(),
            builder:
                (context, snapshot) {
              if (!snapshot.hasData) {
                return const Center(
                  child:
                      CircularProgressIndicator(),
                );
              }

              final docs =
                  snapshot.data!.docs;

              if (docs.isEmpty) {
                return const Center(
                  child: Text(
                    'ما عندك حتى طلب سابق',
                  ),
                );
              }

              return ListView.builder(
                padding:
                    const EdgeInsets.all(
                  12,
                ),
                itemCount:
                    docs.length,
                itemBuilder:
                    (context, index) {
                  final data =
                      docs[index].data();

                  final status =
                      data['status']
                          as String?;

                  final service =
                      data['service']
                          as String?;

                  final item =
                      data['item']
                          as String?;

                  return Card(
                    margin:
                        const EdgeInsets
                            .only(
                      bottom: 12,
                    ),
                    child: ListTile(
                      leading:
                          CircleAvatar(
                        child: Icon(
                          service ==
                                  'alo_jibli'
                              ? Icons
                                  .two_wheeler
                              : Icons
                                  .directions_car,
                        ),
                      ),
                      title: Text(
                        serviceName(
                          service,
                        ),
                      ),
                      subtitle:
                          Text(
                        item != null
                            ? '$item\n${statusName(status)}'
                            : statusName(
                                status,
                              ),
                      ),
                      isThreeLine:
                          item != null,
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

/// ============================================================
/// LOGOUT
/// ============================================================

Future<void> logout(
  BuildContext context,
) async {
  final prefs =
      await SharedPreferences.getInstance();

  await prefs.remove(
    'last_role',
  );

  if (!context.mounted) return;

  Navigator.pushAndRemoveUntil(
    context,
    MaterialPageRoute(
      builder: (_) =>
          const HomePage(),
    ),
    (_) => false,
  );
}
