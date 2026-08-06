import 'dart:async';
import 'dart:convert';
import 'package:employee_wellness/main.dart';
import 'package:employee_wellness/pages/health_profile.dart';
import 'package:employee_wellness/pages/settings_page.dart';
import 'package:employee_wellness/services/user_cache_service.dart';
import 'package:employee_wellness/services/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class Header extends StatefulWidget {
  const Header({super.key});

  @override
  State<Header> createState() => _HeaderState();
}

class _HeaderState extends State<Header> with AutomaticKeepAliveClientMixin {
  final UserCacheService _cacheService = UserCacheService();
  String namaLengkap = "Employee Wellness";
  String? fotoUrl;
  String? fotoBase64;
  bool isLoading = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    // Get cached data immediately if available
    final cachedName = _cacheService.getCachedName();
    if (cachedName != null) {
      setState(() {
        namaLengkap = cachedName;
        fotoUrl = _cacheService.getCachedPhotoUrl();
        fotoBase64 = _cacheService.getCachedPhotoBase64();
        isLoading = false;
      });
      return;
    }

    setState(() => isLoading = true);

    // Load from cache service (with API fallback)
    final userData = await _cacheService.getUserData();

    setState(() {
      namaLengkap = userData['nama_lengkap'] ?? "Employee Wellness";
      fotoUrl = userData['foto_url'];
      fotoBase64 = userData['foto_base64'];
      isLoading = false;
    });

  }

  Future<void> logout(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    final loc = AppLocalizations.of(context)!;

    try {
      // Clear local storage only (no API call)
      await prefs.remove("token");
      await prefs.remove("email");
      await prefs.remove("password");
      await prefs.remove("rememberMe");

      // Clear user data cache using UserCacheService
      await _cacheService.clearCache();


      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(loc.translate('logout_success'))),
      );

      // Redirect to login and remove all previous routes
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
      );
    } catch (e) {

      // Even if error, try to clear storage and redirect
      await prefs.remove("token");
      await prefs.remove("email");
      await prefs.remove("password");
      await prefs.remove("rememberMe");
      await _cacheService.clearCache();

      // Still redirect to login
      Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (context) => const LoginPage()),
          (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context); // Required for AutomaticKeepAliveClientMixin
    final loc = AppLocalizations.of(context)!;

    return Container(
      padding: const EdgeInsets.all(16),
      width: double.infinity,
      color: Colors.white,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Avatar - Show photo from base64 or URL, otherwise show default icon
          CircleAvatar(
            radius: 20,
            backgroundColor: (fotoBase64 != null || fotoUrl != null)
                ? Colors.transparent
                : Colors.grey.withOpacity(0.80),
            backgroundImage: fotoUrl != null ? NetworkImage(fotoUrl!) : null,
            child: fotoBase64 != null
                ? ClipOval(
                    child: Builder(
                      builder: (context) {
                        try {
                          return Image.memory(
                            base64Decode(fotoBase64!),
                            width: 40,
                            height: 40,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return const Icon(Icons.person, color: Colors.white, size: 24);
                            },
                          );
                        } catch (e) {
                          return const Icon(Icons.person, color: Colors.white, size: 24);
                        }
                      },
                    ),
                  )
                : (fotoUrl == null
                    ? const Icon(Icons.person, color: Colors.white, size: 24)
                    : null),
          ),

          const SizedBox(width: 10),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  namaLengkap,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  loc.translate('app_subtitle'),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                // Realtime clock - Widget terpisah untuk prevent rebuild parent
                const RealtimeClock(),
              ],
            ),
          ),

          const SizedBox(width: 10),

          Row(
            children: [
              PopupMenuButton<String>(
                color: Colors.white,
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                offset: const Offset(0, 50),
                onSelected: (value) {
                  if (value == 'profile') {
                    // Navigate to Health Profile
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const HealthProfile()),
                    ).then((_) {
                      // Refresh user data when returning from profile page
                      _loadUserData();
                    });
                  } else if (value == 'settings') {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => const SettingsPage()),
                    );
                  } else if (value == 'logout') {
                    logout(context);
                  }
                },
                itemBuilder: (BuildContext context) => [
                  PopupMenuItem(
                    value: 'profile',
                    child: SizedBox(
                      width: 191,
                      child: Row(
                        children: [
                          const FaIcon(FontAwesomeIcons.circleUser, size: 20, color: Colors.blue),
                          const SizedBox(width: 12),
                          Text(loc.translate('profile_menu')),
                        ],
                      ),
                    )
                  ),
                  PopupMenuItem(
                    value: 'settings',
                    child: SizedBox(
                      width: 191,
                      child: Row(
                        children: [
                          const Icon(Icons.settings, size: 20, color: Colors.blueGrey),
                          const SizedBox(width: 12),
                          Text(loc.translate('settings_title')),
                        ],
                      ),
                    )
                  ),
                  PopupMenuItem(
                    value: 'logout',
                    child: SizedBox(
                      width: 191,
                      child: Row(
                        children: [
                          const Icon(Icons.logout, color: Colors.red),
                          const SizedBox(width: 12),
                          Text(loc.translate('logout_button')),
                        ],
                      ),
                    )
                  ),
                ],
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.more_vert,
                    color: Colors.grey,
                    size: 24,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Widget terpisah untuk realtime clock agar tidak rebuild Header
class RealtimeClock extends StatefulWidget {
  const RealtimeClock({super.key});

  @override
  State<RealtimeClock> createState() => _RealtimeClockState();
}

class _RealtimeClockState extends State<RealtimeClock> {
  String currentTime = "";
  String currentDay = "";
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _startRealtimeClock();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  /// Fetch waktu online dari World Time API
  Future<DateTime?> _fetchOnlineTime() async {
    try {
      final response = await http.get(
        Uri.parse('https://worldtimeapi.org/api/timezone/Asia/Jakarta'),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final datetime = DateTime.parse(data['datetime']);
        print('📅 Online time fetched: $datetime');
        return datetime;
      }
    } catch (e) {
      print('❌ Error fetching online time: $e');
    }

    // Fallback to local time if API fails
    return DateTime.now();
  }

  /// Start realtime clock dengan waktu online
  Future<void> _startRealtimeClock() async {
    // Fetch waktu online
    final onlineTime = await _fetchOnlineTime();
    final now = onlineTime ?? DateTime.now();

    // Update UI pertama kali
    _updateClockDisplay(now);

    // Start timer untuk update setiap detik
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      final currentTime = DateTime.now();
      _updateClockDisplay(currentTime);
    });
  }

  /// Update tampilan jam dan hari
  void _updateClockDisplay(DateTime time) {
    if (!mounted) return;

    final locale = Localizations.localeOf(context).languageCode;
    final isIndonesian = locale == 'id';

    // Format hari
    final List<String> hariIndonesia = [
      'Senin', 'Selasa', 'Rabu', 'Kamis', 'Jumat', 'Sabtu', 'Minggu'
    ];
    final List<String> dayNamesEnglish = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'
    ];

    final dayOfWeek = isIndonesian 
        ? hariIndonesia[time.weekday - 1] 
        : dayNamesEnglish[time.weekday - 1];
    
    final formattedTime = DateFormat('HH:mm:ss').format(time);
    final formattedDate = DateFormat('dd/MM/yyyy').format(time);

    setState(() {
      currentDay = '$dayOfWeek, $formattedDate';
      currentTime = formattedTime;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Icon(
          Icons.access_time,
          size: 12,
          color: Colors.grey,
        ),
        const SizedBox(width: 4),
        Text(
          currentDay.isNotEmpty ? '$currentDay $currentTime' : 'Memuat...',
          style: const TextStyle(
            fontSize: 10,
            color: Colors.grey,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
