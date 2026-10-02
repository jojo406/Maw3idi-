import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';


// ============================================================
// FIREBASE MESSAGING
// ============================================================

@pragma('vm:entry-point')
Future<void> firebaseMessagingBackgroundHandler(
  RemoteMessage message,
) async {
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
      provisional: false,
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
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
        scaffoldBackgroundColor: const Color(0xfff5f7fb),
      ),
      home: const HomePage(),
    );
  }
}


// ============================================================
// GPS
// ============================================================

Future<Position?> getCurrentLocation() async {
  try {
    bool serviceEnabled =
        await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {
      await Geolocator.openLocationSettings();

      await Future.delayed(
        const Duration(seconds: 2),
      );

      serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        return null;
      }
    }

    LocationPermission permission =
        await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission =
          await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied) {
      return null;
    }

    if (permission == LocationPermission.deniedForever) {
      await Geolocator.openAppSettings();
      return null;
    }

    final position =
        await Geolocator.getCurrentPosition(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 5,
      ),
    );

    return position;
  } catch (_) {
    return null;
  }
}


// ============================================================
// HELPERS
// ============================================================

String serviceName(String service) {
  if (service == 'alo_jibli') {
    return 'ألو جيبلي';
  }

  return 'ألو وصلني';
}

String vehicleName(String vehicle) {
  if (vehicle == 'motorcycle') {
    return 'دراجة نارية';
  }

  return 'سيارة';
}

String statusName(String status) {
  switch (status) {
    case 'pending':
      return 'جاري البحث عن السائق';

    case 'accepted':
      return 'تم قبول طلبك';

    case 'driver_arriving':
      return 'السائق في الطريق إليك';

    case 'driver_arrived':
      return 'السائق وصل';

    case 'completed':
      return 'تم إنهاء الطلب';

    case 'cancelled':
      return 'تم إلغاء الطلب';

    default:
      return 'حالة غير معروفة';
  }
}

IconData statusIcon(String status) {
  switch (status) {
    case 'pending':
      return Icons.search;

    case 'accepted':
      return Icons.check_circle_outline;

    case 'driver_arriving':
      return Icons.directions_car;

    case 'driver_arrived':
      return Icons.location_on;

    case 'completed':
      return Icons.done_all;

    case 'cancelled':
      return Icons.cancel_outlined;

    default:
      return Icons.info_outline;
  }
}


// ============================================================
// HOME
// ============================================================

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 25),

              const Icon(
                Icons.local_shipping_rounded,
                size: 70,
                color: Colors.blue,
              ),

              const SizedBox(height: 12),

              const Text(
                'ألو وصلني',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 6),

              const Text(
                'خدمة التوصيل داخل البلدية',
                style: TextStyle(
                  fontSize: 17,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 40),

              _HomeButton(
                icon: Icons.person,
                title: 'زبون',
                subtitle: 'أطلب سيارة أو أرسل لي حاجة',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CustomerPage(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 15),

              _HomeButton(
                icon: Icons.directions_car,
                title: 'سائق سيارة',
                subtitle: 'استقبل طلبات ألو وصلني',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DriverPage(
                        vehicleType: 'car',
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 15),

              _HomeButton(
                icon: Icons.two_wheeler,
                title: 'سائق دراجة',
                subtitle: 'استقبل طلبات ألو جيبلي',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DriverPage(
                        vehicleType: 'motorcycle',
                      ),
                    ),
                  );
                },
              ),

              const Spacer(),

              const Text(
                'ألو وصلني • بسيط • سريع • داخل البلدية',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 10),
            ],
          ),
        ),
      ),
    );
  }
}


class _HomeButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _HomeButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 82,
      child: Card(
        elevation: 2,
        child: InkWell(
          borderRadius: BorderRadius.circular(15),
          onTap: onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 18,
            ),
            child: Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundColor:
                      Colors.blue.withOpacity(.1),
                  child: Icon(
                    icon,
                    color: Colors.blue,
                  ),
                ),

                const SizedBox(width: 15),

                Expanded(
                  child: Column(
                    mainAxisAlignment:
                        MainAxisAlignment.center,
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 3),

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
// CUSTOMER
// ============================================================

class CustomerPage extends StatelessWidget {
  const CustomerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ألو وصلني'),
        centerTitle: true,
        actions: [
          IconButton(
            tooltip: 'طلباتي',
            icon: const Icon(Icons.history),
            onPressed: () {
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
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const SizedBox(height: 10),

          const Text(
            'وش تحتاج اليوم؟',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'اختار الخدمة المناسبة ليك',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
              fontSize: 16,
            ),
          ),

          const SizedBox(height: 30),

          _ServiceCard(
            icon: Icons.directions_car_rounded,
            title: 'ألو وصلني',
            subtitle:
                'اطلب سائق سيارة يجي لموقعك',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const WaselniPage(),
                ),
              );
            },
          ),

          const SizedBox(height: 18),

          _ServiceCard(
            icon: Icons.two_wheeler_rounded,
            title: 'ألو جيبلي',
            subtitle:
                'اطلب من سائق الدراجة يجيبلك حاجة',
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const JibliPage(),
                ),
              );
            },
          ),

          const SizedBox(height: 18),

          Card(
            child: ListTile(
              leading: const CircleAvatar(
                child: Icon(Icons.history),
              ),
              title: const Text(
                'طلباتي السابقة',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              subtitle: const Text(
                'شوف الطلبات اللي درتها من قبل',
              ),
              trailing:
                  const Icon(Icons.arrow_forward_ios),
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


class _ServiceCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ServiceCard({
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
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 65,
                height: 65,
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(.1),
                  borderRadius:
                      BorderRadius.circular(18),
                ),
                child: Icon(
                  icon,
                  size: 34,
                  color: Colors.blue,
                ),
              ),

              const SizedBox(width: 18),

              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 6),

                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: Colors.grey,
                        fontSize: 14,
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


// ============================================================
// MAP WIDGET
// ============================================================

class LocationMap extends StatelessWidget {
  final LatLng? customerLocation;
  final LatLng? driverLocation;
  final double height;

  const LocationMap({
    super.key,
    required this.customerLocation,
    this.driverLocation,
    this.height = 240,
  });

  @override
  Widget build(BuildContext context) {
    final center =
        customerLocation ??
        driverLocation ??
        const LatLng(
          35.6971,
          -0.6308,
        );

    final markers = <Marker>[];

    if (customerLocation != null) {
      markers.add(
        Marker(
          point: customerLocation!,
          width: 55,
          height: 55,
          child: const Icon(
            Icons.location_on,
            color: Colors.blue,
            size: 48,
          ),
        ),
      );
    }

    if (driverLocation != null) {
      markers.add(
        Marker(
          point: driverLocation!,
          width: 55,
          height: 55,
          child: const Icon(
            Icons.local_shipping,
            color: Colors.red,
            size: 43,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: SizedBox(
        height: height,
        child: FlutterMap(
          options: MapOptions(
            initialCenter: center,
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
              markers: markers,
            ),
          ],
        ),
      ),
    );
  }
}


// ============================================================
// WASSELNI - CAR
// ============================================================

class WaselniPage extends StatefulWidget {
  const WaselniPage({super.key});

  @override
  State<WaselniPage> createState() =>
      _WaselniPageState();
}

class _WaselniPageState extends State<WaselniPage> {
  final phoneController =
      TextEditingController();

  Position? position;
  Timer? locationTimer;

  bool loading = false;
  String? requestId;

  @override
  void initState() {
    super.initState();
    loadLocation();
  }

  @override
  void dispose() {
    locationTimer?.cancel();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> loadLocation() async {
    final p = await getCurrentLocation();

    if (!mounted) return;

    setState(() {
      position = p;
    });
  }

  void startLocationUpdates() {
    locationTimer?.cancel();

    locationTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) async {
        if (requestId == null) return;

        final p = await getCurrentLocation();

        if (p == null) return;

        try {
          await FirebaseFirestore.instance
              .collection('requests')
              .doc(requestId)
              .update({
            'customerLocationLat': p.latitude,
            'customerLocationLng': p.longitude,
            'customerLocationUpdatedAt':
                FieldValue.serverTimestamp(),
          });

          if (mounted) {
            setState(() {
              position = p;
            });
          }
        } catch (_) {}
      },
    );
  }

  Future<void> createRequest() async {
    if (phoneController.text.trim().isEmpty) {
      showMessage('دخل رقم الهاتف');
      return;
    }

    if (position == null) {
      await loadLocation();
    }

    if (position == null) {
      showMessage(
        'ما قدرناش نحددو موقعك. فعل GPS وعاود.',
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final doc = await FirebaseFirestore
          .instance
          .collection('requests')
          .add({
        'service': 'alo_waselni',
        'vehicleType': 'car',
        'phone':
            phoneController.text.trim(),
        'customerLocationLat':
            position!.latitude,
        'customerLocationLng':
            position!.longitude,
        'status': 'pending',
        'createdAt':
            FieldValue.serverTimestamp(),
        'customerLocationUpdatedAt':
            FieldValue.serverTimestamp(),
      });

      await saveCustomerRequestId(doc.id);

      requestId = doc.id;

      startLocationUpdates();

      if (!mounted) return;

      setState(() {
        loading = false;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              CustomerTrackingPage(
            requestId: doc.id,
          ),
        ),
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      showMessage(
        'حدث خطأ في إرسال الطلب',
      );
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ألو وصلني'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Icon(
            Icons.directions_car,
            size: 65,
            color: Colors.blue,
          ),

          const SizedBox(height: 12),

          const Text(
            'اطلب سيارة',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'موقعك يتحدد تلقائياً بواسطة GPS',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 20),

          LocationMap(
            customerLocation:
                position == null
                    ? null
                    : LatLng(
                        position!.latitude,
                        position!.longitude,
                      ),
          ),

          const SizedBox(height: 20),

          TextField(
            controller: phoneController,
            keyboardType:
                TextInputType.phone,
            decoration:
                const InputDecoration(
              labelText: 'رقم الهاتف',
              hintText: '05xxxxxxxx',
              prefixIcon:
                  Icon(Icons.phone),
              border:
                  OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 55,
            child: FilledButton.icon(
              onPressed:
                  loading
                      ? null
                      : createRequest,
              icon: loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(
                      Icons.send,
                    ),
              label: Text(
                loading
                    ? 'جاري الإرسال...'
                    : 'اطلب سيارة',
              ),
            ),
          ),
        ],
      ),
    );
  }
}


// ============================================================
// JIBLI - MOTORCYCLE
// ============================================================

class JibliPage extends StatefulWidget {
  const JibliPage({super.key});

  @override
  State<JibliPage> createState() =>
      _JibliPageState();
}

class _JibliPageState extends State<JibliPage> {
  final itemController =
      TextEditingController();

  final phoneController =
      TextEditingController();

  Position? position;

  bool loading = false;

  @override
  void initState() {
    super.initState();
    loadLocation();
  }

  @override
  void dispose() {
    itemController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> loadLocation() async {
    final p = await getCurrentLocation();

    if (!mounted) return;

    setState(() {
      position = p;
    });
  }

  Future<void> createRequest() async {
    if (itemController.text.trim().isEmpty) {
      showMessage(
        'اكتب واش حاب يجيبلك السائق',
      );
      return;
    }

    if (phoneController.text.trim().isEmpty) {
      showMessage('دخل رقم الهاتف');
      return;
    }

    if (position == null) {
      await loadLocation();
    }

    if (position == null) {
      showMessage(
        'ما قدرناش نحددو موقعك. فعل GPS وعاود.',
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final doc = await FirebaseFirestore
          .instance
          .collection('requests')
          .add({
        'service': 'alo_jibli',
        'vehicleType': 'motorcycle',
        'item':
            itemController.text.trim(),
        'phone':
            phoneController.text.trim(),
        'customerLocationLat':
            position!.latitude,
        'customerLocationLng':
            position!.longitude,
        'status': 'pending',
        'createdAt':
            FieldValue.serverTimestamp(),
        'customerLocationUpdatedAt':
            FieldValue.serverTimestamp(),
      });

      await saveCustomerRequestId(doc.id);

      if (!mounted) return;

      setState(() {
        loading = false;
      });

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) =>
              CustomerTrackingPage(
            requestId: doc.id,
          ),
        ),
      );
    } catch (_) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      showMessage(
        'حدث خطأ في إرسال الطلب',
      );
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ألو جيبلي'),
        centerTitle: true,
      ),
      body: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Icon(
            Icons.two_wheeler,
            size: 65,
            color: Colors.blue,
          ),

          const SizedBox(height: 12),

          const Text(
            'ألو جيبلي',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 27,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 8),

          const Text(
            'السائق يجي يجيبلك الحاجة لموقعك',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),

          const SizedBox(height: 20),

          LocationMap(
            customerLocation:
                position == null
                    ? null
                    : LatLng(
                        position!.latitude,
                        position!.longitude,
                      ),
          ),

          const SizedBox(height: 20),

          TextField(
            controller: itemController,
            maxLines: 3,
            decoration:
                const InputDecoration(
              labelText:
                  'واش حاب يجيبلك؟',
              hintText:
                  'مثال: دواء، خبز، غرض...',
              prefixIcon:
                  Icon(Icons.shopping_bag),
              border:
                  OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 15),

          TextField(
            controller: phoneController,
            keyboardType:
                TextInputType.phone,
            decoration:
                const InputDecoration(
              labelText: 'رقم الهاتف',
              hintText: '05xxxxxxxx',
              prefixIcon:
                  Icon(Icons.phone),
              border:
                  OutlineInputBorder(),
            ),
          ),

          const SizedBox(height: 20),

          SizedBox(
            height: 55,
            child: FilledButton.icon(
              onPressed:
                  loading
                      ? null
                      : createRequest,
              icon: loading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child:
                          CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
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
    );
  }
}


// ============================================================
// CUSTOMER TRACKING
// ============================================================

class CustomerTrackingPage
    extends StatelessWidget {
  final String requestId;

  const CustomerTrackingPage({
    super.key,
    required this.requestId,
  });

  Future<void> cancelRequest(
    BuildContext context,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(requestId)
          .update({
        'status': 'cancelled',
        'cancelledAt':
            FieldValue.serverTimestamp(),
      });

      if (context.mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'تم إلغاء الطلب',
            ),
          ),
        );
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'تتبع الطلب',
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<
          DocumentSnapshot<Map<String, dynamic>>>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .doc(requestId)
            .snapshots(),
        builder: (
          context,
          snapshot,
        ) {
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
              child: Text(
                'الطلب غير موجود',
              ),
            );
          }

          final data =
              snapshot.data!.data()!;

          final status =
              data['status'] ?? 'pending';

          final customerLat =
              (data['customerLocationLat']
                      as num?)
                  ?.toDouble();

          final customerLng =
              (data['customerLocationLng']
                      as num?)
                  ?.toDouble();

          final driverLat =
              (data['driverLocationLat']
                      as num?)
                  ?.toDouble();

          final driverLng =
              (data['driverLocationLng']
                      as num?)
                  ?.toDouble();

          LatLng? customerLocation;

          if (customerLat != null &&
              customerLng != null) {
            customerLocation =
                LatLng(
              customerLat,
              customerLng,
            );
          }

          LatLng? driverLocation;

          if (driverLat != null &&
              driverLng != null) {
            driverLocation =
                LatLng(
              driverLat,
              driverLng,
            );
          }

          return ListView(
            padding:
                const EdgeInsets.all(18),
            children: [
              Card(
                child: Padding(
                  padding:
                      const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        statusIcon(status),
                        size: 55,
                        color:
                            status ==
                                    'cancelled'
                                ? Colors.red
                                : Colors.blue,
                      ),

                      const SizedBox(height: 10),

                      Text(
                        statusName(status),
                        textAlign:
                            TextAlign.center,
                        style:
                            const TextStyle(
                          fontSize: 21,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),

                      const SizedBox(height: 7),

                      Text(
                        serviceName(
                          data['service']
                                  ?.toString() ??
                              'alo_waselni',
                        ),
                        style:
                            const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 15),

              LocationMap(
                customerLocation:
                    customerLocation,
                driverLocation:
                    driverLocation,
                height: 300,
              ),

              const SizedBox(height: 15),

              if (data['item'] != null)
                Card(
                  child: ListTile(
                    leading:
                        const Icon(
                      Icons.shopping_bag,
                    ),
                    title:
                        const Text(
                      'الطلب',
                    ),
                    subtitle:
                        Text(
                      data['item']
                          .toString(),
                    ),
                  ),
                ),

              if (data['phone'] != null)
                Card(
                  child: ListTile(
                    leading:
                        const Icon(
                      Icons.phone,
                    ),
                    title:
                        const Text(
                      'رقم الهاتف',
                    ),
                    subtitle:
                        Text(
                      data['phone']
                          .toString(),
                    ),
                  ),
                ),

              const SizedBox(height: 10),

              if (status == 'pending')
                SizedBox(
                  height: 52,
                  child:
                      OutlinedButton.icon(
                    onPressed: () =>
                        cancelRequest(
                      context,
                    ),
                    icon: const Icon(
                      Icons.cancel,
                    ),
                    label:
                        const Text(
                      'إلغاء الطلب',
                    ),
                  ),
                ),

              if (status == 'completed')
                Card(
                  child: ListTile(
                    leading:
                        const Icon(
                      Icons.star,
                      color:
                          Colors.amber,
                    ),
                    title:
                        const Text(
                      'شكراً لاستعمال ألو وصلني',
                      style:
                          TextStyle(
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    subtitle:
                        const Text(
                      'تم إنهاء الطلب بنجاح',
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
// CUSTOMER HISTORY
// ============================================================

Future<void> saveCustomerRequestId(
  String id,
) async {
  final prefs =
      await SharedPreferences
          .getInstance();

  final list =
      prefs.getStringList(
            'customer_request_ids',
          ) ??
          [];

  if (!list.contains(id)) {
    list.insert(0, id);
  }

  if (list.length > 50) {
    list.removeRange(
      50,
      list.length,
    );
  }

  await prefs.setStringList(
    'customer_request_ids',
    list,
  );
}


Future<List<String>>
    getCustomerRequestIds() async {
  final prefs =
      await SharedPreferences
          .getInstance();

  return prefs.getStringList(
        'customer_request_ids',
      ) ??
      [];
}


class CustomerHistoryPage
    extends StatefulWidget {
  const CustomerHistoryPage({
    super.key,
  });

  @override
  State<CustomerHistoryPage> createState() =>
      _CustomerHistoryPageState();
}

class _CustomerHistoryPageState
    extends State<CustomerHistoryPage> {
  List<String> ids = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    loadHistory();
  }

  Future<void> loadHistory() async {
    final result =
        await getCustomerRequestIds();

    if (!mounted) return;

    setState(() {
      ids = result;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('طلباتي السابقة'),
        centerTitle: true,
      ),
      body: loading
          ? const Center(
              child:
                  CircularProgressIndicator(),
            )
          : ids.isEmpty
              ? const Center(
                  child: Padding(
                    padding:
                        EdgeInsets.all(25),
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.history,
                          size: 70,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 12),
                        Text(
                          'مازال ما عندك حتى طلب',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets.all(12),
                  itemCount: ids.length,
                  itemBuilder:
                      (context, index) {
                    final id = ids[index];

                    return StreamBuilder<
                        DocumentSnapshot<
                            Map<String,
                                dynamic>>>(
                      stream:
                          FirebaseFirestore
                              .instance
                              .collection(
                                  'requests')
                              .doc(id)
                              .snapshots(),
                      builder:
                          (context, snapshot) {
                        if (!snapshot
                            .hasData) {
                          return const Card(
                            child: ListTile(
                              title:
                                  Text(
                                'جاري التحميل...',
                              ),
                            ),
                          );
                        }

                        final data =
                            snapshot.data!
                                    .data() ??
                                {};

                        final service =
                            data['service']
                                    ?.toString() ??
                                '';

                        final status =
                            data['status']
                                    ?.toString() ??
                                'pending';

                        return Card(
                          margin:
                              const EdgeInsets
                                  .only(
                            bottom: 10,
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
                              style:
                                  const TextStyle(
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                            subtitle:
                                Text(
                              statusName(
                                status,
                              ),
                            ),
                            trailing:
                                const Icon(
                              Icons
                                  .arrow_forward_ios,
                              size: 17,
                            ),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (_) =>
                                      CustomerTrackingPage(
                                    requestId:
                                        id,
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


// ============================================================
// DRIVER
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
  final FirebaseFirestore firestore =
      FirebaseFirestore.instance;

  String driverId = '';

  bool online = false;
  bool loading = true;

  Position? position;

  Timer? locationTimer;

  String? fcmToken;

  StreamSubscription<
      RemoteMessage>? messageSubscription;

  @override
  void initState() {
    super.initState();

    initializeDriver();
  }

  @override
  void dispose() {
    locationTimer?.cancel();
    messageSubscription?.cancel();
    super.dispose();
  }

  Future<void> initializeDriver() async {
    final prefs =
        await SharedPreferences
            .getInstance();

    String? savedId =
        prefs.getString(
      'driver_id',
    );

    if (savedId == null ||
        savedId.isEmpty) {
      savedId =
          'driver_${DateTime.now().millisecondsSinceEpoch}';

      await prefs.setString(
        'driver_id',
        savedId,
      );
    }

    driverId = savedId;

    await setupFirebaseMessaging();

    await loadLocation();

    if (!mounted) return;

    setState(() {
      loading = false;
    });
  }

  Future<void> setupFirebaseMessaging() async {
    try {
      final messaging =
          FirebaseMessaging.instance;

      await messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );

      final token =
          await messaging.getToken();

      if (token != null) {
        fcmToken = token;

        await firestore
            .collection('drivers')
            .doc(driverId)
            .set(
          {
            'fcmToken': token,
            'vehicleType':
                widget.vehicleType,
            'online': online,
            'updatedAt':
                FieldValue.serverTimestamp(),
          },
          SetOptions(
            merge: true,
          ),
        );
      }

      messageSubscription =
          FirebaseMessaging.onMessage.listen(
        (message) {
          if (!mounted) return;

          final title =
              message.notification?.title ??
                  'طلب جديد';

          final body =
              message.notification?.body ??
                  'عندك طلب جديد';

          ScaffoldMessenger.of(context)
              .showSnackBar(
            SnackBar(
              duration:
                  const Duration(
                seconds: 5,
              ),
              content: Text(
                '$title\n$body',
              ),
            ),
          );
        },
      );

      FirebaseMessaging
          .instance.onTokenRefresh
          .listen(
        (newToken) async {
          fcmToken = newToken;

          try {
            await firestore
                .collection('drivers')
                .doc(driverId)
                .set(
              {
                'fcmToken': newToken,
                'vehicleType':
                    widget.vehicleType,
                'updatedAt':
                    FieldValue
                        .serverTimestamp(),
              },
              SetOptions(
                merge: true,
              ),
            );
          } catch (_) {}
        },
      );
    } catch (_) {}
  }

  Future<void> loadLocation() async {
    final p =
        await getCurrentLocation();

    if (!mounted) return;

    setState(() {
      position = p;
    });

    if (online && p != null) {
      await updateDriverLocation(p);
    }
  }

  Future<void> updateDriverLocation(
    Position p,
  ) async {
    try {
      await firestore
          .collection('drivers')
          .doc(driverId)
          .set(
        {
          'vehicleType':
              widget.vehicleType,
          'online': online,
          'lat': p.latitude,
          'lng': p.longitude,
          'updatedAt':
              FieldValue.serverTimestamp(),
        },
        SetOptions(
          merge: true,
        ),
      );
    } catch (_) {}
  }

  void startLocationTimer() {
    locationTimer?.cancel();

    locationTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) async {
        if (!online) return;

        final p =
            await getCurrentLocation();

        if (p == null) return;

        if (mounted) {
          setState(() {
            position = p;
          });
        }

        await updateDriverLocation(p);

        await updateAcceptedRequestsLocation(
          p,
        );
      },
    );
  }

  Future<void>
      updateAcceptedRequestsLocation(
    Position p,
  ) async {
    try {
      final snapshot =
          await firestore
              .collection('requests')
              .where(
                'driverId',
                isEqualTo: driverId,
              )
              .get();

      for (final doc in snapshot.docs) {
        final data = doc.data();

        final status =
            data['status']
                ?.toString();

        if (status == 'accepted' ||
            status ==
                'driver_arriving' ||
            status ==
                'driver_arrived') {
          await doc.reference.update({
            'driverLocationLat':
                p.latitude,
            'driverLocationLng':
                p.longitude,
            'driverLocationUpdatedAt':
                FieldValue.serverTimestamp(),
          });
        }
      }
    } catch (_) {}
  }

  Future<void> setOnline(
    bool value,
  ) async {
    if (value) {
      final p =
          await getCurrentLocation();

      if (p == null) {
        if (!mounted) return;

        ScaffoldMessenger.of(context)
            .showSnackBar(
          const SnackBar(
            content: Text(
              'لازم تفعل GPS باش تدخل متصل',
            ),
          ),
        );

        return;
      }

      position = p;
    }

    setState(() {
      online = value;
    });

    try {
      await firestore
          .collection('drivers')
          .doc(driverId)
          .set(
        {
          'vehicleType':
              widget.vehicleType,
          'online': online,
          'lat': position?.latitude,
          'lng': position?.longitude,
          'fcmToken': fcmToken,
          'updatedAt':
              FieldValue.serverTimestamp(),
        },
        SetOptions(
          merge: true,
        ),
      );
    } catch (_) {}

    if (online) {
      startLocationTimer();
    } else {
      locationTimer?.cancel();
    }
  }

  Future<void> acceptRequest(
    DocumentSnapshot<Map<String, dynamic>>
        doc,
  ) async {
    if (!online) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'دخل متصل أولاً',
          ),
        ),
      );

      return;
    }

    try {
      final p =
          position ??
              await getCurrentLocation();

      await doc.reference.update({
        'status': 'accepted',
        'driverId': driverId,
        'driverVehicleType':
            widget.vehicleType,
        'acceptedAt':
            FieldValue.serverTimestamp(),
        'driverLocationLat':
            p?.latitude,
        'driverLocationLng':
            p?.longitude,
        'driverLocationUpdatedAt':
            FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'تم قبول الطلب',
          ),
        ),
      );
    } catch (_) {}
  }

  Future<void> nextStatus(
    DocumentSnapshot<Map<String, dynamic>>
        doc,
    String currentStatus,
  ) async {
    String? next;

    if (currentStatus == 'accepted') {
      next = 'driver_arriving';
    } else if (currentStatus ==
        'driver_arriving') {
      next = 'driver_arrived';
    } else if (currentStatus ==
        'driver_arrived') {
      next = 'completed';
    }

    if (next == null) return;

    try {
      await doc.reference.update({
        'status': next,
        '${next}At':
            FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        SnackBar(
          content: Text(
            statusName(next!),
          ),
        ),
      );
    } catch (_) {}
  }

  Future<void> cancelDriverRequest(
    DocumentSnapshot<Map<String, dynamic>>
        doc,
  ) async {
    try {
      await doc.reference.update({
        'status': 'cancelled',
        'cancelledAt':
            FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  String nextButtonText(
    String status,
  ) {
    switch (status) {
      case 'accepted':
        return 'أنا في الطريق';

      case 'driver_arriving':
        return 'وصلت للزبون';

      case 'driver_arrived':
        return 'إنهاء الطلب';

      default:
        return 'متابعة';
    }
  }

  Future<void> callCustomer(
    String phone,
  ) async {
    try {
      const channel =
          MethodChannel(
        'allo_waselni/phone',
      );

      await channel.invokeMethod(
        'call',
        {
          'phone': phone,
        },
      );
    } catch (_) {
      await Clipboard.setData(
        ClipboardData(
          text: phone,
        ),
      );

      if (!mounted) return;

      ScaffoldMessenger.of(context)
          .showSnackBar(
        const SnackBar(
          content: Text(
            'تم نسخ رقم الهاتف',
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final title =
        widget.vehicleType ==
                'motorcycle'
            ? 'سائق دراجة'
            : 'سائق سيارة';

    if (loading) {
      return Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: const Center(
          child:
              CircularProgressIndicator(),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            margin:
                const EdgeInsets.all(12),
            padding:
                const EdgeInsets.all(15),
            decoration: BoxDecoration(
              color: online
                  ? Colors.green
                      .withOpacity(.1)
                  : Colors.grey
                      .withOpacity(.1),
              borderRadius:
                  BorderRadius.circular(15),
              border: Border.all(
                color: online
                    ? Colors.green
                    : Colors.grey,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  online
                      ? Icons.circle
                      : Icons.circle_outlined,
                  color: online
                      ? Colors.green
                      : Colors.grey,
                ),

                const SizedBox(width: 10),

                Expanded(
                  child: Text(
                    online
                        ? 'أنت متصل وتستقبل الطلبات'
                        : 'أنت غير متصل',
                    style:
                        const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
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

          if (position != null)
            Padding(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 12,
              ),
              child: LocationMap(
                customerLocation:
                    LatLng(
                  position!.latitude,
                  position!.longitude,
                ),
                height: 190,
              ),
            ),

          const SizedBox(height: 8),

          Expanded(
            child: StreamBuilder<
                QuerySnapshot<
                    Map<String,
                        dynamic>>>(
              stream: firestore
                  .collection('requests')
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
              builder: (
                context,
                snapshot,
              ) {
                if (snapshot.connectionState ==
                    ConnectionState.waiting) {
                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {
                  return const Center(
                    child: Padding(
                      padding:
                          EdgeInsets.all(20),
                      child: Text(
                        'ما قدرناش نحمّلو الطلبات.\n'
                        'تأكد من إعدادات Firebase.',
                        textAlign:
                            TextAlign.center,
                      ),
                    ),
                  );
                }

                final docs =
                    snapshot.data?.docs ??
                        [];

                final filtered =
                    docs.where((doc) {
                  final data =
                      doc.data();

                  final service =
                      data['service'];

                  final status =
                      data['status'];

                  if (widget.vehicleType ==
                      'car') {
                    if (service !=
                        'alo_waselni') {
                      return false;
                    }
                  }

                  if (widget.vehicleType ==
                      'motorcycle') {
                    if (service !=
                        'alo_jibli') {
                      return false;
                    }
                  }

                  if (data['driverId'] ==
                      driverId) {
                    return true;
                  }

                  if (status !=
                      'pending') {
                    return false;
                  }

                  return true;
                }).toList();

                if (filtered.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize:
                          MainAxisSize.min,
                      children: [
                        Icon(
                          online
                              ? Icons
                                  .hourglass_empty
                              : Icons
                                  .power_settings_new,
                          size: 65,
                          color: Colors.grey,
                        ),
                        const SizedBox(
                            height: 12),
                        Text(
                          online
                              ? 'ما كاش طلبات حالياً'
                              : 'دخل متصل باش تشوف الطلبات',
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

                filtered.sort(
                  (a, b) {
                    final aData =
                        a.data();
                    final bData =
                        b.data();

                    final aTime =
                        aData['createdAt']
                            as Timestamp?;

                    final bTime =
                        bData['createdAt']
                            as Timestamp?;

                    if (aTime == null ||
                        bTime == null) {
                      return 0;
                    }

                    return bTime
                        .compareTo(aTime);
                  },
                );

                return ListView.builder(
                  padding:
                      const EdgeInsets
                          .fromLTRB(
                    12,
                    5,
                    12,
                    20,
                  ),
                  itemCount:
                      filtered.length,
                  itemBuilder:
                      (context, index) {
                    return DriverRequestCard(
                      doc: filtered[index],
                      driverId: driverId,
                      online: online,
                      onAccept:
                          acceptRequest,
                      onNextStatus:
                          nextStatus,
                      onCancel:
                          cancelDriverRequest,
                      onCall:
                          callCustomer,
                      nextButtonText:
                          nextButtonText,
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
  final DocumentSnapshot<
      Map<String, dynamic>> doc;

  final String driverId;
  final bool online;

  final Future<void> Function(
    DocumentSnapshot<
        Map<String, dynamic>>,
  ) onAccept;

  final Future<void> Function(
    DocumentSnapshot<
        Map<String, dynamic>>,
    String,
  ) onNextStatus;

  final Future<void> Function(
    DocumentSnapshot<
        Map<String, dynamic>>,
  ) onCancel;

  final Future<void> Function(
    String,
  ) onCall;

  final String Function(
    String,
  ) nextButtonText;

  const DriverRequestCard({
    super.key,
    required this.doc,
    required this.driverId,
    required this.online,
    required this.onAccept,
    required this.onNextStatus,
    required this.onCancel,
    required this.onCall,
    required this.nextButtonText,
  });

  @override
  Widget build(BuildContext context) {
    final data = doc.data();

    final service =
        data['service']
                ?.toString() ??
            '';

    final status =
        data['status']
                ?.toString() ??
            'pending';

    final phone =
        data['phone']
                ?.toString() ??
            '';

    final item =
        data['item']
                ?.toString();

    final customerLat =
        (data['customerLocationLat']
                as num?)
            ?.toDouble();

    final customerLng =
        (data['customerLocationLng']
                as num?)
            ?.toDouble();

    final driverLat =
        (data['driverLocationLat']
                as num?)
            ?.toDouble();

    final driverLng =
        (data['driverLocationLng']
                as num?)
            ?.toDouble();

    LatLng? customerLocation;

    if (customerLat != null &&
        customerLng != null) {
      customerLocation =
          LatLng(
        customerLat,
        customerLng,
      );
    }

    LatLng? driverLocation;

    if (driverLat != null &&
        driverLng != null) {
      driverLocation =
          LatLng(
        driverLat,
        driverLng,
      );
    }

    final isMine =
        data['driverId'] ==
            driverId;

    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 14,
      ),
      elevation: 3,
      child: Padding(
        padding:
            const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 25,
                  child: Icon(
                    service ==
                            'alo_jibli'
                        ? Icons
                            .two_wheeler
                        : Icons
                            .directions_car,
                  ),
                ),

                const SizedBox(width: 12),

                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment
                            .start,
                    children: [
                      Text(
                        serviceName(
                          service,
                        ),
                        style:
                            const TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight
                                  .bold,
                        ),
                      ),

                      const SizedBox(
                          height: 3),

                      Text(
                        isMine
                            ? statusName(
                                status,
                              )
                            : 'طلب جديد',
                        style:
                            const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),

                if (status !=
                    'pending')
                  Icon(
                    statusIcon(
                      status,
                    ),
                    color:
                        Colors.blue,
                  ),
              ],
            ),

            if (item != null) ...[
              const SizedBox(height: 12),

              Container(
                width:
                    double.infinity,
                padding:
                    const EdgeInsets.all(
                  12,
                ),
                decoration:
                    BoxDecoration(
                  color: Colors.grey
                      .withOpacity(.08),
                  borderRadius:
                      BorderRadius
                          .circular(10),
                ),
                child: Text(
                  'الحاجة: $item',
                  style:
                      const TextStyle(
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ],

            const SizedBox(height: 12),

            LocationMap(
              customerLocation:
                  customerLocation,
              driverLocation:
                  isMine
                      ? driverLocation
                      : null,
              height: 210,
            ),

            const SizedBox(height: 10),

            if (phone.isNotEmpty)
              ListTile(
                contentPadding:
                    EdgeInsets.zero,
                leading:
                    const CircleAvatar(
                  child:
                      Icon(Icons.phone),
                ),
                title:
                    const Text(
                  'رقم الزبون',
                ),
                subtitle:
                    Text(phone),
                trailing:
                    IconButton(
                  icon:
                      const Icon(
                    Icons.call,
                    color: Colors.green,
                  ),
                  onPressed: () =>
                      onCall(phone),
                ),
              ),

            const SizedBox(height: 5),

            if (status == 'pending')
              SizedBox(
                width:
                    double.infinity,
                height: 50,
                child:
                    FilledButton.icon(
                  onPressed:
                      online
                          ? () =>
                              onAccept(
                                doc,
                              )
                          : null,
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

            if (isMine &&
                status != 'completed' &&
                status != 'cancelled' &&
                status != 'pending') ...[
              SizedBox(
                width:
                    double.infinity,
                height: 50,
                child:
                    FilledButton.icon(
                  onPressed: () =>
                      onNextStatus(
                    doc,
                    status,
                  ),
                  icon:
                      const Icon(
                    Icons.arrow_forward,
                  ),
                  label:
                      Text(
                    nextButtonText(
                      status,
                    ),
                  ),
                ),
              ),

              if (status !=
                      'driver_arrived' &&
                  status !=
                      'completed')
                const SizedBox(
                    height: 8),

              if (status !=
                      'completed' &&
                  status !=
                      'driver_arrived')
                SizedBox(
                  width:
                      double.infinity,
                  height: 45,
                  child:
                      OutlinedButton(
                    onPressed: () =>
                        onCancel(
                      doc,
                    ),
                    child:
                        const Text(
                      'إلغاء الطلب',
                    ),
                  ),
                ),
            ],
          ],
        ),
      ),
    );
  }
}
