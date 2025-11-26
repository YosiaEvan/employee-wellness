import 'package:employee_wellness/components/bottom_header.dart';
import 'package:employee_wellness/components/header.dart';
import 'package:employee_wellness/components/smart_food_search.dart';
import 'package:employee_wellness/pages/sehat/udara_segar.dart';
import 'package:employee_wellness/pages/sehat_homepage.dart';
import 'package:employee_wellness/services/tracking_kalori_service.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class PolaMakanSehat extends StatefulWidget {
  const PolaMakanSehat({super.key});

  @override
  State<PolaMakanSehat> createState() => _PolaMakanSehatState();
}

class _PolaMakanSehatState extends State<PolaMakanSehat> {
  bool isLoading = true;

  // New API structure
  Map<String, dynamic> trackingData = {};
  Map<String, dynamic> targetData = {};
  Map<String, dynamic> konsumsiData = {};
  Map<String, dynamic> progressData = {};
  Map<String, dynamic> sisaData = {};
  Map<String, dynamic> daftarMakanan = {
    'sarapan': [],
    'makan_siang': [],
    'makan_malam': [],
    'snack': [],
  };
  int totalItem = 0;

  // Legacy - for backward compatibility
  List<Map<String, dynamic>> foods = [];

  // Health Challenge
  int hariMakanBerminyak = 0;
  int hariMakanBergula = 0;
  int hariTanpaMinyak = 0;
  int hariTanpaGula = 0;
  bool isChallengeAchieved = false;

  double get totalCalories => konsumsiData['kalori']?.toDouble() ?? 0.0;
  double get targetCalories => targetData['kalori']?.toDouble() ?? 2000.0;
  double get remainingCalories => sisaData['kalori']?.toDouble() ?? 0.0;
  double get progress => progressData['kalori']?.toDouble() ?? 0.0;

  // Nutrition from konsumsi
  double get totalProtein => konsumsiData['protein']?.toDouble() ?? 0.0;
  double get totalCarb => konsumsiData['karbohidrat']?.toDouble() ?? 0.0;
  double get totalFiber => konsumsiData['serat']?.toDouble() ?? 0.0;
  double get totalAll => totalProtein + totalCarb + totalFiber;

  @override
  void initState() {
    super.initState();
    loadTodayFood();
  }

  Future<void> loadTodayFood() async {
    setState(() => isLoading = true);

    final result = await TrackingKaloriService.getTrackingHariIni();

    setState(() {
      isLoading = false;
      if (result["success"] && result["data"] != null) {
        trackingData = result["data"];
        targetData = trackingData['target'] ?? {};
        konsumsiData = trackingData['konsumsi'] ?? {};
        progressData = trackingData['progress'] ?? {};
        sisaData = trackingData['sisa'] ?? {};

        // Parse daftar_makanan
        final daftarMakananRaw = trackingData['daftar_makanan'] ?? {};
        daftarMakanan = {
          'sarapan': List<Map<String, dynamic>>.from(daftarMakananRaw['sarapan'] ?? []),
          'makan_siang': List<Map<String, dynamic>>.from(daftarMakananRaw['makan_siang'] ?? []),
          'makan_malam': List<Map<String, dynamic>>.from(daftarMakananRaw['makan_malam'] ?? []),
          'snack': List<Map<String, dynamic>>.from(daftarMakananRaw['snack'] ?? []),
        };

        totalItem = trackingData['total_item'] ?? 0;

        // Flatten for legacy compatibility
        foods = [];
        daftarMakanan.forEach((jenis, items) {
          foods.addAll(items);
        });
  } else {
      }

      // Check health challenge
      _checkHealthChallenge();
    });
  }

void _checkHealthChallenge() {
  // Get riwayat_seminggu data from API
  final riwayatSeminggu = trackingData['riwayat_seminggu'] ?? {};

  hariMakanBerminyak = riwayatSeminggu['hari_makan_berminyak'] ?? 0;
  hariMakanBergula = riwayatSeminggu['hari_makan_bergula'] ?? 0;

  // Calculate days WITHOUT oil and sugar in a week (7 days)
  hariTanpaMinyak = 7 - hariMakanBerminyak;
  hariTanpaGula = 7 - hariMakanBergula;

  // Challenge achieved if both targets met: minimal 2 days without oil AND 2 days without sugar in 7 days
  // This means maximum 5 days with oil OR 5 days with sugar
  if (hariTanpaMinyak >= 2 && hariTanpaGula >= 2) {
    isChallengeAchieved = true;
  } else {
    isChallengeAchieved = false;
  }

  print("🎯 Health Challenge Check (Weekly Data):");
  print("   - Hari makan berminyak: $hariMakanBerminyak / 7");
  print("   - Hari makan bergula: $hariMakanBergula / 7");
  print("   - Hari tanpa minyak: $hariTanpaMinyak / 7");
  print("   - Hari tanpa gula: $hariTanpaGula / 7");
  print("   - Challenge achieved: $isChallengeAchieved (target: 2 hari tanpa minyak & 2 hari tanpa gula)");
}

  Future<void> addFoodFromDatabase(Map<String, dynamic> result) async {
    print("\n🍽️ addFoodFromDatabase() called");
    print("   Result success: ${result["success"]}");

    // Set loading state untuk visual feedback
    if (mounted) {
      print("   Setting isLoading = true");
      setState(() {
        isLoading = true;
      });
    }

    print("   Calling loadTodayFood()...");
    // Force reload data dari API (bypass any cache)
    await loadTodayFood();

    print("   loadTodayFood() completed, forcing UI rebuild...");
    // Extra safety: Force rebuild UI setelah data loaded
    if (mounted) {
      setState(() {
        // Trigger complete rebuild
        print("   ✅ setState() called - UI should rebuild now");
      });
    }

    // Hide loading snackbar
    if (mounted) {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();
    }

    // Small delay untuk memastikan UI sudah rebuild
    await Future.delayed(const Duration(milliseconds: 100));

    print("   Preparing success notification...");
    print("   Current state after refresh:");
    print("   - totalCalories: $totalCalories");
    print("   - totalItem: $totalItem");
    print("   - foods.length: ${foods.length}");

    // Show success notification dengan data terbaru
    if (result["success"]) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(FontAwesomeIcons.check, color: Colors.white, size: 16),
                    const SizedBox(width: 8),
                    Expanded(child: Text(result['message'] ?? 'Berhasil menambahkan')),
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  '📊 Total Kalori: ${totalCalories.toStringAsFixed(1)} kkal',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
                Text(
                  '✅ Total Makanan: $totalItem item',
                  style: const TextStyle(fontSize: 12),
                ),
              ],
            ),
            backgroundColor: const Color(0xFF00C368),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(result["message"] ?? 'Gagal menambahkan'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    }

    print("✅ addFoodFromDatabase() completed!");
    print("═══════════════════════════════════════\n");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffe4f0e4).withValues(alpha: 0.98),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Header(),
            BottomHeader(color: Color(0xff00c368), heading: "Pola Makan Sehat", subHeading: "Nutrisi Seimbang", destination: SehatHomepage(),),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Calorie Counter
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.4),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: Offset(2, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          SizedBox.square(
                            dimension: 80,
                            child: Container(
                              padding: EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: Color(0xff00c368),
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: const Icon(
                                FontAwesomeIcons.fireFlameCurved,
                                size: 36,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(height: 20,),
                          Text(
                            "${totalCalories.toStringAsFixed(2)}",
                            style: TextStyle(
                              fontSize: 60,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12,),
                          Text(
                            "kalori hari ini",
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(height: 20,),
                          SizedBox(
                            height: 20,
                            child: LinearProgressIndicator(
                              value: progress/100,
                              color: Color(0xff00c368),
                              backgroundColor: Colors.grey[300],
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          SizedBox(height: 20,),
                          Text(
                            "${progress}% dari target",
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(height: 20,),
                          Container(
                            alignment: Alignment.center,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: Color(0xffbcf8d1),
                                width: 2,
                                style: BorderStyle.solid,
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      FontAwesomeIcons.bullseye,
                                      size: 20,
                                      color: Color(0xff00c368),
                                    ),
                                    SizedBox(width: 8,),
                                    Text(
                                      "${remainingCalories} kalori lagi",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff00c368),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8,),
                                Text(
                                  "Target: ${totalCalories} kalori",
                                  style: TextStyle(
                                    color: Color(0xff00c368),
                                    fontSize: 16,
                                  ),
                                )
                              ],
                            ),
                          )
                        ],
                      ),
                    ),

                    SizedBox(height: 20,),

                    // Distribusi Nutrisi
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.4),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: Offset(2, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              SizedBox.square(
                                dimension: 60,
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Color(0xff00c368),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    FontAwesomeIcons.arrowTrendUp,
                                    size: 36,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 20,),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Distribusi Nutirisi",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 20,),
                          foods.isEmpty
                          ? Container(
                            width: double.infinity,
                            height: 200,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Color(0xfff9fafb),
                            ),
                            child: Text(
                              "Belum ada data nutrisi hari ini",
                              style: TextStyle(
                                fontSize: 16,
                              ),
                            ),
                          )
                          : Container(
                            width: double.infinity,
                            height: 250,
                            child: Stack(
                              alignment: Alignment.center,
                              children: [
                                PieChart(
                                  PieChartData(
                                    centerSpaceRadius: 60,
                                    sectionsSpace: 2,
                                    startDegreeOffset: -90,
                                    sections: [
                                      PieChartSectionData(
                                        color: Colors.red,
                                        value: totalProtein,
                                        title: '',
                                      ),
                                      PieChartSectionData(
                                        color: Colors.blue,
                                        value: totalCarb,
                                        title: '',
                                      ),
                                      PieChartSectionData(
                                        color: Colors.green,
                                        value: totalFiber,
                                        title: '',
                                      )
                                    ]
                                  )
                                )
                              ],
                            ),
                          ),

                          SizedBox(height: 20,),

                          // Protein
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Color(0xfffef2f2),
                              border: Border.all(
                                  color: Color(0xffffc9c9),
                                  width: 2,
                                  style: BorderStyle.solid
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox.square(
                                          dimension: 10,
                                          child: Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Color(0xfffb2c36),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(""),
                                          ),
                                        ),
                                        SizedBox(width: 8,),
                                        Text(
                                          "Protein",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xffab252f)
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: 16,),
                                    Flexible(
                                      child: Text(
                                        "${((totalProtein/totalAll)*100).toStringAsFixed(2)}%",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.red,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${totalProtein}g",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.red,
                                      ),
                                    ),
                                    SizedBox(width: 16,),
                                    Flexible(
                                      child: Text(
                                        "Target: 30%",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.red,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            )
                          ),

                          SizedBox(height: 12,),

                          // Karbohidrat
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Color(0xffeff6ff),
                              border: Border.all(
                                  color: Color(0xffbedbff),
                                  width: 2,
                                  style: BorderStyle.solid
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox.square(
                                          dimension: 10,
                                          child: Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Color(0xff2b7fff),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(""),
                                          ),
                                        ),
                                        SizedBox(width: 8,),
                                        Text(
                                          "Karbohidrat",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xff193cb8)
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: 16,),
                                    Flexible(
                                      child: Text(
                                        "${((totalCarb/totalAll)*100).toStringAsFixed(2)}%",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${totalCarb}g",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.blue,
                                      ),
                                    ),
                                    SizedBox(width: 16,),
                                    Flexible(
                                      child: Text(
                                        "Target: 50%",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.blue,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            )
                          ),

                          SizedBox(height: 12,),

                          // Serat
                          Container(
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Color(0xfff0fdf4),
                              border: Border.all(
                                  color: Color(0xffb9f8cf),
                                  width: 2,
                                  style: BorderStyle.solid
                              ),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Row(
                                      children: [
                                        SizedBox.square(
                                          dimension: 10,
                                          child: Container(
                                            padding: EdgeInsets.all(8),
                                            decoration: BoxDecoration(
                                              color: Color(0xff00c950),
                                              borderRadius: BorderRadius.circular(12),
                                            ),
                                            child: Text(""),
                                          ),
                                        ),
                                        SizedBox(width: 8,),
                                        Text(
                                          "Serat",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xff016630)
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(width: 16,),
                                    Flexible(
                                      child: Text(
                                        "${((totalFiber/totalAll)*100).toStringAsFixed(2)}%",
                                        style: TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                          color: Colors.green,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "${totalFiber}g",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Colors.green,
                                      ),
                                    ),
                                    SizedBox(width: 16,),
                                    Flexible(
                                      child: Text(
                                        "Target: 20%",
                                        style: TextStyle(
                                          fontSize: 16,
                                          color: Colors.green,
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            )
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20,),

                    // Makanan Hari Ini
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.4),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: Offset(2, 4),
                          ),
                        ],
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              SizedBox.square(
                                dimension: 60,
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Color(0xff00c368),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    FontAwesomeIcons.arrowTrendUp,
                                    size: 36,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 20,),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      "Makanan Hari Ini",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    ElevatedButton(
                                      onPressed: () {
                                        showDialog(
                                          context: context,
                                          builder: (context) => _buildSmartSearchDialog(),
                                        );
                                      },
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Color(0xff00c368),
                                        shadowColor: Color(0xff00c368),
                                        padding: EdgeInsets.all(16),
                                      ),
                                      child: Row(
                                        children: [
                                          Icon(
                                            FontAwesomeIcons.plus,
                                            size: 16,
                                            color: Colors.white,
                                          ),
                                          SizedBox(width: 8,),
                                          Text(
                                            "Tambah",
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 16,
                                            ),
                                          )
                                        ],
                                      )
                                    )
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20,),
                          if (totalItem > 0)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // Sarapan
                                if (daftarMakanan['sarapan']?.isNotEmpty ?? false) ...[
                                  _buildMealCategoryHeader('🌅 Sarapan', daftarMakanan['sarapan']!.length),
                                  SizedBox(height: 12),
                                  ..._buildFoodList(daftarMakanan['sarapan']!),
                                  SizedBox(height: 20),
                                ],

                                // Makan Siang
                                if (daftarMakanan['makan_siang']?.isNotEmpty ?? false) ...[
                                  _buildMealCategoryHeader('☀️ Makan Siang', daftarMakanan['makan_siang']!.length),
                                  SizedBox(height: 12),
                                  ..._buildFoodList(daftarMakanan['makan_siang']!),
                                  SizedBox(height: 20),
                                ],

                                // Makan Malam
                                if (daftarMakanan['makan_malam']?.isNotEmpty ?? false) ...[
                                  _buildMealCategoryHeader('🌙 Makan Malam', daftarMakanan['makan_malam']!.length),
                                  SizedBox(height: 12),
                                  ..._buildFoodList(daftarMakanan['makan_malam']!),
                                  SizedBox(height: 20),
                                ],

                                // Snack
                                if (daftarMakanan['snack']?.isNotEmpty ?? false) ...[
                                  _buildMealCategoryHeader('🍪 Snack', daftarMakanan['snack']!.length),
                                  SizedBox(height: 12),
                                  ..._buildFoodList(daftarMakanan['snack']!),
                                ],
                              ],
                            )
                          else
                            Container(
                              width: double.infinity,
                              height: 200,
                              alignment: Alignment.center,
                              padding: EdgeInsets.all(20),
                              decoration: BoxDecoration(
                                color: Color(0xfff9fafb),
                                borderRadius: BorderRadius.circular(20)
                              ),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    FontAwesomeIcons.appleWhole,
                                    color: Color(0xff99a1af),
                                    size: 40,
                                  ),
                                  SizedBox(height: 12,),
                                  Text(
                                    "Belum ada makanan tercatat hari ini",
                                    style: TextStyle(
                                      color: Color(0xff99a1af),
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500
                                    ),
                                  ),
                                  Text(
                                    'Klik "Tambah" untuk mencatat makanan',
                                    style: TextStyle(
                                        color: Color(0xff99a1af),
                                        fontSize: 12,
                                    ),
                                  )
                                ],
                              ),
                            )
                        ],
                      ),
                    ),

                    SizedBox(height: 20,),

                    // Tantangan Sehat
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: isChallengeAchieved
                              ? [Color(0xFFE8F5E9), Color(0xFFC8E6C9)] // Green when achieved
                              : [Color(0xffdbeafe), Color(0xffcffafe)], // Blue default
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
                          ),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withValues(alpha: 0.4),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: Offset(2, 4),
                            ),
                          ],
                          border: Border.all(
                            color: isChallengeAchieved
                              ? Color(0xFF4CAF50)
                              : Color(0xffa2f4fd),
                            width: 2,
                            style: BorderStyle.solid,
                          )
                      ),
                      child: Column(
                        children: [
                          Row(
                            children: [
                              SizedBox.square(
                                dimension: 60,
                                child: Container(
                                  padding: EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: isChallengeAchieved
                                      ? Color(0xFF4CAF50)
                                      : Color(0xff1e89fe),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Icon(
                                    isChallengeAchieved
                                      ? FontAwesomeIcons.trophy
                                      : FontAwesomeIcons.lightbulb,
                                    size: 36,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                              SizedBox(width: 20,),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      isChallengeAchieved
                                        ? "🎉 Anda Hebat!"
                                        : "Tantangan Sehat",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: isChallengeAchieved
                                          ? Color(0xFF2E7D32)
                                          : Color(0xff193cb8),
                                      ),
                                    ),
                                    if (isChallengeAchieved)
                                      Text(
                                        "Tanpa minyak & gula hari ini!",
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Color(0xFF388E3C),
                                        ),
                                      ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 12,),

                          if (isChallengeAchieved) ...[
                            // Success Message
                            Container(
                              padding: EdgeInsets.all(16),
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color: Color(0xFF4CAF50),
                                  width: 2,
                                ),
                              ),
                              child: Column(
                                children: [
                                  Icon(
                                    FontAwesomeIcons.solidCircleCheck,
                                    size: 48,
                                    color: Color(0xFF4CAF50),
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    "Luar Biasa!",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Color(0xFF2E7D32),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    "Anda berhasil mencapai target tantangan sehat minggu ini!",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 14,
                                      color: Color(0xFF388E3C),
                                    ),
                                  ),
                                  SizedBox(height: 16),
                                  // Progress Summary
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                                    children: [
                                      Column(
                                        children: [
                                          Text(
                                            "$hariTanpaMinyak/7",
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF4CAF50),
                                            ),
                                          ),
                                          Text(
                                            "Hari Tanpa\nMinyak",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF388E3C),
                                            ),
                                          ),
                                        ],
                                      ),
                                      Column(
                                        children: [
                                          Text(
                                            "$hariTanpaGula/7",
                                            style: TextStyle(
                                              fontSize: 24,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xFF4CAF50),
                                            ),
                                          ),
                                          Text(
                                            "Hari Tanpa\nGula",
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: Color(0xFF388E3C),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ] else ...[
                            // Challenge Cards
                            Column(
                              children: [
                                Container(
                                  padding: EdgeInsets.all(16),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      color: Color(0xffecfcff),
                                      borderRadius: BorderRadius.circular(20)
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            hariTanpaMinyak >= 2
                                              ? FontAwesomeIcons.solidCircleCheck
                                              : FontAwesomeIcons.circle,
                                            size: 16,
                                            color: hariTanpaMinyak >= 2
                                              ? Color(0xFF4CAF50)
                                              : Color(0xff193cb8),
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              "🎯 Target 2 Hari Tanpa Minyak",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xff193cb8),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8,),
                                      Text(
                                        "Kurangi gorengan dan masakan berminyak untuk kesehatan jantung",
                                        style: TextStyle(
                                          color: Color(0xff4772ec),
                                          fontSize: 13,
                                        ),
                                      ),
                                      SizedBox(height: 12),
                                      // Progress indicator
                                      Row(
                                        children: [
                                          Expanded(
                                            child: LinearProgressIndicator(
                                              value: hariTanpaMinyak / 7,
                                              backgroundColor: Color(0xFFE3F2FD),
                                              color: hariTanpaMinyak >= 2 ? Color(0xFF4CAF50) : Color(0xff1e89fe),
                                              minHeight: 8,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Text(
                                            "$hariTanpaMinyak/7 hari",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xff193cb8),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(height: 12,),
                                Container(
                                  padding: EdgeInsets.all(16),
                                  width: double.infinity,
                                  decoration: BoxDecoration(
                                      color: Color(0xffecfcff),
                                      borderRadius: BorderRadius.circular(20)
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Icon(
                                            hariTanpaGula >= 2
                                              ? FontAwesomeIcons.solidCircleCheck
                                              : FontAwesomeIcons.circle,
                                            size: 16,
                                            color: hariTanpaGula >= 2
                                              ? Color(0xFF4CAF50)
                                              : Color(0xff193cb8),
                                          ),
                                          SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              "🎯 Target 2 Hari Tanpa Gula",
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.bold,
                                                color: Color(0xff193cb8),
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8,),
                                      Text(
                                        "Hindari minuman manis dan makanan tinggi gula untuk cegah diabetes",
                                        style: TextStyle(
                                          color: Color(0xff4772ec),
                                          fontSize: 13,
                                        ),
                                      ),
                                      SizedBox(height: 12),
                                      // Progress indicator
                                      Row(
                                        children: [
                                          Expanded(
                                            child: LinearProgressIndicator(
                                              value: hariTanpaGula / 7,
                                              backgroundColor: Color(0xFFE3F2FD),
                                              color: hariTanpaGula >= 2 ? Color(0xFF4CAF50) : Color(0xff1e89fe),
                                              minHeight: 8,
                                              borderRadius: BorderRadius.circular(4),
                                            ),
                                          ),
                                          SizedBox(width: 12),
                                          Text(
                                            "$hariTanpaGula/7 hari",
                                            style: TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.bold,
                                              color: Color(0xff193cb8),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),

                    SizedBox(height: 20,),

                    // Navigation to Udara Segar
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Color(0xff00c755),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: ElevatedButton(
                          onPressed: () => {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const UdaraSegar()),
                            )
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.transparent,
                            shadowColor: Colors.transparent,
                          ),
                          child: Text(
                            "Lanjut ke Udara Segar",
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build Smart Food Search Dialog
  Widget _buildSmartSearchDialog() {
    return StatefulBuilder(
      builder: (context, setDialogState) {
        String selectedJenisMakan = 'sarapan';

        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            constraints: BoxConstraints(maxHeight: MediaQuery.of(context).size.height * 0.8),
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: const Color(0xFF00C368),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            FontAwesomeIcons.utensils,
                            color: Colors.white,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Text(
                          "Tambah Makanan",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),

                const SizedBox(height: 16),

                // Smart Food Search (jenis makan already handled in dialog inside SmartFoodSearch)
                Expanded(
                  child: SmartFoodSearch(
                    onFoodSelected: (result) async {
                      print("\n╔════════════════════════════════════════╗");
                      print("║   🎯 CALLBACK TRIGGERED                ║");
                      print("╚════════════════════════════════════════╝");
                      print("Result Success: ${result["success"]}");
                      print("Message: ${result["message"]}");
                      print("Data: ${result["data"]}");

                      // Close bottom sheet first
                      print("\n[1/8] Closing bottom sheet...");
                      Navigator.pop(context);

                      // Wait for animation
                      print("[2/8] Waiting 300ms for animation...");
                      await Future.delayed(const Duration(milliseconds: 300));

                      // Show loading feedback
                      print("[3/8] Showing loading snackbar...");
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Row(
                              children: [
                                SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 12),
                                Text('Memuat data terbaru...'),
                              ],
                            ),
                            backgroundColor: Colors.blue,
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }

                      // Set loading state
                      print("[4/8] Setting isLoading = true...");
                      if (mounted) {
                        setState(() {
                          isLoading = true;
                        });
                      }

                      // Wait for database commit
                      print("[5/8] Waiting 1000ms for database commit...");
                      await Future.delayed(const Duration(milliseconds: 1000));

                      // NOW FETCH DATA - THIS IS THE CRITICAL PART
                      print("[6/8] ⭐ CALLING loadTodayFood() NOW ⭐");
                      print("      This should trigger GET request to API...");
                      await loadTodayFood();
                      print("      loadTodayFood() completed!");

                      // Force rebuilds
                      print("[7/8] Forcing UI rebuilds...");
                      if (mounted) {
                        setState(() {});
                        await Future.delayed(const Duration(milliseconds: 50));
                        setState(() {});
                        await Future.delayed(const Duration(milliseconds: 50));
                        setState(() {});
                      }

                      // Hide loading and show success
                      print("[8/8] Showing success notification...");
                      if (mounted) {
                        ScaffoldMessenger.of(context).hideCurrentSnackBar();
                      }

                      if (result["success"] && mounted) {
                        print("\n✅ SUCCESS - Current State:");
                        print("   Total Calories: $totalCalories kkal");
                        print("   Total Items: $totalItem");
                        print("   Foods Count: ${foods.length}");

                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Column(
                              mainAxisSize: MainAxisSize.min,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(FontAwesomeIcons.check, color: Colors.white, size: 16),
                                    const SizedBox(width: 8),
                                    Expanded(child: Text(result['message'] ?? 'Berhasil menambahkan')),
                                  ],
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '📊 Total Kalori: ${totalCalories.toStringAsFixed(1)} kkal',
                                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                                ),
                                Text(
                                  '✅ Total Makanan: $totalItem item',
                                  style: const TextStyle(fontSize: 12),
                                ),
                              ],
                            ),
                            backgroundColor: const Color(0xFF00C368),
                            duration: const Duration(seconds: 3),
                          ),
                        );
                      }

                    },
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // Helper method untuk build meal category header
  Widget _buildMealCategoryHeader(String title, int count) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: const Color(0xFF4CAF50),
          width: 2,
        ),
      ),
      child: Row(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Color(0xFF2E7D32),
            ),
          ),
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFF4CAF50),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              '$count item',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Helper method untuk build food list
  List<Widget> _buildFoodList(List<Map<String, dynamic>> foodList) {
    return foodList.map((food) {
      final nama = food['nama_makanan'] ?? 'Unknown';
      final porsi = food['porsi']?.toDouble() ?? 1.0;
      final totalKalori = food['total_kalori']?.toDouble() ?? 0.0;
      final totalProtein = food['total_protein']?.toDouble() ?? 0.0;
      final totalKarbo = food['total_karbohidrat']?.toDouble() ?? 0.0;
      final totalSerat = food['total_serat']?.toDouble() ?? 0.0;

      return Container(
        width: double.infinity,
        padding: const EdgeInsets.all(16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(20),
          color: const Color(0xffedfdf5),
          border: Border.all(
            color: const Color(0xffb9f8cf),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    nama,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFFECB3),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "${porsi}x porsi",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(FontAwesomeIcons.fire, size: 14, color: Colors.red),
                const SizedBox(width: 6),
                Text(
                  "${totalKalori.toStringAsFixed(1)} kkal",
                  style: const TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xffffe2e2),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "P: ${totalProtein.toStringAsFixed(1)}g",
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xffdbeafe),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "K: ${totalKarbo.toStringAsFixed(1)}g",
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
                const SizedBox(width: 6),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: const Color(0xffdbfce7),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    "S: ${totalSerat.toStringAsFixed(1)}g",
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
          ],
        ),
      );
    }).toList();
  }
}
