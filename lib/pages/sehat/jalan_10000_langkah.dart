import 'dart:async';
import 'package:employee_wellness/components/header.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:pedometer/pedometer.dart';
import 'package:permission_handler/permission_handler.dart';

class Jalan10000Langkah extends StatefulWidget {
  const Jalan10000Langkah({super.key});

  @override
  State<Jalan10000Langkah> createState() => _Jalan10000LangkahState();
}

class _Jalan10000LangkahState extends State<Jalan10000Langkah> {
  int _totalSteps = 0;
  Stream<StepCount>? _stepCountStream;
  late Pedometer _pedometer;
  StreamSubscription<StepCount>? _subscription;
  double progressValue = 0;
  int _remainingSteps = 10000;
  int _initialSteps = 0;
  bool _isStart = false;

  @override
  void initState() {
    super.initState();
    _pedometer = Pedometer();
    requestPermission();
  }

  void startListening() {
    setState(() {
      _isStart = true;
    });
    _stepCountStream = Pedometer.stepCountStream;
    _subscription = _stepCountStream!.listen(
      (StepCount stepCount) {
        setState(() {
          _totalSteps = stepCount.steps - _initialSteps;
          progressValue = _totalSteps/10000;
          _remainingSteps = 10000-_totalSteps;
        });
        print("Langkah terdeteksi: ${stepCount.steps}");
      },
      onError: (error) {
        print('Error: $error');
      }
    );
  }

  void stopListening() {
    _subscription?.cancel();
    setState(() {
      _isStart = false;
    });
  }

  void resetStep() {
    setState(() {
      _initialSteps = _totalSteps + _initialSteps;
      _totalSteps = 0;
      progressValue = 0;
      _remainingSteps = 10000;
    });
  }

  @override
  void dispose() {
    stopListening();
    super.dispose();
  }

  Future<void> requestPermission() async {
    var status = await Permission.activityRecognition.status;
    if (!status.isGranted) {
      await Permission.activityRecognition.request();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffecfdff).withValues(alpha: 0.98),
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
                  color: Color(0xff1b8cfd),
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
                            "Jalan 10.000 Langkah",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "Aktivitas Fisik",
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
                            FontAwesomeIcons.house,
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
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Counter
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xffecf5ff), Color(0xffe4fafe)],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight
                        ),
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
                                color: Color(0xff1e89fe),
                                borderRadius: BorderRadius.circular(40),
                              ),
                              child: const Icon(
                                FontAwesomeIcons.shoePrints,
                                size: 36,
                                color: Colors.white,
                              ),
                            ),
                          ),
                          SizedBox(height: 20,),
                          Text(
                            "$_totalSteps",
                            style: TextStyle(
                              fontSize: 60,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 12,),
                          Text(
                            "langkah hari ini",
                            style: TextStyle(
                              fontSize: 20,
                            ),
                          ),
                          SizedBox(height: 20,),
                          SizedBox(
                            height: 20,
                            child: LinearProgressIndicator(
                              value: progressValue,
                              color: Colors.blue,
                              backgroundColor: Colors.grey[300],
                              borderRadius: BorderRadius.circular(20),
                            ),
                          ),
                          SizedBox(height: 20,),
                          Text(
                            "${(progressValue * 100).toStringAsFixed(2)}% dari target",
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
                                color: Color(0xffbedbff),
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
                                      color: Colors.blue,
                                    ),
                                    SizedBox(width: 8,),
                                    Text(
                                      "$_remainingSteps langkah lagi",
                                      style: TextStyle(
                                        fontSize: 20,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 8,),
                                Text(
                                  "Target: 10.000 langkah",
                                  style: TextStyle(
                                    color: Colors.blue,
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

                    // Buttons
                    _isStart ? Row(
                      children: [
                        Expanded(
                            child: Container(
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(20),
                                  gradient: LinearGradient(
                                    colors: [Color(0xfff54900), Color(0xffe7000a)],
                                    begin: Alignment.centerLeft,
                                    end: Alignment.centerRight,
                                  ),
                                ),
                                child: ElevatedButton(
                                    onPressed: stopListening,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.transparent,
                                      shadowColor: Colors.transparent,
                                    ),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          FontAwesomeIcons.pause,
                                          size: 16,
                                          color: Colors.white,
                                        ),
                                        SizedBox(width: 8,),
                                        Text(
                                          "Jeda",
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w500,
                                          ),
                                        )
                                      ],
                                    )
                                )
                            )
                        ),
                      ],
                    ) : Row(
                      children: [
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              gradient: LinearGradient(
                                colors: [Color(0xff135ffa), Color(0xff00b7db)],
                                begin: Alignment.centerLeft,
                                end: Alignment.centerRight,
                              ),
                            ),
                            child: ElevatedButton(
                              onPressed: startListening,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    FontAwesomeIcons.play,
                                    size: 16,
                                    color: Colors.white,
                                  ),
                                  SizedBox(width: 8,),
                                  Text(
                                    "Mulai Berjalan",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )
                                ],
                              )
                            )
                          )
                        ),
                        SizedBox(width: 12,),
                        Expanded(
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(20),
                              color: Colors.white,
                            ),
                            child: ElevatedButton(
                              onPressed: resetStep,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.transparent,
                                shadowColor: Colors.transparent,
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(
                                    FontAwesomeIcons.rotateRight,
                                    size: 16,
                                    color: Colors.black,
                                  ),
                                  SizedBox(width: 8,),
                                  Text(
                                    "Reset",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  )
                                ],
                              ),
                            )
                          )
                        )
                      ],
                    ),
                    
                    SizedBox(height: 20,),

                    // Manfaat Jalan 10.000 Langkah
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
                                    color: Color(0xff1e89fe),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    FontAwesomeIcons.personWalking,
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
                                    "Manfaat Jalan 10.000 Langkah",
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
                            child: Row(
                              children: [
                                Text(
                                  "❤️",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 20,
                                  ),
                                ),
                                SizedBox(width: 16,),
                                Flexible(
                                  child: Text(
                                    "Meningkatkan kesehatan jantung",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              ],
                            ),
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
                            child: Row(
                              children: [
                                Text(
                                  "🔥",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 20,
                                  ),
                                ),
                                SizedBox(width: 16,),
                                Flexible(
                                  child: Text(
                                    "Membakar kalori dan menurunkan berat badan",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              ],
                            ),
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
                            child: Row(
                              children: [
                                Text(
                                  "🦴",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 20,
                                  ),
                                ),
                                SizedBox(width: 16,),
                                Flexible(
                                  child: Text(
                                    "Memperkuat tulang dan otot",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              ],
                            ),
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
                            child: Row(
                              children: [
                                Text(
                                  "😊",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 20,
                                  ),
                                ),
                                SizedBox(width: 16,),
                                Flexible(
                                  child: Text(
                                    "Meningkatkan mood dan mengurangi stres",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              ],
                            ),
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
                            child: Row(
                              children: [
                                Text(
                                  "🧠",
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 20,
                                  ),
                                ),
                                SizedBox(width: 16,),
                                Flexible(
                                  child: Text(
                                    "Meningkatkan fungsi otak dan konsentrasi",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    SizedBox(height: 20,),
                    
                    // Tips Mencapai 10.000 Langkah
                    Container(
                      padding: EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          colors: [Color(0xffcffafe), Color(0xffdbeafe)]
                        ),
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
                          color: Color(0xffa2f4fd),
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
                                    color: Color(0xff1e89fe),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: const Icon(
                                    FontAwesomeIcons.lightbulb,
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
                                    "Tips Mencapai 10.000 Langkah",
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
                                          color: Color(0xff1e89fe),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(""),
                                      ),
                                    ),
                                    SizedBox(width: 8,),
                                    Text("Parkir kendaraan lebih jauh dari tujuan")
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
                                          color: Color(0xff1e89fe),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(""),
                                      ),
                                    ),
                                    SizedBox(width: 8,),
                                    Text("Gunakan tangga daripada lift")
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
                                          color: Color(0xff1e89fe),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(""),
                                      ),
                                    ),
                                    SizedBox(width: 8,),
                                    Text("Jalan-jalan saat istirahat makan siang")
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
                                          color: Color(0xff1e89fe),
                                          borderRadius: BorderRadius.circular(12),
                                        ),
                                        child: Text(""),
                                      ),
                                    ),
                                    SizedBox(width: 8,),
                                    Text("Ajak rekan kerja jalan bersama")
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
                    // Container(
                    //   padding: EdgeInsets.all(20),
                    //   width: double.infinity,
                    //   decoration: BoxDecoration(
                    //       color: Color(0xfffef3ca),
                    //       borderRadius: BorderRadius.circular(20),
                    //       boxShadow: [
                    //         BoxShadow(
                    //           color: Colors.grey.withOpacity(0.4),
                    //           spreadRadius: 2,
                    //           blurRadius: 8,
                    //           offset: Offset(2, 4),
                    //         ),
                    //       ],
                    //       border: Border.all(
                    //         color: Color(0xffffdf20),
                    //         width: 2,
                    //         style: BorderStyle.solid,
                    //       )
                    //   ),
                    //   child: Column(
                    //     children: [
                    //       SizedBox.square(
                    //         dimension: 80,
                    //         child: Container(
                    //           padding: EdgeInsets.all(8),
                    //           alignment: Alignment.center,
                    //           decoration: BoxDecoration(
                    //             color: Color(0xffffe09d),
                    //             borderRadius: BorderRadius.circular(40),
                    //           ),
                    //           child: Text(
                    //             "🙋‍♂️",
                    //             style: TextStyle(
                    //               fontSize: 40,
                    //             ),
                    //             textAlign: TextAlign.center,
                    //           ),
                    //         ),
                    //       ),
                    //       SizedBox(height: 12,),
                    //       Column(
                    //         children: [
                    //           Text(
                    //             "Siap untuk berjemur?",
                    //             style: TextStyle(
                    //               fontSize: 20,
                    //               fontWeight: FontWeight.bold,
                    //             ),
                    //           ),
                    //           Text(
                    //             "Konfirmasi aktivitas berjemur Anda hari ini",
                    //             style: TextStyle(
                    //               fontSize: 16,
                    //             ),
                    //           ),
                    //         ],
                    //       ),
                    //       SizedBox(height: 20,),
                    //       isSunbathe ? Column(
                    //         children: [
                    //           Text(
                    //             "Tubuhmu berterima kasih atas sinar energi alami ini!",
                    //             style: TextStyle(
                    //               fontSize: 16,
                    //             ),
                    //           ),
                    //           SizedBox(height: 12,),
                    //           Text(
                    //             "⭐⭐⭐⭐⭐",
                    //             style: TextStyle(
                    //               fontSize: 16,
                    //             ),
                    //           ),
                    //           SizedBox(height: 12,),
                    //           Container(
                    //             padding: EdgeInsets.all(16),
                    //             decoration: BoxDecoration(
                    //                 color: Color(0xffdbfce7),
                    //                 borderRadius: BorderRadius.circular(20),
                    //                 border: Border.all(
                    //                   color: Color(0xff7bf1a8),
                    //                   width: 2,
                    //                   style: BorderStyle.solid,
                    //                 )
                    //             ),
                    //             child: Column(
                    //               children: [
                    //                 Row(
                    //                   mainAxisSize: MainAxisSize.min,
                    //                   children: [
                    //                     Icon(
                    //                       FontAwesomeIcons.circleCheck,
                    //                       size: 20,
                    //                       color: Color(0xff00a63e),
                    //                     ),
                    //                     SizedBox(width: 8,),
                    //                     Text(
                    //                       "Selamat!",
                    //                       style: TextStyle(
                    //                         fontSize: 20,
                    //                         fontWeight: FontWeight.bold,
                    //                         color: Color(0xff00a63e),
                    //                       ),
                    //                     )
                    //                   ],
                    //                 ),
                    //                 SizedBox(height: 12,),
                    //                 Text(
                    //                   "Kamu mendapatkan 1 poin kesehatan",
                    //                   style: TextStyle(
                    //                     fontSize: 16,
                    //                     color: Color(0xff00a63e),
                    //                   ),
                    //                 ),
                    //               ],
                    //             ),
                    //           ),
                    //           SizedBox(height: 20,),
                    //           Container(
                    //             decoration: BoxDecoration(
                    //                 gradient: LinearGradient(
                    //                   colors: [Color(0xff00c951), Color(0xff00bba6)],
                    //                   begin: Alignment.centerLeft,
                    //                   end: Alignment.centerRight,
                    //                 ),
                    //                 borderRadius: BorderRadius.circular(20)
                    //             ),
                    //             child: ElevatedButton(
                    //                 onPressed: () {},
                    //                 style: ElevatedButton.styleFrom(
                    //                   padding: EdgeInsets.all(16),
                    //                   backgroundColor: Colors.transparent,
                    //                   shadowColor: Colors.transparent,
                    //                   shape: RoundedRectangleBorder(
                    //                     borderRadius: BorderRadius.circular(20),
                    //                   ),
                    //                 ),
                    //                 child: Text(
                    //                   "Lanjut ke Jalan 10.000 Langkah",
                    //                   style: TextStyle(
                    //                     fontSize: 20,
                    //                     fontWeight: FontWeight.bold,
                    //                     color: Colors.white,
                    //                   ),
                    //                 )
                    //             ),
                    //           )
                    //         ],
                    //       ) : Container(
                    //         decoration: BoxDecoration(
                    //             gradient: LinearGradient(
                    //               colors: [Color(0xfff0b000), Color(0xffff6a00)],
                    //               begin: Alignment.centerLeft,
                    //               end: Alignment.centerRight,
                    //             ),
                    //             borderRadius: BorderRadius.circular(20)
                    //         ),
                    //         child: ElevatedButton(
                    //             onPressed: sunbathe,
                    //             style: ElevatedButton.styleFrom(
                    //               padding: EdgeInsets.all(16),
                    //               backgroundColor: Colors.transparent,
                    //               shadowColor: Colors.transparent,
                    //               shape: RoundedRectangleBorder(
                    //                 borderRadius: BorderRadius.circular(20),
                    //               ),
                    //             ),
                    //             child: Text(
                    //               "☀️ Saya Sudah Berjemur",
                    //               style: TextStyle(
                    //                 fontSize: 20,
                    //                 fontWeight: FontWeight.bold,
                    //                 color: Colors.white,
                    //               ),
                    //             )
                    //         ),
                    //       )
                    //     ],
                    //   ),
                    // ),
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
