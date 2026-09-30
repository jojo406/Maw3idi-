import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(const AloWaselniApp());
}

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
          seedColor: const Color(0xFF1565C0),
        ),
      ),
      home: const HomePage(),
    );
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
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              const SizedBox(height: 25),
              const Icon(
                Icons.local_shipping_rounded,
                size: 72,
                color: Color(0xFF1565C0),
              ),
              const SizedBox(height: 10),
              const Text(
                'ألو وصلني',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1565C0),
                ),
              ),
              const Text(
                'خدمة التوصيل داخل البلدية',
                style: TextStyle(
                  color: Colors.grey,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 42),

              RoleButton(
                icon: Icons.person_rounded,
                title: 'أنا زبون',
                subtitle: 'اطلب خدمة التوصيل',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CustomerPage(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 16),

              RoleButton(
                icon: Icons.directions_car_rounded,
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

              const SizedBox(height: 16),

              RoleButton(
                icon: Icons.two_wheeler_rounded,
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
            ],
          ),
        ),
      ),
    );
  }
}

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
    return Material(
      color: Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(19),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFFE3F2FD),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Icon(
                  icon,
                  size: 30,
                  color: const Color(0xFF1565C0),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: Colors.grey,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// CUSTOMER HOME
// ============================================================

class CustomerPage extends StatelessWidget {
  const CustomerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ألو وصلني',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            ServiceButton(
              icon: Icons.local_shipping_rounded,
              title: 'ألو وصلني',
              subtitle: 'اطلب سيارة',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WaselniPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            ServiceButton(
              icon: Icons.shopping_bag_rounded,
              title: 'ألو جيبلي',
              subtitle: 'خلي سائق الدراجة يجيبلك طلبك',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const JibliPage(),
                  ),
                );
              },
            ),
            const SizedBox(height: 16),
            ServiceButton(
              icon: Icons.history,
              title: 'طلباتي السابقة',
              subtitle: 'شوف الطلبات والتقييمات',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const HistoryPage(),
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

class ServiceButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const ServiceButton({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 2,
      borderRadius: BorderRadius.circular(22),
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              CircleAvatar(
                radius: 29,
                backgroundColor: const Color(0xFFE3F2FD),
                child: Icon(
                  icon,
                  size: 30,
                  color: const Color(0xFF1565C0),
                ),
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
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
                      style: const TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
              const Icon(Icons.arrow_forward_ios_rounded),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// LOCATION
// ============================================================

Future<LatLng?> getCurrentLocation() async {
  try {
    if (!await Geolocator.isLocationServiceEnabled()) {
      return null;
    }

    var permission = await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.denied ||
        permission == LocationPermission.deniedForever) {
      return null;
    }

    final position = await Geolocator.getCurrentPosition();

    return LatLng(
      position.latitude,
      position.longitude,
    );
  } catch (_) {
    return null;
  }
}

// ============================================================
// AUTOMATIC CUSTOMER MAP
// ============================================================

class LocationMap extends StatefulWidget {
  final LatLng? location;
  final LatLng? driverLocation;
  final bool showDriver;

  const LocationMap({
    super.key,
    this.location,
    this.driverLocation,
    this.showDriver = false,
  });

  @override
  State<LocationMap> createState() => _LocationMapState();
}

class _LocationMapState extends State<LocationMap> {
  final MapController mapController = MapController();

  LatLng? currentLocation;
  Timer? timer;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadLocation();

    timer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _loadLocation(),
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  Future<void> _loadLocation() async {
    final location = await getCurrentLocation();

    if (!mounted || location == null) return;

    setState(() {
      currentLocation = location;
      loading = false;
    });

    try {
      mapController.move(location, 16);
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    final center =
        currentLocation ??
        widget.location ??
        const LatLng(35.6971, -0.6308);

    final markers = <Marker>[];

    if (currentLocation != null) {
      markers.add(
        Marker(
          point: currentLocation!,
          width: 70,
          height: 70,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 3,
                ),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Text(
                  'موقعك',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 11,
                  ),
                ),
              ),
              const Icon(
                Icons.location_on,
                color: Colors.blue,
                size: 40,
              ),
            ],
          ),
        ),
      );
    }

    if (widget.showDriver &&
        widget.driverLocation != null) {
      markers.add(
        Marker(
          point: widget.driverLocation!,
          width: 65,
          height: 65,
          child: const Icon(
            Icons.local_taxi,
            color: Colors.orange,
            size: 42,
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(22),
      child: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
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
              MarkerLayer(markers: markers),
            ],
          ),

          Positioned(
            right: 10,
            bottom: 10,
            child: Column(
              children: [
                MapControlButton(
                  icon: Icons.add,
                  onTap: () {
                    mapController.move(
                      mapController.camera.center,
                      mapController.camera.zoom + 1,
                    );
                  },
                ),
                const SizedBox(height: 7),
                MapControlButton(
                  icon: Icons.remove,
                  onTap: () {
                    mapController.move(
                      mapController.camera.center,
                      mapController.camera.zoom - 1,
                    );
                  },
                ),
                const SizedBox(height: 7),
                MapControlButton(
                  icon: Icons.my_location,
                  onTap: () {
                    if (currentLocation != null) {
                      mapController.move(
                        currentLocation!,
                        16,
                      );
                    }
                  },
                ),
              ],
            ),
          ),

          if (loading)
            const Positioned.fill(
              child: Center(
                child: CircularProgressIndicator(),
              ),
            ),
        ],
      ),
    );
  }
}

// ============================================================
// ألو وصلني - CAR ONLY
// ============================================================

class WaselniPage extends StatefulWidget {
  const WaselniPage({super.key});

  @override
  State<WaselniPage> createState() => _WaselniPageState();
}

class _WaselniPageState extends State<WaselniPage> {
  String? requestId;
  LatLng? customerLocation;

  Timer? locationTimer;

  final phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  @override
  void dispose() {
    locationTimer?.cancel();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadLocation() async {
    final location = await getCurrentLocation();

    if (!mounted) return;

    setState(() {
      customerLocation = location;
    });
  }

  Future<void> _sendRequest() async {
    if (customerLocation == null) {
      _message(
        'ما قدرناش نحدد موقعك. فعّل GPS وحاول من جديد.',
      );
      return;
    }

    if (phoneController.text.trim().isEmpty) {
      _message('أدخل رقم الهاتف');
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('requests')
          .add({
        'service': 'alo_waselni',
        'vehicleType': 'car',

        'customerLocationLat':
            customerLocation!.latitude,
        'customerLocationLng':
            customerLocation!.longitude,

        'phone': phoneController.text.trim(),

        'status': 'pending',

        'customerLocationUpdatedAt':
            FieldValue.serverTimestamp(),

        'createdAt':
            FieldValue.serverTimestamp(),
      });

      requestId = doc.id;

      await saveRequestId(doc.id);

      _startLocationTracking();

      if (mounted) {
        setState(() {});
      }
    } catch (_) {
      _message('حدث خطأ أثناء إرسال الطلب');
    }
  }

  void _startLocationTracking() {
    locationTimer?.cancel();

    locationTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _updateCustomerLocation(),
    );

    _updateCustomerLocation();
  }

  Future<void> _updateCustomerLocation() async {
    if (requestId == null) return;

    final location = await getCurrentLocation();

    if (location == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(requestId)
          .update({
        'customerLocationLat': location.latitude,
        'customerLocationLng': location.longitude,
        'customerLocationUpdatedAt':
            FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  Future<void> _cancelRequest() async {
    if (requestId == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(requestId)
          .update({
        'status': 'cancelled',
      });
    } catch (_) {}

    locationTimer?.cancel();

    if (mounted) {
      setState(() {
        requestId = null;
      });
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ألو وصلني',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: requestId != null
          ? CustomerTrackingPage(
              requestId: requestId!,
              onCancel: _cancelRequest,
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  SizedBox(
                    height: 350,
                    child: LocationMap(
                      location: customerLocation,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.my_location,
                          color: Color(0xFF1565C0),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'موقعك يتحدد أوتوماتيكياً',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 14),

                  ModernTextField(
                    controller: phoneController,
                    hint: 'رقم الهاتف',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 18),

                  MainButton(
                    icon: Icons.local_taxi,
                    text: 'اطلب السيارة الآن',
                    onPressed: _sendRequest,
                  ),
                ],
              ),
            ),
    );
  }
}

// ============================================================
// ألو جيبلي - MOTORCYCLE ONLY
// ============================================================

class JibliPage extends StatefulWidget {
  const JibliPage({super.key});

  @override
  State<JibliPage> createState() => _JibliPageState();
}

class _JibliPageState extends State<JibliPage> {
  String? requestId;
  LatLng? customerLocation;

  Timer? locationTimer;

  final itemController = TextEditingController();
  final phoneController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadLocation();
  }

  @override
  void dispose() {
    locationTimer?.cancel();
    itemController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadLocation() async {
    final location = await getCurrentLocation();

    if (!mounted) return;

    setState(() {
      customerLocation = location;
    });
  }

  Future<void> _sendRequest() async {
    if (customerLocation == null) {
      _message(
        'ما قدرناش نحدد موقعك. فعّل GPS وحاول من جديد.',
      );
      return;
    }

    if (itemController.text.trim().isEmpty) {
      _message('اكتب واش حاب السائق يجيبلك');
      return;
    }

    if (phoneController.text.trim().isEmpty) {
      _message('أدخل رقم الهاتف');
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('requests')
          .add({
        'service': 'alo_jibli',
        'vehicleType': 'motorcycle',

        'item': itemController.text.trim(),

        'customerLocationLat':
            customerLocation!.latitude,
        'customerLocationLng':
            customerLocation!.longitude,

        'phone': phoneController.text.trim(),

        'status': 'pending',

        'customerLocationUpdatedAt':
            FieldValue.serverTimestamp(),

        'createdAt':
            FieldValue.serverTimestamp(),
      });

      requestId = doc.id;

      await saveRequestId(doc.id);

      _startLocationTracking();

      if (mounted) {
        setState(() {});
      }
    } catch (_) {
      _message('حدث خطأ أثناء إرسال الطلب');
    }
  }

  void _startLocationTracking() {
    locationTimer?.cancel();

    locationTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _updateLocation(),
    );

    _updateLocation();
  }

  Future<void> _updateLocation() async {
    if (requestId == null) return;

    final location = await getCurrentLocation();

    if (location == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(requestId)
          .update({
        'customerLocationLat': location.latitude,
        'customerLocationLng': location.longitude,
        'customerLocationUpdatedAt':
            FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  Future<void> _cancelRequest() async {
    if (requestId == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(requestId)
          .update({
        'status': 'cancelled',
      });
    } catch (_) {}

    locationTimer?.cancel();

    if (mounted) {
      setState(() {
        requestId = null;
      });
    }
  }

  void _message(String text) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(text)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ألو جيبلي',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: requestId != null
          ? CustomerTrackingPage(
              requestId: requestId!,
              onCancel: _cancelRequest,
            )
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  ModernTextField(
                    controller: itemController,
                    hint: 'واش حاب سائق الدراجة يجيبلك؟',
                    icon: Icons.shopping_bag,
                  ),

                  const SizedBox(height: 12),

                  ModernTextField(
                    controller: phoneController,
                    hint: 'رقم الهاتف',
                    icon: Icons.phone,
                    keyboardType: TextInputType.phone,
                  ),

                  const SizedBox(height: 14),

                  SizedBox(
                    height: 350,
                    child: LocationMap(
                      location: customerLocation,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.my_location,
                          color: Color(0xFF1565C0),
                        ),
                        SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            'موقعك يتحدد أوتوماتيكياً',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 18),

                  MainButton(
                    icon: Icons.two_wheeler,
                    text: 'أرسل طلب ألو جيبلي',
                    onPressed: _sendRequest,
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

class CustomerTrackingPage extends StatelessWidget {
  final String requestId;
  final VoidCallback onCancel;

  const CustomerTrackingPage({
    super.key,
    required this.requestId,
    required this.onCancel,
  });

  String statusTitle(String status) {
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
        return 'حالة الطلب';
    }
  }

  IconData statusIcon(String status) {
    switch (status) {
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
        return Icons.search;
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot>(
      stream: FirebaseFirestore.instance
          .collection('requests')
          .doc(requestId)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(
            child: CircularProgressIndicator(),
          );
        }

        if (!snapshot.data!.exists) {
          return const Center(
            child: Text('الطلب غير موجود'),
          );
        }

        final data =
            snapshot.data!.data() as Map<String, dynamic>;

        final status = data['status'] ?? 'pending';

        LatLng? customerLocation;
        LatLng? driverLocation;

        if (data['customerLocationLat'] != null &&
            data['customerLocationLng'] != null) {
          customerLocation = LatLng(
            (data['customerLocationLat'] as num).toDouble(),
            (data['customerLocationLng'] as num).toDouble(),
          );
        }

        if (data['driverLocationLat'] != null &&
            data['driverLocationLng'] != null) {
          driverLocation = LatLng(
            (data['driverLocationLat'] as num).toDouble(),
            (data['driverLocationLng'] as num).toDouble(),
          );
        }

        return SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                ),
                child: Column(
                  children: [
                    Icon(
                      statusIcon(status),
                      size: 50,
                      color: status == 'cancelled'
                          ? Colors.red
                          : const Color(0xFF1565C0),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      statusTitle(status),
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 21,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 15),

              if (customerLocation != null)
                SizedBox(
                  height: 330,
                  child: LocationMap(
                    location: customerLocation,
                    driverLocation: driverLocation,
                    showDriver: driverLocation != null,
                  ),
                ),

              const SizedBox(height: 15),

              if (data['driverId'] != null)
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Row(
                    children: [
                      CircleAvatar(
                        child: Icon(Icons.person),
                      ),
                      SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'تم العثور على سائق لطلبك',
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 15),

              if (status == 'pending')
                MainButton(
                  icon: Icons.cancel,
                  text: 'إلغاء الطلب',
                  color: Colors.red,
                  onPressed: onCancel,
                ),

              if (status == 'completed')
                RatingWidget(requestId: requestId),
            ],
          ),
        );
      },
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
  State<DriverPage> createState() => _DriverPageState();
}

class _DriverPageState extends State<DriverPage> {
  bool online = true;

  String? driverId;
  Timer? driverTimer;

  @override
  void initState() {
    super.initState();
    _loadDriverId();
  }

  @override
  void dispose() {
    driverTimer?.cancel();
    _setDriverOffline();
    super.dispose();
  }

  Future<void> _loadDriverId() async {
    final prefs = await SharedPreferences.getInstance();

    driverId = prefs.getString('driver_id');

    if (driverId == null) {
      driverId =
          'driver_${DateTime.now().millisecondsSinceEpoch}';

      await prefs.setString(
        'driver_id',
        driverId!,
      );
    }

    await _setDriverOnline();
    _startDriverLocation();

    if (mounted) {
      setState(() {});
    }
  }

  Future<void> _setDriverOnline() async {
    if (driverId == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('drivers')
          .doc(driverId)
          .set({
        'vehicleType': widget.vehicleType,
        'online': true,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  Future<void> _setDriverOffline() async {
    if (driverId == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('drivers')
          .doc(driverId)
          .set({
        'online': false,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  void _startDriverLocation() {
    driverTimer?.cancel();

    driverTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _updateDriverLocation(),
    );

    _updateDriverLocation();
  }

  Future<void> _updateDriverLocation() async {
    if (driverId == null || !online) return;

    final location = await getCurrentLocation();

    if (location == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('drivers')
          .doc(driverId)
          .set({
        'vehicleType': widget.vehicleType,
        'online': true,
        'lat': location.latitude,
        'lng': location.longitude,
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (_) {}
  }

  Future<void> _toggleOnline(bool value) async {
    setState(() {
      online = value;
    });

    if (value) {
      await _setDriverOnline();
      _startDriverLocation();
    } else {
      await _setDriverOffline();
      driverTimer?.cancel();
    }
  }

  @override
  Widget build(BuildContext context) {
    final title = widget.vehicleType == 'car'
        ? 'طلبات ألو وصلني'
        : 'طلبات ألو جيبلي';

    if (!online) {
      return Scaffold(
        appBar: AppBar(
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          centerTitle: true,
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.power_settings_new,
                  size: 75,
                  color: Colors.grey,
                ),
                const SizedBox(height: 15),
                const Text(
                  'أنت غير متصل',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'فعّل الاتصال باش تستقبل الطلبات',
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Switch(
                  value: online,
                  onChanged: _toggleOnline,
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        actions: [
          Switch(
            value: online,
            onChanged: _toggleOnline,
          ),
        ],
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
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
        builder: (context, snapshot) {
          if (snapshot.connectionState ==
              ConnectionState.waiting) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return const Center(
              child: Text(
                'تعذر تحميل الطلبات',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          final docs = snapshot.data?.docs ?? [];

          final filtered = docs.where((doc) {
            final data =
                doc.data() as Map<String, dynamic>;

            final service = data['service'];
            final status = data['status'];

            // 🚗 السيارة = ألو وصلني فقط
            if (widget.vehicleType == 'car') {
              if (service != 'alo_waselni') {
                return false;
              }
            }

            // 🛵 الدراجة = ألو جيبلي فقط
            if (widget.vehicleType == 'motorcycle') {
              if (service != 'alo_jibli') {
                return false;
              }
            }

            // الطلب المقبول من هذا السائق يبقى ظاهر له
            if (data['driverId'] == driverId) {
              return true;
            }

            // الطلبات الجديدة فقط للسائقين الآخرين
            if (status != 'pending') {
              return false;
            }

            return true;
          }).toList();

          if (filtered.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    widget.vehicleType == 'car'
                        ? Icons.local_taxi
                        : Icons.two_wheeler,
                    size: 70,
                    color: Colors.grey,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'ما كاش طلبات حالياً',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    widget.vehicleType == 'car'
                        ? 'طلبات ألو وصلني تظهر هنا'
                        : 'طلبات ألو جيبلي تظهر هنا',
                    style: const TextStyle(
                      color: Colors.grey,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              return DriverRequestCard(
                doc: filtered[index],
                driverId: driverId,
              );
            },
          );
        },
      ),
    );
  }
}

// ============================================================
// DRIVER REQUEST CARD
// ============================================================

class DriverRequestCard extends StatefulWidget {
  final QueryDocumentSnapshot doc;
  final String? driverId;

  const DriverRequestCard({
    super.key,
    required this.doc,
    required this.driverId,
  });

  @override
  State<DriverRequestCard> createState() =>
      _DriverRequestCardState();
}

class _DriverRequestCardState
    extends State<DriverRequestCard> {
  Timer? locationTimer;

  @override
  void initState() {
    super.initState();

    locationTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _updateLocationIfAccepted(),
    );
  }

  @override
  void dispose() {
    locationTimer?.cancel();
    super.dispose();
  }

  Future<void> _updateLocationIfAccepted() async {
    final data =
        widget.doc.data() as Map<String, dynamic>;

    if (data['driverId'] != widget.driverId) {
      return;
    }

    final status = data['status'];

    if (status == 'completed' ||
        status == 'cancelled') {
      return;
    }

    final location = await getCurrentLocation();

    if (location == null) return;

    try {
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(widget.doc.id)
          .update({
        'driverLocationLat': location.latitude,
        'driverLocationLng': location.longitude,
        'driverLocationUpdatedAt':
            FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  Future<void> _accept() async {
    if (widget.driverId == null) return;

    final location = await getCurrentLocation();

    final update = <String, dynamic>{
      'status': 'accepted',
      'driverId': widget.driverId,
      'acceptedAt': FieldValue.serverTimestamp(),
    };

    if (location != null) {
      update['driverLocationLat'] =
          location.latitude;
      update['driverLocationLng'] =
          location.longitude;
      update['driverLocationUpdatedAt'] =
          FieldValue.serverTimestamp();
    }

    try {
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(widget.doc.id)
          .update(update);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تم قبول الطلب ✅'),
          ),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('تعذر قبول الطلب'),
          ),
        );
      }
    }
  }

  Future<void> _changeStatus(String status) async {
    try {
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(widget.doc.id)
          .update({
        'status': status,
        '${status}At':
            FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  Future<void> _callCustomer() async {
    final data =
        widget.doc.data() as Map<String, dynamic>;

    final phone = data['phone'];

    if (phone == null ||
        phone.toString().isEmpty) {
      return;
    }

    const channel =
        MethodChannel('allo_waselni/phone');

    try {
      await channel.invokeMethod(
        'call',
        {
          'phone': phone.toString(),
        },
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              'رقم الزبون: $phone',
            ),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final data =
        widget.doc.data() as Map<String, dynamic>;

    final service = data['service'] ?? '';
    final status = data['status'] ?? 'pending';

    final isJibli =
        service == 'alo_jibli';

    LatLng? customerLocation;

    if (data['customerLocationLat'] != null &&
        data['customerLocationLng'] != null) {
      customerLocation = LatLng(
        (data['customerLocationLat'] as num)
            .toDouble(),
        (data['customerLocationLng'] as num)
            .toDouble(),
      );
    }

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(22),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 26,
                  backgroundColor:
                      const Color(0xFFE3F2FD),
                  child: Icon(
                    isJibli
                        ? Icons.shopping_bag
                        : Icons.local_taxi,
                    color:
                        const Color(0xFF1565C0),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        isJibli
                            ? 'ألو جيبلي'
                            : 'ألو وصلني',
                        style: const TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.bold,
                        ),
                      ),

                      if (isJibli)
                        Text(
                          'الطلب: ${data['item'] ?? ''}',
                          style: const TextStyle(
                            color: Colors.grey,
                          ),
                        ),

                      Text(
                        'الهاتف: ${data['phone'] ?? ''}',
                        style: const TextStyle(
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // الخريطة فيها الزبون فقط
            if (customerLocation != null)
              SizedBox(
                height: 250,
                child: LiveCustomerMap(
                  initialLocation:
                      customerLocation,
                  requestId: widget.doc.id,
                ),
              ),

            const SizedBox(height: 10),

            StatusChip(status: status),

            const SizedBox(height: 12),

            if (status == 'pending')
              MainButton(
                icon: Icons.check_circle,
                text: 'قبول الطلب',
                onPressed: _accept,
              ),

            if (status == 'accepted') ...[
              MainButton(
                icon: Icons.directions_car,
                text: 'أنا في الطريق',
                onPressed: () =>
                    _changeStatus(
                  'driver_arriving',
                ),
              ),
              const SizedBox(height: 8),
              MainButton(
                icon: Icons.phone,
                text: 'اتصال بالزبون',
                onPressed: _callCustomer,
              ),
            ],

            if (status == 'driver_arriving') ...[
              MainButton(
                icon: Icons.location_on,
                text: 'وصلت للزبون',
                onPressed: () =>
                    _changeStatus(
                  'driver_arrived',
                ),
              ),
              const SizedBox(height: 8),
              MainButton(
                icon: Icons.phone,
                text: 'اتصال بالزبون',
                onPressed: _callCustomer,
              ),
            ],

            if (status == 'driver_arrived')
              MainButton(
                icon: Icons.done_all,
                text: 'تم إنهاء الطلب',
                onPressed: () =>
                    _changeStatus(
                  'completed',
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// LIVE CUSTOMER MAP
// ============================================================

class LiveCustomerMap extends StatefulWidget {
  final String requestId;
  final LatLng initialLocation;

  const LiveCustomerMap({
    super.key,
    required this.requestId,
    required this.initialLocation,
  });

  @override
  State<LiveCustomerMap> createState() =>
      _LiveCustomerMapState();
}

class _LiveCustomerMapState
    extends State<LiveCustomerMap> {
  final MapController controller =
      MapController();

  late LatLng customerLocation;

  @override
  void initState() {
    super.initState();
    customerLocation =
        widget.initialLocation;
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .doc(widget.requestId)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasData &&
              snapshot.data!.exists) {
            final data =
                snapshot.data!.data()
                    as Map<String, dynamic>;

            if (data['customerLocationLat'] !=
                    null &&
                data['customerLocationLng'] !=
                    null) {
              customerLocation = LatLng(
                (data['customerLocationLat']
                        as num)
                    .toDouble(),
                (data['customerLocationLng']
                        as num)
                    .toDouble(),
              );
            }
          }

          return Stack(
            children: [
              FlutterMap(
                mapController: controller,
                options: MapOptions(
                  initialCenter:
                      customerLocation,
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
                        point:
                            customerLocation,
                        width: 75,
                        height: 70,
                        child: Column(
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets
                                      .symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              decoration:
                                  BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius
                                        .circular(8),
                              ),
                              child: const Text(
                                'الزبون',
                                style: TextStyle(
                                  fontWeight:
                                      FontWeight.bold,
                                  fontSize: 11,
                                ),
                              ),
                            ),
                            const Icon(
                              Icons.location_on,
                              color: Colors.blue,
                              size: 38,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              Positioned(
                right: 10,
                bottom: 10,
                child: MapControlButton(
                  icon: Icons.my_location,
                  onTap: () {
                    controller.move(
                      customerLocation,
                      16,
                    );
                  },
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
// HISTORY
// ============================================================

Future<void> saveRequestId(String id) async {
  final prefs =
      await SharedPreferences.getInstance();

  final list =
      prefs.getStringList('my_requests') ?? [];

  if (!list.contains(id)) {
    list.insert(0, id);
  }

  await prefs.setStringList(
    'my_requests',
    list,
  );
}

class HistoryPage extends StatelessWidget {
  const HistoryPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'طلباتي السابقة',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor:
          const Color(0xFFF5F7FA),
      body: FutureBuilder<SharedPreferences>(
        future:
            SharedPreferences.getInstance(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          final ids = snapshot.data!
                  .getStringList(
                    'my_requests',
                  ) ??
              [];

          if (ids.isEmpty) {
            return const Center(
              child: Text(
                'ما عندكش طلبات سابقة',
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(14),
            itemCount: ids.length,
            itemBuilder: (context, index) {
              return FutureBuilder<
                  DocumentSnapshot>(
                future:
                    FirebaseFirestore.instance
                        .collection(
                          'requests',
                        )
                        .doc(ids[index])
                        .get(),
                builder: (
                  context,
                  snap,
                ) {
                  if (!snap.hasData ||
                      !snap.data!.exists) {
                    return const SizedBox();
                  }

                  final data =
                      snap.data!.data()
                          as Map<String, dynamic>;

                  return HistoryCard(
                    data: data,
                    requestId: ids[index],
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

class HistoryCard extends StatelessWidget {
  final Map<String, dynamic> data;
  final String requestId;

  const HistoryCard({
    super.key,
    required this.data,
    required this.requestId,
  });

  @override
  Widget build(BuildContext context) {
    final service =
        data['service'] ?? '';
    final status =
        data['status'] ?? '';

    return Card(
      margin:
          const EdgeInsets.only(bottom: 12),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              service == 'alo_jibli'
                  ? '📦 ألو جيبلي'
                  : '🚗 ألو وصلني',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 7),
            Text(
              'الحالة: $status',
            ),
            if (data['phone'] != null)
              Text(
                'الهاتف: ${data['phone']}',
              ),
            if (status == 'completed')
              RatingWidget(
                requestId: requestId,
              ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// RATING
// ============================================================

class RatingWidget extends StatefulWidget {
  final String requestId;

  const RatingWidget({
    super.key,
    required this.requestId,
  });

  @override
  State<RatingWidget> createState() =>
      _RatingWidgetState();
}

class _RatingWidgetState
    extends State<RatingWidget> {
  int rating = 0;
  bool saved = false;

  Future<void> _saveRating() async {
    if (rating == 0) return;

    try {
      await FirebaseFirestore.instance
          .collection('requests')
          .doc(widget.requestId)
          .update({
        'rating': rating,
        'ratedAt':
            FieldValue.serverTimestamp(),
      });

      if (mounted) {
        setState(() {
          saved = true;
        });
      }
    } catch (_) {}
  }

  @override
  Widget build(BuildContext context) {
    if (saved) {
      return const Padding(
        padding: EdgeInsets.only(top: 10),
        child: Text(
          'شكراً على تقييمك ⭐',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      );
    }

    return Column(
      children: [
        const SizedBox(height: 10),
        const Text(
          'قيّم الخدمة',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment:
              MainAxisAlignment.center,
          children: List.generate(
            5,
            (index) => IconButton(
              onPressed: () {
                setState(() {
                  rating = index + 1;
                });
              },
              icon: Icon(
                Icons.star,
                color: index < rating
                    ? Colors.amber
                    : Colors.grey,
              ),
            ),
          ),
        ),
        TextButton(
          onPressed: _saveRating,
          child: const Text(
            'إرسال التقييم',
          ),
        ),
      ],
    );
  }
}

// ============================================================
// STATUS
// ============================================================

class StatusChip extends StatelessWidget {
  final String status;

  const StatusChip({
    super.key,
    required this.status,
  });

  String get text {
    switch (status) {
      case 'pending':
        return 'جديد';
      case 'accepted':
        return 'تم قبول الطلب';
      case 'driver_arriving':
        return 'السائق في الطريق';
      case 'driver_arrived':
        return 'السائق وصل';
      case 'completed':
        return 'مكتمل';
      case 'cancelled':
        return 'ملغى';
      default:
        return status;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding:
          const EdgeInsets.symmetric(
        vertical: 11,
        horizontal: 14,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFE3F2FD),
        borderRadius:
            BorderRadius.circular(14),
      ),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

// ============================================================
// UI
// ============================================================

class MainButton extends StatelessWidget {
  final IconData icon;
  final String text;
  final VoidCallback onPressed;
  final Color? color;

  const MainButton({
    super.key,
    required this.icon,
    required this.text,
    required this.onPressed,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 53,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor:
              color ??
              const Color(0xFF1565C0),
          foregroundColor: Colors.white,
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(17),
          ),
        ),
        onPressed: onPressed,
        icon: Icon(icon),
        label: Text(
          text,
          style: const TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

class ModernTextField
    extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final IconData icon;
  final TextInputType? keyboardType;

  const ModernTextField({
    super.key,
    required this.controller,
    required this.hint,
    required this.icon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(18),
          borderSide:
              BorderSide.none,
        ),
      ),
    );
  }
}

class MapControlButton
    extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;

  const MapControlButton({
    super.key,
    required this.icon,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      elevation: 3,
      borderRadius:
          BorderRadius.circular(12),
      child: InkWell(
        borderRadius:
            BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon),
        ),
      ),
    );
  }
}
