import 'package:employee_wellness/home.dart';
import 'package:employee_wellness/register.dart';
import 'package:employee_wellness/services/auth_service.dart';
import 'package:employee_wellness/services/background_steps_tracker.dart';
import 'package:employee_wellness/services/background_task_service.dart';
import 'package:employee_wellness/services/offline_steps_service.dart';
import 'package:employee_wellness/services/steps_sync_service.dart';
import 'package:employee_wellness/services/language_provider.dart';
import 'package:employee_wellness/services/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await BackgroundTaskService.instance.initialize();
  final isLoggedIn = await AuthService.isLoggedIn();
  if (isLoggedIn) {
    print('🚀 User is logged in, initializing background services...');
    await BackgroundStepsTracker.initialize();
    await BackgroundTaskService.instance.registerPeriodicSync();
    await BackgroundTaskService.instance.registerCleanupTask();
    await StepsSyncService.instance.autoSync();
  }
  runApp(
    ChangeNotifierProvider(
      create: (context) => LanguageProvider(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  Future<bool> checkLogin() async => await AuthService.isLoggedIn();

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Employee Wellness',
      locale: languageProvider.currentLocale,
      supportedLocales: const [
        Locale('en', 'US'),
        Locale('id', 'ID'),
      ],
      localizationsDelegates: const [
        AppLocalizations.delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      home: FutureBuilder(
        future: checkLogin(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Scaffold(body: Center(child: CircularProgressIndicator()));
          } else {
            return snapshot.data == true ? const HomePage() : const LoginPage();
          }
        },
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
  bool _rememberMe = true;

  // Declare errorIcon for snackbar
  IconData? errorIcon; // ✅ added

  Future<void> login() async {
    print("🔵 Login button pressed");
    final loc = AppLocalizations.of(context)!;
    if (emailController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.translate('email_required')), backgroundColor: Colors.red),
      );
      return;
    }
    if (passwordController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.translate('password_required')), backgroundColor: Colors.red),
      );
      return;
    }
    setState(() => isLoading = true);
    final result = await AuthService.login(
      email: emailController.text.trim(),
      password: passwordController.text.trim(),
      rememberMe: _rememberMe,
    );
    setState(() => isLoading = false);

    if (result["success"]) {
      await BackgroundStepsTracker.initialize();
      await OfflineStepsService.autoSyncOnAppStart();
      if (!mounted) return;
      await Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => const HomePage()),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                const Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                Text(loc.translate('login_success')),
              ],
            ),
            backgroundColor: const Color(0xFF00C368),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } else {
      print("❌ Login FAILED: ${result['message']}");
      String errorMessage = result["message"] ?? loc.translate('login_failed');
      errorIcon = Icons.error_outline; // ✅ now defined
      Color errorColor = Colors.red;

      if (errorMessage.toLowerCase().contains("email atau password salah") ||
          errorMessage.toLowerCase().contains("credentials")) {
        errorMessage = loc.translate('invalid_credentials');
        errorIcon = Icons.lock_outline;
      } else if (errorMessage.toLowerCase().contains("network") ||
          errorMessage.toLowerCase().contains("connection")) {
        errorMessage = loc.translate('server_error');
        errorIcon = Icons.wifi_off;
      }

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(errorIcon, color: Colors.white), // ✅ now valid
              const SizedBox(width: 12),
              Expanded(
                child: Text(errorMessage, style: const TextStyle(fontSize: 14)),
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
    final loc = AppLocalizations.of(context)!;
    return Scaffold(
      backgroundColor: const Color(0xFFEDFDF4),
      body: SingleChildScrollView(
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Color(0xFF00C97A),
                  child: FaIcon(FontAwesomeIcons.building, size: 40, color: Colors.white), // ✅ already FaIcon
                ),
                const SizedBox(height: 20),
                Text(loc.translate('app_title'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 16),
                Text(loc.translate('app_subtitle'), style: const TextStyle(fontSize: 16, color: Color(0xFF4A5565))),
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
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(loc.translate('login_title'), style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w600), textAlign: TextAlign.center),
                        const SizedBox(height: 20),
                        TextField(
                          controller: emailController,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.email_outlined),
                            hintText: loc.translate('email_hint'),
                            labelText: loc.translate('email_label'),
                            isDense: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: passwordController,
                          obscureText: _obscurePassword,
                          decoration: InputDecoration(
                            prefixIcon: const Icon(Icons.lock_outline),
                            suffixIcon: IconButton(
                              onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
                              icon: Icon(_obscurePassword ? Icons.visibility_outlined : Icons.visibility_off_outlined),
                            ),
                            hintText: loc.translate('password_hint'),
                            labelText: loc.translate('password_label'),
                            isDense: true,
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                        Align(
                          alignment: Alignment.centerRight,
                          child: TextButton(
                            onPressed: () {},
                            child: Text(loc.translate('forgot_password'), style: const TextStyle(color: Color(0xFF30B762), fontSize: 16)),
                          ),
                        ),
                        const SizedBox(height: 8),
                        SizedBox(
                          width: double.infinity,
                          height: 52,
                          child: ElevatedButton(
                            onPressed: isLoading ? null : login,
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                              backgroundColor: const Color(0xFF7EDFBB),
                            ),
                            child: isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text(loc.translate('login_button'), style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: Colors.white)),
                          ),
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(loc.translate('no_account'), style: const TextStyle(fontSize: 16)),
                            GestureDetector(
                              onTap: () => Navigator.push(context, MaterialPageRoute(builder: (context) => const Register())),
                              child: Text(loc.translate('register_now'), style: const TextStyle(fontSize: 16, color: Colors.green, fontWeight: FontWeight.w500)),
                            ),
                          ],
                        ),
                      ],
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