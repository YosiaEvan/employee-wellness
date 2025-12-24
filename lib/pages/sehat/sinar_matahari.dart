import 'package:employee_wellness/components/bottom_header.dart';
import 'package:employee_wellness/components/header.dart';
import 'package:employee_wellness/pages/sehat/jalan_10000_langkah.dart';
import 'package:employee_wellness/pages/sehat_homepage.dart';
import 'package:employee_wellness/services/sinar_matahari_service.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class SinarMatahari extends StatefulWidget {
  const SinarMatahari({super.key});

  @override
  State<SinarMatahari> createState() => _SinarMatahariState();
}

class _SinarMatahariState extends State<SinarMatahari> {
  bool isSunbathe = false;
  bool isLoading = true;
  bool sudahBerjemur = false;

  @override
  void initState() {
    super.initState();
    _cekStatusBerjemur();
  }

  Future<void> _cekStatusBerjemur() async {
    setState(() {
      isLoading = true;
    });

    final result = await SinarMatahariService.cekBerjemur();

    setState(() {
      sudahBerjemur = result['sudah_berjemur'] ?? false;
      isLoading = false;
    });

    print("📊 Status berjemur: ${sudahBerjemur ? 'SUDAH' : 'BELUM'}");
  }

  Future<void> _catatBerjemur() async {
    if (sudahBerjemur) {
      _showSnackBar("Anda sudah berjemur hari ini!", Colors.orange);
      return;
    }

    setState(() {
      isLoading = true;
    });

    final result = await SinarMatahariService.catatBerjemur();

    setState(() {
      isLoading = false;
    });

    if (result['success']) {
      setState(() {
        sudahBerjemur = true;
        isSunbathe = true;
      });
      _showSnackBar("✅ Aktivitas berjemur berhasil dicatat!", const Color(0xFF00C368));
    } else {
      _showSnackBar(result['message'] ?? "Gagal mencatat aktivitas", Colors.red);
    }
  }

  void _showSnackBar(String message, Color backgroundColor) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: backgroundColor,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void sunbathe() {
    _catatBerjemur();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xfffff7ed).withValues(alpha: 0.98),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            const Header(),
            BottomHeader(color: Color(0xfffb8f00), heading: "Sinar Matahari", subHeading: "Energi Alami", destination: SehatHomepage(),),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Manfaat Sinar Matahari
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
                                    color: Color(0xfffb8f00),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    FontAwesomeIcons.cloudSun,
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
                                    "Manfaat Sinar Matahari",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 12,),
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
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "WHO (World Health Organization)",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                Text("Sumber utama vitamin D untuk kesehatan tulang dan otot, memperkuat sistem kekebalan tubuh dan membantu melawan infeksi."),
                              ],
                            ),
                          ),
                          SizedBox(height: 12,),
                          Container(
                            width: double.infinity,
                            padding: EdgeInsets.all(16),
                            decoration: BoxDecoration(
                              color: Color(0xfffff8ed),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Color(0xfffff085),
                                width: 2,
                                  style: BorderStyle.solid
                              )
                            ),
                            child: Text(
                              '"Matahari memberi kita kehidupan, kesehatan, dan kegembiraan."',
                              style: TextStyle(
                                fontStyle: FontStyle.italic,
                              ),
                            )
                          )
                        ],
                      ),
                    ),

                    SizedBox(height: 20,),

                    // Waktu Optimal Berjemur
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Color(0xffd2fbe5),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.4),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: Offset(2, 4),
                          ),
                        ],
                        border: Border.all(
                          color: Color(0xffb9f8cf),
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
                                    color: Color(0xff00aa61),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    FontAwesomeIcons.check,
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
                                    "Waktu Optimal Berjemur",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 12,),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Pagi: 06:00 - 09:00",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        "Vitamin D maksimal",
                                        style: TextStyle(
                                          fontSize: 12,
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              ),
                              SizedBox(width: 12,),
                              Expanded(
                                child: Container(
                                  padding: EdgeInsets.all(16),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20),
                                  ),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Sore: 15:00 - 17:00",
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w500,
                                        ),
                                      ),
                                      Text(
                                        "Waktu aman kedua",
                                        style: TextStyle(
                                          fontSize: 12,
                                        ),
                                      )
                                    ],
                                  ),
                                )
                              )
                            ],
                          )
                        ],
                      ),
                    ),

                    SizedBox(height: 20,),

                    // Durasi Berjemur
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                          color: Color(0xffd0f9ff),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.4),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: Offset(2, 4),
                            ),
                          ],
                          border: Border.all(
                            color: Color(0xffbedbff),
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
                                    color: Color(0xff008dd4),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    FontAwesomeIcons.clock,
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
                                    "Durasi Berjemur",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 12,),
                          Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(16),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Kulit Terang",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          "Risiko terbakar lebih cepat",
                                          style: TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "5-15 menit",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                              SizedBox(height: 12,),
                              Container(
                                padding: EdgeInsets.all(16),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          "Kulit Gelap",
                                          style: TextStyle(
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        ),
                                        Text(
                                          "Butuh paparan lebih lama",
                                          style: TextStyle(
                                            fontSize: 16,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Text(
                                      "15-20 menit",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),

                    SizedBox(height: 20,),

                    // Persiapan Berjemur
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
                                    color: Color(0xffbd4aef),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    FontAwesomeIcons.shirt,
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
                                    "Persiapan Berjemur",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 12,),
                          Column(
                            children: [
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                        color: Color(0xfffff5f0),
                                        borderRadius: BorderRadius.circular(20),
                                        border: Border.all(
                                          color: Color(0xffffd7a8),
                                          width: 2,
                                          style: BorderStyle.solid,
                                        )
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            "🧴",
                                            style: TextStyle(
                                              fontSize: 20,
                                            ),
                                          ),
                                          Text(
                                            "Sunscreen SPF 30+",
                                            style: TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.w500
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ),
                                  SizedBox(width: 12,),
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                          color: Color(0xffedfbff),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: Color(0xffbedbff),
                                            width: 2,
                                            style: BorderStyle.solid,
                                          )
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            "🧢",
                                            style: TextStyle(
                                              fontSize: 20,
                                            ),
                                          ),
                                          Text(
                                            "Topi Pelindung",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  )
                                ],
                              ),
                              SizedBox(height: 12,),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                          color: Color(0xfff8fafb),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: Color(0xffe5e7eb),
                                            width: 2,
                                            style: BorderStyle.solid,
                                          )
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            "🕶️",
                                            style: TextStyle(
                                              fontSize: 20,
                                            ),
                                          ),
                                          Text(
                                            "Kacamata UV",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ),
                                  SizedBox(width: 12,),
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.all(16),
                                      decoration: BoxDecoration(
                                          color: Color(0xffeefdf5),
                                          borderRadius: BorderRadius.circular(20),
                                          border: Border.all(
                                            color: Color(0xffb9f8cf),
                                            width: 2,
                                            style: BorderStyle.solid,
                                          )
                                      ),
                                      child: Column(
                                        children: [
                                          Text(
                                            "👚",
                                            style: TextStyle(
                                              fontSize: 20,
                                            ),
                                          ),
                                          Text(
                                            "Pakaian Terang",
                                            style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w500
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  )
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 12,),
                          Container(
                            padding: EdgeInsets.all(16),
                            width: double.infinity,
                            decoration: BoxDecoration(
                              color: Color(0xfffefce8),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: Color(0xfffff085),
                                width: 2,
                                style: BorderStyle.solid,
                              ),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Posisi",
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                Text(
                                  "Telungkup/telentang, duduk menghadap matahari, atau duduk membelakangi matahari",
                                )
                              ],
                            )
                          )
                        ],
                      ),
                    ),

                    SizedBox(height: 20,),

                    // Tips Keamanan
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Color(0xfffce6f0),
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.4),
                            spreadRadius: 2,
                            blurRadius: 8,
                            offset: Offset(2, 4),
                          ),
                        ],
                        border: Border.all(
                          color: Color(0xffffc9c9),
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
                                    color: Color(0xffec0865),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    FontAwesomeIcons.shield,
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
                                    "Tips Keamanan",
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          SizedBox(height: 12,),
                          Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(16),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(20)
                                ),
                                child: Row(
                                  children: [
                                    SizedBox.square(
                                      dimension: 10,
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Color(0xffec0865),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(""),
                                      ),
                                    ),
                                    SizedBox(width: 8,),
                                    Text("Gunakan tabir surya SPF minimal 30")
                                  ],
                                ),
                              ),
                              SizedBox(height: 12,),
                              Container(
                                padding: EdgeInsets.all(16),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                child: Row(
                                  children: [
                                    SizedBox.square(
                                      dimension: 10,
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Color(0xffec0865),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(""),
                                      ),
                                    ),
                                    SizedBox(width: 8,),
                                    Text("Hindari jam 10:00 - 15:00 (puncak UV)")
                                  ],
                                ),
                              ),
                              SizedBox(height: 12,),
                              Container(
                                padding: EdgeInsets.all(16),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                child: Row(
                                  children: [
                                    SizedBox.square(
                                      dimension: 10,
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Color(0xffec0865),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(""),
                                      ),
                                    ),
                                    SizedBox(width: 8,),
                                    Text("Gunakan kacamata hitam dan topi")
                                  ],
                                ),
                              ),
                              SizedBox(height: 12,),
                              Container(
                                padding: EdgeInsets.all(16),
                                width: double.infinity,
                                decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                child: Row(
                                  children: [
                                    SizedBox.square(
                                      dimension: 10,
                                      child: Container(
                                        padding: EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                          color: Color(0xffec0865),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(""),
                                      ),
                                    ),
                                    SizedBox(width: 8,),
                                    Text("Hindari kepanasan - minum air yang cukup")
                                  ],
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),

                    SizedBox(height: 20,),

                    // CTA
                    Container(
                      padding: EdgeInsets.all(20),
                      width: double.infinity,
                      decoration: BoxDecoration(
                          color: Color(0xfffef3ca),
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.grey.withOpacity(0.4),
                              spreadRadius: 2,
                              blurRadius: 8,
                              offset: Offset(2, 4),
                            ),
                          ],
                          border: Border.all(
                            color: Color(0xffffdf20),
                            width: 2,
                            style: BorderStyle.solid,
                          )
                      ),
                      child: Column(
                        children: [
                          SizedBox.square(
                            dimension: 80,
                            child: Container(
                              padding: EdgeInsets.all(8),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                color: Color(0xffffe09d),
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: Text(
                                "🙋‍♂️",
                                style: TextStyle(
                                  fontSize: 40,
                                ),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ),
                          SizedBox(height: 12,),
                          Column(
                            children: [
                              Text(
                                "Siap untuk berjemur?",
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Konfirmasi aktivitas berjemur Anda hari ini",
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 20,),
                          isSunbathe ? Column(
                            children: [
                              Text(
                                "Tubuhmu berterima kasih atas sinar energi alami ini!",
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 12,),
                              Text(
                                "⭐⭐⭐⭐⭐",
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              ),
                              SizedBox(height: 12,),
                              Container(
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                  color: Color(0xffdbfce7),
                                  borderRadius: BorderRadius.circular(20),
                                  border: Border.all(
                                    color: Color(0xff7bf1a8),
                                    width: 2,
                                    style: BorderStyle.solid,
                                  )
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Icon(
                                          FontAwesomeIcons.circleCheck,
                                          size: 20,
                                          color: Color(0xff00a63e),
                                        ),
                                        SizedBox(width: 8,),
                                        Text(
                                          "Selamat!",
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                            color: Color(0xff00a63e),
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(height: 12,),
                                    Text(
                                      "Kamu mendapatkan 1 poin kesehatan",
                                      style: TextStyle(
                                        fontSize: 16,
                                        color: Color(0xff00a63e),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(height: 20,),
                              Container(
                                decoration: BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [Color(0xff00c951), Color(0xff00bba6)],
                                      begin: Alignment.centerLeft,
                                      end: Alignment.centerRight,
                                    ),
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                child: ElevatedButton(
                                    onPressed: () {
                                      Navigator.push(context, MaterialPageRoute(builder: (context) => const Jalan10000Langkah()));
                                    },
                                    style: ElevatedButton.styleFrom(
                                      padding: EdgeInsets.all(16),
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                    ),
                                    child: Text(
                                      "Lanjut ke Jalan 10.000 Langkah",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),
                                    )
                                ),
                              )
                            ],
                          ) : Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: sudahBerjemur
                                  ? [Colors.grey.shade400, Colors.grey.shade500]  // Grey when done
                                  : [Color(0xfff0b000), Color(0xffff6a00)],       // Orange when active
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                              borderRadius: BorderRadius.circular(20)
                            ),
                            child: ElevatedButton(
                              onPressed: sudahBerjemur ? null : sunbathe,  // Disable if already done
                              style: ElevatedButton.styleFrom(
                                padding: EdgeInsets.all(16),
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                disabledBackgroundColor: Colors.transparent,  // Keep gradient visible
                              ),
                              child: isLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : Text(
                                    sudahBerjemur
                                      ? "✅ Kamu Sudah Berjemur Hari Ini"  // Done text
                                      : "☀️ Saya Sudah Berjemur",          // Active text
                                    style: TextStyle(
                                      fontSize: 20,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  )
                            ),
                          )
                        ],
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
}
