import 'package:employee_wellness/components/header.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class TenangHomepage extends StatelessWidget {
  const TenangHomepage({super.key});

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
            Container(
              padding: EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Color(0xff2c7eff),
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(20),
                    bottomRight: Radius.circular(20),
                  )
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: SizedBox.square(
                          dimension: 40,
                          child: Container(
                            padding: EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: Colors.white.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(40),
                            ),
                            child: const Icon(
                              FontAwesomeIcons.arrowLeft,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "TENANG 360\u00B0",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "Zona Kendali Emosi",
                            style: TextStyle(
                              fontSize: 16,
                              color: Colors.white,
                            ),
                          )
                        ],
                      ),
                      SizedBox.square(
                        dimension: 40,
                        child: Container(
                          padding: EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: const Icon(
                            FontAwesomeIcons.brain,
                            size: 20,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            
            // Main Content
            Expanded(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        "Coming Soon",
                        style: TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Color(0xff2c7eff),
                        ),
                      ),
                      SizedBox(height: 20,),
                      Text(
                        "Modul ini masih dalam tahap pengembangan",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        "Kami sedang menyiapkan sesuatu yang keren untukmu!",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(height: 20,),
                      Text(
                        "Terima kasih sudah sabar menunggu",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        "Update akan segera tersedia di versi berikutnya.",
                        style: TextStyle(
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      // SizedBox.square(
                      //   dimension: 80,
                      //   child: Container(
                      //     padding: EdgeInsets.all(8),
                      //     decoration: BoxDecoration(
                      //       color: Colors.blue,
                      //       borderRadius: BorderRadius.circular(40),
                      //     ),
                      //     child: const Icon(
                      //       FontAwesomeIcons.brain,
                      //       size: 40,
                      //       color: Colors.white,
                      //     ),
                      //   ),
                      // ),
                      //
                      // SizedBox(height: 20,),
                      //
                      // Text(
                      //   "T.E.N.A.N.G 360\u00B0",
                      //   style: TextStyle(
                      //     fontWeight: FontWeight.w700,
                      //     fontSize: 24,
                      //   ),
                      // ),
                      //
                      // SizedBox(height: 12,),
                      //
                      // Text(
                      //   "Zona Kendali Emosi",
                      //   style: TextStyle(
                      //     fontWeight: FontWeight.w500,
                      //     fontSize: 18,
                      //     color: Colors.blue,
                      //   ),
                      // ),
                      //
                      // SizedBox(height: 20,),
                      //
                      // Text(
                      //   "Selamat datang di ruang virtual 360° yang dirancang khusus untuk membantu Anda mengendalikan emosi dan mencapai ketenangan batin.",
                      //   textAlign: TextAlign.center,
                      // ),
                      //
                      // SizedBox(height: 20,),
                      //
                      // Container(
                      //   width: double.infinity,
                      //   padding: EdgeInsets.all(20),
                      //   decoration: BoxDecoration(
                      //     color: Colors.blue,
                      //     borderRadius: BorderRadius.circular(12)
                      //   ),
                      //   child: Column(
                      //     children: [
                      //       Text(
                      //         "Fitur T.E.N.A.N.G",
                      //         style: TextStyle(
                      //           color: Colors.white,
                      //           fontSize: 16,
                      //           fontWeight: FontWeight.bold,
                      //         ),
                      //         textAlign: TextAlign.center,
                      //       ),
                      //
                      //       SizedBox(height: 12,),
                      //
                      //       RichText(
                      //         textAlign: TextAlign.center,
                      //         text: TextSpan(
                      //           style: const TextStyle(
                      //             color: Colors.white,
                      //             fontSize: 16,
                      //           ),
                      //           children: [
                      //             TextSpan(
                      //               text: "🧠",
                      //             ),
                      //             TextSpan(
                      //               text: " T",
                      //               style: TextStyle(fontWeight: FontWeight.bold),
                      //             ),
                      //             TextSpan(
                      //               text: "eknologi adaptif emosi",
                      //             ),
                      //           ]
                      //         )
                      //       ),
                      //
                      //       SizedBox(height: 8,),
                      //
                      //       RichText(
                      //           textAlign: TextAlign.center,
                      //           text: TextSpan(
                      //               style: const TextStyle(
                      //                 color: Colors.white,
                      //                 fontSize: 16,
                      //               ),
                      //               children: [
                      //                 TextSpan(
                      //                   text: "🌿",
                      //                 ),
                      //                 TextSpan(
                      //                   text: " E",
                      //                   style: TextStyle(fontWeight: FontWeight.bold),
                      //                 ),
                      //                 TextSpan(
                      //                   text: "nvironment virtual calming",
                      //                 ),
                      //               ]
                      //           )
                      //       ),
                      //
                      //       SizedBox(height: 8,),
                      //
                      //       RichText(
                      //           textAlign: TextAlign.center,
                      //           text: TextSpan(
                      //               style: const TextStyle(
                      //                 color: Colors.white,
                      //                 fontSize: 16,
                      //               ),
                      //               children: [
                      //                 TextSpan(
                      //                   text: "🎵",
                      //                 ),
                      //                 TextSpan(
                      //                   text: " N",
                      //                   style: TextStyle(fontWeight: FontWeight.bold),
                      //                 ),
                      //                 TextSpan(
                      //                   text: "atural soundscape therapy",
                      //                 ),
                      //               ]
                      //           )
                      //       ),
                      //
                      //       SizedBox(height: 8,),
                      //
                      //       RichText(
                      //           textAlign: TextAlign.center,
                      //           text: TextSpan(
                      //               style: const TextStyle(
                      //                 color: Colors.white,
                      //                 fontSize: 16,
                      //               ),
                      //               children: [
                      //                 TextSpan(
                      //                   text: "🎯",
                      //                 ),
                      //                 TextSpan(
                      //                   text: " A",
                      //                   style: TextStyle(fontWeight: FontWeight.bold),
                      //                 ),
                      //                 TextSpan(
                      //                   text: "daptive guided meditation",
                      //                 ),
                      //               ]
                      //           )
                      //       ),
                      //
                      //       SizedBox(height: 8,),
                      //
                      //       RichText(
                      //           textAlign: TextAlign.center,
                      //           text: TextSpan(
                      //               style: const TextStyle(
                      //                 color: Colors.white,
                      //                 fontSize: 16,
                      //               ),
                      //               children: [
                      //                 TextSpan(
                      //                   text: "💤",
                      //                 ),
                      //                 TextSpan(
                      //                   text: " N",
                      //                   style: TextStyle(fontWeight: FontWeight.bold),
                      //                 ),
                      //                 TextSpan(
                      //                   text: "eurological relaxation",
                      //                 ),
                      //               ]
                      //           )
                      //       ),
                      //
                      //       SizedBox(height: 8,),
                      //
                      //       RichText(
                      //           textAlign: TextAlign.center,
                      //           text: TextSpan(
                      //               style: const TextStyle(
                      //                 color: Colors.white,
                      //                 fontSize: 16,
                      //               ),
                      //               children: [
                      //                 TextSpan(
                      //                   text: "✨",
                      //                 ),
                      //                 TextSpan(
                      //                   text: " G",
                      //                   style: TextStyle(fontWeight: FontWeight.bold),
                      //                 ),
                      //                 TextSpan(
                      //                   text: "entle emotion regulation",
                      //                 ),
                      //               ]
                      //           )
                      //       ),
                      //     ],
                      //   )
                      // ),
                      //
                      // SizedBox(height: 20,),
                      //
                      // SizedBox(
                      //     width: double.infinity,
                      //     height: 52,
                      //     child: Container(
                      //       decoration: BoxDecoration(
                      //         gradient: const LinearGradient(
                      //           colors: [
                      //             Color(0xFF2a7fff),
                      //             Color(0xFF00b9db),
                      //           ],
                      //         ),
                      //         borderRadius: BorderRadius.circular(16),
                      //       ),
                      //       child: ElevatedButton(
                      //         onPressed: () {
                      //           Navigator.push(
                      //             context,
                      //             MaterialPageRoute(builder: (context) => const TenangHomepage()),
                      //           );
                      //         },
                      //         style: ElevatedButton.styleFrom(
                      //           padding: const EdgeInsets.symmetric(vertical: 15),
                      //           shape: RoundedRectangleBorder(
                      //             borderRadius: BorderRadius.circular(20),
                      //           ),
                      //           backgroundColor: Colors.transparent,
                      //         ),
                      //         child: Row(
                      //           mainAxisAlignment: MainAxisAlignment.center,
                      //           children: [
                      //             Text(
                      //               "Lanjutkan",
                      //               style: TextStyle(
                      //                 fontSize: 16,
                      //                 fontWeight: FontWeight.w500,
                      //                 color: Colors.white,
                      //               ),
                      //             ),
                      //             SizedBox(width: 8,),
                      //             Icon(FontAwesomeIcons.arrowRight, color: Colors.white, size: 14,),
                      //           ],
                      //         )
                      //       ),
                      //     )
                      // ),
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
