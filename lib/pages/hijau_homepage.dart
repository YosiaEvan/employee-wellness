import 'package:employee_wellness/components/header.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HijauHomepage extends StatelessWidget {
  const HijauHomepage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withValues(alpha: 0.98),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Header(),

            // Main Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      SizedBox.square(
                        dimension: 80,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.green,
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: const Icon(
                            FontAwesomeIcons.leaf,
                            size: 40,
                            color: Colors.white,
                          ),
                        ),
                      ),

                      SizedBox(height: 20,),

                      Text(
                        "H.I.J.A.U 360\u00B0",
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 24,
                        ),
                      ),

                      SizedBox(height: 12,),

                      Text(
                        "Kantor Ramah Lingkungan dalam Genggaman",
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontSize: 18,
                          color: Colors.green,
                        ),
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 20,),

                      Text(
                        "Selamat datang di HIJAU 360°! Bersiaplah menjelajahi kantor masa depan - lebih hijau, hemat energi, dan berkelanjutan!",
                        textAlign: TextAlign.center,
                      ),

                      SizedBox(height: 20,),

                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.green,
                          borderRadius: BorderRadius.circular(12)
                        ),
                        child: Column(
                          children: [
                            Text(
                              "Fitur H.I.J.A.U",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                              textAlign: TextAlign.center,
                            ),

                            SizedBox(height: 12,),

                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                                children: [
                                  TextSpan(
                                    text: "",
                                  ),
                                  TextSpan(
                                    text: " H",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: "emat air",
                                  ),
                                ]
                              )
                            ),

                            SizedBox(height: 8,),

                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                                children: [
                                  TextSpan(
                                    text: "",
                                  ),
                                  TextSpan(
                                    text: " I",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: "ntegrasikan AR",
                                  ),
                                ]
                              )
                            ),

                            SizedBox(height: 8,),

                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                                children: [
                                  TextSpan(
                                    text: "",
                                  ),
                                  TextSpan(
                                    text: " J",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: "alani gaya hidup hijau",
                                  ),
                                ]
                              )
                            ),

                            SizedBox(height: 8,),

                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                                children: [
                                  TextSpan(
                                    text: "",
                                  ),
                                  TextSpan(
                                    text: " A",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: "jarkan kepada orang lain",
                                  ),
                                ]
                              )
                            ),

                            SizedBox(height: 8,),

                            RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 16,
                                ),
                                children: [
                                  TextSpan(
                                    text: "",
                                  ),
                                  TextSpan(
                                    text: " U",
                                    style: TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                  TextSpan(
                                    text: "bah kebiasaan",
                                  ),
                                ]
                              )
                            ),
                          ],
                        )
                      ),

                      SizedBox(height: 20,),

                      SizedBox(
                        width: double.infinity,
                        height: 52,
                        child: Container(
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                Color(0xFF00c951),
                                Color(0xFF00bd7d),
                              ],
                            ),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: ElevatedButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const HijauHomepage()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(20),
                              ),
                              backgroundColor: Colors.transparent,
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  "Lanjutkan",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(width: 8,),
                                Icon(FontAwesomeIcons.arrowRight, color: Colors.white, size: 14,),
                              ],
                            )
                          ),
                        )
                      ),
                    ],
                  ),
                ),
              )
            ),
          ],
        )
      ),
    );
  }
}
