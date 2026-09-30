import 'dart:async';

import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp();

  runApp(const AlloWasselniApp());
}

// ============================================================
// APP
// ============================================================

class AlloWasselniApp extends StatelessWidget {
  const AlloWasselniApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ألو وصلني',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Arial',
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryGreen,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: backgroundColor,
        appBarTheme: const AppBarTheme(
          centerTitle: true,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.transparent,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: Colors.white,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: BorderSide.none,
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(
              color: primaryGreen,
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 18,
            vertical: 17,
          ),
        ),
      ),
      home: const SplashScreen(),
    );
  }
}

// ============================================================
// COLORS
// ============================================================

const Color primaryGreen = Color(0xFF087F5B);
const Color darkGreen = Color(0xFF075A42);
const Color lightGreen = Color(0xFFE8F6F0);
const Color backgroundColor = Color(0xFFF7F9F8);
const Color deliveryOrange = Color(0xFFF28C28);

// ============================================================
// SPLASH
// ============================================================

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

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
          builder: (_) => const RoleScreen(),
        ),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: primaryGreen,
      body: SafeArea(
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 110,
                height: 110,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(30),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(.15),
                      blurRadius: 25,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.local_taxi_rounded,
                  size: 65,
                  color: primaryGreen,
                ),
              ),
              const SizedBox(height: 25),
              const Text(
                'ألو وصلني',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 34,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'مشاوير وتوصيل داخل البلدية',
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                ),
              ),
              const SizedBox(height: 45),
              const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  color: Colors.white,
                  strokeWidth: 3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// ROLE
// ============================================================

enum UserRole {
  passenger,
  driver,
  motorcycleDriver,
}

// ============================================================
// ROLE SCREEN
// ============================================================

class RoleScreen extends StatelessWidget {
  const RoleScreen({super.key});

  void openLogin(BuildContext context, UserRole role) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => LoginScreen(role: role),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                const SizedBox(height: 35),
                Container(
                  width: 85,
                  height: 85,
                  decoration: BoxDecoration(
                    color: lightGreen,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: const Icon(
                    Icons.apps_rounded,
                    size: 48,
                    color: primaryGreen,
                  ),
                ),
                const SizedBox(height: 25),
                const Text(
                  'مرحبا بك في ألو وصلني',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'اختر كيف تريد استعمال التطبيق',
                  style: TextStyle(
                    color: Colors.grey.shade600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 35),

                RoleCard(
                  icon: Icons.person_rounded,
                  title: 'أنا زبون',
                  subtitle: 'أطلب سيارة أو توصيل غرض',
                  onTap: () => openLogin(
                    context,
                    UserRole.passenger,
                  ),
                ),

                const SizedBox(height: 15),

                RoleCard(
                  icon: Icons.directions_car_rounded,
                  title: 'أنا سائق سيارة',
                  subtitle: 'أستقبل طلبات ألو وصلني',
                  onTap: () => openLogin(
                    context,
                    UserRole.driver,
                  ),
                ),

                const SizedBox(height: 15),

                RoleCard(
                  icon: Icons.two_wheeler_rounded,
                  title: 'أنا سائق دراجة',
                  subtitle: 'أستقبل طلبات ألو جيبلي',
                  iconColor: deliveryOrange,
                  onTap: () => openLogin(
                    context,
                    UserRole.motorcycleDriver,
                  ),
                ),

                const SizedBox(height: 30),

                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: lightGreen,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.info_outline_rounded,
                        color: primaryGreen,
                      ),
                      SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'ألو جيبلي مخصصة لتوصيل الأغراض بواسطة سائقي الدراجات النارية.',
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 25),

                Text(
                  'ألو وصلني • خدمة محلية',
                  style: TextStyle(
                    color: Colors.grey.shade500,
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
  final Color? iconColor;
  final VoidCallback onTap;

  const RoleCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = iconColor ?? primaryGreen;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: Container(
        padding: const EdgeInsets.all(19),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Colors.grey.shade200,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.04),
              blurRadius: 15,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 62,
              height: 62,
              decoration: BoxDecoration(
                color: color.withOpacity(.10),
                borderRadius: BorderRadius.circular(18),
              ),
              child: Icon(
                icon,
                color: color,
                size: 32,
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
            Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 17,
              color: color,
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// LOGIN
// ============================================================

class LoginScreen extends StatefulWidget {
  final UserRole role;

  const LoginScreen({
    super.key,
    required this.role,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final phoneController = TextEditingController();

  bool loading = false;

  @override
  void dispose() {
    phoneController.dispose();
    super.dispose();
  }

  String formatPhoneNumber(String phone) {
    String value = phone.trim();

    if (value.startsWith('+213')) {
      return value;
    }

    if (value.startsWith('0')) {
      value = value.substring(1);
    }

    return '+213$value';
  }

  Future<void> login() async {
    final phone = phoneController.text.trim();

    if (phone.isEmpty) {
      showMessage(context, 'أدخل رقم الهاتف');
      return;
    }

    if (phone.length < 9) {
      showMessage(context, 'أدخل رقم هاتف صحيح');
      return;
    }

    setState(() {
      loading = true;
    });

    final formattedPhone = formatPhoneNumber(phone);

    try {
      await FirebaseAuth.instance.verifyPhoneNumber(
        phoneNumber: formattedPhone,

        verificationCompleted:
            (PhoneAuthCredential credential) async {
          try {
            await FirebaseAuth.instance
                .signInWithCredential(credential);

            if (!mounted) return;

            setState(() {
              loading = false;
            });

            goToHome();
          } catch (e) {
            if (!mounted) return;

            setState(() {
              loading = false;
            });

            showMessage(
              context,
              'تعذر تسجيل الدخول',
            );
          }
        },

        verificationFailed: (FirebaseAuthException e) {
          if (!mounted) return;

          setState(() {
            loading = false;
          });

          showMessage(
            context,
            e.message ?? 'فشل إرسال رمز التحقق',
          );
        },

        codeSent: (
          String verificationId,
          int? resendToken,
        ) {
          if (!mounted) return;

          setState(() {
            loading = false;
          });

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VerificationCodeScreen(
                verificationId: verificationId,
                role: widget.role,
              ),
            ),
          );
        },

        codeAutoRetrievalTimeout:
            (String verificationId) {},
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      showMessage(
        context,
        'حدث خطأ، حاول مرة أخرى',
      );
    }
  }

  void goToHome() {
    if (widget.role == UserRole.passenger) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const PassengerHome(),
        ),
        (route) => false,
      );
    } else if (widget.role == UserRole.motorcycleDriver) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const DriverHome(
            driverType: DriverType.motorcycle,
          ),
        ),
        (route) => false,
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const DriverHome(
            driverType: DriverType.car,
          ),
        ),
        (route) => false,
      );
    }
  }

  String get title {
    if (widget.role == UserRole.passenger) {
      return 'دخول الزبون';
    }

    if (widget.role == UserRole.motorcycleDriver) {
      return 'دخول سائق الدراجة';
    }

    return 'دخول سائق السيارة';
  }

  IconData get icon {
    if (widget.role == UserRole.passenger) {
      return Icons.person_rounded;
    }

    if (widget.role == UserRole.motorcycleDriver) {
      return Icons.two_wheeler_rounded;
    }

    return Icons.drive_eta_rounded;
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                const SizedBox(height: 25),

                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: lightGreen,
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Icon(
                    icon,
                    size: 48,
                    color: primaryGreen,
                  ),
                ),

                const SizedBox(height: 25),

                Text(
                  'مرحبا بك',
                  style: const TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'أدخل رقم هاتفك وسنرسل لك رمز التحقق',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 35),

                TextField(
                  controller: phoneController,
                  keyboardType: TextInputType.phone,
                  textDirection: TextDirection.ltr,
                  decoration: const InputDecoration(
                    labelText: 'رقم الهاتف',
                    hintText: '05 XX XX XX XX',
                    prefixIcon: Icon(
                      Icons.phone_rounded,
                    ),
                  ),
                ),

                const SizedBox(height: 25),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: FilledButton(
                    onPressed: loading ? null : login,
                    style: FilledButton.styleFrom(
                      backgroundColor: primaryGreen,
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(16),
                      ),
                    ),
                    child: loading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'إرسال رمز التحقق',
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
        ),
      ),
    );
  }
}

// ============================================================
// VERIFICATION CODE
// ============================================================

class VerificationCodeScreen extends StatefulWidget {
  final String verificationId;
  final UserRole role;

  const VerificationCodeScreen({
    super.key,
    required this.verificationId,
    required this.role,
  });

  @override
  State<VerificationCodeScreen> createState() =>
      _VerificationCodeScreenState();
}

class _VerificationCodeScreenState
    extends State<VerificationCodeScreen> {
  final codeController = TextEditingController();

  bool loading = false;

  @override
  void dispose() {
    codeController.dispose();
    super.dispose();
  }

  Future<void> verifyCode() async {
    final code = codeController.text.trim();

    if (code.length != 6) {
      showMessage(
        context,
        'أدخل رمز التحقق المكون من 6 أرقام',
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      final credential =
          PhoneAuthProvider.credential(
        verificationId: widget.verificationId,
        smsCode: code,
      );

      await FirebaseAuth.instance
          .signInWithCredential(credential);

      if (!mounted) return;

      if (widget.role == UserRole.passenger) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const PassengerHome(),
          ),
          (route) => false,
        );
      } else if (widget.role ==
          UserRole.motorcycleDriver) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const DriverHome(
              driverType: DriverType.motorcycle,
            ),
          ),
          (route) => false,
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (_) => const DriverHome(
              driverType: DriverType.car,
            ),
          ),
          (route) => false,
        );
      }
    } on FirebaseAuthException catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      showMessage(
        context,
        e.message ?? 'رمز التحقق غير صحيح',
      );
    } catch (e) {
      if (!mounted) return;

      setState(() {
        loading = false;
      });

      showMessage(
        context,
        'حدث خطأ، حاول مرة أخرى',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'تأكيد رقم الهاتف',
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                const SizedBox(height: 35),

                Container(
                  width: 90,
                  height: 90,
                  decoration: BoxDecoration(
                    color: lightGreen,
                    borderRadius:
                        BorderRadius.circular(25),
                  ),
                  child: const Icon(
                    Icons.sms_rounded,
                    size: 48,
                    color: primaryGreen,
                  ),
                ),

                const SizedBox(height: 25),

                const Text(
                  'أدخل رمز التحقق',
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'تم إرسال رمز من 6 أرقام إلى هاتفك',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey.shade600,
                  ),
                ),

                const SizedBox(height: 35),

                TextField(
                  controller: codeController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  decoration: const InputDecoration(
                    labelText: 'رمز التحقق',
                    prefixIcon: Icon(
                      Icons.lock_rounded,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: FilledButton(
                    onPressed:
                        loading ? null : verifyCode,
                    child: loading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child:
                                CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Text(
                            'تأكيد الدخول',
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
        ),
      ),
    );
  }
}

// ============================================================
// PASSENGER HOME
// ============================================================

class PassengerHome extends StatefulWidget {
  const PassengerHome({super.key});

  @override
  State<PassengerHome> createState() =>
      _PassengerHomeState();
}

class _PassengerHomeState extends State<PassengerHome> {
  int currentIndex = 0;

  final pages = const [
    PassengerDashboard(),
    TripsScreen(),
    PassengerAccountScreen(),
  ];

  @override
  Widget build(BuildContext context) {
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
              selectedIcon:
                  Icon(Icons.home_rounded),
              label: 'الرئيسية',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.receipt_long_outlined,
              ),
              selectedIcon:
                  Icon(Icons.receipt_long_rounded),
              label: 'طلباتي',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.person_outline_rounded,
              ),
              selectedIcon:
                  Icon(Icons.person_rounded),
              label: 'حسابي',
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// PASSENGER DASHBOARD
// ============================================================

class PassengerDashboard extends StatelessWidget {
  const PassengerDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: lightGreen,
                    borderRadius:
                        BorderRadius.circular(15),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: primaryGreen,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        'مرحبا 👋',
                        style: TextStyle(
                          color: Colors.grey,
                          fontSize: 14,
                        ),
                      ),
                      Text(
                        'ألو وصلني',
                        style: TextStyle(
                          fontSize: 21,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  onPressed: () {
                    showMessage(
                      context,
                      'لا توجد إشعارات جديدة',
                    );
                  },
                  icon: const Icon(
                    Icons.notifications_none_rounded,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            // ALLO WASSELNI
            ServiceCard(
              color: primaryGreen,
              icon: Icons.local_taxi_rounded,
              title: 'ألو وصلني',
              subtitle:
                  'اطلب سيارة واذهب إلى وجهتك',
              buttonText: 'طلب توصيلة',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const BookingScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 15),

            // ALLO JIBLI
            ServiceCard(
              color: deliveryOrange,
              icon: Icons.inventory_2_rounded,
              title: 'ألو جيبلي',
              subtitle:
                  'أرسل غرضك مع سائق دراجة',
              buttonText: 'طلب توصيل',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const DeliveryBookingScreen(),
                  ),
                );
              },
            ),

            const SizedBox(height: 25),

            const Text(
              'لماذا ألو وصلني؟',
              style: TextStyle(
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 13),

            Row(
              children: [
                Expanded(
                  child: FeatureCard(
                    icon: Icons.speed_rounded,
                    title: 'سريع',
                    subtitle: 'استجابة سريعة',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FeatureCard(
                    icon:
                        Icons.verified_user_rounded,
                    title: 'آمن',
                    subtitle: 'خدمة محلية',
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FeatureCard(
                    icon: Icons.location_on_rounded,
                    title: 'محلي',
                    subtitle: 'داخل البلدية',
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
// SERVICE CARD
// ============================================================

class ServiceCard extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final String buttonText;
  final VoidCallback onTap;

  const ServiceCard({
    super.key,
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.buttonText,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            color,
            color.withOpacity(.80),
          ],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Row(
        children: [
          Container(
            width: 62,
            height: 62,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(.18),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: Colors.white,
              size: 34,
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 21,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: const TextStyle(
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 12),
                FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: primaryGreen,
                  ),
                  onPressed: onTap,
                  child: Text(buttonText),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// FEATURE CARD
// ============================================================

class FeatureCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const FeatureCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(
        vertical: 15,
        horizontal: 8,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: Column(
        children: [
          Icon(
            icon,
            color: primaryGreen,
            size: 28,
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey.shade600,
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// DELIVERY BOOKING
// ============================================================

class DeliveryBookingScreen extends StatefulWidget {
  const DeliveryBookingScreen({super.key});

  @override
  State<DeliveryBookingScreen> createState() =>
      _DeliveryBookingScreenState();
}

class _DeliveryBookingScreenState
    extends State<DeliveryBookingScreen> {
  final pickupController = TextEditingController();
  final destinationController =
      TextEditingController();
  final receiverController =
      TextEditingController();
  final descriptionController =
      TextEditingController();
  final notesController = TextEditingController();

  String packageSize = 'صغير';

  @override
  void dispose() {
    pickupController.dispose();
    destinationController.dispose();
    receiverController.dispose();
    descriptionController.dispose();
    notesController.dispose();
    super.dispose();
  }

  void confirmDelivery() {
    if (pickupController.text.trim().isEmpty) {
      showMessage(
        context,
        'أدخل مكان استلام الغرض',
      );
      return;
    }

    if (destinationController.text.trim().isEmpty) {
      showMessage(
        context,
        'أدخل مكان التسليم',
      );
      return;
    }

    if (receiverController.text.trim().isEmpty) {
      showMessage(
        context,
        'أدخل رقم هاتف المستلم',
      );
      return;
    }

    if (descriptionController.text.trim().isEmpty) {
      showMessage(
        context,
        'اكتب وصف الغرض',
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => SearchingDeliveryScreen(
          pickup: pickupController.text.trim(),
          destination:
              destinationController.text.trim(),
          receiverPhone:
              receiverController.text.trim(),
          description:
              descriptionController.text.trim(),
          packageSize: packageSize,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('ألو جيبلي'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: deliveryOrange
                        .withOpacity(.12),
                    borderRadius:
                        BorderRadius.circular(20),
                  ),
                  child: const Row(
                    children: [
                      Icon(
                        Icons.two_wheeler_rounded,
                        color: deliveryOrange,
                        size: 40,
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: Text(
                          'أرسل أغراضك داخل البلدية مع سائق دراجة.',
                          style: TextStyle(
                            fontWeight:
                                FontWeight.bold,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                const FakeMap(),

                const SizedBox(height: 20),

                const Text(
                  'مكان الاستلام',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller: pickupController,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'من أين يأخذ السائق الغرض؟',
                    prefixIcon: Icon(
                      Icons.my_location_rounded,
                      color: deliveryOrange,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                const Text(
                  'مكان التسليم',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                TextField(
                  controller:
                      destinationController,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'أين يسلم السائق الغرض؟',
                    prefixIcon: Icon(
                      Icons.location_on_rounded,
                      color: Colors.redAccent,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                TextField(
                  controller: receiverController,
                  keyboardType:
                      TextInputType.phone,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'رقم هاتف المستلم',
                    prefixIcon: Icon(
                      Icons.phone_rounded,
                    ),
                  ),
                ),

                const SizedBox(height: 14),

                TextField(
                  controller:
                      descriptionController,
                  maxLines: 2,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'ما هو الغرض؟',
                    hintText:
                        'مثال: وثائق، ملابس، علبة...',
                    prefixIcon: Icon(
                      Icons.inventory_2_rounded,
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                const Text(
                  'حجم الغرض',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label: const Text('صغير'),
                      selected:
                          packageSize == 'صغير',
                      onSelected: (_) {
                        setState(() {
                          packageSize = 'صغير';
                        });
                      },
                    ),
                    ChoiceChip(
                      label: const Text('متوسط'),
                      selected:
                          packageSize == 'متوسط',
                      onSelected: (_) {
                        setState(() {
                          packageSize = 'متوسط';
                        });
                      },
                    ),
                    ChoiceChip(
                      label: const Text('كبير'),
                      selected:
                          packageSize == 'كبير',
                      onSelected: (_) {
                        setState(() {
                          packageSize = 'كبير';
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                TextField(
                  controller: notesController,
                  maxLines: 3,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'ملاحظات للسائق (اختياري)',
                    prefixIcon: Icon(
                      Icons.notes_rounded,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: lightGreen,
                    borderRadius:
                        BorderRadius.circular(18),
                  ),
                  child: const Column(
                    children: [
                      PriceRow(
                        title:
                            'سعر التوصيل التقديري',
                        value: '200 دج',
                        bold: true,
                      ),
                      SizedBox(height: 8),
                      PriceRow(
                        title: 'الخدمة',
                        value:
                            'ألو جيبلي',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    style: FilledButton.styleFrom(
                      backgroundColor:
                          deliveryOrange,
                    ),
                    onPressed: confirmDelivery,
                    icon: const Icon(
                      Icons.two_wheeler_rounded,
                    ),
                    label: const Text(
                      'اطلب ألو جيبلي',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
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
// SEARCHING DELIVERY DRIVER
// ============================================================

class SearchingDeliveryScreen
    extends StatefulWidget {
  final String pickup;
  final String destination;
  final String receiverPhone;
  final String description;
  final String packageSize;

  const SearchingDeliveryScreen({
    super.key,
    required this.pickup,
    required this.destination,
    required this.receiverPhone,
    required this.description,
    required this.packageSize,
  });

  @override
  State<SearchingDeliveryScreen> createState() =>
      _SearchingDeliveryScreenState();
}

class _SearchingDeliveryScreenState
    extends State<SearchingDeliveryScreen> {
  bool found = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    timer = Timer(
      const Duration(seconds: 4),
      () {
        if (!mounted) return;

        setState(() {
          found = true;
        });
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'ألو جيبلي',
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: found
                ? DeliveryDriverFound(
                    pickup: widget.pickup,
                    destination:
                        widget.destination,
                    description:
                        widget.description,
                    onContinue: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ActiveDeliveryScreen(
                            pickup: widget.pickup,
                            destination:
                                widget.destination,
                            receiverPhone:
                                widget.receiverPhone,
                            description:
                                widget.description,
                          ),
                        ),
                      );
                    },
                  )
                : const SearchingDeliveryContent(),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SEARCHING DELIVERY CONTENT
// ============================================================

class SearchingDeliveryContent
    extends StatelessWidget {
  const SearchingDeliveryContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment:
          MainAxisAlignment.center,
      children: [
        const Spacer(),

        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color:
                deliveryOrange.withOpacity(.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.two_wheeler_rounded,
            size: 60,
            color: deliveryOrange,
          ),
        ),

        const SizedBox(height: 30),

        const Text(
          'نبحث عن سائق دراجة...',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 12),

        Text(
          'نبحث عن أقرب سائق متاح لاستلام غرضك.',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),

        const SizedBox(height: 30),

        const SizedBox(
          width: 45,
          height: 45,
          child: CircularProgressIndicator(
            strokeWidth: 4,
          ),
        ),

        const Spacer(),

        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'إلغاء الطلب',
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// DELIVERY DRIVER FOUND
// ============================================================

class DeliveryDriverFound
    extends StatelessWidget {
  final String pickup;
  final String destination;
  final String description;
  final VoidCallback onContinue;

  const DeliveryDriverFound({
    super.key,
    required this.pickup,
    required this.destination,
    required this.description,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),

        Container(
          width: 95,
          height: 95,
          decoration: BoxDecoration(
            color:
                deliveryOrange.withOpacity(.12),
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.check_circle_rounded,
            size: 70,
            color: deliveryOrange,
          ),
        ),

        const SizedBox(height: 20),

        const Text(
          'تم العثور على سائق!',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),

        const SizedBox(height: 25),

        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(20),
          ),
          child: Column(
            children: [
              const Row(
                children: [
                  CircleAvatar(
                    radius: 31,
                    backgroundColor:
                        lightGreen,
                    child: Icon(
                      Icons.two_wheeler_rounded,
                      color: primaryGreen,
                      size: 32,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ياسين',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '⭐ 4.9 • 86 توصيل',
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.verified_rounded,
                    color: primaryGreen,
                  ),
                ],
              ),

              const Divider(height: 28),

              PriceRow(
                title: 'الغرض',
                value: description,
              ),

              const SizedBox(height: 10),

              const PriceRow(
                title: 'الدراجة',
                value: 'دراجة نارية',
              ),

              const SizedBox(height: 10),

              const PriceRow(
                title: 'السعر',
                value: '200 دج',
                bold: true,
              ),
            ],
          ),
        ),

        const SizedBox(height: 18),

        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              RideLocationRow(
                icon:
                    Icons.inventory_2_rounded,
                color: deliveryOrange,
                title: 'الاستلام',
                value: pickup,
              ),
              const SizedBox(height: 12),
              RideLocationRow(
                icon:
                    Icons.location_on_rounded,
                color: Colors.redAccent,
                title: 'التسليم',
                value: destination,
              ),
            ],
          ),
        ),

        const Spacer(),

        SizedBox(
          width: double.infinity,
          height: 55,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor:
                  deliveryOrange,
            ),
            onPressed: onContinue,
            child: const Text(
              'متابعة التوصيل',
              style: TextStyle(
                fontSize: 17,
                fontWeight:
                    FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// ACTIVE DELIVERY
// ============================================================

class ActiveDeliveryScreen
    extends StatelessWidget {
  final String pickup;
  final String destination;
  final String receiverPhone;
  final String description;

  const ActiveDeliveryScreen({
    super.key,
    required this.pickup,
    required this.destination,
    required this.receiverPhone,
    required this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            'التوصيل الحالي',
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                const FakeMap(),

                const SizedBox(height: 18),

                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(22),
                  ),
                  child: Column(
                    children: [
                      const Row(
                        children: [
                          CircleAvatar(
                            radius: 31,
                            backgroundColor:
                                lightGreen,
                            child: Icon(
                              Icons
                                  .two_wheeler_rounded,
                              color:
                                  primaryGreen,
                              size: 32,
                            ),
                          ),
                          SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment:
                                  CrossAxisAlignment
                                      .start,
                              children: [
                                Text(
                                  'ياسين',
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontWeight:
                                        FontWeight
                                            .bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'سائق ألو جيبلي',
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 16),

                      Row(
                        children: [
                          Expanded(
                            child:
                                OutlinedButton.icon(
                              onPressed: () {
                                showMessage(
                                  context,
                                  'ميزة الاتصال ستضاف لاحقاً',
                                );
                              },
                              icon: const Icon(
                                Icons
                                    .phone_rounded,
                              ),
                              label:
                                  const Text(
                                'اتصال',
                              ),
                            ),
                          ),
                          const SizedBox(
                            width: 10,
                          ),
                          Expanded(
                            child:
                                OutlinedButton.icon(
                              onPressed: () {
                                showMessage(
                                  context,
                                  'المحادثة ستضاف لاحقاً',
                                );
                              },
                              icon: const Icon(
                                Icons
                                    .chat_rounded,
                              ),
                              label:
                                  const Text(
                                'رسالة',
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                Container(
                  padding:
                      const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                  ),
                  child: Column(
                    children: [
                      RideLocationRow(
                        icon: Icons
                            .inventory_2_rounded,
                        color:
                            deliveryOrange,
                        title:
                            'مكان استلام الغرض',
                        value: pickup,
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(
                          vertical: 8,
                        ),
                        child: Divider(),
                      ),
                      RideLocationRow(
                        icon: Icons
                            .location_on_rounded,
                        color:
                            Colors.redAccent,
                        title:
                            'مكان التسليم',
                        value: destination,
                      ),
                      const Padding(
                        padding:
                            EdgeInsets.symmetric(
                          vertical: 8,
                        ),
                        child: Divider(),
                      ),
                      RideLocationRow(
                        icon: Icons
                            .inventory_2_outlined,
                        color:
                            deliveryOrange,
                        title: 'الغرض',
                        value: description,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                Container(
                  padding:
                      const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: lightGreen,
                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                  ),
                  child: const Column(
                    children: [
                      PriceRow(
                        title:
                            'سعر التوصيل',
                        value: '200 دج',
                        bold: true,
                      ),
                      SizedBox(height: 10),
                      PriceRow(
                        title:
                            'هاتف المستلم',
                        value:
                            'رقم المستلم محفوظ',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: FilledButton.icon(
                    style:
                        FilledButton.styleFrom(
                      backgroundColor:
                          deliveryOrange,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) =>
                            AlertDialog(
                          title: const Text(
                            'إنهاء التوصيل',
                          ),
                          content:
                              const Text(
                            'هل تم تسليم الغرض للمستلم؟',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(
                                context,
                              ),
                              child:
                                  const Text(
                                'لا',
                              ),
                            ),
                            FilledButton(
                              onPressed: () {
                                Navigator.pop(
                                  context,
                                );
                                Navigator.pop(
                                  context,
                                );
                                showMessage(
                                  context,
                                  'تم إنهاء التوصيل بنجاح',
                                );
                              },
                              child:
                                  const Text(
                                'نعم، تم التسليم',
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons
                          .check_circle_rounded,
                    ),
                    label: const Text(
                      'تم تسليم الغرض',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
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
// BOOKING CAR
// ============================================================

class BookingScreen extends StatefulWidget {
  const BookingScreen({super.key});

  @override
  State<BookingScreen> createState() =>
      _BookingScreenState();
}

class _BookingScreenState
    extends State<BookingScreen> {
  final pickupController =
      TextEditingController();
  final destinationController =
      TextEditingController();
  final notesController =
      TextEditingController();

  String rideType = 'عادية';
  int passengers = 1;

  @override
  void dispose() {
    pickupController.dispose();
    destinationController.dispose();
    notesController.dispose();
    super.dispose();
  }

  void confirmBooking() {
    if (pickupController.text.trim().isEmpty) {
      showMessage(
        context,
        'أدخل نقطة الانطلاق',
      );
      return;
    }

    if (destinationController.text
        .trim()
        .isEmpty) {
      showMessage(
        context,
        'أدخل الوجهة',
      );
      return;
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            SearchingDriverScreen(
          pickup:
              pickupController.text.trim(),
          destination:
              destinationController.text.trim(),
          rideType: rideType,
          passengers: passengers,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'طلب توصيلة',
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start,
              children: [
                const FakeMap(),
                const SizedBox(height: 20),

                const Text(
                  'تفاصيل الرحلة',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 14),

                TextField(
                  controller:
                      pickupController,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'نقطة الانطلاق',
                    prefixIcon: Icon(
                      Icons
                          .my_location_rounded,
                      color: primaryGreen,
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                TextField(
                  controller:
                      destinationController,
                  decoration:
                      const InputDecoration(
                    labelText: 'إلى أين؟',
                    prefixIcon: Icon(
                      Icons
                          .location_on_rounded,
                      color:
                          Colors.redAccent,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                const Text(
                  'نوع السيارة',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Wrap(
                  spacing: 8,
                  children: [
                    ChoiceChip(
                      label:
                          const Text(
                        'عادية',
                      ),
                      selected:
                          rideType ==
                              'عادية',
                      onSelected: (_) {
                        setState(() {
                          rideType =
                              'عادية';
                        });
                      },
                    ),
                    ChoiceChip(
                      label:
                          const Text(
                        'مريحة',
                      ),
                      selected:
                          rideType ==
                              'مريحة',
                      onSelected: (_) {
                        setState(() {
                          rideType =
                              'مريحة';
                        });
                      },
                    ),
                    ChoiceChip(
                      label:
                          const Text(
                        'كبيرة',
                      ),
                      selected:
                          rideType ==
                              'كبيرة',
                      onSelected: (_) {
                        setState(() {
                          rideType =
                              'كبيرة';
                        });
                      },
                    ),
                  ],
                ),

                const SizedBox(height: 20),

                const Text(
                  'عدد الركاب',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                Row(
                  children: [
                    IconButton(
                      onPressed:
                          passengers > 1
                              ? () {
                                  setState(
                                    () =>
                                        passengers--,
                                  );
                                }
                              : null,
                      icon: const Icon(
                        Icons
                            .remove_circle_outline,
                      ),
                    ),
                    Text(
                      '$passengers',
                      style:
                          const TextStyle(
                        fontSize: 20,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    IconButton(
                      onPressed:
                          passengers < 6
                              ? () {
                                  setState(
                                    () =>
                                        passengers++,
                                  );
                                }
                              : null,
                      icon: const Icon(
                        Icons
                            .add_circle_outline,
                      ),
                    ),
                  ],
                ),

                TextField(
                  controller:
                      notesController,
                  maxLines: 3,
                  decoration:
                      const InputDecoration(
                    labelText:
                        'ملاحظات للسائق',
                    prefixIcon: Icon(
                      Icons.notes_rounded,
                    ),
                  ),
                ),

                const SizedBox(height: 20),

                Container(
                  padding:
                      const EdgeInsets.all(
                    18,
                  ),
                  decoration: BoxDecoration(
                    color: lightGreen,
                    borderRadius:
                        BorderRadius.circular(
                      18,
                    ),
                  ),
                  child: const Column(
                    children: [
                      PriceRow(
                        title:
                            'المسافة التقديرية',
                        value: '3.5 كم',
                      ),
                      SizedBox(height: 10),
                      PriceRow(
                        title:
                            'السعر التقديري',
                        value: '350 دج',
                        bold: true,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    onPressed:
                        confirmBooking,
                    icon: const Icon(
                      Icons
                          .local_taxi_rounded,
                    ),
                    label: const Text(
                      'اطلب التوصيلة',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
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
// SEARCHING CAR DRIVER
// ============================================================

class SearchingDriverScreen
    extends StatefulWidget {
  final String pickup;
  final String destination;
  final String rideType;
  final int passengers;

  const SearchingDriverScreen({
    super.key,
    required this.pickup,
    required this.destination,
    required this.rideType,
    required this.passengers,
  });

  @override
  State<SearchingDriverScreen> createState() =>
      _SearchingDriverScreenState();
}

class _SearchingDriverScreenState
    extends State<SearchingDriverScreen> {
  bool found = false;
  Timer? timer;

  @override
  void initState() {
    super.initState();

    timer = Timer(
      const Duration(seconds: 4),
      () {
        if (!mounted) return;

        setState(() {
          found = true;
        });
      },
    );
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'البحث عن سائق',
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: found
                ? DriverFoundContent(
                    pickup: widget.pickup,
                    destination:
                        widget.destination,
                    onContinue: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              ActiveRideScreen(
                            pickup:
                                widget.pickup,
                            destination:
                                widget.destination,
                          ),
                        ),
                      );
                    },
                  )
                : const SearchingContent(),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// SEARCHING CONTENT
// ============================================================

class SearchingContent
    extends StatelessWidget {
  const SearchingContent({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment:
          MainAxisAlignment.center,
      children: [
        const Spacer(),
        Container(
          width: 120,
          height: 120,
          decoration: BoxDecoration(
            color: lightGreen,
            shape: BoxShape.circle,
          ),
          child: const Icon(
            Icons.search_rounded,
            size: 60,
            color: primaryGreen,
          ),
        ),
        const SizedBox(height: 30),
        const Text(
          'نبحث عن أقرب سائق...',
          style: TextStyle(
            fontSize: 23,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'انتظر قليلاً، نحن نبحث عن سائق متاح بالقرب منك',
          textAlign: TextAlign.center,
          style: TextStyle(
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(height: 30),
        const SizedBox(
          width: 45,
          height: 45,
          child: CircularProgressIndicator(
            strokeWidth: 4,
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          height: 52,
          child: OutlinedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: const Text(
              'إلغاء الطلب',
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// DRIVER FOUND
// ============================================================

class DriverFoundContent
    extends StatelessWidget {
  final String pickup;
  final String destination;
  final VoidCallback onContinue;

  const DriverFoundContent({
    super.key,
    required this.pickup,
    required this.destination,
    required this.onContinue,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        const SizedBox(height: 20),
        const Icon(
          Icons.check_circle_rounded,
          size: 90,
          color: primaryGreen,
        ),
        const SizedBox(height: 20),
        const Text(
          'تم العثور على سائق!',
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 25),
        Container(
          padding: const EdgeInsets.all(18),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(20),
          ),
          child: const Column(
            children: [
              Row(
                children: [
                  CircleAvatar(
                    radius: 31,
                    backgroundColor:
                        lightGreen,
                    child: Icon(
                      Icons.person_rounded,
                      color: primaryGreen,
                      size: 32,
                    ),
                  ),
                  SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'محمد',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: 4),
                        Text(
                          '⭐ 4.9 • 126 رحلة',
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.verified_rounded,
                    color: primaryGreen,
                  ),
                ],
              ),
              Divider(height: 28),
              PriceRow(
                title: 'السيارة',
                value: 'Renault Symbol',
              ),
              SizedBox(height: 10),
              PriceRow(
                title: 'اللون',
                value: 'أبيض',
              ),
              SizedBox(height: 10),
              PriceRow(
                title: 'الترقيم',
                value: '00000-000-48',
                bold: true,
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.all(15),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
                BorderRadius.circular(18),
          ),
          child: Column(
            children: [
              RideLocationRow(
                icon:
                    Icons.my_location_rounded,
                color: primaryGreen,
                title: 'نقطة الانطلاق',
                value: pickup,
              ),
              const SizedBox(height: 12),
              RideLocationRow(
                icon:
                    Icons.location_on_rounded,
                color: Colors.redAccent,
                title: 'الوجهة',
                value: destination,
              ),
            ],
          ),
        ),
        const Spacer(),
        SizedBox(
          width: double.infinity,
          height: 55,
          child: FilledButton(
            onPressed: onContinue,
            child: const Text(
              'متابعة الرحلة',
              style: TextStyle(
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// ACTIVE RIDE
// ============================================================

class ActiveRideScreen extends StatelessWidget {
  final String pickup;
  final String destination;

  const ActiveRideScreen({
    super.key,
    required this.pickup,
    required this.destination,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'رحلتك الحالية',
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: Column(
              children: [
                const FakeMap(),
                const SizedBox(height: 18),

                Container(
                  padding:
                      const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(
                      22,
                    ),
                  ),
                  child: const Row(
                    children: [
                      CircleAvatar(
                        radius: 31,
                        backgroundColor:
                            lightGreen,
                        child: Icon(
                          Icons.person_rounded,
                          color:
                              primaryGreen,
                          size: 32,
                        ),
                      ),
                      SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment:
                              CrossAxisAlignment
                                  .start,
                          children: [
                            Text(
                              'محمد',
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                            SizedBox(height: 5),
                            Text(
                              '⭐ 4.9 • Renault Symbol',
                            ),
                            SizedBox(height: 3),
                            Text(
                              '00000-000-48',
                              style: TextStyle(
                                fontWeight:
                                    FontWeight
                                        .bold,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                Container(
                  padding:
                      const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                  ),
                  child: Column(
                    children: [
                      RideLocationRow(
                        icon: Icons
                            .my_location_rounded,
                        color:
                            primaryGreen,
                        title:
                            'نقطة الانطلاق',
                        value: pickup,
                      ),
                      const Divider(
                        height: 28,
                      ),
                      RideLocationRow(
                        icon: Icons
                            .location_on_rounded,
                        color:
                            Colors.redAccent,
                        title: 'الوجهة',
                        value:
                            destination,
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                const PriceRow(
                  title: 'السعر',
                  value: '350 دج',
                  bold: true,
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 54,
                  child: OutlinedButton(
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const RatingScreen(),
                        ),
                      );
                    },
                    child: const Text(
                      'وصلت إلى الوجهة',
                    ),
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
// RATING
// ============================================================

class RatingScreen extends StatefulWidget {
  const RatingScreen({super.key});

  @override
  State<RatingScreen> createState() =>
      _RatingScreenState();
}

class _RatingScreenState
    extends State<RatingScreen> {
  int rating = 5;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(
            'تقييم الرحلة',
          ),
        ),
        body: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(22),
            child: Column(
              children: [
                const Spacer(),

                const Icon(
                  Icons.check_circle_rounded,
                  color: primaryGreen,
                  size: 90,
                ),

                const SizedBox(height: 20),

                const Text(
                  'وصلت بالسلامة!',
                  style: TextStyle(
                    fontSize: 27,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 10),

                Text(
                  'كيف كانت رحلتك؟',
                  style: TextStyle(
                    color:
                        Colors.grey.shade600,
                    fontSize: 16,
                  ),
                ),

                const SizedBox(height: 25),

                Row(
                  mainAxisAlignment:
                      MainAxisAlignment.center,
                  children: List.generate(
                    5,
                    (index) {
                      final value =
                          index + 1;

                      return IconButton(
                        onPressed: () {
                          setState(() {
                            rating = value;
                          });
                        },
                        icon: Icon(
                          value <= rating
                              ? Icons.star_rounded
                              : Icons
                                  .star_border_rounded,
                          color:
                              Colors.amber,
                          size: 43,
                        ),
                      );
                    },
                  ),
                ),

                const Spacer(),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: FilledButton(
                    onPressed: () {
                      Navigator
                          .pushAndRemoveUntil(
                        context,
                        MaterialPageRoute(
                          builder: (_) =>
                              const PassengerHome(),
                        ),
                        (route) => false,
                      );
                    },
                    child: const Text(
                      'حفظ التقييم',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
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
// TRIPS
// ============================================================

class TripsScreen extends StatelessWidget {
  const TripsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const Text(
              'طلباتي',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            Container(
              padding:
                  const EdgeInsets.all(25),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(
                  22,
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    Icons.receipt_long_rounded,
                    size: 55,
                    color:
                        Colors.grey.shade400,
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    'لا توجد طلبات سابقة',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight:
                          FontWeight.bold,
                    ),
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

// ============================================================
// PASSENGER ACCOUNT
// ============================================================

class PassengerAccountScreen
    extends StatelessWidget {
  const PassengerAccountScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(18),
          children: [
            const Text(
              'حسابي',
              style: TextStyle(
                fontSize: 27,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 20),

            const AccountHeader(
              icon: Icons.person_rounded,
              title: 'مستخدم ألو وصلني',
              subtitle: 'زبون',
            ),

            const SizedBox(height: 15),

            AccountItem(
              icon:
                  Icons.person_outline_rounded,
              title: 'المعلومات الشخصية',
              onTap: () {
                showMessage(
                  context,
                  'ستضاف لاحقاً',
                );
              },
            ),

            AccountItem(
              icon: Icons.settings_outlined,
              title: 'الإعدادات',
              onTap: () {
                showMessage(
                  context,
                  'ستضاف لاحقاً',
                );
              },
            ),

            AccountItem(
              icon:
                  Icons.help_outline_rounded,
              title: 'المساعدة',
              onTap: () {
                showMessage(
                  context,
                  'ستضاف لاحقاً',
                );
              },
            ),

            const SizedBox(height: 15),

            OutlinedButton.icon(
              onPressed: () async {
                await FirebaseAuth.instance
                    .signOut();

                if (!context.mounted) return;

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const RoleScreen(),
                  ),
                  (route) => false,
                );
              },
              icon: const Icon(
                Icons.logout_rounded,
              ),
              label: const Text(
                'تسجيل الخروج',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// DRIVER TYPE
// ============================================================

enum DriverType {
  car,
  motorcycle,
}

// ============================================================
// DRIVER HOME
// ============================================================

class DriverHome extends StatefulWidget {
  final DriverType driverType;

  const DriverHome({
    super.key,
    required this.driverType,
  });

  @override
  State<DriverHome> createState() =>
      _DriverHomeState();
}

class _DriverHomeState
    extends State<DriverHome> {
  int currentIndex = 0;
  bool online = false;

  @override
  Widget build(BuildContext context) {
    final pages = [
      DriverDashboard(
        driverType: widget.driverType,
        online: online,
        onOnlineChanged: (value) {
          setState(() {
            online = value;
          });
        },
      ),
      DriverEarningsScreen(
        driverType: widget.driverType,
      ),
      DriverAccountScreen(
        driverType: widget.driverType,
      ),
    ];

    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        body: pages[currentIndex],
        bottomNavigationBar:
            NavigationBar(
          selectedIndex: currentIndex,
          onDestinationSelected:
              (index) {
            setState(() {
              currentIndex = index;
            });
          },
          destinations: const [
            NavigationDestination(
              icon: Icon(
                Icons.dashboard_outlined,
              ),
              selectedIcon: Icon(
                Icons.dashboard_rounded,
              ),
              label: 'الرئيسية',
            ),
            NavigationDestination(
              icon: Icon(
                Icons
                    .account_balance_wallet_outlined,
              ),
              selectedIcon: Icon(
                Icons
                    .account_balance_wallet_rounded,
              ),
              label: 'الأرباح',
            ),
            NavigationDestination(
              icon: Icon(
                Icons.person_outline_rounded,
              ),
              selectedIcon: Icon(
                Icons.person_rounded,
              ),
              label: 'حسابي',
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// DRIVER DASHBOARD
// ============================================================

class DriverDashboard
    extends StatelessWidget {
  final DriverType driverType;
  final bool online;
  final ValueChanged<bool>
      onOnlineChanged;

  const DriverDashboard({
    super.key,
    required this.driverType,
    required this.online,
    required this.onOnlineChanged,
  });

  bool get isMotorcycle =>
      driverType == DriverType.motorcycle;

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment:
              CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment:
                        CrossAxisAlignment.start,
                    children: [
                      Text(
                        isMotorcycle
                            ? 'لوحة سائق ألو جيبلي'
                            : 'لوحة سائق ألو وصلني',
                        style: const TextStyle(
                          fontSize: 24,
                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        isMotorcycle
                            ? 'توصيل الطلبات بالدراجة'
                            : 'نقل الركاب',
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isMotorcycle
                        ? deliveryOrange
                            .withOpacity(.12)
                        : lightGreen,
                    borderRadius:
                        BorderRadius.circular(
                      15,
                    ),
                  ),
                  child: Icon(
                    isMotorcycle
                        ? Icons
                            .two_wheeler_rounded
                        : Icons
                            .drive_eta_rounded,
                    color: isMotorcycle
                        ? deliveryOrange
                        : primaryGreen,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 20),

            Container(
              padding:
                  const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: online
                    ? lightGreen
                    : Colors.white,
                borderRadius:
                    BorderRadius.circular(
                  22,
                ),
                border: Border.all(
                  color: online
                      ? primaryGreen
                          .withOpacity(.3)
                      : Colors.grey.shade200,
                ),
              ),
              child: Row(
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: online
                          ? primaryGreen
                          : Colors.grey
                              .shade200,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      online
                          ? Icons.wifi_rounded
                          : Icons
                              .wifi_off_rounded,
                      color: online
                          ? Colors.white
                          : Colors.grey,
                    ),
                  ),
                  const SizedBox(width: 15),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start,
                      children: [
                        Text(
                          'حالة السائق',
                          style: TextStyle(
                            fontWeight:
                                FontWeight.bold,
                            fontSize: 17,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'فعّل الحالة لاستقبال الطلبات',
                        ),
                      ],
                    ),
                  ),
                  Switch(
                    value: online,
                    onChanged:
                        onOnlineChanged,
                    activeColor:
                        primaryGreen,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Row(
              children: [
                Expanded(
                  child: DriverStatCard(
                    title: isMotorcycle
                        ? 'توصيلات اليوم'
                        : 'رحلات اليوم',
                    value: '8',
                    icon: isMotorcycle
                        ? Icons
                            .inventory_2_rounded
                        : Icons
                            .local_taxi_rounded,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: DriverStatCard(
                    title: 'أرباح اليوم',
                    value: isMotorcycle
                        ? '1,600 دج'
                        : '2,450 دج',
                    icon:
                        Icons.payments_rounded,
                  ),
                ),
              ],
            ),

            const SizedBox(height: 22),

            if (online)
              isMotorcycle
                  ? DeliveryRequestCard(
                      onAccept: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const DriverActiveDeliveryScreen(),
                          ),
                        );
                      },
                      onReject: () {
                        showMessage(
                          context,
                          'تم رفض الطلب',
                        );
                      },
                    )
                  : DriverRequestCard(
                      onAccept: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) =>
                                const DriverActiveRideScreen(),
                          ),
                        );
                      },
                      onReject: () {
                        showMessage(
                          context,
                          'تم رفض الطلب',
                        );
                      },
                    )
            else
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.all(22),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius:
                      BorderRadius.circular(
                    22,
                  ),
                ),
                child: Column(
                  children: [
                    Icon(
                      isMotorcycle
                          ? Icons
                              .two_wheeler_rounded
                          : Icons
                              .drive_eta_rounded,
                      size: 55,
                      color:
                          Colors.grey.shade400,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'أنت غير متصل',
                      style: TextStyle(
                        fontSize: 19,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      isMotorcycle
                          ? 'فعّل الحالة لاستقبال طلبات ألو جيبلي'
                          : 'فعّل الحالة لاستقبال طلبات ألو وصلني',
                      textAlign:
                          TextAlign.center,
                      style: TextStyle(
                        color:
                            Colors.grey.shade600,
                      ),
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

// ============================================================
// DRIVER STAT
// ============================================================

class DriverStatCard
    extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;

  const DriverStatCard({
    super.key,
    required this.title,
    required this.value,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: primaryGreen,
          ),
          const SizedBox(height: 13),
          Text(
            value,
            style: const TextStyle(
              fontSize: 21,
              fontWeight:
                  FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              color: Colors.grey.shade600,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CAR REQUEST
// ============================================================

class DriverRequestCard
    extends StatelessWidget {
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const DriverRequestCard({
    super.key,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return RequestContainer(
      color: primaryGreen,
      icon: Icons.local_taxi_rounded,
      title: 'طلب رحلة جديد',
      subtitle: 'راكب يريد الذهاب إلى وجهته',
      pickup: 'حي السلام',
      destination: 'وسط البلدية',
      price: '350 دج',
      onAccept: onAccept,
      onReject: onReject,
    );
  }
}

// ============================================================
// DELIVERY REQUEST
// ============================================================

class DeliveryRequestCard
    extends StatelessWidget {
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const DeliveryRequestCard({
    super.key,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return RequestContainer(
      color: deliveryOrange,
      icon: Icons.inventory_2_rounded,
      title: 'طلب ألو جيبلي جديد',
      subtitle: 'توصيل غرض بالدراجة',
      pickup: 'حي السلام',
      destination: 'وسط البلدية',
      price: '200 دج',
      onAccept: onAccept,
      onReject: onReject,
    );
  }
}

// ============================================================
// REQUEST CONTAINER
// ============================================================

class RequestContainer
    extends StatelessWidget {
  final Color color;
  final IconData icon;
  final String title;
  final String subtitle;
  final String pickup;
  final String destination;
  final String price;
  final VoidCallback onAccept;
  final VoidCallback onReject;

  const RequestContainer({
    super.key,
    required this.color,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.pickup,
    required this.destination,
    required this.price,
    required this.onAccept,
    required this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(22),
        border: Border.all(
          color: color.withOpacity(.25),
        ),
      ),
      child: Column(
        crossAxisAlignment:
            CrossAxisAlignment.start,
        children: [
          Row(
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
                      style:
                          const TextStyle(
                        fontSize: 19,
                        fontWeight:
                            FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(subtitle),
                  ],
                ),
              ),
              Container(
                padding:
                    const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color:
                      color.withOpacity(.10),
                  borderRadius:
                      BorderRadius.circular(
                    10,
                  ),
                ),
                child: Text(
                  'جديد',
                  style: TextStyle(
                    color: color,
                    fontWeight:
                        FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          RideLocationRow(
            icon:
                Icons.my_location_rounded,
            color: color,
            title: 'الاستلام',
            value: pickup,
          ),

          const SizedBox(height: 15),

          RideLocationRow(
            icon:
                Icons.location_on_rounded,
            color: Colors.redAccent,
            title: 'التسليم',
            value: destination,
          ),

          const Divider(height: 30),

          PriceRow(
            title: 'السعر',
            value: price,
            bold: true,
          ),

          const SizedBox(height: 15),

          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: onReject,
                  child:
                      const Text('رفض'),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: FilledButton(
                  style:
                      FilledButton.styleFrom(
                    backgroundColor: color,
                  ),
                  onPressed: onAccept,
                  child:
                      const Text('قبول'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// DRIVER ACTIVE RIDE
// ============================================================

class DriverActiveRideScreen
    extends StatelessWidget {
  const DriverActiveRideScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title:
              const Text('الرحلة الحالية'),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.all(18),
            child: Column(
              children: [
                const FakeMap(),
                const SizedBox(height: 18),

                const AccountHeader(
                  icon: Icons.person_rounded,
                  title: 'الراكب: أحمد',
                  subtitle: '⭐ 4.8',
                ),

                const SizedBox(height: 15),

                const RideLocationRow(
                  icon:
                      Icons.my_location_rounded,
                  color: primaryGreen,
                  title: 'الانطلاق',
                  value: 'حي السلام',
                ),

                const SizedBox(height: 15),

                const RideLocationRow(
                  icon:
                      Icons.location_on_rounded,
                  color: Colors.redAccent,
                  title: 'الوجهة',
                  value: 'وسط البلدية',
                ),

                const SizedBox(height: 20),

                const DriverStatCard(
                  title: 'قيمة الرحلة',
                  value: '350 دج',
                  icon:
                      Icons.payments_rounded,
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: FilledButton.icon(
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) =>
                            AlertDialog(
                          title: const Text(
                            'إنهاء الرحلة',
                          ),
                          content:
                              const Text(
                            'هل وصلت بالراكب إلى الوجهة؟',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(
                                context,
                              ),
                              child:
                                  const Text(
                                'لا',
                              ),
                            ),
                            FilledButton(
                              onPressed: () {
                                Navigator.pop(
                                  context,
                                );
                                Navigator.pop(
                                  context,
                                );
                                showMessage(
                                  context,
                                  'تم إنهاء الرحلة بنجاح',
                                );
                              },
                              child:
                                  const Text(
                                'نعم',
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons
                          .check_circle_rounded,
                    ),
                    label: const Text(
                      'إنهاء الرحلة',
                    ),
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
// DRIVER ACTIVE DELIVERY
// ============================================================

class DriverActiveDeliveryScreen
    extends StatelessWidget {
  const DriverActiveDeliveryScreen({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            'توصيل ألو جيبلي',
          ),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding:
                const EdgeInsets.all(18),
            child: Column(
              children: [
                const FakeMap(),

                const SizedBox(height: 18),

                const AccountHeader(
                  icon:
                      Icons.inventory_2_rounded,
                  title: 'طلب توصيل',
                  subtitle:
                      'الزبون: أحمد',
                ),

                const SizedBox(height: 18),

                Container(
                  padding:
                      const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(
                      20,
                    ),
                  ),
                  child: const Column(
                    children: [
                      RideLocationRow(
                        icon: Icons
                            .inventory_2_rounded,
                        color:
                            deliveryOrange,
                        title:
                            'مكان استلام الغرض',
                        value: 'حي السلام',
                      ),
                      SizedBox(height: 18),
                      RideLocationRow(
                        icon: Icons
                            .location_on_rounded,
                        color:
                            Colors.redAccent,
                        title:
                            'مكان التسليم',
                        value:
                            'وسط البلدية',
                      ),
                      Divider(height: 30),
                      RideLocationRow(
                        icon: Icons
                            .inventory_2_outlined,
                        color:
                            deliveryOrange,
                        title: 'الغرض',
                        value:
                            'علبة صغيرة',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 15),

                const DriverStatCard(
                  title:
                      'قيمة التوصيل',
                  value: '200 دج',
                  icon:
                      Icons.payments_rounded,
                ),

                const SizedBox(height: 20),

                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: FilledButton.icon(
                    style:
                        FilledButton.styleFrom(
                      backgroundColor:
                          deliveryOrange,
                    ),
                    onPressed: () {
                      showDialog(
                        context: context,
                        builder: (_) =>
                            AlertDialog(
                          title: const Text(
                            'تأكيد التسليم',
                          ),
                          content:
                              const Text(
                            'هل سلمت الغرض للمستلم؟',
                          ),
                          actions: [
                            TextButton(
                              onPressed: () =>
                                  Navigator.pop(
                                context,
                              ),
                              child:
                                  const Text(
                                'لا',
                              ),
                            ),
                            FilledButton(
                              onPressed: () {
                                Navigator.pop(
                                  context,
                                );
                                Navigator.pop(
                                  context,
                                );
                                showMessage(
                                  context,
                                  'تم إنهاء التوصيل بنجاح',
                                );
                              },
                              child:
                                  const Text(
                                'نعم، تم التسليم',
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                    icon: const Icon(
                      Icons
                          .check_circle_rounded,
                    ),
                    label: const Text(
                      'تم تسليم الغرض',
                    ),
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
// DRIVER EARNINGS
// ============================================================

class DriverEarningsScreen
    extends StatelessWidget {
  final DriverType driverType;

  const DriverEarningsScreen({
    super.key,
    required this.driverType,
  });

  bool get isMotorcycle =>
      driverType == DriverType.motorcycle;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: ListView(
          padding:
              const EdgeInsets.all(18),
          children: [
            Text(
              isMotorcycle
                  ? 'أرباح ألو جيبلي'
                  : 'أرباح ألو وصلني',
              style: const TextStyle(
                fontSize: 27,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            Container(
              padding:
                  const EdgeInsets.all(25),
              decoration: BoxDecoration(
                gradient:
                    const LinearGradient(
                  colors: [
                    primaryGreen,
                    darkGreen,
                  ],
                ),
                borderRadius:
                    BorderRadius.circular(
                  24,
                ),
              ),
              child: Column(
                crossAxisAlignment:
                    CrossAxisAlignment.start,
                children: [
                  const Text(
                    'أرباح اليوم',
                    style: TextStyle(
                      color:
                          Colors.white70,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    isMotorcycle
                        ? '1,600 دج'
                        : '2,450 دج',
                    style:
                        const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight:
                          FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 15),
                  Text(
                    isMotorcycle
                        ? '8 توصيلات اليوم'
                        : '8 رحلات اليوم',
                    style:
                        const TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 20),

            Text(
              isMotorcycle
                  ? 'آخر التوصيلات'
                  : 'آخر الرحلات',
              style: const TextStyle(
                fontSize: 19,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 12),

            EarningsItem(
              icon: isMotorcycle
                  ? Icons
                      .two_wheeler_rounded
                  : Icons
                      .local_taxi_rounded,
              destination:
                  'وسط البلدية',
              time: '10:30',
              amount: isMotorcycle
                  ? '200 دج'
                  : '350 دج',
            ),

            EarningsItem(
              icon: isMotorcycle
                  ? Icons
                      .two_wheeler_rounded
                  : Icons
                      .local_taxi_rounded,
              destination: 'حي النور',
              time: '11:15',
              amount: isMotorcycle
                  ? '250 دج'
                  : '450 دج',
            ),

            EarningsItem(
              icon: isMotorcycle
                  ? Icons
                      .two_wheeler_rounded
                  : Icons
                      .local_taxi_rounded,
              destination: 'المحطة',
              time: '12:40',
              amount: isMotorcycle
                  ? '180 دج'
                  : '300 دج',
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// EARNINGS ITEM
// ============================================================

class EarningsItem
    extends StatelessWidget {
  final IconData icon;
  final String destination;
  final String time;
  final String amount;

  const EarningsItem({
    super.key,
    required this.icon,
    required this.destination,
    required this.time,
    required this.amount,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin:
          const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: lightGreen,
          child: Icon(
            icon,
            color: primaryGreen,
          ),
        ),
        title: Text(
          destination,
          style: const TextStyle(
            fontWeight:
                FontWeight.bold,
          ),
        ),
        subtitle: Text(time),
        trailing: Text(
          amount,
          style: const TextStyle(
            color: primaryGreen,
            fontWeight:
                FontWeight.bold,
          ),
        ),
      ),
    );
  }
}

// ============================================================
// DRIVER ACCOUNT
// ============================================================

class DriverAccountScreen
    extends StatelessWidget {
  final DriverType driverType;

  const DriverAccountScreen({
    super.key,
    required this.driverType,
  });

  bool get isMotorcycle =>
      driverType == DriverType.motorcycle;

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: SafeArea(
        child: ListView(
          padding:
              const EdgeInsets.all(18),
          children: [
            Text(
              isMotorcycle
                  ? 'حساب سائق الدراجة'
                  : 'حساب سائق السيارة',
              style: const TextStyle(
                fontSize: 27,
                fontWeight:
                    FontWeight.bold,
              ),
            ),

            const SizedBox(height: 20),

            AccountHeader(
              icon: isMotorcycle
                  ? Icons
                      .two_wheeler_rounded
                  : Icons
                      .drive_eta_rounded,
              title: 'محمد',
              subtitle: isMotorcycle
                  ? 'سائق ألو جيبلي'
                  : 'سائق ألو وصلني',
            ),

            const SizedBox(height: 15),

            AccountItem(
              icon: isMotorcycle
                  ? Icons
                      .two_wheeler_outlined
                  : Icons
                      .directions_car_outlined,
              title: isMotorcycle
                  ? 'بيانات الدراجة'
                  : 'بيانات السيارة',
              onTap: () {
                showMessage(
                  context,
                  'هذه الصفحة ستضاف لاحقاً',
                );
              },
            ),

            AccountItem(
              icon: Icons.badge_outlined,
              title: 'وثائق السائق',
              onTap: () {
                showMessage(
                  context,
                  'التحقق من الوثائق سيضاف لاحقاً',
                );
              },
            ),

            AccountItem(
              icon: Icons.settings_outlined,
              title: 'الإعدادات',
              onTap: () {
                showMessage(
                  context,
                  'الإعدادات ستضاف لاحقاً',
                );
              },
            ),

            const SizedBox(height: 15),

            OutlinedButton.icon(
              onPressed: () async {
                await FirebaseAuth.instance
                    .signOut();

                if (!context.mounted) return;

                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        const RoleScreen(),
                  ),
                  (route) => false,
                );
              },
              icon: const Icon(
                Icons.logout_rounded,
              ),
              label: const Text(
                'تسجيل الخروج',
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ============================================================
// ACCOUNT HEADER
// ============================================================

class AccountHeader
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;

  const AccountHeader({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding:
          const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius:
            BorderRadius.circular(22),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 35,
            backgroundColor: lightGreen,
            child: Icon(
              icon,
              color: primaryGreen,
              size: 38,
            ),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment:
                CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
              const SizedBox(height: 5),
              Text(subtitle),
            ],
          ),
        ],
      ),
    );
  }
}

// ============================================================
// ACCOUNT ITEM
// ============================================================

class AccountItem
    extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const AccountItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 0,
      margin:
          const EdgeInsets.only(bottom: 8),
      child: ListTile(
        onTap: onTap,
        leading: Icon(
          icon,
          color: primaryGreen,
        ),
        title: Text(title),
        trailing: const Icon(
          Icons
              .arrow_back_ios_new_rounded,
          size: 16,
        ),
      ),
    );
  }
}

// ============================================================
// FAKE MAP
// ============================================================

class FakeMap extends StatelessWidget {
  const FakeMap({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 210,
      width: double.infinity,
      decoration: BoxDecoration(
        color: const Color(0xFFE3EDE8),
        borderRadius:
            BorderRadius.circular(22),
        border: Border.all(
          color: Colors.grey.shade300,
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: 30,
            left: 20,
            right: 20,
            child: Container(
              height: 2,
              color: Colors.white,
            ),
          ),
          Positioned(
            top: 85,
            left: 0,
            right: 0,
            child: Transform.rotate(
              angle: .1,
              child: Container(
                height: 8,
                color: Colors.white,
              ),
            ),
          ),
          Positioned(
            top: 145,
            left: 40,
            right: 20,
            child: Transform.rotate(
              angle: -.15,
              child: Container(
                height: 5,
                color: Colors.white,
              ),
            ),
          ),
          const Center(
            child: Icon(
              Icons.location_on_rounded,
              size: 52,
              color: primaryGreen,
            ),
          ),
          Positioned(
            bottom: 12,
            right: 12,
            child: Container(
              padding:
                  const EdgeInsets.symmetric(
                horizontal: 12,
                vertical: 8,
              ),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius:
                    BorderRadius.circular(
                  12,
                ),
              ),
              child: const Text(
                'داخل البلدية',
                style: TextStyle(
                  fontWeight:
                      FontWeight.bold,
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
// RIDE LOCATION ROW
// ============================================================

class RideLocationRow
    extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String value;

  const RideLocationRow({
    super.key,
    required this.icon,
    required this.color,
    required this.title,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          color: color,
          size: 25,
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
                  color:
                      Colors.grey.shade600,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                value,
                style: const TextStyle(
                  fontWeight:
                      FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================
// PRICE ROW
// ============================================================

class PriceRow extends StatelessWidget {
  final String title;
  final String value;
  final bool bold;

  const PriceRow({
    super.key,
    required this.title,
    required this.value,
    this.bold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Text(title),
        ),
        const SizedBox(width: 10),
        Flexible(
          child: Text(
            value,
            textAlign: TextAlign.end,
            style: TextStyle(
              fontWeight: bold
                  ? FontWeight.bold
                  : FontWeight.normal,
              fontSize: bold ? 19 : 15,
              color: bold
                  ? primaryGreen
                  : null,
            ),
          ),
        ),
      ],
    );
  }
}

// ============================================================
// MESSAGE
// ============================================================

void showMessage(
  BuildContext context,
  String message,
) {
  ScaffoldMessenger.of(context)
      .hideCurrentSnackBar();

  ScaffoldMessenger.of(context)
      .showSnackBar(
    SnackBar(
      content: Text(
        message,
        textAlign: TextAlign.right,
      ),
      behavior:
          SnackBarBehavior.floating,
      duration:
          const Duration(seconds: 2),
    ),
  );
}
