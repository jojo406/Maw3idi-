import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;

const String appName = 'ألو وصلني';

final FirebaseFirestore db = FirebaseFirestore.instance;

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
  await Firebase.initializeApp();
}

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

class AloWaselniApp extends StatelessWidget {
  const AloWaselniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: appName,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        scaffoldBackgroundColor: const Color(0xfff5f7fb),
      ),
      home: const HomePage(),
    );
  }
}

// ============================================================
// HELPERS
// ============================================================

Future<Position?> getCurrentLocation() async {
  try {
    bool enabled =
        await Geolocator.isLocationServiceEnabled();

    if (!enabled) {
      return null;
    }

    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission =
          await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission ==
            LocationPermission.deniedForever) {
      return null;
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  } catch (_) {
    return null;
  }
}

String serviceName(String value) {
  switch (value) {
    case 'alo_waselni':
      return 'ألو وصلني';
    case 'alo_jibli':
      return 'ألو جيبلي';
    default:
      return 'طلب';
  }
}

String vehicleName(String value) {
  switch (value) {
    case 'car':
      return 'سيارة';
    case 'motorcycle':
      return 'دراجة';
    default:
      return 'مركبة';
  }
}

String statusName(String value) {
  switch (value) {
    case 'pending':
      return 'في انتظار السائق';
    case 'accepted':
      return 'تم قبول الطلب';
    case 'driver_arriving':
      return 'السائق في الطريق';
    case 'driver_arrived':
      return 'السائق وصل';
    case 'completed':
      return 'اكتمل الطلب';
    case 'cancelled':
      return 'تم إلغاء الطلب';
    default:
      return value;
  }
}

IconData statusIcon(String value) {
  switch (value) {
    case 'pending':
      return Icons.hourglass_top;
    case 'accepted':
      return Icons.check_circle;
    case 'driver_arriving':
      return Icons.directions_car;
    case 'driver_arrived':
      return Icons.location_on;
    case 'completed':
      return Icons.done_all;
    case 'cancelled':
      return Icons.cancel;
    default:
      return Icons.info;
  }
}

Future<void> callPhoneNumber(
  BuildContext context,
  String? phone,
) async {
  if (phone == null || phone.trim().isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('رقم الهاتف غير موجود'),
      ),
    );
    return;
  }

  final Uri uri = Uri(
    scheme: 'tel',
    path: phone.trim(),
  );

  try {
    final bool ok = await launchUrl(
      uri,
      mode: LaunchMode.externalApplication,
    );

    if (!ok && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر فتح الاتصال'),
        ),
      );
    }
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر الاتصال'),
        ),
      );
    }
  }
}

String newId() {
  return DateTime.now()
      .microsecondsSinceEpoch
      .toString();
}

// ============================================================
// HOME
// ============================================================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() =>
      _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _openSavedAccount();
  }

  Future<void> _openSavedAccount() async {
    final prefs =
        await SharedPreferences.getInstance();

    final String role =
        prefs.getString('last_role') ?? '';

    if (!mounted) return;

    if (role == 'customer' &&
        (prefs.getString('customer_id') ?? '')
            .isNotEmpty) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const CustomerPage(),
        ),
      );
      return;
    }

    if (role == 'driver_car' &&
        (prefs.getString('driver_car_id') ?? '')
            .isNotEmpty) {
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

    if (role == 'driver_motorcycle' &&
        (prefs.getString(
                    'driver_motorcycle_id') ??
                '')
            .isNotEmpty) {
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

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ألو وصلني',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 15),
            const Icon(
              Icons.local_shipping_rounded,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 15),
            const Text(
              'مرحبا بك في ألو وصلني',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'خدمات التوصيل والتنقل داخل البلدية',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 35),
            _RoleButton(
              icon: Icons.person,
              title: 'أنا الزبون',
              subtitle: 'اطلب سيارة أو توصيل',
              color: Colors.blue,
              onTap: () async {
                await ensureCustomerProfile(
                  context,
                );
              },
            ),
            const SizedBox(height: 15),
            _RoleButton(
              icon: Icons.directions_car,
              title: 'أنا سائق السيارة',
              subtitle: 'استقبل طلبات ألو وصلني',
              color: Colors.green,
              onTap: () async {
                await ensureDriverProfile(
                  context,
                  'car',
                );
              },
            ),
            const SizedBox(height: 15),
            _RoleButton(
              icon: Icons.two_wheeler,
              title: 'أنا سائق الدراجة',
              subtitle: 'استقبل طلبات ألو جيبلي',
              color: Colors.orange,
              onTap: () async {
                await ensureDriverProfile(
                  context,
                  'motorcycle',
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _RoleButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: InkWell(
        borderRadius:
            BorderRadius.circular(18),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(18),
          child: Row(
            children: [
              CircleAvatar(
                radius: 29,
                backgroundColor:
                    color.withOpacity(.12),
                child: Icon(
                  icon,
                  color: color,
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
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(subtitle),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// CUSTOMER PROFILE
// ============================================================

Future<void> ensureCustomerProfile(
  BuildContext context,
) async {
  final prefs =
      await SharedPreferences.getInstance();

  String? id =
      prefs.getString('customer_id');

  if (id != null && id.isNotEmpty) {
    await prefs.setString(
      'last_role',
      'customer',
    );

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CustomerPage(),
      ),
    );
    return;
  }

  final controller =
      TextEditingController();

  final result = await showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        title:
            const Text('تسجيل الزبون'),
        content: TextField(
          controller: controller,
          keyboardType:
              TextInputType.phone,
          decoration:
              const InputDecoration(
            labelText: 'رقم الهاتف',
            hintText: '05xxxxxxxx',
            prefixIcon:
                Icon(Icons.phone),
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
          FilledButton(
            onPressed: () {
              final phone =
                  controller.text.trim();

              if (phone.isEmpty) {
                return;
              }

              Navigator.pop(
                dialogContext,
                phone,
              );
            },
            child:
                const Text('دخول'),
          ),
        ],
      );
    },
  );

  controller.dispose();

  if (result == null ||
      result.trim().isEmpty) {
    return;
  }

  final customerId = newId();

  try {
    await db
        .collection('customers')
        .doc(customerId)
        .set({
      'phone': result.trim(),
      'createdAt':
          FieldValue.serverTimestamp(),
      'updatedAt':
          FieldValue.serverTimestamp(),
    });

    await prefs.setString(
      'customer_id',
      customerId,
    );

    await prefs.setString(
      'customer_phone',
      result.trim(),
    );

    await prefs.setString(
      'last_role',
      'customer',
    );

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CustomerPage(),
      ),
    );
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
              Text('حدث خطأ: $e'),
        ),
      );
    }
  }
}

// ============================================================
// DRIVER PROFILE
// ============================================================

String driverIdKey(
  String vehicleType,
) {
  return vehicleType == 'car'
      ? 'driver_car_id'
      : 'driver_motorcycle_id';
}

String driverPhoneKey(
  String vehicleType,
) {
  return vehicleType == 'car'
      ? 'driver_car_phone'
      : 'driver_motorcycle_phone';
}

Future<void> ensureDriverProfile(
  BuildContext context,
  String vehicleType,
) async {
  final prefs =
      await SharedPreferences.getInstance();

  final idKey =
      driverIdKey(vehicleType);

  String? id =
      prefs.getString(idKey);

  if (id != null && id.isNotEmpty) {
    await prefs.setString(
      'last_role',
      vehicleType == 'car'
          ? 'driver_car'
          : 'driver_motorcycle',
    );

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DriverPage(
          vehicleType: vehicleType,
        ),
      ),
    );

    return;
  }

  final nameController =
      TextEditingController();

  final phoneController =
      TextEditingController();

  final result =
      await showDialog<List<String>>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        title: Text(
          vehicleType == 'car'
              ? 'تسجيل سائق السيارة'
              : 'تسجيل سائق الدراجة',
        ),
        content: Column(
          mainAxisSize:
              MainAxisSize.min,
          children: [
            TextField(
              controller:
                  nameController,
              decoration:
                  const InputDecoration(
                labelText: 'الاسم',
                prefixIcon:
                    Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 12),
            TextField(
              controller:
                  phoneController,
              keyboardType:
                  TextInputType.phone,
              decoration:
                  const InputDecoration(
                labelText:
                    'رقم الهاتف',
                prefixIcon:
                    Icon(Icons.phone),
              ),
            ),
          ],
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
          FilledButton(
            onPressed: () {
              final name =
                  nameController.text
                      .trim();

              final phone =
                  phoneController.text
                      .trim();

              if (name.isEmpty ||
                  phone.isEmpty) {
                return;
              }

              Navigator.pop(
                dialogContext,
                [
                  name,
                  phone,
                ],
              );
            },
            child:
                const Text('تسجيل'),
          ),
        ],
      );
    },
  );

  nameController.dispose();
  phoneController.dispose();

  if (result == null ||
      result.length < 2) {
    return;
  }

  final driverId = newId();

  try {
    await db
        .collection('drivers')
        .doc(driverId)
        .set({
      'name': result[0],
      'phone': result[1],
      'vehicleType': vehicleType,
      'online': false,
      'createdAt':
          FieldValue.serverTimestamp(),
      'updatedAt':
          FieldValue.serverTimestamp(),
    });

    await prefs.setString(
      idKey,
      driverId,
    );

    await prefs.setString(
      driverPhoneKey(vehicleType),
      result[1],
    );

    await prefs.setString(
      'last_role',
      vehicleType == 'car'
          ? 'driver_car'
          : 'driver_motorcycle',
    );

    if (!context.mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DriverPage(
          vehicleType: vehicleType,
        ),
      ),
    );
  } catch (e) {
    if (context.mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content:
              Text('حدث خطأ: $e'),
        ),
      );
    }
  }
}

// ============================================================
// CUSTOMER PAGE
// ============================================================

class CustomerPage
    extends StatelessWidget {
  const CustomerPage({super.key});

  Future<void> logout(
    BuildContext context,
  ) async {
    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove(
      'customer_id',
    );

    await prefs.remove(
      'customer_phone',
    );

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
      (route) => false,
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('أنا الزبون'),
        actions: [
          IconButton(
            tooltip:
                'تسجيل الخروج',
            onPressed: () =>
                logout(context),
            icon:
                const Icon(Icons.logout),
          ),
        ],
      ),
      body: ListView(
        padding:
            const EdgeInsets.all(20),
        children: [
          const SizedBox(height: 10),
          const Icon(
            Icons.person_pin_circle,
            size: 75,
            color: Colors.blue,
          ),
          const SizedBox(height: 12),
          const Text(
            'اختر الخدمة',
            textAlign:
                TextAlign.center,
            style: TextStyle(
              fontSize: 25,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          const SizedBox(height: 25),
          Card(
            child: ListTile(
              contentPadding:
                  const EdgeInsets.all(
                18,
              ),
              leading:
                  const CircleAvatar(
                radius: 28,
                child: Icon(
                  Icons.directions_car,
                ),
              ),
              title: const Text(
                'ألو وصلني',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              subtitle:
                  const Text(
                'اطلب سيارة وتابع السائق على الخريطة',
              ),
              trailing:
                  const Icon(
                Icons.arrow_forward_ios,
              ),
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
          ),
          const SizedBox(height: 15),
          Card(
            child: ListTile(
              contentPadding:
                  const EdgeInsets.all(
                18,
              ),
              leading:
                  const CircleAvatar(
                radius: 28,
                child: Icon(
                  Icons.two_wheeler,
                ),
              ),
              title: const Text(
                'ألو جيبلي',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              subtitle:
                  const Text(
                'اطلب توصيل دراجة',
              ),
              trailing:
                  const Icon(
                Icons.arrow_forward_ios,
              ),
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
          ),
          const SizedBox(height: 15),
          Card(
            child: ListTile(
              contentPadding:
                  const EdgeInsets.all(
                18,
              ),
              leading:
                  const CircleAvatar(
                radius: 28,
                child: Icon(
                  Icons.history,
                ),
              ),
              title: const Text(
                'طلباتي',
                style: TextStyle(
                  fontSize: 19,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              trailing:
                  const Icon(
                Icons.arrow_forward_ios,
              ),
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
          ),
        ],
      ),
    );
  }
}

// ============================================================
// REQUEST: ALO WASELNI
// ============================================================

class WaselniPage
    extends StatefulWidget {
  const WaselniPage({super.key});

  @override
  State<WaselniPage>
      createState() =>
          _WaselniPageState();
}

class _WaselniPageState
    extends State<WaselniPage> {
  bool loading = false;

  Future<void> createRequest() async {
    setState(() {
      loading = true;
    });

    final prefs =
        await SharedPreferences.getInstance();

    final customerId =
        prefs.getString(
              'customer_id',
            ) ??
            '';

    final phone =
        prefs.getString(
              'customer_phone',
            ) ??
            '';

    final position =
        await getCurrentLocation();

    if (position == null) {
      if (mounted) {
        setState(() {
          loading = false;
        });

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'فعّل الموقع GPS وحاول من جديد',
            ),
          ),
        );
      }

      return;
    }

    final requestId = newId();

    try {
      await db
          .collection('requests')
          .doc(requestId)
          .set({
        'customerId':
            customerId,
        'phone': phone,
        'service':
            'alo_waselni',
        'vehicleType': 'car',
        'status': 'pending',
        'customerLat':
            position.latitude,
        'customerLng':
            position.longitude,
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              'فشل إرسال الطلب: $e',
            ),
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('ألو وصلني'),
      ),
      body: Padding(
        padding:
            const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.directions_car,
              size: 90,
              color: Colors.blue,
            ),
            const SizedBox(height: 20),
            const Text(
              'اطلب سيارة',
              style: TextStyle(
                fontSize: 27,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'حدد موقعك الحالي وسيظهر طلبك للسائقين المتاحين.',
              textAlign:
                  TextAlign.center,
            ),
            const Spacer(),
            SizedBox(
              width:
                  double.infinity,
              height: 55,
              child:
                  FilledButton.icon(
                onPressed: loading
                    ? null
                    : createRequest,
                icon: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color:
                              Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.send,
                      ),
                label: Text(
                  loading
                      ? 'جاري إرسال الطلب...'
                      : 'اطلب الآن',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// REQUEST: ALO JIBLI
// ============================================================

class JibliPage
    extends StatefulWidget {
  const JibliPage({super.key});

  @override
  State<JibliPage>
      createState() =>
          _JibliPageState();
}

class _JibliPageState
    extends State<JibliPage> {
  final itemController =
      TextEditingController();

  bool loading = false;

  @override
  void dispose() {
    itemController.dispose();
    super.dispose();
  }

  Future<void> createRequest() async {
    if (itemController.text
        .trim()
        .isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text('اكتب واش حاب تجيب'),
        ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    final prefs =
        await SharedPreferences.getInstance();

    final customerId =
        prefs.getString(
              'customer_id',
            ) ??
            '';

    final phone =
        prefs.getString(
              'customer_phone',
            ) ??
            '';

    final position =
        await getCurrentLocation();

    if (position == null) {
      if (mounted) {
        setState(() {
          loading = false;
        });

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'فعّل الموقع GPS وحاول من جديد',
            ),
          ),
        );
      }

      return;
    }

    final requestId = newId();

    try {
      await db
          .collection('requests')
          .doc(requestId)
          .set({
        'customerId':
            customerId,
        'phone': phone,
        'service':
            'alo_jibli',
        'vehicleType':
            'motorcycle',
        'item':
            itemController.text.trim(),
        'status': 'pending',
        'customerLat':
            position.latitude,
        'customerLng':
            position.longitude,
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
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              'فشل إرسال الطلب: $e',
            ),
          ),
        );
      }
    }

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
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
            const Icon(
              Icons.two_wheeler,
              size: 90,
              color: Colors.orange,
            ),
            const SizedBox(height: 15),
            const Text(
              'ألو جيبلي',
              style: TextStyle(
                fontSize: 27,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller:
                  itemController,
              maxLines: 3,
              decoration:
                  const InputDecoration(
                labelText:
                    'واش حاب نجيبولك؟',
                hintText:
                    'مثال: دواء، أكل، غرض...',
                border:
                    OutlineInputBorder(),
              ),
            ),
            const Spacer(),
            SizedBox(
              width:
                  double.infinity,
              height: 55,
              child:
                  FilledButton.icon(
                onPressed: loading
                    ? null
                    : createRequest,
                icon: loading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                          color:
                              Colors.white,
                        ),
                      )
                    : const Icon(
                        Icons.send,
                      ),
                label: Text(
                  loading
                      ? 'جاري الإرسال...'
                      : 'أرسل الطلب',
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// CUSTOMER TRACKING
// ============================================================

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
    startCustomerLocationTracking();
  }

  @override
  void dispose() {
    locationTimer?.cancel();
    super.dispose();
  }

  void startCustomerLocationTracking() {
    locationTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) async {
        await updateCustomerLocation();
      },
    );
  }

  Future<void> updateCustomerLocation() async {
    try {
      final position =
          await getCurrentLocation();

      if (position == null) return;

      await db
          .collection('requests')
          .doc(widget.requestId)
          .update({
        'customerLat':
            position.latitude,
        'customerLng':
            position.longitude,
        'updatedAt':
            FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  Future<void> cancelRequest() async {
    try {
      await db
          .collection('requests')
          .doc(widget.requestId)
          .update({
        'status': 'cancelled',
        'updatedAt':
            FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content:
                Text('تعذر الإلغاء: $e'),
          ),
        );
      }
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('متابعة الطلب'),
      ),
      body: StreamBuilder<
          DocumentSnapshot<
              Map<String, dynamic>>>(
        stream: db
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
              data['status'] ??
                  'pending';

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

          final driverPhone =
              data['driverPhone']
                  ?.toString();

          return Column(
            children: [
              _StatusHeader(
                status: status,
              ),
              Expanded(
                child: LocationMap(
                  customerLat:
                      customerLat,
                  customerLng:
                      customerLng,
                  driverLat:
                      driverLat,
                  driverLng:
                      driverLng,
                  showCustomer:
                      true,
                  showDriver:
                      true,
                ),
              ),
              if (driverPhone !=
                      null &&
                  driverPhone.isNotEmpty)
                Padding(
                  padding:
                      const EdgeInsets.fromLTRB(
                    15,
                    10,
                    15,
                    0,
                  ),
                  child: SizedBox(
                    width:
                        double.infinity,
                    child:
                        FilledButton.icon(
                      onPressed: () {
                        callPhoneNumber(
                          context,
                          driverPhone,
                        );
                      },
                      icon:
                          const Icon(
                        Icons.phone,
                      ),
                      label:
                          const Text(
                        'اتصل بالسائق',
                      ),
                    ),
                  ),
                ),
              Padding(
                padding:
                    const EdgeInsets.all(
                  15,
                ),
                child: Column(
                  children: [
                    if (data['item'] !=
                        null)
                      Text(
                        'الطلب: ${data['item']}',
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),
                    const SizedBox(
                      height: 8,
                    ),
                    if (status ==
                        'pending')
                      SizedBox(
                        width:
                            double.infinity,
                        child:
                            OutlinedButton
                                .icon(
                          onPressed:
                              cancelRequest,
                          icon:
                              const Icon(
                            Icons.close,
                          ),
                          label:
                              const Text(
                            'إلغاء الطلب',
                          ),
                        ),
                      ),
                    if (status ==
                        'completed')
                      const Text(
                        'تم إكمال الطلب بنجاح',
                        style:
                            TextStyle(
                          color:
                              Colors.green,
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}

// ============================================================
// STATUS HEADER
// ============================================================

class _StatusHeader
    extends StatelessWidget {
  final String status;

  const _StatusHeader({
    required this.status,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.all(14),
      color: Colors.white,
      child: Row(
        children: [
          Icon(
            statusIcon(status),
            color: Theme.of(context)
                .colorScheme
                .primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              statusName(status),
              style:
                  const TextStyle(
                fontSize: 17,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// DRIVER PAGE
// ============================================================

class DriverPage
    extends StatefulWidget {
  final String vehicleType;

  const DriverPage({
    super.key,
    required this.vehicleType,
  });

  @override
  State<DriverPage>
      createState() =>
          _DriverPageState();
}

class _DriverPageState
    extends State<DriverPage> {
  String driverId = '';
  String driverPhone = '';

  bool online = false;
  bool loading = true;

  Timer? locationTimer;

  @override
  void initState() {
    super.initState();
    loadDriver();
  }

  @override
  void dispose() {
    locationTimer?.cancel();
    super.dispose();
  }

  Future<void> loadDriver() async {
    final prefs =
        await SharedPreferences.getInstance();

    driverId =
        prefs.getString(
              driverIdKey(
                widget.vehicleType,
              ),
            ) ??
            '';

    driverPhone =
        prefs.getString(
              driverPhoneKey(
                widget.vehicleType,
              ),
            ) ??
            '';

    try {
      final token =
          await FirebaseMessaging
              .instance
              .getToken();

      if (token != null &&
          driverId.isNotEmpty) {
        await db
            .collection('drivers')
            .doc(driverId)
            .set(
          {
            'fcmToken': token,
            'updatedAt':
                FieldValue
                    .serverTimestamp(),
          },
          SetOptions(
            merge: true,
          ),
        );
      }
    } catch (_) {}

    if (mounted) {
      setState(() {
        loading = false;
      });
    }
  }

  Future<void> setOnline(
    bool value,
  ) async {
    setState(() {
      online = value;
    });

    try {
      await db
          .collection('drivers')
          .doc(driverId)
          .set(
        {
          'online': value,
          'vehicleType':
              widget.vehicleType,
          'phone': driverPhone,
          'updatedAt':
              FieldValue.serverTimestamp(),
        },
        SetOptions(
          merge: true,
        ),
      );

      if (value) {
        startLocationTracking();
      } else {
        locationTimer?.cancel();
        locationTimer = null;
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          online = !value;
        });

        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content:
                Text('حدث خطأ: $e'),
          ),
        );
      }
    }
  }

  void startLocationTracking() {
    locationTimer?.cancel();

    updateDriverLocation();

    locationTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) {
        updateDriverLocation();
      },
    );
  }

  Future<void> updateDriverLocation() async {
    if (driverId.isEmpty ||
        !online) {
      return;
    }

    final position =
        await getCurrentLocation();

    if (position == null) {
      return;
    }

    try {
      await db
          .collection('drivers')
          .doc(driverId)
          .set(
        {
          'lat': position.latitude,
          'lng': position.longitude,
          'online': true,
          'updatedAt':
              FieldValue.serverTimestamp(),
        },
        SetOptions(
          merge: true,
        ),
      );

      final query = await db
          .collection('requests')
          .where(
            'driverId',
            isEqualTo: driverId,
          )
          .get();

      for (final doc
          in query.docs) {
        final data = doc.data();
        final status =
            data['status'];

        if (status == 'accepted' ||
            status ==
                'driver_arriving' ||
            status ==
                'driver_arrived') {
          await doc.reference.update({
            'driverLat':
                position.latitude,
            'driverLng':
                position.longitude,
            'updatedAt':
                FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (_) {}
  }

  Future<void> logout() async {
    locationTimer?.cancel();

    try {
      await db
          .collection('drivers')
          .doc(driverId)
          .set(
        {
          'online': false,
          'updatedAt':
              FieldValue.serverTimestamp(),
        },
        SetOptions(
          merge: true,
        ),
      );
    } catch (_) {}

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove(
      driverIdKey(
        widget.vehicleType,
      ),
    );

    await prefs.remove(
      driverPhoneKey(
        widget.vehicleType,
      ),
    );

    await prefs.remove(
      'last_role',
    );

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) =>
            const HomePage(),
      ),
      (route) => false,
    );
  }

  Future<void> acceptRequest(
    String requestId,
    Map<String, dynamic> data,
  ) async {
    try {
      final driverDoc =
          await db
              .collection('drivers')
              .doc(driverId)
              .get();

      final driverData =
          driverDoc.data() ?? {};

      final phone =
          driverData['phone']
                  ?.toString() ??
              driverPhone;

      await db
          .collection('requests')
          .doc(requestId)
          .update({
        'status': 'accepted',
        'driverId': driverId,
        'driverPhone': phone,
        'driverVehicleType':
            widget.vehicleType,
        'acceptedAt':
            FieldValue.serverTimestamp(),
        'updatedAt':
            FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content:
              Text('تم قبول الطلب'),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              'تعذر قبول الطلب: $e',
            ),
          ),
        );
      }
    }
  }

  Future<void> updateStatus(
    String requestId,
    String status,
  ) async {
    try {
      await db
          .collection('requests')
          .doc(requestId)
          .update({
        'status': status,
        'updatedAt':
            FieldValue.serverTimestamp(),
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(
              'تعذر تحديث الحالة: $e',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    if (loading) {
      return const Scaffold(
        body: Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    final service =
        widget.vehicleType == 'car'
            ? 'alo_waselni'
            : 'alo_jibli';

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.vehicleType == 'car'
              ? 'سائق السيارة'
              : 'سائق الدراجة',
        ),
        actions: [
          IconButton(
            onPressed: logout,
            icon:
                const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.white,
            padding:
                const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 10,
            ),
            child: Row(
              children: [
                Icon(
                  widget.vehicleType ==
                          'car'
                      ? Icons
                          .directions_car
                      : Icons.two_wheeler,
                  size: 32,
                ),
                const SizedBox(
                  width: 12,
                ),
                const Expanded(
                  child: Text(
                    'متاح لاستقبال الطلبات',
                    style:
                        TextStyle(
                      fontSize: 17,
                      fontWeight:
                          FontWeight
                              .bold,
                    ),
                  ),
                ),
                Switch(
                  value: online,
                  onChanged: setOnline,
                ),
              ],
            ),
          ),
          if (!online)
            const Expanded(
              child: Center(
                child: Column(
                  mainAxisSize:
                      MainAxisSize.min,
                  children: [
                    Icon(
                      Icons
                          .power_settings_new,
                      size: 70,
                      color:
                          Colors.grey,
                    ),
                    SizedBox(
                      height: 15,
                    ),
                    Text(
                      'أنت غير متاح',
                      style:
                          TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight
                                .bold,
                      ),
                    ),
                    SizedBox(
                      height: 6,
                    ),
                    Text(
                      'فعّل الزر لاستقبال الطلبات',
                    ),
                  ],
                ),
              ),
            )
          else
            Expanded(
              child: StreamBuilder<
                  QuerySnapshot<
                      Map<String,
                          dynamic>>>(
                stream: db
                    .collection(
                        'requests')
                    .where(
                      'vehicleType',
                      isEqualTo:
                          widget.vehicleType,
                    )
                    .snapshots(),
                builder: (
                  context,
                  snapshot,
                ) {
                  if (snapshot
                          .connectionState ==
                      ConnectionState
                          .waiting) {
                    return const Center(
                      child:
                          CircularProgressIndicator(),
                    );
                  }

                  if (!snapshot
                          .hasData ||
                      snapshot.data!
                          .docs
                          .isEmpty) {
                    return const Center(
                      child: Text(
                        'لا توجد طلبات حاليا',
                        style:
                            TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    );
                  }

                  final docs = snapshot
                      .data!
                      .docs
                      .where((doc) {
                    final data =
                        doc.data();

                    final requestService =
                        data['service']
                            ?.toString();

                    final status =
                        data['status']
                            ?.toString();

                    final requestDriver =
                        data['driverId']
                            ?.toString();

                    if (requestService !=
                        service) {
                      return false;
                    }

                    if (status ==
                        'pending') {
                      return true;
                    }

                    if (requestDriver ==
                            driverId &&
                        (status ==
                                'accepted' ||
                            status ==
                                'driver_arriving' ||
                            status ==
                                'driver_arrived')) {
                      return true;
                    }

                    return false;
                  }).toList();

                  if (docs.isEmpty) {
                    return const Center(
                      child: Text(
                        'لا توجد طلبات حاليا',
                        style:
                            TextStyle(
                          fontSize: 18,
                        ),
                      ),
                    );
                  }

                  docs.sort(
                    (a, b) {
                      final aTime =
                          a.data()[
                              'createdAt'];

                      final bTime =
                          b.data()[
                              'createdAt'];

                      if (aTime
                              is Timestamp &&
                          bTime
                              is Timestamp) {
                        return bTime
                            .compareTo(
                                aTime);
                      }

                      return 0;
                    },
                  );

                  return ListView
                      .builder(
                    padding:
                        const EdgeInsets
                            .all(12),
                    itemCount:
                        docs.length,
                    itemBuilder:
                        (context,
                            index) {
                      final doc =
                          docs[index];

                      return DriverRequestCard(
                        requestId:
                            doc.id,
                        data:
                            doc.data(),
                        driverId:
                            driverId,
                        onAccept: () {
                          acceptRequest(
                            doc.id,
                            doc.data(),
                          );
                        },
                        onStatusChange:
                            (status) {
                          updateStatus(
                            doc.id,
                            status,
                          );
                        },
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

// ============================================================
// DRIVER REQUEST CARD
// ============================================================

class DriverRequestCard
    extends StatelessWidget {
  final String requestId;
  final Map<String, dynamic> data;
  final String driverId;
  final VoidCallback onAccept;
  final Function(String)
      onStatusChange;

  const DriverRequestCard({
    super.key,
    required this.requestId,
    required this.data,
    required this.driverId,
    required this.onAccept,
    required this.onStatusChange,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    final service =
        data['service']
                ?.toString() ??
            '';

    final status =
        data['status']
                ?.toString() ??
            'pending';

    final phone =
        data['phone']?.toString();

    final item =
        data['item']?.toString();

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

    final bool mine =
        data['driverId']
                ?.toString() ==
            driverId;

    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 15,
      ),
      clipBehavior:
          Clip.antiAlias,
      child: Padding(
        padding:
            const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment
                  .start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Icon(
                    service ==
                            'alo_waselni'
                        ? Icons
                            .directions_car
                        : Icons
                            .two_wheeler,
                  ),
                ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Text(
                    serviceName(
                        service),
                    style:
                        const TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight
                              .bold,
                    ),
                  ),
                ),
                Chip(
                  label: Text(
                    statusName(
                        status),
                  ),
                ),
              ],
            ),
            if (item != null &&
                item.isNotEmpty) ...[
              const SizedBox(
                height: 8,
              ),
              Text(
                'الطلب: $item',
                style:
                    const TextStyle(
                  fontWeight:
                      FontWeight
                          .bold,
                ),
              ),
            ],
            const SizedBox(
              height: 10,
            ),
            SizedBox(
              height: 260,
              child: LocationMap(
                customerLat:
                    customerLat,
                customerLng:
                    customerLng,
                driverLat:
                    driverLat,
                driverLng:
                    driverLng,
                showCustomer:
                    true,
                showDriver:
                    mine,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            if (phone != null &&
                phone.isNotEmpty)
              SizedBox(
                width:
                    double.infinity,
                child:
                    OutlinedButton
                        .icon(
                  onPressed: () {
                    callPhoneNumber(
                      context,
                      phone,
                    );
                  },
                  icon:
                      const Icon(
                    Icons.phone,
                  ),
                  label:
                      const Text(
                    'اتصل بالزبون',
                  ),
                ),
              ),
            const SizedBox(
              height: 8,
            ),
            if (status ==
                'pending')
              SizedBox(
                width:
                    double.infinity,
                child:
                    FilledButton
                        .icon(
                  onPressed:
                      onAccept,
                  icon:
                      const Icon(
                    Icons.check,
                  ),
                  label:
                      const Text(
                    'قبول الطلب',
                  ),
                ),
              ),
            if (mine &&
                status ==
                    'accepted')
              SizedBox(
                width:
                    double.infinity,
                child:
                    FilledButton
                        .icon(
                  onPressed: () {
                    onStatusChange(
                      'driver_arriving',
                    );
                  },
                  icon:
                      const Icon(
                    Icons.navigation,
                  ),
                  label:
                      const Text(
                    'أنا في الطريق',
                  ),
                ),
              ),
            if (mine &&
                status ==
                    'driver_arriving')
              SizedBox(
                width:
                    double.infinity,
                child:
                    FilledButton
                        .icon(
                  onPressed: () {
                    onStatusChange(
                      'driver_arrived',
                    );
                  },
                  icon:
                      const Icon(
                    Icons.location_on,
                  ),
                  label:
                      const Text(
                    'وصلت للزبون',
                  ),
                ),
              ),
            if (mine &&
                status ==
                    'driver_arrived')
              SizedBox(
                width:
                    double.infinity,
                child:
                    FilledButton
                        .icon(
                  onPressed: () {
                    onStatusChange(
                      'completed',
                    );
                  },
                  icon:
                      const Icon(
                    Icons.done_all,
                  ),
                  label:
                      const Text(
                    'إنهاء الطلب',
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// REAL ROAD ROUTE
// ============================================================

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
      '?overview=full&geometries=geojson&steps=false',
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

    if (response.statusCode !=
        200) {
      return null;
    }

    final Map<String, dynamic>
        jsonData =
        jsonDecode(response.body);

    if (jsonData['code'] !=
        'Ok') {
      return null;
    }

    final routes =
        jsonData['routes'];

    if (routes is! List ||
        routes.isEmpty) {
      return null;
    }

    final route =
        routes.first;

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

// ============================================================
// MAP WITH REAL ROAD ROUTE
// ============================================================

class LocationMap
    extends StatefulWidget {
  final double? customerLat;
  final double? customerLng;
  final double? driverLat;
  final double? driverLng;
  final bool showCustomer;
  final bool showDriver;

  const LocationMap({
    super.key,
    required this.customerLat,
    required this.customerLng,
    required this.driverLat,
    required this.driverLng,
    required this.showCustomer,
    required this.showDriver,
  });

  @override
  State<LocationMap> createState() =>
      _LocationMapState();
}

class _LocationMapState
    extends State<LocationMap> {
  final MapController
      mapController =
      MapController();

  List<LatLng> routePoints = [];

  double? routeDistance;
  double? routeDuration;

  bool routeLoading = false;

  LatLng? lastRouteStart;
  LatLng? lastRouteEnd;

  Timer? routeTimer;

  LatLng? get customerPoint {
    if (widget.customerLat ==
            null ||
        widget.customerLng ==
            null) {
      return null;
    }

    return LatLng(
      widget.customerLat!,
      widget.customerLng!,
    );
  }

  LatLng? get driverPoint {
    if (widget.driverLat ==
            null ||
        widget.driverLng ==
            null) {
      return null;
    }

    return LatLng(
      widget.driverLat!,
      widget.driverLng!,
    );
  }

  LatLng get center {
    if (driverPoint != null) {
      return driverPoint!;
    }

    if (customerPoint != null) {
      return customerPoint!;
    }

    return const LatLng(
      35.6971,
      -0.6308,
    );
  }

  @override
  void initState() {
    super.initState();

    _scheduleRouteUpdate();
  }

  @override
  void didUpdateWidget(
    covariant LocationMap oldWidget,
  ) {
    super.didUpdateWidget(
      oldWidget,
    );

    final oldDriverLat =
        oldWidget.driverLat;

    final oldDriverLng =
        oldWidget.driverLng;

    final oldCustomerLat =
        oldWidget.customerLat;

    final oldCustomerLng =
        oldWidget.customerLng;

    final changed =
        oldDriverLat !=
                widget.driverLat ||
            oldDriverLng !=
                widget.driverLng ||
            oldCustomerLat !=
                widget.customerLat ||
            oldCustomerLng !=
                widget.customerLng;

    if (changed) {
      _scheduleRouteUpdate();
    }
  }

  void _scheduleRouteUpdate() {
    routeTimer?.cancel();

    routeTimer = Timer(
      const Duration(
        milliseconds: 500,
      ),
      () {
        updateRoute();
      },
    );
  }

  bool _movedEnough(
    LatLng? oldPoint,
    LatLng? newPoint,
  ) {
    if (oldPoint == null ||
        newPoint == null) {
      return true;
    }

    final distance =
        const Distance().as(
      LengthUnit.Meter,
      oldPoint,
      newPoint,
    );

    return distance >= 20;
  }

  Future<void> updateRoute() async {
    final customer =
        customerPoint;

    final driver =
        driverPoint;

    if (customer == null ||
        driver == null) {
      if (mounted) {
        setState(() {
          routePoints = [];
          routeDistance = null;
          routeDuration = null;
          routeLoading = false;
        });
      }

      return;
    }

    final bool enoughMovement =
        _movedEnough(
              lastRouteStart,
              driver,
            ) ||
            _movedEnough(
              lastRouteEnd,
              customer,
            );

    if (!enoughMovement &&
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
        (seconds / 60).ceil();

    if (minutes <= 1) {
      return 'أقل من دقيقة';
    }

    if (minutes < 60) {
      return '$minutes دقيقة';
    }

    final hours =
        minutes ~/ 60;

    final remaining =
        minutes % 60;

    if (remaining == 0) {
      return '$hours ساعة';
    }

    return '$hours س و $remaining د';
  }

  @override
  void dispose() {
    routeTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(
    BuildContext context,
  ) {
    final List<Marker>
        markers = [];

    if (widget.showCustomer &&
        customerPoint != null) {
      markers.add(
        Marker(
          point:
              customerPoint!,
          width: 55,
          height: 55,
          child:
              const Icon(
            Icons.person_pin_circle,
            size: 48,
            color: Colors.red,
          ),
        ),
      );
    }

    if (widget.showDriver &&
        driverPoint != null) {
      markers.add(
        Marker(
          point:
              driverPoint!,
          width: 55,
          height: 55,
          child:
              const Icon(
            Icons.directions_car,
            size: 43,
            color: Colors.blue,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius:
          BorderRadius.circular(
        15,
      ),
      child: Stack(
        children: [
          FlutterMap(
            mapController:
                mapController,
            options: MapOptions(
              initialCenter:
                  center,
              initialZoom: 15,
              minZoom: 5,
              maxZoom: 19,
            ),
            children: [
              TileLayer(
                urlTemplate:
                    'https://tile.openstreetmap.org/'
                    '{z}/{x}/{y}.png',
                userAgentPackageName:
                    'com.example.maw3idi',
              ),

              // المسار الحقيقي
              if (routePoints.length >=
                  2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points:
                          routePoints,
                      strokeWidth: 6,
                      color:
                          Colors.blue,
                      borderStrokeWidth:
                          2,
                      borderColor:
                          Colors.white,
                    ),
                  ],
                ),

              MarkerLayer(
                markers: markers,
              ),

              RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                  ),
                ],
              ),
            ],
          ),

          // معلومات المسافة والوقت
          if (routeDistance !=
                  null &&
              routeDuration !=
                  null)
            Positioned(
              top: 12,
              left: 12,
              right: 12,
              child: Material(
                elevation: 5,
                borderRadius:
                    BorderRadius.circular(
                  14,
                ),
                color:
                    Colors.white,
                child: Padding(
                  padding:
                      const EdgeInsets
                          .symmetric(
                    horizontal: 15,
                    vertical: 11,
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons
                            .route,
                        color:
                            Colors.blue,
                      ),
                      const SizedBox(
                        width: 8,
                      ),
                      Expanded(
                        child: Text(
                          'المسافة: ${formatDistance(routeDistance!)}',
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight
                                    .bold,
                          ),
                        ),
                      ),
                      const Icon(
                        Icons
                            .access_time,
                        color:
                            Colors.green,
                      ),
                      const SizedBox(
                        width: 6,
                      ),
                      Text(
                        formatDuration(
                          routeDuration!,
                        ),
                        style:
                            const TextStyle(
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // تحميل المسار
          if (routeLoading)
            Positioned(
              bottom: 12,
              left: 12,
              child: Material(
                elevation: 4,
                borderRadius:
                    BorderRadius.circular(
                  20,
                ),
                color:
                    Colors.white,
                child: const Padding(
                  padding:
                      EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 8,
                  ),
                  child: Row(
                    mainAxisSize:
                        MainAxisSize.min,
                    children: [
                      SizedBox(
                        width: 17,
                        height: 17,
                        child:
                            CircularProgressIndicator(
                          strokeWidth:
                              2,
                        ),
                      ),
                      SizedBox(
                        width: 8,
                      ),
                      Text(
                        'جاري تحديث المسار...',
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// CUSTOMER HISTORY
// ============================================================

class CustomerHistoryPage
    extends StatelessWidget {
  const CustomerHistoryPage({
    super.key,
  });

  @override
  Widget build(
    BuildContext context,
  ) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('طلباتي'),
      ),
      body:
          FutureBuilder<
              SharedPreferences>(
        future:
            SharedPreferences
                .getInstance(),
        builder: (
          context,
          prefsSnapshot,
        ) {
          if (!prefsSnapshot
              .hasData) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          final prefs =
              prefsSnapshot.data!;

          final customerId =
              prefs.getString(
                    'customer_id',
                  ) ??
                  '';

          if (customerId.isEmpty) {
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
            stream: db
                .collection(
                    'requests')
                .where(
                  'customerId',
                  isEqualTo:
                      customerId,
                )
                .snapshots(),
            builder: (
              context,
              snapshot,
            ) {
              if (snapshot
                      .connectionState ==
                  ConnectionState
                      .waiting) {
                return const Center(
                  child:
                      CircularProgressIndicator(),
                );
              }

              if (!snapshot
                      .hasData ||
                  snapshot.data!
                      .docs
                      .isEmpty) {
                return const Center(
                  child: Text(
                    'لا توجد طلبات بعد',
                  ),
                );
              }

              final docs = snapshot
                  .data!
                  .docs
                  .toList();

              docs.sort(
                (a, b) {
                  final aTime =
                      a.data()[
                          'createdAt'];

                  final bTime =
                      b.data()[
                          'createdAt'];

                  if (aTime
                          is Timestamp &&
                      bTime
                          is Timestamp) {
                    return bTime
                        .compareTo(
                            aTime);
                  }

                  return 0;
                },
              );

              return ListView
                  .builder(
                padding:
                    const EdgeInsets
                        .all(12),
                itemCount:
                    docs.length,
                itemBuilder:
                    (context,
                        index) {
                  final data =
                      docs[index]
                          .data();

                  final status =
                      data['status']
                              ?.toString() ??
                          'pending';

                  final service =
                      data['service']
                              ?.toString() ??
                          '';

                  return Card(
                    child:
                        ListTile(
                      leading:
                          Icon(
                        statusIcon(
                            status),
                      ),
                      title: Text(
                        serviceName(
                            service),
                      ),
                      subtitle:
                          Text(
                        statusName(
                            status),
                      ),
                      trailing:
                          const Icon(
                        Icons
                            .arrow_forward_ios,
                        size: 18,
                      ),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder:
                                (_) =>
                                    CustomerTrackingPage(
                              requestId:
                                  docs[index]
                                      .id,
                            ),
                          ),
                        );
                      },
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
