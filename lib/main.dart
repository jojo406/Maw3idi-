import 'dart:async';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:geolocator/geolocator.dart';
import 'package:url_launcher/url_launcher.dart';


// ============================================================
// FIREBASE MESSAGES
// ============================================================

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
    RemoteMessage message) async {
  await Firebase.initializeApp();
}


// ============================================================
// MAIN
// ============================================================

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


// ============================================================
// APP
// ============================================================

class AloWaselniApp extends StatelessWidget {
  const AloWaselniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ألو وصلني',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
        scaffoldBackgroundColor: const Color(0xfff5f7fb),
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          elevation: 0,
        ),
      ),
      home: const HomePage(),
    );
  }
}


// ============================================================
// HELPERS
// ============================================================

String serviceName(String service) {
  if (service == 'alo_waselni') return 'ألو وصلني';
  if (service == 'alo_jibli') return 'ألو جيبلي';
  return service;
}

String vehicleName(String vehicle) {
  if (vehicle == 'car') return 'سيارة';
  if (vehicle == 'motorcycle') return 'دراجة';
  return vehicle;
}

String statusName(String status) {
  switch (status) {
    case 'pending':
      return 'في انتظار سائق';
    case 'accepted':
      return 'تم قبول الطلب';
    case 'driver_arriving':
      return 'السائق في الطريق';
    case 'driver_arrived':
      return 'السائق وصل';
    case 'completed':
      return 'تم إكمال الطلب';
    case 'cancelled':
      return 'تم إلغاء الطلب';
    default:
      return status;
  }
}

IconData statusIcon(String status) {
  switch (status) {
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


// ============================================================
// PHONE CALL
// ============================================================

Future<void> callPhoneNumber(
  BuildContext context,
  String phone,
) async {
  final cleaned = phone.trim();

  if (cleaned.isEmpty) {
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('رقم الهاتف غير موجود'),
      ),
    );
    return;
  }

  final uri = Uri(
    scheme: 'tel',
    path: cleaned,
  );

  try {
    final ok = await launchUrl(uri);

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
          content: Text('تعذر فتح الاتصال'),
        ),
      );
    }
  }
}


// ============================================================
// LOCATION
// ============================================================

Future<Position?> getCurrentLocation(
  BuildContext context,
) async {
  try {
    bool serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'فعّل الموقع GPS في الهاتف أولاً',
            ),
          ),
        );
      }
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
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'لازم تسمح للتطبيق باستعمال الموقع',
            ),
          ),
        );
      }
      return null;
    }

    return await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
      ),
    );
  } catch (_) {
    if (context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('تعذر الحصول على الموقع'),
        ),
      );
    }

    return null;
  }
}


// ============================================================
// CUSTOMER PROFILE
// ============================================================

Future<String?> getCustomerPhone() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString('customer_phone');
}

Future<String?> ensureCustomerProfile(
  BuildContext context,
) async {
  final prefs = await SharedPreferences.getInstance();

  String? phone = prefs.getString('customer_phone');

  if (phone != null && phone.trim().isNotEmpty) {
    return phone;
  }

  final controller = TextEditingController();

  phone = await showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (dialogContext) {
      return AlertDialog(
        title: const Text('تسجيل الزبون'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.phone,
          decoration: const InputDecoration(
            labelText: 'رقم الهاتف',
            hintText: 'مثال: 0550000000',
            prefixIcon: Icon(Icons.phone),
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          FilledButton(
            onPressed: () {
              final value = controller.text.trim();

              if (value.length < 8) {
                ScaffoldMessenger.of(dialogContext).showSnackBar(
                  const SnackBar(
                    content: Text('أدخل رقم هاتف صحيح'),
                  ),
                );
                return;
              }

              Navigator.pop(dialogContext, value);
            },
            child: const Text('تسجيل'),
          ),
        ],
      );
    },
  );

  controller.dispose();

  if (phone == null || phone.trim().isEmpty) {
    return null;
  }

  final customerId =
      prefs.getString('customer_id') ??
      'customer_${DateTime.now().millisecondsSinceEpoch}';

  await prefs.setString('customer_id', customerId);
  await prefs.setString('customer_phone', phone);

  try {
    await FirebaseFirestore.instance
        .collection('customers')
        .doc(customerId)
        .set(
      {
        'phone': phone,
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  } catch (_) {}

  return phone;
}


// ============================================================
// DRIVER PROFILE
// ============================================================

String driverIdKey(String vehicleType) {
  return vehicleType == 'car'
      ? 'driver_id_car'
      : 'driver_id_motorcycle';
}

String driverPhoneKey(String vehicleType) {
  return vehicleType == 'car'
      ? 'driver_phone_car'
      : 'driver_phone_motorcycle';
}

Future<String?> ensureDriverProfile(
  BuildContext context,
  String vehicleType,
) async {
  final prefs = await SharedPreferences.getInstance();

  String? driverId =
      prefs.getString(driverIdKey(vehicleType));

  String? phone =
      prefs.getString(driverPhoneKey(vehicleType));

  if (driverId == null || driverId.isEmpty) {
    driverId =
        'driver_${vehicleType}_${DateTime.now().millisecondsSinceEpoch}';

    await prefs.setString(
      driverIdKey(vehicleType),
      driverId,
    );
  }

  if (phone == null || phone.trim().isEmpty) {
    final controller = TextEditingController();

    phone = await showDialog<String>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(
            vehicleType == 'car'
                ? 'تسجيل سائق السيارة'
                : 'تسجيل سائق الدراجة',
          ),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.phone,
            decoration: const InputDecoration(
              labelText: 'رقم الهاتف',
              hintText: 'مثال: 0550000000',
              prefixIcon: Icon(Icons.phone),
              border: OutlineInputBorder(),
            ),
          ),
          actions: [
            FilledButton(
              onPressed: () {
                final value = controller.text.trim();

                if (value.length < 8) {
                  ScaffoldMessenger.of(dialogContext).showSnackBar(
                    const SnackBar(
                      content: Text('أدخل رقم هاتف صحيح'),
                    ),
                  );
                  return;
                }

                Navigator.pop(dialogContext, value);
              },
              child: const Text('تسجيل'),
            ),
          ],
        );
      },
    );

    controller.dispose();

    if (phone == null || phone.trim().isEmpty) {
      return null;
    }

    await prefs.setString(
      driverPhoneKey(vehicleType),
      phone,
    );
  }

  try {
    await FirebaseFirestore.instance
        .collection('drivers')
        .doc(driverId)
        .set(
      {
        'phone': phone,
        'vehicleType': vehicleType,
        'updatedAt': FieldValue.serverTimestamp(),
        'createdAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  } catch (_) {}

  return phone;
}


// ============================================================
// MAP
// ============================================================

class LocationMap extends StatelessWidget {
  final double latitude;
  final double longitude;

  const LocationMap({
    super.key,
    required this.latitude,
    required this.longitude,
  });

  @override
  Widget build(BuildContext context) {
    final point = LatLng(latitude, longitude);

    return ClipRRect(
      borderRadius: BorderRadius.circular(18),
      child: SizedBox(
        height: 230,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: point,
            initialZoom: 15,
          ),
          children: [
            TileLayer(
              urlTemplate:
                  'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName:
                  'com.example.maw3idi',
            ),
            MarkerLayer(
              markers: [
                Marker(
                  point: point,
                  width: 55,
                  height: 55,
                  child: const Icon(
                    Icons.location_pin,
                    size: 50,
                    color: Colors.red,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}


// ============================================================
// HOME
// ============================================================

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  bool checking = true;

  @override
  void initState() {
    super.initState();
    checkSavedSession();
  }

  Future<void> checkSavedSession() async {
    final prefs = await SharedPreferences.getInstance();

    final role = prefs.getString('last_role');

    if (!mounted) return;

    if (role == 'customer') {
      final phone = prefs.getString('customer_phone');

      if (phone != null && phone.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const CustomerPage(),
            ),
          );
        });

        return;
      }
    }

    if (role == 'car') {
      final phone = prefs.getString('driver_phone_car');

      if (phone != null && phone.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const DriverPage(
                vehicleType: 'car',
              ),
            ),
          );
        });

        return;
      }
    }

    if (role == 'motorcycle') {
      final phone =
          prefs.getString('driver_phone_motorcycle');

      if (phone != null && phone.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted) return;

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => const DriverPage(
                vehicleType: 'motorcycle',
              ),
            ),
          );
        });

        return;
      }
    }

    setState(() {
      checking = false;
    });
  }

  Future<void> openCustomer() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('last_role', 'customer');

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const CustomerPage(),
      ),
    );
  }

  Future<void> openDriver(String vehicleType) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setString(
      'last_role',
      vehicleType == 'car'
          ? 'car'
          : 'motorcycle',
    );

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => DriverPage(
          vehicleType: vehicleType,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (checking) {
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
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 20),

              const Icon(
                Icons.local_shipping,
                size: 75,
                color: Colors.blue,
              ),

              const SizedBox(height: 10),

              const Text(
                'ألو وصلني',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const Text(
                'خدمات التوصيل داخل البلدية',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),

              const SizedBox(height: 35),

              _RoleButton(
                icon: Icons.person,
                title: 'أنا الزبون',
                subtitle:
                    'اطلب سيارة أو أرسل غرض',
                color: Colors.blue,
                onTap: openCustomer,
              ),

              const SizedBox(height: 15),

              _RoleButton(
                icon: Icons.directions_car,
                title: 'أنا سائق السيارة',
                subtitle:
                    'استقبل طلبات ألو وصلني',
                color: Colors.green,
                onTap: () => openDriver('car'),
              ),

              const SizedBox(height: 15),

              _RoleButton(
                icon: Icons.two_wheeler,
                title: 'أنا سائق الدراجة',
                subtitle:
                    'استقبل طلبات ألو جيبلي',
                color: Colors.orange,
                onTap: () => openDriver('motorcycle'),
              ),
            ],
          ),
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
    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
                  backgroundColor:
                      color.withOpacity(.12),
                  child: Icon(
                    icon,
                    color: color,
                    size: 30,
                  ),
                ),
                const SizedBox(width: 16),
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
                      const SizedBox(height: 4),
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
      ),
    );
  }
}


// ============================================================
// CUSTOMER PAGE
// ============================================================

class CustomerPage extends StatefulWidget {
  const CustomerPage({super.key});

  @override
  State<CustomerPage> createState() =>
      _CustomerPageState();
}

class _CustomerPageState extends State<CustomerPage> {
  String? phone;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadCustomer();
  }

  Future<void> loadCustomer() async {
    final result =
        await ensureCustomerProfile(context);

    if (!mounted) return;

    setState(() {
      phone = result;
      loading = false;
    });

    if (result == null) {
      final prefs =
          await SharedPreferences.getInstance();

      await prefs.remove('last_role');

      if (mounted) {
        Navigator.pop(context);
      }
    }
  }

  Future<void> logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('تسجيل الخروج'),
          content: const Text(
            'هل تريد تسجيل الخروج وتغيير الحساب؟',
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
              child: const Text('خروج'),
            ),
          ],
        );
      },
    );

    if (confirm != true) return;

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove('customer_phone');
    await prefs.remove('customer_id');
    await prefs.remove('last_role');

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const HomePage(),
      ),
      (route) => false,
    );
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
          'أنا الزبون',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'تسجيل الخروج',
            onPressed: logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  child: Icon(Icons.person),
                ),
                title: const Text(
                  'رقمك المسجل',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                subtitle: Text(
                  phone ?? '',
                ),
              ),
            ),

            const SizedBox(height: 20),

            _CustomerServiceButton(
              icon: Icons.directions_car,
              title: 'ألو وصلني',
              subtitle:
                  'اطلب سيارة داخل البلدية',
              color: Colors.blue,
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

            const SizedBox(height: 15),

            _CustomerServiceButton(
              icon: Icons.two_wheeler,
              title: 'ألو جيبلي',
              subtitle:
                  'ابعث غرض مع سائق الدراجة',
              color: Colors.orange,
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

            const SizedBox(height: 15),

            _CustomerServiceButton(
              icon: Icons.history,
              title: 'طلباتي',
              subtitle:
                  'شوف الطلبات السابقة',
              color: Colors.purple,
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
    );
  }
}


class _CustomerServiceButton
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _CustomerServiceButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      child: Card(
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 28,
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
      ),
    );
  }
}


// ============================================================
// ALO WASELNI
// ============================================================

class WaselniPage extends StatefulWidget {
  const WaselniPage({super.key});

  @override
  State<WaselniPage> createState() =>
      _WaselniPageState();
}

class _WaselniPageState
    extends State<WaselniPage> {
  String phone = '';
  bool loading = true;
  bool sending = false;

  @override
  void initState() {
    super.initState();
    loadPhone();
  }

  Future<void> loadPhone() async {
    final value = await getCustomerPhone();

    if (!mounted) return;

    setState(() {
      phone = value ?? '';
      loading = false;
    });
  }

  Future<void> createRequest() async {
    if (phone.isEmpty) {
      final value =
          await ensureCustomerProfile(context);

      if (value == null) return;

      phone = value;
    }

    setState(() {
      sending = true;
    });

    final position =
        await getCurrentLocation(context);

    if (position == null) {
      if (mounted) {
        setState(() {
          sending = false;
        });
      }
      return;
    }

    try {
      final ref = await FirebaseFirestore.instance
          .collection('requests')
          .add(
        {
          'service': 'alo_waselni',
          'vehicleType': 'car',
          'phone': phone,
          'customerLat': position.latitude,
          'customerLng': position.longitude,
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );

      final prefs =
          await SharedPreferences.getInstance();

      await prefs.setString(
        'last_request_id',
        ref.id,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              CustomerTrackingPage(
            requestId: ref.id,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تعذر إنشاء الطلب: $e',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          sending = false;
        });
      }
    }
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
        title: const Text('ألو وصلني'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.directions_car,
              size: 90,
              color: Colors.blue,
            ),

            const SizedBox(height: 15),

            const Text(
              'اطلب سيارة',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Card(
              child: ListTile(
                leading:
                    const Icon(Icons.phone),
                title: const Text(
                  'رقم الهاتف',
                ),
                subtitle: Text(phone),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: FilledButton.icon(
                onPressed:
                    sending ? null : createRequest,
                icon: sending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.search,
                      ),
                label: Text(
                  sending
                      ? 'جاري إرسال الطلب...'
                      : 'اطلب سيارة الآن',
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
// ALO JIBLI
// ============================================================

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

  String phone = '';
  bool loading = true;
  bool sending = false;

  @override
  void initState() {
    super.initState();
    loadPhone();
  }

  Future<void> loadPhone() async {
    final value = await getCustomerPhone();

    if (!mounted) return;

    setState(() {
      phone = value ?? '';
      loading = false;
    });
  }

  Future<void> createRequest() async {
    final item = itemController.text.trim();

    if (item.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('اكتب واش حاب تبعث'),
        ),
      );
      return;
    }

    if (phone.isEmpty) {
      final value =
          await ensureCustomerProfile(context);

      if (value == null) return;

      phone = value;
    }

    setState(() {
      sending = true;
    });

    final position =
        await getCurrentLocation(context);

    if (position == null) {
      if (mounted) {
        setState(() {
          sending = false;
        });
      }
      return;
    }

    try {
      final ref = await FirebaseFirestore.instance
          .collection('requests')
          .add(
        {
          'service': 'alo_jibli',
          'vehicleType': 'motorcycle',
          'item': item,
          'phone': phone,
          'customerLat': position.latitude,
          'customerLng': position.longitude,
          'status': 'pending',
          'createdAt': FieldValue.serverTimestamp(),
          'updatedAt': FieldValue.serverTimestamp(),
        },
      );

      final prefs =
          await SharedPreferences.getInstance();

      await prefs.setString(
        'last_request_id',
        ref.id,
      );

      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              CustomerTrackingPage(
            requestId: ref.id,
          ),
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'تعذر إنشاء الطلب: $e',
            ),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          sending = false;
        });
      }
    }
  }

  @override
  void dispose() {
    itemController.dispose();
    super.dispose();
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
        title: const Text('ألو جيبلي'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const Icon(
              Icons.two_wheeler,
              size: 90,
              color: Colors.orange,
            ),

            const SizedBox(height: 15),

            const Text(
              'أرسل غرضك',
              style: TextStyle(
                fontSize: 25,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            TextField(
              controller: itemController,
              decoration: const InputDecoration(
                labelText: 'واش حاب تبعث؟',
                hintText:
                    'مثال: وثيقة، دواء، غرض...',
                prefixIcon:
                    Icon(Icons.inventory_2),
                border: OutlineInputBorder(),
              ),
            ),

            const SizedBox(height: 15),

            Card(
              child: ListTile(
                leading:
                    const Icon(Icons.phone),
                title:
                    const Text('رقم الهاتف'),
                subtitle:
                    Text(phone),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: FilledButton.icon(
                onPressed:
                    sending ? null : createRequest,
                icon: sending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child:
                            CircularProgressIndicator(
                          strokeWidth: 2,
                        ),
                      )
                    : const Icon(
                        Icons.send,
                      ),
                label: Text(
                  sending
                      ? 'جاري إرسال الطلب...'
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
  State<CustomerTrackingPage> createState() =>
      _CustomerTrackingPageState();
}

class _CustomerTrackingPageState
    extends State<CustomerTrackingPage> {
  Timer? locationTimer;

  @override
  void initState() {
    super.initState();
    startLocationTracking();
  }

  void startLocationTracking() {
    locationTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) async {
        try {
          final position =
              await Geolocator.getCurrentPosition();

          await FirebaseFirestore.instance
              .collection('requests')
              .doc(widget.requestId)
              .update(
            {
              'customerLat':
                  position.latitude,
              'customerLng':
                  position.longitude,
              'updatedAt':
                  FieldValue.serverTimestamp(),
            },
          );
        } catch (_) {}
      },
    );
  }

  @override
  void dispose() {
    locationTimer?.cancel();
    super.dispose();
  }

  Future<void> cancelRequest() async {
    try {
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(widget.requestId)
          .update(
        {
          'status': 'cancelled',
          'updatedAt':
              FieldValue.serverTimestamp(),
        },
      );
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'تتبع الطلب',
        ),
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .doc(widget.requestId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          if (!snapshot.hasData ||
              !snapshot.data!.exists) {
            return const Center(
              child:
                  Text('الطلب غير موجود'),
            );
          }

          final data =
              snapshot.data!.data()
                  as Map<String, dynamic>;

          final status =
              data['status']?.toString() ??
                  'pending';

          final lat =
              (data['customerLat'] as num?)
                  ?.toDouble();

          final lng =
              (data['customerLng'] as num?)
                  ?.toDouble();

          final driverPhone =
              data['driverPhone']
                      ?.toString() ??
                  '';

          final driverVehicle =
              data['driverVehicleType']
                      ?.toString() ??
                  '';

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Card(
                child: ListTile(
                  leading: Icon(
                    statusIcon(status),
                    color: Colors.blue,
                    size: 32,
                  ),
                  title: Text(
                    statusName(status),
                    style: const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    serviceName(
                      data['service']
                              ?.toString() ??
                          '',
                    ),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              if (lat != null && lng != null)
                LocationMap(
                  latitude: lat,
                  longitude: lng,
                ),

              const SizedBox(height: 15),

              if (data['item'] != null)
                Card(
                  child: ListTile(
                    leading: const Icon(
                      Icons.inventory_2,
                    ),
                    title:
                        const Text('الغرض'),
                    subtitle: Text(
                      data['item']
                          .toString(),
                    ),
                  ),
                ),

              if (driverPhone.isNotEmpty &&
                  status != 'pending' &&
                  status != 'cancelled')
                Card(
                  child: ListTile(
                    leading: const CircleAvatar(
                      child: Icon(
                        Icons.person,
                      ),
                    ),
                    title: const Text(
                      'السائق',
                      style: TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '$driverPhone\n${vehicleName(driverVehicle)}',
                    ),
                    isThreeLine: true,
                    trailing: IconButton(
                      tooltip: 'اتصل بالسائق',
                      icon: const Icon(
                        Icons.phone,
                        color: Colors.green,
                        size: 30,
                      ),
                      onPressed: () {
                        callPhoneNumber(
                          context,
                          driverPhone,
                        );
                      },
                    ),
                  ),
                ),

              const SizedBox(height: 15),

              if (status == 'pending')
                SizedBox(
                  height: 50,
                  child: OutlinedButton.icon(
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

              if (status == 'completed')
                const Card(
                  child: Padding(
                    padding:
                        EdgeInsets.all(18),
                    child: Row(
                      children: [
                        Icon(
                          Icons.check_circle,
                          color: Colors.green,
                          size: 30,
                        ),
                        SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'تم إكمال الطلب بنجاح',
                            style: TextStyle(
                              fontWeight:
                                  FontWeight.bold,
                              fontSize: 17,
                            ),
                          ),
                        ),
                      ],
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


// ============================================================
// DRIVER PAGE
// ============================================================

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
  String? driverId;
  String? phone;

  bool loading = true;
  bool online = false;

  StreamSubscription<RemoteMessage>?
      messageSubscription;

  Timer? locationTimer;

  @override
  void initState() {
    super.initState();
    initializeDriver();
  }

  Future<void> initializeDriver() async {
    final prefs =
        await SharedPreferences.getInstance();

    driverId =
        prefs.getString(
      driverIdKey(widget.vehicleType),
    );

    phone =
        await ensureDriverProfile(
      context,
      widget.vehicleType,
    );

    if (phone == null) {
      if (mounted) {
        Navigator.pop(context);
      }
      return;
    }

    if (driverId == null) {
      driverId =
          prefs.getString(
        driverIdKey(widget.vehicleType),
      );
    }

    try {
      await FirebaseMessaging.instance
          .requestPermission();

      final token =
          await FirebaseMessaging.instance
              .getToken();

      await FirebaseFirestore.instance
          .collection('drivers')
          .doc(driverId)
          .set(
        {
          'phone': phone,
          'vehicleType':
              widget.vehicleType,
          'fcmToken': token,
          'online': false,
          'updatedAt':
              FieldValue.serverTimestamp(),
        },
        SetOptions(merge: true),
      );

      messageSubscription =
          FirebaseMessaging.onMessage
              .listen((message) {
        if (!mounted) return;

        final title =
            message.notification?.title ??
                'ألو وصلني';

        ScaffoldMessenger.of(context)
            .showSnackBar(
          SnackBar(
            content: Text(title),
          ),
        );
      });

      FirebaseMessaging.instance
          .onTokenRefresh
          .listen((newToken) async {
        try {
          await FirebaseFirestore.instance
              .collection('drivers')
              .doc(driverId)
              .update(
            {
              'fcmToken': newToken,
            },
          );
        } catch (_) {}
      });
    } catch (_) {}

    if (!mounted) return;

    setState(() {
      loading = false;
    });
  }

  Future<void> setOnline(bool value) async {
    if (driverId == null ||
        phone == null) {
      return;
    }

    if (value) {
      final position =
          await getCurrentLocation(context);

      if (position == null) {
        return;
      }

      String? token;

      try {
        token =
            await FirebaseMessaging.instance
                .getToken();
      } catch (_) {}

      try {
        await FirebaseFirestore.instance
            .collection('drivers')
            .doc(driverId)
            .set(
          {
            'phone': phone,
            'vehicleType':
                widget.vehicleType,
            'online': true,
            'lat': position.latitude,
            'lng': position.longitude,
            'fcmToken': token,
            'updatedAt':
                FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );

        if (!mounted) return;

        setState(() {
          online = true;
        });

        startDriverLocation();
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context)
              .showSnackBar(
            SnackBar(
              content: Text(
                'تعذر الاتصال: $e',
              ),
            ),
          );
        }
      }
    } else {
      locationTimer?.cancel();

      try {
        await FirebaseFirestore.instance
            .collection('drivers')
            .doc(driverId)
            .set(
          {
            'online': false,
            'updatedAt':
                FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      } catch (_) {}

      if (!mounted) return;

      setState(() {
        online = false;
      });
    }
  }

  void startDriverLocation() {
    locationTimer?.cancel();

    locationTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) async {
        if (!online ||
            driverId == null) {
          return;
        }

        try {
          final position =
              await Geolocator.getCurrentPosition();

          await FirebaseFirestore.instance
              .collection('drivers')
              .doc(driverId)
              .update(
            {
              'lat': position.latitude,
              'lng': position.longitude,
              'updatedAt':
                  FieldValue.serverTimestamp(),
            },
          );
        } catch (_) {}
      },
    );
  }

  Future<void> acceptRequest(
    String requestId,
  ) async {
    if (driverId == null ||
        phone == null) {
      return;
    }

    try {
      final position =
          await Geolocator.getCurrentPosition();

      await FirebaseFirestore.instance
          .collection('requests')
          .doc(requestId)
          .update(
        {
          'status': 'accepted',
          'driverId': driverId,
          'driverPhone': phone,
          'driverVehicleType':
              widget.vehicleType,
          'driverLat':
              position.latitude,
          'driverLng':
              position.longitude,
          'acceptedAt':
              FieldValue.serverTimestamp(),
          'updatedAt':
              FieldValue.serverTimestamp(),
        },
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

  Future<void> updateRequestStatus(
    String requestId,
    String nextStatus,
  ) async {
    try {
      final data = {
        'status': nextStatus,
        'updatedAt':
            FieldValue.serverTimestamp(),
      };

      if (nextStatus == 'driver_arriving' ||
          nextStatus == 'driver_arrived') {
        try {
          final position =
              await Geolocator.getCurrentPosition();

          data['driverLat'] =
              position.latitude;
          data['driverLng'] =
              position.longitude;
        } catch (_) {}
      }

      await FirebaseFirestore.instance
          .collection('requests')
          .doc(requestId)
          .update(data);
    } catch (_) {}
  }

  Future<void> cancelDriverRequest(
    String requestId,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(requestId)
          .update(
        {
          'status': 'cancelled',
          'updatedAt':
              FieldValue.serverTimestamp(),
        },
      );
    } catch (_) {}
  }

  Future<void> logout() async {
    await setOnline(false);

    if (driverId != null) {
      try {
        await FirebaseFirestore.instance
            .collection('drivers')
            .doc(driverId)
            .set(
          {
            'online': false,
            'updatedAt':
                FieldValue.serverTimestamp(),
          },
          SetOptions(merge: true),
        );
      } catch (_) {}
    }

    final prefs =
        await SharedPreferences.getInstance();

    await prefs.remove(
      driverPhoneKey(widget.vehicleType),
    );

    await prefs.remove(
      driverIdKey(widget.vehicleType),
    );

    await prefs.remove('last_role');

    if (!mounted) return;

    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => const HomePage(),
      ),
      (route) => false,
    );
  }

  @override
  void dispose() {
    locationTimer?.cancel();
    messageSubscription?.cancel();
    super.dispose();
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
            tooltip: 'تسجيل الخروج',
            onPressed: logout,
            icon: const Icon(Icons.logout),
          ),
        ],
      ),
      body: Column(
        children: [
          Card(
            margin: const EdgeInsets.all(12),
            child: Padding(
              padding:
                  const EdgeInsets.all(15),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 27,
                    child: Icon(
                      widget.vehicleType ==
                              'car'
                          ? Icons.directions_car
                          : Icons.two_wheeler,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          phone ?? '',
                          style:
                              const TextStyle(
                            fontWeight:
                                FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        const SizedBox(
                          height: 4,
                        ),
                        Text(
                          online
                              ? 'متصل ويستقبل الطلبات'
                              : 'غير متصل',
                          style: TextStyle(
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
                    onChanged: setOnline,
                  ),
                ],
              ),
            ),
          ),

          Expanded(
            child: StreamBuilder<
                QuerySnapshot>(
              stream: FirebaseFirestore
                  .instance
                  .collection('requests')
                  .where(
                    'service',
                    isEqualTo: service,
                  )
                  .where(
                    'status',
                    whereIn: [
                      'pending',
                      'accepted',
                      'driver_arriving',
                      'driver_arrived',
                    ],
                  )
                  .snapshots(),
              builder:
                  (context, snapshot) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding:
                          const EdgeInsets.all(
                              20),
                      child: Text(
                        'تعذر تحميل الطلبات\n${snapshot.error}',
                        textAlign:
                            TextAlign.center,
                      ),
                    ),
                  );
                }

                final docs =
                    snapshot.data?.docs ??
                        [];

                final filtered = docs
                    .where((doc) {
                  final data =
                      doc.data()
                          as Map<String,
                              dynamic>;

                  final status =
                      data['status']
                              ?.toString() ??
                          '';

                  if (status ==
                      'pending') {
                    return online;
                  }

                  return data['driverId'] ==
                      driverId;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment
                              .center,
                      children: [
                        Icon(
                          online
                              ? Icons.inbox
                              : Icons
                                  .power_settings_new,
                          size: 65,
                          color: Colors.grey,
                        ),
                        const SizedBox(
                          height: 12,
                        ),
                        Text(
                          online
                              ? 'لا توجد طلبات حالياً'
                              : 'فعّل الحالة متصل لاستقبال الطلبات',
                          textAlign:
                              TextAlign.center,
                          style:
                              const TextStyle(
                            fontSize: 17,
                            color:
                                Colors.grey,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  padding:
                      const EdgeInsets.all(12),
                  itemCount:
                      filtered.length,
                  itemBuilder:
                      (context, index) {
                    final doc =
                        filtered[index];

                    final data =
                        doc.data()
                            as Map<String,
                                dynamic>;

                    return DriverRequestCard(
                      requestId: doc.id,
                      data: data,
                      driverId:
                          driverId ?? '',
                      onAccept: () =>
                          acceptRequest(
                        doc.id,
                      ),
                      onStatus:
                          (nextStatus) =>
                              updateRequestStatus(
                        doc.id,
                        nextStatus,
                      ),
                      onCancel: () =>
                          cancelDriverRequest(
                        doc.id,
                      ),
                      onCall: (phone) =>
                          callPhoneNumber(
                        context,
                        phone,
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


// ============================================================
// DRIVER REQUEST CARD
// ============================================================

class DriverRequestCard
    extends StatelessWidget {
  final String requestId;
  final Map<String, dynamic> data;
  final String driverId;
  final VoidCallback onAccept;
  final Function(String) onStatus;
  final VoidCallback onCancel;
  final Function(String) onCall;

  const DriverRequestCard({
    super.key,
    required this.requestId,
    required this.data,
    required this.driverId,
    required this.onAccept,
    required this.onStatus,
    required this.onCancel,
    required this.onCall,
  });

  @override
  Widget build(BuildContext context) {
    final status =
        data['status']?.toString() ??
            'pending';

    final phone =
        data['phone']?.toString() ?? '';

    final lat =
        (data['customerLat'] as num?)
            ?.toDouble();

    final lng =
        (data['customerLng'] as num?)
            ?.toDouble();

    final item =
        data['item']?.toString() ?? '';

    final isMine =
        data['driverId'] == driverId;

    return Card(
      margin:
          const EdgeInsets.only(bottom: 15),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  child: Icon(
                    data['vehicleType'] ==
                            'car'
                        ? Icons
                            .directions_car
                        : Icons.two_wheeler,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    serviceName(
                      data['service']
                              ?.toString() ??
                          '',
                    ),
                    style:
                        const TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
                Chip(
                  label: Text(
                    statusName(status),
                  ),
                ),
              ],
            ),

            if (item.isNotEmpty) ...[
              const SizedBox(height: 12),
              ListTile(
                contentPadding:
                    EdgeInsets.zero,
                leading:
                    const Icon(Icons.inventory),
                title:
                    const Text('الغرض'),
                subtitle:
                    Text(item),
              ),
            ],

            const SizedBox(height: 8),

            ListTile(
              contentPadding:
                  EdgeInsets.zero,
              leading:
                  const Icon(Icons.phone),
              title:
                  const Text('رقم الزبون'),
              subtitle:
                  Text(phone),
              trailing: IconButton(
                tooltip: 'اتصل بالزبون',
                icon: const Icon(
                  Icons.phone,
                  color: Colors.green,
                ),
                onPressed: phone.isEmpty
                    ? null
                    : () => onCall(phone),
              ),
            ),

            if (lat != null && lng != null) ...[
              const SizedBox(height: 5),
              LocationMap(
                latitude: lat,
                longitude: lng,
              ),
            ],

            const SizedBox(height: 12),

            if (status == 'pending')
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  onPressed: onAccept,
                  icon: const Icon(
                    Icons.check,
                  ),
                  label: const Text(
                    'قبول الطلب',
                  ),
                ),
              ),

            if (isMine &&
                status == 'accepted')
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  onPressed: () =>
                      onStatus(
                    'driver_arriving',
                  ),
                  icon: const Icon(
                    Icons.directions_car,
                  ),
                  label: const Text(
                    'أنا في الطريق',
                  ),
                ),
              ),

            if (isMine &&
                status ==
                    'driver_arriving')
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  onPressed: () =>
                      onStatus(
                    'driver_arrived',
                  ),
                  icon: const Icon(
                    Icons.location_on,
                  ),
                  label: const Text(
                    'وصلت للزبون',
                  ),
                ),
              ),

            if (isMine &&
                status ==
                    'driver_arrived')
              SizedBox(
                width: double.infinity,
                height: 50,
                child: FilledButton.icon(
                  onPressed: () =>
                      onStatus(
                    'completed',
                  ),
                  icon: const Icon(
                    Icons.done_all,
                  ),
                  label: const Text(
                    'إكمال الطلب',
                  ),
                ),
              ),

            if (isMine &&
                status != 'completed' &&
                status != 'cancelled')
              TextButton.icon(
                onPressed: onCancel,
                icon: const Icon(
                  Icons.cancel,
                ),
                label: const Text(
                  'إلغاء الطلب',
                ),
              ),
          ],
        ),
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

  Future<List<String>> getRequestIds() async {
    final prefs =
        await SharedPreferences.getInstance();

    return prefs.getStringList(
          'customer_request_history',
        ) ??
        [];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'طلباتي',
        ),
      ),
      body: FutureBuilder<List<String>>(
        future: getRequestIds(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child:
                  CircularProgressIndicator(),
            );
          }

          final ids = snapshot.data!;

          if (ids.isEmpty) {
            return const Center(
              child: Text(
                'ما عندك حتى طلب سابق',
              ),
            );
          }

          return ListView.builder(
            padding:
                const EdgeInsets.all(12),
            itemCount: ids.length,
            itemBuilder:
                (context, index) {
              final id = ids[index];

              return Card(
                child: ListTile(
                  leading: const Icon(
                    Icons.receipt_long,
                  ),
                  title: Text(
                    'الطلب ${index + 1}',
                  ),
                  subtitle:
                      Text(id),
                  trailing: const Icon(
                    Icons.arrow_forward_ios,
                    size: 16,
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            CustomerTrackingPage(
                          requestId: id,
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
