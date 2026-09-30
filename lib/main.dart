import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:geolocator/geolocator.dart';

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

// =====================================================
// HOME
// =====================================================

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
                size: 70,
                color: Color(0xFF1565C0),
              ),

              const SizedBox(height: 12),

              const Text(
                'ألو وصلني',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF1565C0),
                ),
              ),

              const SizedBox(height: 5),

              const Text(
                'خدمة التوصيل داخل البلدية',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),

              const SizedBox(height: 45),

              RoleButton(
                icon: Icons.person_rounded,
                title: 'أنا زبون',
                subtitle: 'اطلب سيارة أو دراجة',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const CustomerPage(),
                    ),
                  );
                },
              ),

              const SizedBox(height: 18),

              RoleButton(
                icon: Icons.directions_car_rounded,
                title: 'سائق سيارة',
                subtitle: 'استقبل طلبات الزبائن',
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

              const SizedBox(height: 18),

              RoleButton(
                icon: Icons.two_wheeler_rounded,
                title: 'سائق دراجة',
                subtitle: 'استقبل طلبات الزبائن',
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

// =====================================================
// ROLE BUTTON
// =====================================================

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
      borderRadius: BorderRadius.circular(22),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(20),
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
                  color: const Color(0xFF1565C0),
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
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
                      style: const TextStyle(
                        color: Colors.grey,
                      ),
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

// =====================================================
// CUSTOMER
// =====================================================

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
              subtitle: 'اطلب سيارة أو دراجة',
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

            ServiceButton(
              icon: Icons.shopping_bag_rounded,
              title: 'ألو جيبلي',
              subtitle: 'خلي السائق يجيبلك طلبك',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const JibliPage(),
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
      borderRadius: BorderRadius.circular(22),
      elevation: 2,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(22),
          child: Row(
            children: [
              CircleAvatar(
                radius: 29,
                backgroundColor: const Color(0xFFE3F2FD),
                child: Icon(
                  icon,
                  color: const Color(0xFF1565C0),
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 5),
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

// =====================================================
// LOCATION MAP
// =====================================================

class LocationMap extends StatefulWidget {
  final LatLng? pickup;
  final LatLng? destination;
  final Function(LatLng) onMapTap;
  final bool showDestination;

  const LocationMap({
    super.key,
    this.pickup,
    this.destination,
    required this.onMapTap,
    this.showDestination = true,
  });

  @override
  State<LocationMap> createState() => _LocationMapState();
}

class _LocationMapState extends State<LocationMap> {
  final MapController mapController = MapController();

  LatLng? currentLocation;
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    try {
      final serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        setState(() => loading = false);
        return;
      }

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        setState(() => loading = false);
        return;
      }

      final position =
          await Geolocator.getCurrentPosition();

      final location = LatLng(
        position.latitude,
        position.longitude,
      );

      setState(() {
        currentLocation = location;
        loading = false;
      });

      mapController.move(location, 15);
    } catch (_) {
      setState(() => loading = false);
    }
  }

  void _centerLocation() {
    if (currentLocation != null) {
      mapController.move(currentLocation!, 16);
    }
  }

  @override
  Widget build(BuildContext context) {
    final center =
        currentLocation ??
        widget.pickup ??
        const LatLng(35.6971, -0.6308);

    final markers = <Marker>[];

    if (currentLocation != null) {
      markers.add(
        Marker(
          point: currentLocation!,
          width: 55,
          height: 55,
          child: const Icon(
            Icons.my_location,
            color: Colors.blue,
            size: 38,
          ),
        ),
      );
    }

    if (widget.pickup != null) {
      markers.add(
        Marker(
          point: widget.pickup!,
          width: 55,
          height: 55,
          child: const Icon(
            Icons.location_on,
            color: Colors.green,
            size: 42,
          ),
        ),
      );
    }

    if (widget.showDestination &&
        widget.destination != null) {
      markers.add(
        Marker(
          point: widget.destination!,
          width: 55,
          height: 55,
          child: const Icon(
            Icons.flag_rounded,
            color: Colors.red,
            size: 38,
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
              initialZoom: 14,
              onTap: (_, point) {
                widget.onMapTap(point);
              },
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
            right: 12,
            bottom: 12,
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
                const SizedBox(height: 8),
                MapControlButton(
                  icon: Icons.remove,
                  onTap: () {
                    mapController.move(
                      mapController.camera.center,
                      mapController.camera.zoom - 1,
                    );
                  },
                ),
                const SizedBox(height: 8),
                MapControlButton(
                  icon: Icons.my_location,
                  onTap: _centerLocation,
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

// =====================================================
// WASELNI
// =====================================================

class WaselniPage extends StatefulWidget {
  const WaselniPage({super.key});

  @override
  State<WaselniPage> createState() => _WaselniPageState();
}

class _WaselniPageState extends State<WaselniPage> {
  LatLng? pickup;
  LatLng? destination;

  String vehicle = 'car';

  final phoneController = TextEditingController();

  String? requestId;

  Timer? locationTimer;

  @override
  void dispose() {
    locationTimer?.cancel();
    phoneController.dispose();
    super.dispose();
  }

  void _mapTap(LatLng point) {
    setState(() {
      if (pickup == null) {
        pickup = point;
      } else if (destination == null) {
        destination = point;
      } else {
        pickup = point;
        destination = null;
      }
    });
  }

  Future<void> sendRequest() async {
    if (pickup == null || destination == null) {
      _showMessage('حدد نقطة الانطلاق والوجهة من الخريطة');
      return;
    }

    if (phoneController.text.trim().isEmpty) {
      _showMessage('أدخل رقم الهاتف');
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('requests')
          .add({
        'service': 'alo_waselni',
        'vehicleType': vehicle,
        'pickupLat': pickup!.latitude,
        'pickupLng': pickup!.longitude,
        'destinationLat': destination!.latitude,
        'destinationLng': destination!.longitude,
        'phone': phoneController.text.trim(),
        'status': 'pending',

        // الموقع الحالي للزبون
        'customerLocationLat': pickup!.latitude,
        'customerLocationLng': pickup!.longitude,
        'customerLocationUpdatedAt':
            FieldValue.serverTimestamp(),

        'createdAt': FieldValue.serverTimestamp(),
      });

      requestId = doc.id;

      _startLiveLocation();

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return AlertDialog(
            title: const Text('تم إرسال الطلب ✅'),
            content: const Text(
              'الطلب وصل للسائقين.\n'
              'موقعك الحالي يتحدث تلقائياً للسائق.',
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text('حسناً'),
              ),
            ],
          );
        },
      );
    } catch (e) {
      _showMessage('حدث خطأ أثناء إرسال الطلب');
    }
  }

  void _startLiveLocation() {
    locationTimer?.cancel();

    locationTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _updateCustomerLocation(),
    );

    _updateCustomerLocation();
  }

  Future<void> _updateCustomerLocation() async {
    if (requestId == null) return;

    try {
      final serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) return;

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final position =
          await Geolocator.getCurrentPosition();

      await FirebaseFirestore.instance
          .collection('requests')
          .doc(requestId)
          .update({
        'customerLocationLat': position.latitude,
        'customerLocationLng': position.longitude,
        'customerLocationUpdatedAt':
            FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            SizedBox(
              height: 330,
              child: LocationMap(
                pickup: pickup,
                destination: destination,
                onMapTap: _mapTap,
              ),
            ),

            const SizedBox(height: 14),

            const Text(
              'اضغط على الخريطة لاختيار الانطلاق ثم الوجهة',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 15),

            Row(
              children: [
                Expanded(
                  child: VehicleButton(
                    icon: Icons.directions_car,
                    title: 'سيارة',
                    selected: vehicle == 'car',
                    onTap: () {
                      setState(() => vehicle = 'car');
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: VehicleButton(
                    icon: Icons.two_wheeler,
                    title: 'دراجة',
                    selected: vehicle == 'motorcycle',
                    onTap: () {
                      setState(() => vehicle = 'motorcycle');
                    },
                  ),
                ),
              ],
            ),

            const SizedBox(height: 14),

            ModernTextField(
              controller: phoneController,
              hint: 'رقم الهاتف',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: sendRequest,
                icon: const Icon(Icons.send),
                label: const Text(
                  'اطلب الآن',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// JIBLI
// =====================================================

class JibliPage extends StatefulWidget {
  const JibliPage({super.key});

  @override
  State<JibliPage> createState() => _JibliPageState();
}

class _JibliPageState extends State<JibliPage> {
  LatLng? pickup;
  LatLng? destination;

  final itemController = TextEditingController();
  final phoneController = TextEditingController();

  String? requestId;
  Timer? locationTimer;

  @override
  void dispose() {
    locationTimer?.cancel();
    itemController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void _mapTap(LatLng point) {
    setState(() {
      if (pickup == null) {
        pickup = point;
      } else if (destination == null) {
        destination = point;
      } else {
        pickup = point;
        destination = null;
      }
    });
  }

  Future<void> sendRequest() async {
    if (pickup == null || destination == null) {
      _showMessage('حدد نقطة الانطلاق والوجهة');
      return;
    }

    if (itemController.text.trim().isEmpty) {
      _showMessage('اكتب واش حاب السائق يجيبلك');
      return;
    }

    if (phoneController.text.trim().isEmpty) {
      _showMessage('أدخل رقم الهاتف');
      return;
    }

    try {
      final doc = await FirebaseFirestore.instance
          .collection('requests')
          .add({
        'service': 'alo_jibli',
        'item': itemController.text.trim(),
        'pickupLat': pickup!.latitude,
        'pickupLng': pickup!.longitude,
        'destinationLat': destination!.latitude,
        'destinationLng': destination!.longitude,
        'phone': phoneController.text.trim(),
        'status': 'pending',

        'customerLocationLat': pickup!.latitude,
        'customerLocationLng': pickup!.longitude,
        'customerLocationUpdatedAt':
            FieldValue.serverTimestamp(),

        'createdAt': FieldValue.serverTimestamp(),
      });

      requestId = doc.id;

      _startLiveLocation();

      if (!mounted) return;

      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (_) {
          return AlertDialog(
            title: const Text('تم إرسال الطلب ✅'),
            content: const Text(
              'السائقين يقدرو يشوفو موقعك الحالي على الخريطة.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('حسناً'),
              ),
            ],
          );
        },
      );
    } catch (_) {
      _showMessage('حدث خطأ أثناء إرسال الطلب');
    }
  }

  void _startLiveLocation() {
    locationTimer?.cancel();

    locationTimer = Timer.periodic(
      const Duration(seconds: 5),
      (_) => _updateCustomerLocation(),
    );

    _updateCustomerLocation();
  }

  Future<void> _updateCustomerLocation() async {
    if (requestId == null) return;

    try {
      final serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) return;

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return;
      }

      final position =
          await Geolocator.getCurrentPosition();

      await FirebaseFirestore.instance
          .collection('requests')
          .doc(requestId)
          .update({
        'customerLocationLat': position.latitude,
        'customerLocationLng': position.longitude,
        'customerLocationUpdatedAt':
            FieldValue.serverTimestamp(),
      });
    } catch (_) {}
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
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
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            ModernTextField(
              controller: itemController,
              hint: 'واش حاب السائق يجيبلك؟',
              icon: Icons.shopping_bag,
            ),

            const SizedBox(height: 14),

            ModernTextField(
              controller: phoneController,
              hint: 'رقم الهاتف',
              icon: Icons.phone,
              keyboardType: TextInputType.phone,
            ),

            const SizedBox(height: 15),

            SizedBox(
              height: 330,
              child: LocationMap(
                pickup: pickup,
                destination: destination,
                onMapTap: _mapTap,
              ),
            ),

            const SizedBox(height: 12),

            const Text(
              'حدد مكان الانطلاق ثم مكان التسليم',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.grey),
            ),

            const SizedBox(height: 18),

            SizedBox(
              width: double.infinity,
              height: 55,
              child: ElevatedButton.icon(
                onPressed: sendRequest,
                icon: const Icon(Icons.send),
                label: const Text(
                  'أرسل الطلب',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// DRIVER
// =====================================================

class DriverPage extends StatelessWidget {
  final String vehicleType;

  const DriverPage({
    super.key,
    required this.vehicleType,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          vehicleType == 'car'
              ? 'طلبات السيارة'
              : 'طلبات الدراجة',
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      backgroundColor: const Color(0xFFF5F7FA),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .where('status', isEqualTo: 'pending')
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
                  fontSize: 17,
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

            // ألو جيبلي يبان لجميع السائقين
            if (service == 'alo_jibli') {
              return true;
            }

            return data['vehicleType'] == vehicleType;
          }).toList();

          if (filtered.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_rounded,
                    size: 70,
                    color: Colors.grey,
                  ),
                  SizedBox(height: 12),
                  Text(
                    'ما كاش طلبات حالياً',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    'الطلبات الجديدة راح تظهر هنا',
                    style: TextStyle(color: Colors.grey),
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
              );
            },
          );
        },
      ),
    );
  }
}

// =====================================================
// DRIVER REQUEST CARD
// =====================================================

class DriverRequestCard extends StatelessWidget {
  final QueryDocumentSnapshot doc;

  const DriverRequestCard({
    super.key,
    required this.doc,
  });

  @override
  Widget build(BuildContext context) {
    final data =
        doc.data() as Map<String, dynamic>;

    final service = data['service'] ?? '';

    final isJibli = service == 'alo_jibli';

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
                  radius: 25,
                  backgroundColor:
                      const Color(0xFFE3F2FD),
                  child: Icon(
                    isJibli
                        ? Icons.shopping_bag
                        : Icons.local_shipping,
                    color: const Color(0xFF1565C0),
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

                      if (isJibli &&
                          data['item'] != null)
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 4),
                          child: Text(
                            'الطلب: ${data['item']}',
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ),

                      if (data['phone'] != null)
                        Padding(
                          padding:
                              const EdgeInsets.only(top: 3),
                          child: Text(
                            'الهاتف: ${data['phone']}',
                            style: const TextStyle(
                              color: Colors.grey,
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            // =================================================
            // خريطة السائق:
            // موقع الزبون فقط
            // بدون الوجهة
            // =================================================

            SizedBox(
              height: 250,
              child: LiveCustomerMap(
                requestId: doc.id,
                initialLat:
                    (data['customerLocationLat'] ??
                            data['pickupLat'])
                        .toDouble(),
                initialLng:
                    (data['customerLocationLng'] ??
                            data['pickupLng'])
                        .toDouble(),
              ),
            ),

            const SizedBox(height: 12),

            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(
                horizontal: 14,
                vertical: 11,
              ),
              decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.location_on,
                    color: Colors.blue,
                  ),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'موقع الزبون الحالي يتحدث مباشرة',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton.icon(
                onPressed: () async {
                  await FirebaseFirestore.instance
                      .collection('requests')
                      .doc(doc.id)
                      .update({
                    'status': 'accepted',
                    'acceptedAt':
                        FieldValue.serverTimestamp(),
                  });

                  if (context.mounted) {
                    ScaffoldMessenger.of(context)
                        .showSnackBar(
                      const SnackBar(
                        content:
                            Text('تم قبول الطلب ✅'),
                      ),
                    );
                  }
                },
                icon: const Icon(Icons.check_circle),
                label: const Text(
                  'قبول الطلب',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// LIVE CUSTOMER MAP
// =====================================================

class LiveCustomerMap extends StatefulWidget {
  final String requestId;
  final double initialLat;
  final double initialLng;

  const LiveCustomerMap({
    super.key,
    required this.requestId,
    required this.initialLat,
    required this.initialLng,
  });

  @override
  State<LiveCustomerMap> createState() =>
      _LiveCustomerMapState();
}

class _LiveCustomerMapState
    extends State<LiveCustomerMap> {
  final MapController mapController = MapController();

  late LatLng customerLocation;

  @override
  void initState() {
    super.initState();

    customerLocation = LatLng(
      widget.initialLat,
      widget.initialLng,
    );
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
            final data = snapshot.data!.data()
                as Map<String, dynamic>;

            final lat = data['customerLocationLat'];
            final lng = data['customerLocationLng'];

            if (lat != null && lng != null) {
              customerLocation = LatLng(
                (lat as num).toDouble(),
                (lng as num).toDouble(),
              );
            }
          }

          return Stack(
            children: [
              FlutterMap(
                mapController: mapController,
                options: MapOptions(
                  initialCenter: customerLocation,
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
                        point: customerLocation,
                        width: 70,
                        height: 70,
                        child: Column(
                          children: [
                            Container(
                              padding:
                                  const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius:
                                    BorderRadius.circular(8),
                                boxShadow: const [
                                  BoxShadow(
                                    blurRadius: 5,
                                    color: Colors.black26,
                                  ),
                                ],
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
                    mapController.move(
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

// =====================================================
// TEXT FIELD
// =====================================================

class ModernTextField extends StatelessWidget {
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
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(18),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 17,
        ),
      ),
    );
  }
}

// =====================================================
// VEHICLE BUTTON
// =====================================================

class VehicleButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final bool selected;
  final VoidCallback onTap;

  const VehicleButton({
    super.key,
    required this.icon,
    required this.title,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(18),
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: selected
              ? const Color(0xFFE3F2FD)
              : Colors.white,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: selected
                ? const Color(0xFF1565C0)
                : Colors.transparent,
            width: 2,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: selected
                  ? const Color(0xFF1565C0)
                  : Colors.grey,
            ),
            const SizedBox(width: 8),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: selected
                    ? const Color(0xFF1565C0)
                    : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// =====================================================
// MAP CONTROL
// =====================================================

class MapControlButton extends StatelessWidget {
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
      borderRadius: BorderRadius.circular(12),
      elevation: 3,
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: SizedBox(
          width: 45,
          height: 45,
          child: Icon(icon),
        ),
      ),
    );
  }
}
