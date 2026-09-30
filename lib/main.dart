import 'package:flutter/material.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const AlloWasselniApp());
}

// ============================================================
// APP
// ============================================================

class AlloWasselniApp extends StatefulWidget {
  const AlloWasselniApp({super.key});

  @override
  State<AlloWasselniApp> createState() => _AlloWasselniAppState();
}

class _AlloWasselniAppState extends State<AlloWasselniApp> {
  bool darkMode = false;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ألو وصلني',
      themeMode: darkMode ? ThemeMode.dark : ThemeMode.light,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF16A34A),
        ),
        scaffoldBackgroundColor: const Color(0xFFF5F7FA),
      ),
      darkTheme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF16A34A),
          brightness: Brightness.dark,
        ),
      ),
      home: SplashScreen(
        onThemeChanged: (value) {
          setState(() {
            darkMode = value;
          });
        },
        darkMode: darkMode,
      ),
    );
  }
}

// ============================================================
// COLORS
// ============================================================

const primaryGreen = Color(0xFF16A34A);
const darkGreen = Color(0xFF15803D);
const lightGreen = Color(0xFFDCFCE7);

// ============================================================
// SPLASH
// ============================================================

class SplashScreen extends StatefulWidget {
  final bool darkMode;
  final ValueChanged<bool> onThemeChanged;

  const SplashScreen({
    super.key,
    required this.darkMode,
    required this.onThemeChanged,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();

    Future.delayed(const Duration(seconds: 2), () {
      if (!mounted) return;

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => RoleScreen(
            darkMode: widget.darkMode,
            onThemeChanged: widget.onThemeChanged,
          ),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              radius: 55,
              backgroundColor: lightGreen,
              child: Icon(
                Icons.local_taxi_rounded,
                size: 65,
                color: darkGreen,
              ),
            ),
            SizedBox(height: 25),
            Text(
              'ألو وصلني',
              style: TextStyle(
                fontSize: 36,
                fontWeight: FontWeight.bold,
                color: darkGreen,
              ),
            ),
            SizedBox(height: 8),
            Text(
              'وصلتك قريبة... بضغطة واحدة',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ROLE SCREEN
// ============================================================

class RoleScreen extends StatelessWidget {
  final bool darkMode;
  final ValueChanged<bool> onThemeChanged;

  const RoleScreen({
    super.key,
    required this.darkMode,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'ألو وصلني',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          centerTitle: true,
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                const SizedBox(height: 35),

                const CircleAvatar(
                  radius: 45,
                  backgroundColor: lightGreen,
                  child: Icon(
                    Icons.local_taxi_rounded,
                    size: 50,
                    color: darkGreen,
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  'مرحبا بك 👋',
                  style: TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'كيفاش تحب تستعمل ألو وصلني؟',
                  style: TextStyle(
                    fontSize: 17,
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 45),

                RoleCard(
                  icon: Icons.person_rounded,
                  title: 'أنا راكب',
                  subtitle: 'نحب نطلب توصيلة',
                  color: primaryGreen,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LoginScreen(
                          role: UserRole.passenger,
                          darkMode: darkMode,
                          onThemeChanged: onThemeChanged,
                        ),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 18),

                RoleCard(
                  icon: Icons.directions_car_rounded,
                  title: 'أنا سائق',
                  subtitle: 'نحب نستقبل طلبات التوصيل',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => LoginScreen(
                          role: UserRole.driver,
                          darkMode: darkMode,
                          onThemeChanged: onThemeChanged,
                        ),
                      ),
                    );
                  },
                ),

                const Spacer(),

                Text(
                  'الخدمة متوفرة داخل البلدية',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 13,
                  ),
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
// ROLE CARD
// ============================================================

class RoleCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const RoleCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: color.withOpacity(.15),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.05),
              blurRadius: 15,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 65,
              height: 65,
              decoration: BoxDecoration(
                color: color.withOpacity(.12),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Icon(
                icon,
                color: color,
                size: 34,
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
                      fontSize: 21,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.grey.shade600,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.arrow_back_ios_rounded,
              size: 19,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// USER ROLE
// ============================================================

enum UserRole {
  passenger,
  driver,
}

// ============================================================
// LOGIN
// ============================================================

class LoginScreen extends StatefulWidget {
  final UserRole role;
  final bool darkMode;
  final ValueChanged<bool> onThemeChanged;

  const LoginScreen({
    super.key,
    required this.role,
    required this.darkMode,
    required this.onThemeChanged,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final nameController = TextEditingController();
  final phoneController = TextEditingController();

  bool loading = false;

  bool get isDriver => widget.role == UserRole.driver;

  @override
  void dispose() {
    nameController.dispose();
    phoneController.dispose();
    super.dispose();
  }

  Future<void> continueApp() async {
    if (nameController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('دخل اسمك من فضلك'),
        ),
      );
      return;
    }

    if (phoneController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('دخل رقم الهاتف'),
        ),
      );
      return;
    }

    setState(() {
      loading = true;
    });

    await Future.delayed(const Duration(milliseconds: 700));

    if (!mounted) return;

    setState(() {
      loading = false;
    });

    if (isDriver) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => DriverHomeScreen(
            name: nameController.text.trim(),
            phone: phoneController.text.trim(),
            darkMode: widget.darkMode,
            onThemeChanged: widget.onThemeChanged,
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => PassengerHomeScreen(
            name: nameController.text.trim(),
            phone: phoneController.text.trim(),
            darkMode: widget.darkMode,
            onThemeChanged: widget.onThemeChanged,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            isDriver ? 'دخول السائق' : 'دخول الراكب',
          ),
        ),
        body: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 30),

            CircleAvatar(
              radius: 42,
              backgroundColor: isDriver
                  ? Colors.blue.withOpacity(.12)
                  : lightGreen,
              child: Icon(
                isDriver
                    ? Icons.directions_car_rounded
                    : Icons.person_rounded,
                size: 45,
                color: isDriver ? Colors.blue : darkGreen,
              ),
            ),

            const SizedBox(height: 25),

            Text(
              isDriver
                  ? 'مرحبا بالسائق 🚕'
                  : 'مرحبا بك 👋',
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 8),

            Text(
              'دخل معلوماتك باش نكملو',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),

            const SizedBox(height: 35),

            TextField(
              controller: nameController,
              textDirection: TextDirection.rtl,
              decoration: InputDecoration(
                labelText: 'الاسم',
                prefixIcon: const Icon(
                  Icons.person_outline_rounded,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            const SizedBox(height: 15),

            TextField(
              controller: phoneController,
              keyboardType: TextInputType.phone,
              decoration: InputDecoration(
                labelText: 'رقم الهاتف',
                prefixIcon: const Icon(
                  Icons.phone_rounded,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),

            const SizedBox(height: 25),

            SizedBox(
              height: 55,
              child: FilledButton(
                onPressed: loading ? null : continueApp,
                child: loading
                    ? const SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(
                          color: Colors.white,
                        ),
                      )
                    : const Text(
                        'متابعة',
                        style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
              ),
            ),

            const SizedBox(height: 20),

            Text(
              'في النسخة النهائية راح يكون الدخول مربوط برقم الهاتف وFirebase.',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// PASSENGER HOME
// ============================================================

class PassengerHomeScreen extends StatefulWidget {
  final String name;
  final String phone;
  final bool darkMode;
  final ValueChanged<bool> onThemeChanged;

  const PassengerHomeScreen({
    super.key,
    required this.name,
    required this.phone,
    required this.darkMode,
    required this.onThemeChanged,
  });

  @override
  State<PassengerHomeScreen> createState() =>
      _PassengerHomeScreenState();
}

class _PassengerHomeScreenState extends State<PassengerHomeScreen> {
  int currentIndex = 0;

  String pickup = '';
  String destination = '';

  bool searching = false;
  bool rideActive = false;

  @override
  Widget build(BuildContext context) {
    final pages = [
      _buildHome(),
      _buildRides(),
      _buildAccount(),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: pages[currentIndex],
        bottomNavigationBar: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'الرئيسية',
            ),
            NavigationDestination(
              icon: Icon(Icons.history_outlined),
              selectedIcon: Icon(Icons.history_rounded),
              label: 'رحلاتي',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'حسابي',
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHome() {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: lightGreen,
                child: Text(
                  widget.name.isNotEmpty
                      ? widget.name[0].toUpperCase()
                      : 'م',
                  style: const TextStyle(
                    color: darkGreen,
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مرحبا ${widget.name} 👋',
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      'وين رايح اليوم؟',
                      style: TextStyle(
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: _showNotifications,
                icon: const Icon(
                  Icons.notifications_none_rounded,
                ),
              ),
            ],
          ),

          const SizedBox(height: 18),

          Container(
            height: 230,
            decoration: BoxDecoration(
              color: Colors.grey.shade300,
              borderRadius: BorderRadius.circular(25),
            ),
            child: Stack(
              children: [
                const Center(
                  child: Icon(
                    Icons.map_rounded,
                    size: 70,
                    color: Colors.grey,
                  ),
                ),
                Positioned(
                  top: 15,
                  right: 15,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 7,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      children: [
                        Icon(
                          Icons.location_on_rounded,
                          color: primaryGreen,
                          size: 18,
                        ),
                        SizedBox(width: 5),
                        Text('داخل البلدية'),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 15),

          const Text(
            'اطلب توصيلة',
            style: TextStyle(
              fontSize: 21,
              fontWeight: FontWeight.bold,
            ),
          ),

          const SizedBox(height: 10),

          _locationField(
            icon: Icons.my_location_rounded,
            title: 'نقطة الانطلاق',
            value: pickup,
            color: Colors.blue,
            onTap: () => _chooseLocation(true),
          ),

          const SizedBox(height: 10),

          _locationField(
            icon: Icons.location_on_rounded,
            title: 'إلى أين؟',
            value: destination,
            color: Colors.red,
            onTap: () => _chooseLocation(false),
          ),

          const SizedBox(height: 15),

          SizedBox(
            height: 56,
            child: FilledButton.icon(
              onPressed: pickup.isEmpty || destination.isEmpty
                  ? null
                  : _requestRide,
              icon: const Icon(
                Icons.local_taxi_rounded,
              ),
              label: const Text(
                'اطلب توصيلة',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          if (searching) ...[
            const SizedBox(height: 18),
            _searchingCard(),
          ],

          if (rideActive) ...[
            const SizedBox(height: 18),
            _activeRideCard(),
          ],
        ],
      ),
    );
  }

  Widget _locationField({
    required IconData icon,
    required String title,
    required String value,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(17),
      child: Container(
        padding: const EdgeInsets.all(15),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(17),
          border: Border.all(
            color: Colors.grey.withOpacity(.15),
          ),
        ),
        child: Row(
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(.1),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    value.isEmpty ? 'اضغط لاختيار المكان' : value,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: value.isEmpty
                          ? Colors.grey
                          : null,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(
              Icons.chevron_left_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget _searchingCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 15),
            const Text(
              'نقلبولك على سائق قريب...',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              'استنى لحظات',
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
            const SizedBox(height: 15),
            OutlinedButton(
              onPressed: () {
                setState(() {
                  searching = false;
                  pickup = '';
                  destination = '';
                });
              },
              child: const Text('إلغاء الطلب'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _activeRideCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const Row(
              children: [
                CircleAvatar(
                  backgroundColor: lightGreen,
                  child: Icon(
                    Icons.person,
                    color: darkGreen,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'محمد - سائق',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text('Renault Symbol • 123456'),
                    ],
                  ),
                ),
                Icon(
                  Icons.star_rounded,
                  color: Colors.amber,
                ),
                Text('4.9'),
              ],
            ),
            const SizedBox(height: 15),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: lightGreen,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.directions_car_rounded,
                    color: darkGreen,
                  ),
                  SizedBox(width: 10),
                  Text(
                    'السائق في الطريق إليك',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: darkGreen,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 12),
            OutlinedButton.icon(
              onPressed: _cancelRide,
              icon: const Icon(Icons.close_rounded),
              label: const Text('إلغاء الرحلة'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildRides() {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            'رحلاتي',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'سجل الرحلات الخاصة بك',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 25),
          if (!rideActive && !searching)
            const Center(
              child: Padding(
                padding: EdgeInsets.only(top: 80),
                child: Column(
                  children: [
                    Icon(
                      Icons.route_rounded,
                      size: 75,
                      color: Colors.grey,
                    ),
                    SizedBox(height: 15),
                    Text(
                      'ما عندكش رحلات حالياً',
                      style: TextStyle(
                        fontSize: 17,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            )
          else
            Card(
              child: ListTile(
                leading: const CircleAvatar(
                  backgroundColor: lightGreen,
                  child: Icon(
                    Icons.local_taxi_rounded,
                    color: darkGreen,
                  ),
                ),
                title: Text(
                  destination.isEmpty
                      ? 'رحلة جديدة'
                      : destination,
                ),
                subtitle: const Text(
                  'رحلة قيد التنفيذ',
                ),
                trailing: const Icon(
                  Icons.arrow_back_ios_rounded,
                  size: 16,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAccount() {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const SizedBox(height: 20),
          CircleAvatar(
            radius: 45,
            backgroundColor: lightGreen,
            child: Text(
              widget.name.isNotEmpty
                  ? widget.name[0].toUpperCase()
                  : 'م',
              style: const TextStyle(
                fontSize: 35,
                color: darkGreen,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            widget.phone,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 30),
          _accountTile(
            Icons.person_outline_rounded,
            'معلومات الحساب',
            () {},
          ),
          _accountTile(
            Icons.notifications_none_rounded,
            'الإشعارات',
            _showNotifications,
          ),
          _accountTile(
            Icons.dark_mode_outlined,
            'الوضع الليلي',
            () {
              _showThemeDialog();
            },
          ),
          _accountTile(
            Icons.help_outline_rounded,
            'المساعدة',
            _showHelp,
          ),
          _accountTile(
            Icons.security_rounded,
            'السلامة',
            _showSafety,
          ),
          _accountTile(
            Icons.logout_rounded,
            'تسجيل الخروج',
            () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => RoleScreen(
                    darkMode: widget.darkMode,
                    onThemeChanged:
                        widget.onThemeChanged,
                  ),
                ),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _accountTile(
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(
          Icons.chevron_left_rounded,
        ),
        onTap: onTap,
      ),
    );
  }

  void _chooseLocation(bool isPickup) {
    final controller = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28),
        ),
      ),
      builder: (context) {
        return Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context)
                    .viewInsets
                    .bottom +
                20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                isPickup
                    ? 'حدد نقطة الانطلاق'
                    : 'حدد الوجهة',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: controller,
                autofocus: true,
                textDirection: TextDirection.rtl,
                decoration: InputDecoration(
                  hintText: isPickup
                      ? 'مثال: البلدية'
                      : 'مثال: وسط المدينة',
                  prefixIcon: const Icon(
                    Icons.location_on_rounded,
                  ),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                height: 52,
                child: FilledButton(
                  onPressed: () {
                    if (controller.text.trim().isEmpty) {
                      return;
                    }

                    setState(() {
                      if (isPickup) {
                        pickup =
                            controller.text.trim();
                      } else {
                        destination =
                            controller.text.trim();
                      }
                    });

                    Navigator.pop(context);
                  },
                  child: const Text('تأكيد المكان'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _requestRide() {
    setState(() {
      searching = true;
    });

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted || !searching) return;

      setState(() {
        searching = false;
        rideActive = true;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'لقينا سائق قريب منك 🚕',
          ),
        ),
      );
    });
  }

  void _cancelRide() {
    setState(() {
      searching = false;
      rideActive = false;
      pickup = '';
      destination = '';
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('تم إلغاء الرحلة'),
      ),
    );
  }

  void _showNotifications() {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Text('الإشعارات'),
          content: Text(
            'ما عندك حتى إشعار جديد حالياً.',
          ),
        );
      },
    );
  }

  void _showThemeDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('المظهر'),
          content: SwitchListTile(
            title: const Text('الوضع الليلي'),
            value: widget.darkMode,
            onChanged: (value) {
              widget.onThemeChanged(value);
              Navigator.pop(context);
            },
          ),
        );
      },
    );
  }

  void _showHelp() {
    showDialog(
      context: context,
      builder: (context) {
        return const AlertDialog(
          title: Text('المساعدة'),
          content: Text(
            'إذا واجهتك مشكلة، راح نضيف مركز مساعدة ودعم مباشر في النسخة النهائية.',
          ),
        );
      },
    );
  }

  void _showSafety() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('السلامة'),
          content: const Text(
            'في النسخة النهائية راح نضيف زر SOS، مشاركة الرحلة، وجهة اتصال للطوارئ وميزات أمان إضافية.',
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
  }
}

// ============================================================
// DRIVER HOME
// ============================================================

class DriverHomeScreen extends StatefulWidget {
  final String name;
  final String phone;
  final bool darkMode;
  final ValueChanged<bool> onThemeChanged;

  const DriverHomeScreen({
    super.key,
    required this.name,
    required this.phone,
    required this.darkMode,
    required this.onThemeChanged,
  });

  @override
  State<DriverHomeScreen> createState() =>
      _DriverHomeScreenState();
}

class _DriverHomeScreenState extends State<DriverHomeScreen> {
  bool online = false;
  bool hasRequest = false;
  bool activeRide = false;

  int currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final pages = [
      _driverHome(),
      _driverEarnings(),
      _driverAccount(),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: pages[currentIndex],
        bottomNavigationBar: NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected: (index) {
            setState(() {
              currentIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(Icons.home_outlined),
              selectedIcon: Icon(Icons.home_rounded),
              label: 'الرئيسية',
            ),
            NavigationDestination(
              icon: Icon(Icons.payments_outlined),
              selectedIcon: Icon(Icons.payments_rounded),
              label: 'الأرباح',
            ),
            NavigationDestination(
              icon: Icon(Icons.person_outline_rounded),
              selectedIcon: Icon(Icons.person_rounded),
              label: 'حسابي',
            ),
          ],
        ),
      ),
    );
  }

  Widget _driverHome() {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const CircleAvatar(
                radius: 25,
                backgroundColor: Colors.blueAccent,
                child: Icon(
                  Icons.directions_car_rounded,
                  color: Colors.white,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment:
                      CrossAxisAlignment.start,
                  children: [
                    Text(
                      'مرحبا ${widget.name}',
                      style: const TextStyle(
                        fontSize: 19,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      online
                          ? 'أنت متصل وتستقبل الطلبات'
                          : 'أنت غير متصل',
                      style: TextStyle(
                        color: online
                            ? primaryGreen
                            : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  Color(0xFF2563EB),
                  Color(0xFF1D4ED8),
                ],
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: Column(
              children: [
                const Text(
                  'حالة السائق',
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  online ? 'متصل' : 'غير متصل',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 15),
                Switch.adaptive(
                  value: online,
                  activeColor: Colors.white,
                  onChanged: (value) {
                    setState(() {
                      online = value;
                    });

                    if (value) {
                      Future.delayed(
                        const Duration(seconds: 2),
                        () {
                          if (!mounted || !online) return;

                          setState(() {
                            hasRequest = true;
                          });
                        },
                      );
                    } else {
                      setState(() {
                        hasRequest = false;
                      });
                    }
                  },
                ),
                const Text(
                  'فعّل الحالة باش تستقبل طلبات',
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 20),

          if (hasRequest)
            _rideRequestCard()
          else if (activeRide)
            _activeDriverRide()
          else
            Card(
              child: Padding(
                padding: const EdgeInsets.all(25),
                child: Column(
                  children: [
                    Icon(
                      online
                          ? Icons.radar_rounded
                          : Icons.pause_circle_outline_rounded,
                      size: 65,
                      color: online
                          ? primaryGreen
                          : Colors.grey,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      online
                          ? 'نستناو في طلبات جديدة...'
                          : 'فعّل الاتصال باش تبدأ',
                      style: const TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.bold,
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

  Widget _rideRequestCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const Row(
              children: [
                CircleAvatar(
                  backgroundColor: lightGreen,
                  child: Icon(
                    Icons.person_rounded,
                    color: darkGreen,
                  ),
                ),
                SizedBox(width: 12),
                Expanded(
                  child: Text(
                    'طلب توصيلة جديد 🚕',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            _routeRow(
              Icons.my_location_rounded,
              'نقطة الانطلاق',
              'وسط البلدية',
              Colors.blue,
            ),
            _routeRow(
              Icons.location_on_rounded,
              'الوجهة',
              'حي النصر',
              Colors.red,
            ),
            const Divider(height: 25),
            const Row(
              children: [
                Icon(Icons.route_rounded),
                SizedBox(width: 8),
                Text('المسافة: 4.2 كم'),
                Spacer(),
                Text(
                  '250 دج',
                  style: TextStyle(
                    fontSize: 19,
                    fontWeight: FontWeight.bold,
                    color: primaryGreen,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        hasRequest = false;
                      });
                    },
                    child: const Text('رفض'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton(
                    onPressed: () {
                      setState(() {
                        hasRequest = false;
                        activeRide = true;
                      });
                    },
                    child: const Text('قبول الرحلة'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _activeDriverRide() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            const Icon(
              Icons.local_taxi_rounded,
              size: 60,
              color: primaryGreen,
            ),
            const SizedBox(height: 10),
            const Text(
              'رحلة نشطة',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 15),
            _routeRow(
              Icons.my_location_rounded,
              'الانطلاق',
              'وسط البلدية',
              Colors.blue,
            ),
            _routeRow(
              Icons.location_on_rounded,
              'الوجهة',
              'حي النصر',
              Colors.red,
            ),
            const SizedBox(height: 15),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: FilledButton(
                onPressed: () {
                  setState(() {
                    activeRide = false;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                        'تم إنهاء الرحلة بنجاح ✅',
                      ),
                    ),
                  );
                },
                child: const Text('إنهاء الرحلة'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _routeRow(
    IconData icon,
    String title,
    String value,
    Color color,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 7),
      child: Row(
        children: [
          Icon(
            icon,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey.shade600,
                  ),
                ),
                Text(
                  value,
                  style: const TextStyle(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _driverEarnings() {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const Text(
            'الأرباح',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'ملخص نشاطك',
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [
                  primaryGreen,
                  darkGreen,
                ],
              ),
              borderRadius: BorderRadius.circular(25),
            ),
            child: const Column(
              children: [
                Text(
                  'أرباح اليوم',
                  style: TextStyle(
                    color: Colors.white70,
                  ),
                ),
                SizedBox(height: 8),
                Text(
                  '0 دج',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 35,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 15),
          Row(
            children: [
              Expanded(
                child: _earningCard(
                  'الرحلات',
                  '0',
                  Icons.route_rounded,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: _earningCard(
                  'التقييم',
                  '5.0',
                  Icons.star_rounded,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _earningCard(
    String title,
    String value,
    IconData icon,
  ) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          children: [
            Icon(icon, color: primaryGreen),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _driverAccount() {
    return SafeArea(
      child: ListView(
        padding: const EdgeInsets.all(18),
        children: [
          const SizedBox(height: 20),
          const CircleAvatar(
            radius: 45,
            backgroundColor: Colors.blue,
            child: Icon(
              Icons.directions_car_rounded,
              size: 45,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            widget.name,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 23,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            widget.phone,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: 25),
          _accountTile(
            Icons.directions_car_rounded,
            'معلومات السيارة',
            () {},
          ),
          _accountTile(
            Icons.verified_user_rounded,
            'توثيق السائق',
            () {},
          ),
          _accountTile(
            Icons.dark_mode_outlined,
            'الوضع الليلي',
            () {
              showDialog(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('المظهر'),
                    content: SwitchListTile(
                      title: const Text('الوضع الليلي'),
                      value: widget.darkMode,
                      onChanged: (value) {
                        widget.onThemeChanged(value);
                        Navigator.pop(context);
                      },
                    ),
                  );
                },
              );
            },
          ),
          _accountTile(
            Icons.help_outline_rounded,
            'المساعدة',
            () {},
          ),
          _accountTile(
            Icons.logout_rounded,
            'تسجيل الخروج',
            () {
              Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                  builder: (_) => RoleScreen(
                    darkMode: widget.darkMode,
                    onThemeChanged:
                        widget.onThemeChanged,
                  ),
                ),
                (route) => false,
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _accountTile(
    IconData icon,
    String title,
    VoidCallback onTap,
  ) {
    return Card(
      child: ListTile(
        leading: Icon(icon),
        title: Text(title),
        trailing: const Icon(
          Icons.chevron_left_rounded,
        ),
        onTap: onTap,
      ),
    );
  }
}
