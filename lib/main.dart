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

// =====================================================
// التطبيق
// =====================================================

class AloWaselniApp extends StatelessWidget {
  const AloWaselniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ألو وصلني',
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'sans',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF1976D2),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      ),
      home: const HomePage(),
    );
  }
}

// =====================================================
// الصفحة الرئيسية
// =====================================================

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 30, 20, 30),
          child: Column(
            children: [
              const SizedBox(height: 15),

              // الشعار
              Container(
                width: 100,
                height: 100,
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [
                      Color(0xFF1976D2),
                      Color(0xFF42A5F5),
                    ],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.blue.withOpacity(.22),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.local_shipping_rounded,
                  color: Colors.white,
                  size: 55,
                ),
              ),

              const SizedBox(height: 20),

              const Text(
                'ألو وصلني',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF172033),
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'النقل والتوصيل داخل البلدية',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 38),

              RoleButton(
                icon: Icons.person_rounded,
                title: 'أنا الزبون',
                subtitle: 'اطلب سيارة أو خدمة توصيل',
                color: const Color(0xFF1976D2),
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

              RoleButton(
                icon: Icons.directions_car_rounded,
                title: 'أنا السائق',
                subtitle: 'شوف طلبات السيارات',
                color: const Color(0xFF159447),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DriverPage(
                        vehicleType: 'car',
                        title: 'أنا السائق',
                      ),
                    ),
                  );
                },
              ),

              const SizedBox(height: 15),

              RoleButton(
                icon: Icons.two_wheeler_rounded,
                title: 'أنا سائق الدراجة',
                subtitle: 'شوف طلبات الدراجات والتوصيل',
                color: const Color(0xFFFF8A00),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const DriverPage(
                        vehicleType: 'motorcycle',
                        title: 'أنا سائق الدراجة',
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
// زر الدور
// =====================================================

class RoleButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const RoleButton({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(22),
      elevation: 2,
      shadowColor: Colors.black12,
      child: InkWell(
        borderRadius: BorderRadius.circular(22),
        onTap: onTap,
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(17),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: color.withOpacity(.11),
                  borderRadius: BorderRadius.circular(17),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 31,
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
                        fontWeight: FontWeight.w800,
                        color: Color(0xFF172033),
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================
// صفحة الزبون
// =====================================================

class CustomerPage extends StatelessWidget {
  const CustomerPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'أنا الزبون',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF172033),
        elevation: 0,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 15),

            ServiceButton(
              icon: Icons.directions_car_rounded,
              title: 'ألو وصلني',
              subtitle: 'نقلك للمكان اللي حاب تروحلو',
              color: const Color(0xFF1976D2),
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
              subtitle: 'نجيبلك الحاجة اللي تحتاجها',
              color: const Color(0xFFFF8A00),
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

// =====================================================
// زر الخدمة
// =====================================================

class ServiceButton extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const ServiceButton({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(24),
      elevation: 2,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Container(
                width: 68,
                height: 68,
                decoration: BoxDecoration(
                  color: color.withOpacity(.10),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Icon(
                  icon,
                  color: color,
                  size: 38,
                ),
              ),

              const SizedBox(width: 17),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: Colors.grey.shade400,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// =====================================================
// الخريطة العصرية
// =====================================================

class LocationMap extends StatefulWidget {
  final LatLng? pickup;
  final LatLng? destination;
  final Function(LatLng) onMapTap;
  final bool showCurrentLocationButton;

  const LocationMap({
    super.key,
    required this.pickup,
    required this.destination,
    required this.onMapTap,
    this.showCurrentLocationButton = true,
  });

  @override
  State<LocationMap> createState() => _LocationMapState();
}

class _LocationMapState extends State<LocationMap> {
  final MapController mapController = MapController();

  LatLng? currentLocation;
  bool loadingLocation = false;

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  Future<void> getCurrentLocation() async {
    if (loadingLocation) return;

    setState(() {
      loadingLocation = true;
    });

    try {
      bool serviceEnabled =
          await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (mounted) {
          showLocationMessage(
            'فعّل الموقع GPS في الهاتف',
          );
        }
        return;
      }

      LocationPermission permission =
          await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission =
            await Geolocator.requestPermission();
      }

      if (permission ==
              LocationPermission.denied ||
          permission ==
              LocationPermission.deniedForever) {
        if (mounted) {
          showLocationMessage(
            'اسمح للتطبيق باستعمال موقعك',
          );
        }
        return;
      }

      final position =
          await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      final point = LatLng(
        position.latitude,
        position.longitude,
      );

      if (!mounted) return;

      setState(() {
        currentLocation = point;
      });

      mapController.move(point, 16);
    } catch (e) {
      if (mounted) {
        showLocationMessage(
          'تعذر تحديد موقعك',
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          loadingLocation = false;
        });
      }
    }
  }

  void showLocationMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>[];

    // الموقع الحالي
    if (currentLocation != null) {
      markers.add(
        Marker(
          point: currentLocation!,
          width: 45,
          height: 45,
          child: Container(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: Colors.blue.withOpacity(.18),
            ),
            padding: const EdgeInsets.all(7),
            child: Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.blue,
                border: Border.all(
                  color: Colors.white,
                  width: 3,
                ),
                boxShadow: const [
                  BoxShadow(
                    blurRadius: 8,
                    color: Colors.black26,
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    }

    // الانطلاق
    if (widget.pickup != null) {
      markers.add(
        Marker(
          point: widget.pickup!,
          width: 55,
          height: 65,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFF16A05D),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 8,
                      color: Colors.black26,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.trip_origin_rounded,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              const Icon(
                Icons.arrow_drop_down,
                color: Color(0xFF16A05D),
                size: 20,
              ),
            ],
          ),
        ),
      );
    }

    // الوجهة
    if (widget.destination != null) {
      markers.add(
        Marker(
          point: widget.destination!,
          width: 55,
          height: 65,
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: const Color(0xFFE53935),
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: const [
                    BoxShadow(
                      blurRadius: 8,
                      color: Colors.black26,
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.flag_rounded,
                  color: Colors.white,
                  size: 25,
                ),
              ),
              const Icon(
                Icons.arrow_drop_down,
                color: Color(0xFFE53935),
                size: 20,
              ),
            ],
          ),
        ),
      );
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(25),
      child: Stack(
        children: [
          FlutterMap(
            mapController: mapController,
            options: MapOptions(
              initialCenter:
                  currentLocation ??
                  const LatLng(
                    36.7372,
                    3.0863,
                  ),
              initialZoom: 13.5,
              minZoom: 5,
              maxZoom: 19,
              onTap: (tapPosition, point) {
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

              MarkerLayer(
                markers: markers,
              ),

              const RichAttributionWidget(
                attributions: [
                  TextSourceAttribution(
                    'OpenStreetMap contributors',
                  ),
                ],
              ),
            ],
          ),

          // زر موقعي
          if (widget.showCurrentLocationButton)
            Positioned(
              right: 14,
              bottom: 18,
              child: Material(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                elevation: 5,
                child: InkWell(
                  borderRadius:
                      BorderRadius.circular(16),
                  onTap: () async {
                    await getCurrentLocation();

                    if (currentLocation != null) {
                      widget.onMapTap(
                        currentLocation!,
                      );
                    }
                  },
                  child: Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      borderRadius:
                          BorderRadius.circular(16),
                    ),
                    child: loadingLocation
                        ? const Padding(
                            padding: EdgeInsets.all(14),
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Icon(
                            Icons.my_location_rounded,
                            color: Color(0xFF1976D2),
                            size: 27,
                          ),
                  ),
                ),
              ),
            ),

          // أزرار التكبير
          Positioned(
            left: 14,
            bottom: 18,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// زر التحكم بالخريطة
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
      borderRadius: BorderRadius.circular(14),
      elevation: 5,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: SizedBox(
          width: 48,
          height: 48,
          child: Icon(
            icon,
            color: const Color(0xFF172033),
          ),
        ),
      ),
    );
  }
}

// =====================================================
// ألو وصلني
// =====================================================

class WaselniPage extends StatefulWidget {
  const WaselniPage({super.key});

  @override
  State<WaselniPage> createState() => _WaselniPageState();
}

class _WaselniPageState extends State<WaselniPage> {
  LatLng? pickup;
  LatLng? destination;

  bool selectingPickup = true;
  bool sending = false;

  String vehicle = 'car';

  final phoneController = TextEditingController();

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  void selectLocation(LatLng point) {
    setState(() {
      if (selectingPickup) {
        pickup = point;
        selectingPickup = false;
      } else {
        destination = point;
      }
    });
  }

  Future<void> sendRequest() async {
    if (pickup == null) {
      showMessage(
        'حدد مكان الانطلاق من الخريطة',
      );
      return;
    }

    if (destination == null) {
      showMessage(
        'حدد الوجهة من الخريطة',
      );
      return;
    }

    if (phoneController.text.trim().isEmpty) {
      showMessage(
        'أدخل رقم الهاتف',
      );
      return;
    }

    setState(() {
      sending = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('requests')
          .add({
        'service': 'alo_waselni',
        'vehicleType': vehicle,
        'pickupLat': pickup!.latitude,
        'pickupLng': pickup!.longitude,
        'destinationLat':
            destination!.latitude,
        'destinationLng':
            destination!.longitude,
        'phone':
            phoneController.text.trim(),
        'status': 'pending',
        'createdAt':
            FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      showMessage(
        'تم إرسال الطلب بنجاح ✅',
      );

      setState(() {
        pickup = null;
        destination = null;
        selectingPickup = true;
      });

      phoneController.clear();
    } catch (e) {
      showMessage(
        'تعذر إرسال الطلب. تأكد من إعداد Firebase.',
      );
    }

    if (mounted) {
      setState(() {
        sending = false;
      });
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
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
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF172033),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(
              15,
              8,
              15,
              10,
            ),
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
              vertical: 12,
            ),
            decoration: BoxDecoration(
              color: const Color(0xFFEAF3FF),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.touch_app_rounded,
                  color: Color(0xFF1976D2),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    selectingPickup
                        ? 'اضغط على الخريطة لتحديد مكان الانطلاق'
                        : destination == null
                            ? 'اضغط على الخريطة لتحديد الوجهة'
                            : 'تم تحديد الانطلاق والوجهة ✅',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: 15,
            ),
            child: SizedBox(
              height: 330,
              child: LocationMap(
                pickup: pickup,
                destination: destination,
                onMapTap: selectLocation,
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  const SizedBox(height: 5),

                  Row(
                    children: [
                      Expanded(
                        child: VehicleButton(
                          title: '🚗 سيارة',
                          selected:
                              vehicle == 'car',
                          color:
                              const Color(0xFF1976D2),
                          onTap: () {
                            setState(() {
                              vehicle = 'car';
                            });
                          },
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: VehicleButton(
                          title: '🏍️ دراجة',
                          selected:
                              vehicle ==
                                  'motorcycle',
                          color:
                              const Color(0xFFFF8A00),
                          onTap: () {
                            setState(() {
                              vehicle =
                                  'motorcycle';
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  ModernTextField(
                    controller: phoneController,
                    label: 'رقم الهاتف',
                    icon: Icons.phone_rounded,
                    keyboardType:
                        TextInputType.phone,
                  ),

                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed:
                          sending
                              ? null
                              : sendRequest,
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(0xFF1976D2),
                        foregroundColor:
                            Colors.white,
                        elevation: 2,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            18,
                          ),
                        ),
                      ),
                      child: Text(
                        sending
                            ? 'جاري إرسال الطلب...'
                            : 'اطلب التوصيلة 🚗',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// زر السيارة والدراجة
// =====================================================

class VehicleButton extends StatelessWidget {
  final String title;
  final bool selected;
  final Color color;
  final VoidCallback onTap;

  const VehicleButton({
    super.key,
    required this.title,
    required this.selected,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 54,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              selected
                  ? color
                  : Colors.white,
          foregroundColor:
              selected
                  ? Colors.white
                  : const Color(0xFF172033),
          elevation: selected ? 2 : 0,
          side: BorderSide(
            color:
                selected
                    ? color
                    : Colors.grey.shade300,
          ),
          shape:
              RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(16),
          ),
        ),
        child: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// =====================================================
// حقل عصري
// =====================================================

class ModernTextField extends StatelessWidget {
  final TextEditingController controller;
  final String label;
  final IconData icon;
  final TextInputType? keyboardType;

  const ModernTextField({
    super.key,
    required this.controller,
    required this.label,
    required this.icon,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: keyboardType,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
        filled: true,
        fillColor: Colors.white,
        border: OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(17),
          borderSide: BorderSide.none,
        ),
        enabledBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(17),
          borderSide: BorderSide(
            color: Colors.grey.shade200,
          ),
        ),
        focusedBorder:
            OutlineInputBorder(
          borderRadius:
              BorderRadius.circular(17),
          borderSide: const BorderSide(
            color: Color(0xFF1976D2),
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

// =====================================================
// ألو جيبلي
// =====================================================

class JibliPage extends StatefulWidget {
  const JibliPage({super.key});

  @override
  State<JibliPage> createState() => _JibliPageState();
}

class _JibliPageState extends State<JibliPage> {
  LatLng? pickup;
  LatLng? destination;

  bool selectingPickup = true;
  bool sending = false;

  final itemController =
      TextEditingController();

  final phoneController =
      TextEditingController();

  @override
  void dispose() {
    itemController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  void selectLocation(LatLng point) {
    setState(() {
      if (selectingPickup) {
        pickup = point;
        selectingPickup = false;
      } else {
        destination = point;
      }
    });
  }

  Future<void> sendRequest() async {
    if (itemController.text.trim().isEmpty) {
      showMessage(
        'اكتب واش حاب يجيبلك',
      );
      return;
    }

    if (pickup == null) {
      showMessage(
        'حدد مكان الجلب',
      );
      return;
    }

    if (destination == null) {
      showMessage(
        'حدد مكان التسليم',
      );
      return;
    }

    if (phoneController.text.trim().isEmpty) {
      showMessage(
        'أدخل رقم الهاتف',
      );
      return;
    }

    setState(() {
      sending = true;
    });

    try {
      await FirebaseFirestore.instance
          .collection('requests')
          .add({
        'service': 'alo_jibli',
        'item':
            itemController.text.trim(),
        'pickupLat':
            pickup!.latitude,
        'pickupLng':
            pickup!.longitude,
        'destinationLat':
            destination!.latitude,
        'destinationLng':
            destination!.longitude,
        'phone':
            phoneController.text.trim(),
        'status': 'pending',
        'createdAt':
            FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      showMessage(
        'تم إرسال طلب ألو جيبلي بنجاح ✅',
      );

      setState(() {
        pickup = null;
        destination = null;
        selectingPickup = true;
      });

      itemController.clear();
      phoneController.clear();
    } catch (e) {
      showMessage(
        'تعذر إرسال الطلب. تأكد من إعداد Firebase.',
      );
    }

    if (mounted) {
      setState(() {
        sending = false;
      });
    }
  }

  void showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'ألو جيبلي',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF172033),
        elevation: 0,
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.fromLTRB(
              15,
              8,
              15,
              10,
            ),
            padding: const EdgeInsets.all(13),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF3E2),
              borderRadius:
                  BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.location_on_rounded,
                  color: Color(0xFFFF8A00),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    selectingPickup
                        ? 'حدد مكان الجلب من الخريطة'
                        : destination == null
                            ? 'حدد مكان التسليم'
                            : 'تم تحديد المكانين ✅',
                    style: const TextStyle(
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding:
                const EdgeInsets.symmetric(
              horizontal: 15,
            ),
            child: SizedBox(
              height: 300,
              child: LocationMap(
                pickup: pickup,
                destination: destination,
                onMapTap: selectLocation,
              ),
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  ModernTextField(
                    controller:
                        itemController,
                    label:
                        'وش حاب يجيبلك؟',
                    icon:
                        Icons.shopping_bag_rounded,
                  ),

                  const SizedBox(height: 12),

                  ModernTextField(
                    controller:
                        phoneController,
                    label:
                        'رقم الهاتف',
                    icon:
                        Icons.phone_rounded,
                    keyboardType:
                        TextInputType.phone,
                  ),

                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    height: 58,
                    child: ElevatedButton(
                      onPressed:
                          sending
                              ? null
                              : sendRequest,
                      style:
                          ElevatedButton.styleFrom(
                        backgroundColor:
                            const Color(
                          0xFFFF8A00,
                        ),
                        foregroundColor:
                            Colors.white,
                        elevation: 2,
                        shape:
                            RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(
                            18,
                          ),
                        ),
                      ),
                      child: Text(
                        sending
                            ? 'جاري إرسال الطلب...'
                            : 'اطلب ألو جيبلي 📦',
                        style:
                            const TextStyle(
                          fontSize: 18,
                          fontWeight:
                              FontWeight.w900,
                        ),
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// =====================================================
// صفحة السائق
// =====================================================

class DriverPage extends StatelessWidget {
  final String vehicleType;
  final String title;

  const DriverPage({
    super.key,
    required this.vehicleType,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    final color =
        vehicleType == 'car'
            ? const Color(0xFF159447)
            : const Color(0xFFFF8A00);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.white,
        foregroundColor: const Color(0xFF172033),
        elevation: 0,
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .where(
              'status',
              isEqualTo: 'pending',
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
            return const Center(
              child: Text(
                'تعذر تحميل الطلبات',
                style: TextStyle(
                  fontSize: 18,
                ),
              ),
            );
          }

          final documents =
              snapshot.data?.docs ?? [];

          final requests =
              documents.where((doc) {
            final data =
                doc.data()
                    as Map<String, dynamic>;

            if (data['service'] ==
                'alo_jibli') {
              return true;
            }

            return data['vehicleType'] ==
                    vehicleType ||
                data['vehicleType'] ==
                    'any';
          }).toList();

          if (requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment:
                    MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.inbox_rounded,
                    size: 70,
                    color:
                        Colors.grey.shade300,
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'ما كاش طلبات حاليا 📭',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding:
                const EdgeInsets.all(15),
            itemCount:
                requests.length,
            itemBuilder:
                (context, index) {
              final doc =
                  requests[index];

              final data =
                  doc.data()
                      as Map<String, dynamic>;

              return DriverRequestCard(
                documentId: doc.id,
                data: data,
                color: color,
              );
            },
          );
        },
      ),
    );
  }
}

// =====================================================
// بطاقة طلب السائق
// =====================================================

class DriverRequestCard
    extends StatelessWidget {
  final String documentId;
  final Map<String, dynamic> data;
  final Color color;

  const DriverRequestCard({
    super.key,
    required this.documentId,
    required this.data,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final service =
        data['service'] ?? '';

    final isJibli =
        service == 'alo_jibli';

    final pickupLat =
        (data['pickupLat'] as num?)
            ?.toDouble();

    final pickupLng =
        (data['pickupLng'] as num?)
            ?.toDouble();

    final destinationLat =
        (data['destinationLat']
                as num?)
            ?.toDouble();

    final destinationLng =
        (data['destinationLng']
                as num?)
            ?.toDouble();

    return Card(
      margin:
          const EdgeInsets.only(
        bottom: 15,
      ),
      elevation: 2,
      color: Colors.white,
      shape:
          RoundedRectangleBorder(
        borderRadius:
            BorderRadius.circular(22),
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
                Container(
                  width: 48,
                  height: 48,
                  decoration:
                      BoxDecoration(
                    color:
                        color.withOpacity(
                      .10,
                    ),
                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),
                  ),
                  child: Icon(
                    isJibli
                        ? Icons
                            .shopping_bag_rounded
                        : Icons
                            .directions_car_rounded,
                    color: color,
                  ),
                ),

                const SizedBox(width: 12),

                Text(
                  isJibli
                      ? 'ألو جيبلي'
                      : 'ألو وصلني',
                  style:
                      const TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.w900,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 12),

            if (isJibli)
              Container(
                width:
                    double.infinity,
                padding:
                    const EdgeInsets.all(12),
                decoration:
                    BoxDecoration(
                  color:
                      Colors.orange.shade50,
                  borderRadius:
                      BorderRadius.circular(
                    14,
                  ),
                ),
                child: Text(
                  '🛍️ المطلوب: ${data['item'] ?? ''}',
                  style:
                      const TextStyle(
                    fontSize: 16,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),

            const SizedBox(height: 8),

            Text(
              '📞 ${data['phone'] ?? ''}',
              style:
                  const TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 12),

            if (pickupLat != null &&
                pickupLng != null &&
                destinationLat !=
                    null &&
                destinationLng !=
                    null)
              ClipRRect(
                borderRadius:
                    BorderRadius.circular(
                  18,
                ),
                child: SizedBox(
                  height: 190,
                  child: FlutterMap(
                    options:
                        MapOptions(
                      initialCenter:
                          LatLng(
                        pickupLat,
                        pickupLng,
                      ),
                      initialZoom: 13,
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
                            point: LatLng(
                              pickupLat,
                              pickupLng,
                            ),
                            width: 50,
                            height: 60,
                            child:
                                const Icon(
                              Icons
                                  .location_on_rounded,
                              color:
                                  Colors.green,
                              size: 45,
                            ),
                          ),
                          Marker(
                            point: LatLng(
                              destinationLat,
                              destinationLng,
                            ),
                            width: 50,
                            height: 60,
                            child:
                                const Icon(
                              Icons
                                  .flag_rounded,
                              color:
                                  Colors.red,
                              size: 43,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),

            const SizedBox(height: 13),

            SizedBox(
              width:
                  double.infinity,
              height: 54,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await FirebaseFirestore
                        .instance
                        .collection(
                          'requests',
                        )
                        .doc(documentId)
                        .update({
                      'status':
                          'accepted',
                      'acceptedAt':
                          FieldValue
                              .serverTimestamp(),
                    });

                    if (context
                        .mounted) {
                      ScaffoldMessenger
                          .of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            'تم قبول الطلب ✅',
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context
                        .mounted) {
                      ScaffoldMessenger
                          .of(context)
                          .showSnackBar(
                        const SnackBar(
                          content: Text(
                            'تعذر قبول الطلب',
                          ),
                        ),
                      );
                    }
                  }
                },
                style:
                    ElevatedButton.styleFrom(
                  backgroundColor:
                      color,
                  foregroundColor:
                      Colors.white,
                  shape:
                      RoundedRectangleBorder(
                    borderRadius:
                        BorderRadius.circular(
                      16,
                    ),
                  ),
                ),
                child: const Text(
                  'قبول الطلب',
                  style: TextStyle(
                    fontSize: 17,
                    fontWeight:
                        FontWeight.w900,
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
