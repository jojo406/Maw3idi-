import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

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
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
        ),
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
      backgroundColor: Colors.grey.shade100,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(22),
          child: Column(
            children: [
              const SizedBox(height: 30),

              Container(
                width: 105,
                height: 105,
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(30),
                ),
                child: const Icon(
                  Icons.local_shipping_rounded,
                  color: Colors.white,
                  size: 58,
                ),
              ),

              const SizedBox(height: 18),

              const Text(
                'ألو وصلني',
                style: TextStyle(
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),

              const SizedBox(height: 8),

              Text(
                'خدمات النقل والتوصيل داخل البلدية',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey.shade600,
                ),
              ),

              const SizedBox(height: 40),

              RoleButton(
                icon: Icons.person,
                title: 'أنا الزبون',
                color: Colors.blue,
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
                icon: Icons.directions_car,
                title: 'أنا السائق',
                color: Colors.green,
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
                icon: Icons.two_wheeler,
                title: 'أنا سائق الدراجة',
                color: Colors.orange,
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
  final Color color;
  final VoidCallback onTap;

  const RoleButton({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 72,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 31),
        label: Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 3,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
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
        title: const Text('أنا الزبون'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey.shade100,
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            const SizedBox(height: 25),

            ServiceButton(
              icon: Icons.directions_car,
              title: 'ألو وصلني',
              color: Colors.blue,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => const WaselniPage(),
                  ),
                );
              },
            ),

            const SizedBox(height: 20),

            ServiceButton(
              icon: Icons.shopping_bag,
              title: 'ألو جيبلي',
              color: Colors.orange,
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
  final Color color;
  final VoidCallback onTap;

  const ServiceButton({
    super.key,
    required this.icon,
    required this.title,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 90,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 40),
        label: Text(
          title,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
      ),
    );
  }
}

// =====================================================
// الخريطة
// =====================================================

class LocationMap extends StatelessWidget {
  final LatLng? pickup;
  final LatLng? destination;
  final Function(LatLng) onMapTap;

  const LocationMap({
    super.key,
    required this.pickup,
    required this.destination,
    required this.onMapTap,
  });

  @override
  Widget build(BuildContext context) {
    final markers = <Marker>[];

    if (pickup != null) {
      markers.add(
        Marker(
          point: pickup!,
          width: 50,
          height: 50,
          child: const Icon(
            Icons.location_on,
            color: Colors.green,
            size: 48,
          ),
        ),
      );
    }

    if (destination != null) {
      markers.add(
        Marker(
          point: destination!,
          width: 50,
          height: 50,
          child: const Icon(
            Icons.location_on,
            color: Colors.red,
            size: 48,
          ),
        ),
      );
    }

    return FlutterMap(
      options: MapOptions(
        initialCenter: const LatLng(
          36.7372,
          3.0863,
        ),
        initialZoom: 13,
        onTap: (tapPosition, point) {
          onMapTap(point);
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
      showMessage('حدد مكان الانطلاق من الخريطة');
      return;
    }

    if (destination == null) {
      showMessage('حدد الوجهة من الخريطة');
      return;
    }

    if (phoneController.text.trim().isEmpty) {
      showMessage('أدخل رقم الهاتف');
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

        'destinationLat': destination!.latitude,
        'destinationLng': destination!.longitude,

        'phone': phoneController.text.trim(),

        'status': 'pending',

        'createdAt':
            FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      showMessage('تم إرسال الطلب بنجاح ✅');

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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ألو وصلني'),
        centerTitle: true,
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.blue.shade50,
            child: Text(
              selectingPickup
                  ? '📍 اضغط على الخريطة لتحديد مكان الانطلاق'
                  : destination == null
                      ? '📍 اضغط على الخريطة لتحديد الوجهة'
                      : '✅ تم تحديد المكانين',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ),

          SizedBox(
            height: 330,
            child: LocationMap(
              pickup: pickup,
              destination: destination,
              onMapTap: selectLocation,
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: VehicleButton(
                          title: '🚗 سيارة',
                          selected: vehicle == 'car',
                          color: Colors.blue,
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
                              vehicle == 'motorcycle',
                          color: Colors.orange,
                          onTap: () {
                            setState(() {
                              vehicle = 'motorcycle';
                            });
                          },
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: phoneController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'رقم الهاتف',
                      prefixIcon:
                          const Icon(Icons.phone),
                      filled: true,
                      fillColor:
                          Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed:
                          sending ? null : sendRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        foregroundColor: Colors.white,
                      ),
                      child: Text(
                        sending
                            ? 'جاري الإرسال...'
                            : 'طلب التوصيلة',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
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
// زر السيارة / الدراجة
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
      height: 50,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor:
              selected ? color : Colors.grey.shade300,
          foregroundColor:
              selected ? Colors.white : Colors.black87,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
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

  final itemController = TextEditingController();
  final phoneController = TextEditingController();

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
      showMessage('اكتب واش حاب يجيبلك');
      return;
    }

    if (pickup == null) {
      showMessage('حدد مكان الجلب');
      return;
    }

    if (destination == null) {
      showMessage('حدد مكان التسليم');
      return;
    }

    if (phoneController.text.trim().isEmpty) {
      showMessage('أدخل رقم الهاتف');
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

        'item': itemController.text.trim(),

        'pickupLat': pickup!.latitude,
        'pickupLng': pickup!.longitude,

        'destinationLat':
            destination!.latitude,
        'destinationLng':
            destination!.longitude,

        'phone': phoneController.text.trim(),

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
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('ألو جيبلي'),
        centerTitle: true,
        backgroundColor: Colors.orange,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            color: Colors.orange.shade50,
            child: Text(
              selectingPickup
                  ? '📍 حدد مكان الجلب'
                  : destination == null
                      ? '📍 حدد مكان التسليم'
                      : '✅ تم تحديد المكانين',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),

          SizedBox(
            height: 300,
            child: LocationMap(
              pickup: pickup,
              destination: destination,
              onMapTap: selectLocation,
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(15),
              child: Column(
                children: [
                  TextField(
                    controller: itemController,
                    decoration: InputDecoration(
                      labelText: 'وش حاب يجيبلك؟',
                      prefixIcon: const Icon(
                        Icons.shopping_bag,
                      ),
                      filled: true,
                      fillColor:
                          Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: phoneController,
                    keyboardType:
                        TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: 'رقم الهاتف',
                      prefixIcon:
                          const Icon(Icons.phone),
                      filled: true,
                      fillColor:
                          Colors.grey.shade100,
                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),

                  const SizedBox(height: 12),

                  SizedBox(
                    width: double.infinity,
                    height: 55,
                    child: ElevatedButton(
                      onPressed:
                          sending ? null : sendRequest,
                      style: ElevatedButton.styleFrom(
                        backgroundColor:
                            Colors.orange,
                        foregroundColor:
                            Colors.white,
                      ),
                      child: Text(
                        sending
                            ? 'جاري الإرسال...'
                            : 'طلب ألو جيبلي',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
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
    final color = vehicleType == 'car'
        ? Colors.green
        : Colors.orange;

    return Scaffold(
      appBar: AppBar(
        title: Text(title),
        centerTitle: true,
        backgroundColor: color,
        foregroundColor: Colors.white,
      ),
      backgroundColor: Colors.grey.shade100,
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('requests')
            .where(
              'status',
              isEqualTo: 'pending',
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
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'تعذر تحميل الطلبات',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 18,
                  ),
                ),
              ),
            );
          }

          final documents =
              snapshot.data?.docs ?? [];

          final requests = documents.where((doc) {
            final data =
                doc.data() as Map<String, dynamic>;

            if (data['service'] ==
                'alo_jibli') {
              return true;
            }

            return data['vehicleType'] ==
                    vehicleType ||
                data['vehicleType'] == 'any';
          }).toList();

          if (requests.isEmpty) {
            return const Center(
              child: Text(
                'ما كاش طلبات حاليا 📭',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.bold,
                ),
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(15),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final doc = requests[index];

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
// بطاقة الطلب للسائق
// =====================================================

class DriverRequestCard extends StatelessWidget {
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
        (data['pickupLat'] as num?)?.toDouble();

    final pickupLng =
        (data['pickupLng'] as num?)?.toDouble();

    final destinationLat =
        (data['destinationLat'] as num?)
            ?.toDouble();

    final destinationLng =
        (data['destinationLng'] as num?)
            ?.toDouble();

    return Card(
      margin: const EdgeInsets.only(
        bottom: 15,
      ),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Text(
              isJibli
                  ? '📦 ألو جيبلي'
                  : '🚗 ألو وصلني',
              style: const TextStyle(
                fontSize: 21,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            if (isJibli)
              Text(
                '🛍️ المطلوب: ${data['item'] ?? ''}',
                style: const TextStyle(
                  fontSize: 16,
                ),
              ),

            const SizedBox(height: 5),

            Text(
              '📞 ${data['phone'] ?? ''}',
              style: const TextStyle(
                fontSize: 16,
              ),
            ),

            const SizedBox(height: 12),

            if (pickupLat != null &&
                pickupLng != null &&
                destinationLat != null &&
                destinationLng != null)
              SizedBox(
                height: 180,
                child: FlutterMap(
                  options: MapOptions(
                    initialCenter: LatLng(
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
                          height: 50,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.green,
                            size: 45,
                          ),
                        ),
                        Marker(
                          point: LatLng(
                            destinationLat,
                            destinationLng,
                          ),
                          width: 50,
                          height: 50,
                          child: const Icon(
                            Icons.location_on,
                            color: Colors.red,
                            size: 45,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 12),

            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: () async {
                  try {
                    await FirebaseFirestore
                        .instance
                        .collection('requests')
                        .doc(documentId)
                        .update({
                      'status': 'accepted',
                      'acceptedAt':
                          FieldValue
                              .serverTimestamp(),
                    });

                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'تم قبول الطلب ✅',
                          ),
                        ),
                      );
                    }
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(
                        context,
                      ).showSnackBar(
                        const SnackBar(
                          content: Text(
                            'تعذر قبول الطلب',
                          ),
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: color,
                  foregroundColor: Colors.white,
                ),
                child: const Text(
                  'قبول الطلب',
                  style: TextStyle(
                    fontSize: 17,
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
