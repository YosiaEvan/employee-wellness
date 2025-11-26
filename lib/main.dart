import 'package:employee_wellness/home.dart';
import 'package:employee_wellness/register.dart';
import 'package:employee_wellness/services/auth_service.dart';
import 'package:employee_wellness/services/background_steps_tracker.dart';
import 'package:employee_wellness/services/background_task_service.dart';
import 'package:employee_wellness/services/offline_steps_service.dart';
import 'package:employee_wellness/services/steps_sync_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize background task service
  await BackgroundTaskService.instance.initialize();

  // Initialize background steps tracker if user is logged in
  final isLoggedIn = await AuthService.isLoggedIn();
  if (isLoggedIn) {
    print('🚀 User is logged in, initializing background services...');

    // Initialize background tracker
    await BackgroundStepsTracker.initialize();

    // Register background tasks
    await BackgroundTaskService.instance.registerPeriodicSync();
    await BackgroundTaskService.instance.registerCleanupTask();

    // Run auto sync on app start
    await StepsSyncService.instance.autoSync();
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> checkLogin() async {
    return await AuthService.isLoggedIn();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Employee Wellness',
      home: FutureBuilder(
        future: checkLogin(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else {
            if (snapshot.data == true) {
              return const HomePage(); // Go to home if logged in
            } else {
              return const LoginPage(); // Go to login if not
            }
          }
        }
      ),
    );
  }
}

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  bool isLoading = false;
  bool _obscurePassword = true;
  bool _rememberMe = true; // Remember credentials for auto-refresh

  Future<void> login() async {
    print("🔵 Login button pressed");

    // Validation
    if (emailController.text.trim().isEmpty) {
      print("❌ Validation failed: Email empty");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Email harus diisi"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    if (passwordController.text.trim().isEmpty) {
      print("❌ Validation failed: Password empty");
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Password harus diisi"),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    print("✅ Validation passed");
    print("📧 Email: ${emailController.text.trim()}");

    setState(() {
      isLoading = true;
    });

    // Use new AuthService with auto-refresh capability
    print("🔄 Calling AuthService.login()...");
    final result = await AuthService.login(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      rememberMe: _rememberMe, // Save credentials
    );

    print("📨 Login result received: ${result['success']}");

    setState(() {
      isLoading = false;
    });

    if (result["success"]) {
      // Success - Initialize background services
      print("✅ Login SUCCESS! Token: ${result['token']?.substring(0, 20)}...");

      // Initialize background tracker
      print("🚀 Initializing background services...");
      await BackgroundStepsTracker.initialize();
      await OfflineStepsService.autoSyncOnAppStart();
      print("✅ Background services initialized");

      print("🚀 Navigating to HomePage...");

      try {
        // Navigate
        await Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) {
            print("🏠 Building HomePage widget...");
            return const HomePage();
          }),
        );

        print("✅ Navigation completed successfully!");

        // Show success message after navigation
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Row(
                children: const [
                  Icon(Icons.check_circle, color: Colors.white),
                  SizedBox(width: 8),
                  Text("Login berhasil! Selamat datang."),
                ],
              ),
              backgroundColor: const Color(0xFF00C368),
              duration: const Duration(seconds: 2),
            ),
          );
        }
      } catch (error) {
        // Handle navigation error
        print("❌ Navigation error: $error");
        print("❌ Stack trace: ${StackTrace.current}");

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text("Error navigasi: $error"),
              backgroundColor: Colors.red,
              duration: const Duration(seconds: 5),
            ),
          );
        }
      }
    } else {
      print("❌ Login FAILED: ${result['message']}");

      // Failed - Show error notification
      String errorMessage = result["message"] ?? "Login gagal";
      IconData errorIcon = Icons.error_outline;
      Color errorColor = Colors.red;

      // Customize message based on error
      if (errorMessage.toLowerCase().contains("email atau password salah") ||
          errorMessage.toLowerCase().contains("credentials")) {
        errorMessage = "Email atau password salah!\nSilakan periksa kembali data Anda.";
        errorIcon = Icons.lock_outline;
      } else if (errorMessage.toLowerCase().contains("network") ||
          errorMessage.toLowerCase().contains("connection")) {
        errorMessage = "Tidak dapat terhubung ke server.\nPeriksa koneksi internet Anda.";
        errorIcon = Icons.wifi_off;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(errorIcon, color: Colors.white),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  errorMessage,
                  style: const TextStyle(fontSize: 14),
                ),
              ),
            ],
          ),
          backgroundColor: errorColor,
          duration: const Duration(seconds: 4),
          action: SnackBarAction(
            label: "OK",
            textColor: Colors.white,
            onPressed: () {},
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xFFEDFDF4),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                CircleAvatar(
                  radius: 40,
                  backgroundColor: const Color(0xFF00C97A),
                  child: Icon(FontAwesomeIcons.building, size: 40, color: Colors.white),
                ),

                const SizedBox(height: 20),

                const Text(
                  "Employee Wellness",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                const Text(
                  "Kesehatan & Kebahagiaan Karyawan",
                  style: TextStyle(
                    fontSize: 16,
                    color: Color(0xFF4A5565),
                  ),
                ),

                const SizedBox(height: 20),

                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Container(
                    padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          "Masuk ke Akun Anda",
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.w600,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 20),

                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.email_outlined),
                            hintText: "nama@perusahaan.com",
                            labelText: "Email",
                            isDense: true,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)
                            ),
                          ),
                        ),

                        const SizedBox(height: 16),

                        TextField(
                          controller: passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              onPressed: () {
                                setState(() {
                                  _obscurePassword = !_obscurePassword;
                                });
                              },
                              icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                            ),
                            hintText: "Masukan kata sandi",
                            labelText: "Kata Sandi",
                            isDense: true,
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10)
                            ),
                          ),
                        ),

                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                              onPressed: () {},
                              child: const Text(
                                "Lupa kata sandi?",
                                style: TextStyle(
                                  color: Color(0xFF30B762),
                                  fontSize: 16,
                                ),
                              )
                          ),
                        ),

                        SizedBox(height: 8,),

                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : login,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              backgroundColor: Color(0xFF7EDFBB),
                            ),
                            child: isLoading
                              ? const CircularProgressIndicator(color: Colors.white)
                              : const Text(
                              "Masuk",
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),

                        SizedBox(height: 24,),

                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Belum punya akun? ",
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                            GestureDetector(
                              onTap: () => {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(builder: (context) => const Register()),
                                )
                              },
                              child: Text(
                                "Registrasi",
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.green,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ],
                        )
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
