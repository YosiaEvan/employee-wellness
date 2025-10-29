import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';

class HealthProfile extends StatefulWidget {
  const HealthProfile({super.key});

  @override
  State<HealthProfile> createState() => _HealthProfileState();
}

class _HealthProfileState extends State<HealthProfile> {
  String? selectedOption = "A";
  String? selectedDietType;
  final TextEditingController _dateController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _allergyController = TextEditingController();
  final TextEditingController _medicalConditionController = TextEditingController();
  final TextEditingController _drugController = TextEditingController();
  // List<Map<String, dynamic>> options = [
  //   {"label": "Hipertensi", "checked": false},
  //   {"label": "Diabetes", "checked": false},
  //   {"label": "Obesitas", "checked": false},
  //   {"label": "Berat Badan diatas ideal", "checked": false},
  //   {"label": "Jantung", "checked": false},
  //   {"label": "Asam Urat", "checked": false},
  //   {"label": "Kolesterol Tinggi", "checked": false},
  //   {"label": "Penyakit Ginjal", "checked": false},
  //   {"label": "Penyakit Autoimun", "checked": false},
  //   {"label": "Lainnya", "checked": false},
  // ];
  final List<String> _allergyList = [];
  final List<String> _medicalConditionList = [];
  final List<String> _drugList = [];


  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1945),
      lastDate: DateTime(2100),
    );

    if (pickedDate != null) {
      setState(() {
        _dateController.text = DateFormat('dd/MM/yyyy').format(pickedDate);
      });
    }
  }

  void _addAllergy() {
    final text = _allergyController.text.trim();
    if (text.isNotEmpty && !_allergyList.contains(text)) {
      setState(() {
        _allergyList.add(text);
        _allergyController.clear();
      });
    }
  }

  void _removeAllergy(String item) {
    setState(() {
      _allergyList.remove(item);
    });
  }

  void _addMedicalCondition() {
    final text = _medicalConditionController.text.trim();
    if (text.isNotEmpty && !_medicalConditionList.contains(text)) {
      setState(() {
        _medicalConditionList.add(text);
        _medicalConditionController.clear();
      });
    }
  }

  void _removeMedicalCondition(String item) {
    setState(() {
      _medicalConditionList.remove(item);
    });
  }

  void _addDrug() {
    final text = _drugController.text.trim();
    if (text.isNotEmpty && !_drugList.contains(text)) {
      setState(() {
        _drugList.add(text);
        _drugController.clear();
      });
    }
  }

  void _removeDrug(String item) {
    setState(() {
      _drugList.remove(item);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withValues(alpha: 0.98),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              width: double.infinity,
              color: Colors.white,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    onPressed: () => Navigator.pop(context),
                    icon: Icon(
                      FontAwesomeIcons.arrowLeft,
                      size: 20,
                    )
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                        "Profil Kesehatan",
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        "Biodata Lengkap"
                      )
                    ],
                  )
                ],
              ),
            ),

            // Main Content
            Expanded(
              child: SingleChildScrollView(
                padding: EdgeInsets.all(20),
                child: Column(
                  children: [
                    // Alert
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Color(0xfffff8ed),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 4),
                              child: Icon(
                                FontAwesomeIcons.circleInfo,
                                size: 16,
                              ),
                            ),
                            SizedBox(width: 16,),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Lengkapi Profil Kesehatan",
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  Text(
                                    "Data ini akan membantu personalisasi program wellness Anda",
                                    style: TextStyle(
                                      fontSize: 16,
                                    ),
                                  ),
                                ],
                              )
                            )
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 20,),

                    // Informasi Pribadi
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SizedBox.square(
                                  dimension: 40,
                                  child: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      FontAwesomeIcons.person,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Text(
                                  "Informasi Pribadi",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Nama Lengkap",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                TextField(
                                  decoration: InputDecoration(
                                    hintText: "Masukan nama lengkap",
                                    isDense: true,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10)
                                    ),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 20),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Email",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                TextField(
                                  decoration: InputDecoration(
                                    hintText: "email@example.com",
                                    isDense: true,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10)
                                    ),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 20),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Jenis Kelamin",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),

                                Row(
                                  children: [
                                    Row(
                                      children: [
                                        Radio<String>(
                                          value: "L",
                                          groupValue: selectedOption,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedOption = value;
                                            });
                                          },
                                        ),
                                        const Text("Laki-Laki")
                                      ],
                                    ),
                                    Row(
                                      children: [
                                        Radio<String>(
                                          value: "P",
                                          groupValue: selectedOption,
                                          onChanged: (value) {
                                            setState(() {
                                              selectedOption = value;
                                            });
                                          },
                                        ),
                                        const Text("Perempuan")
                                      ],
                                    )
                                  ],
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Taggal Lahir",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                TextField(
                                  controller: _dateController,
                                  readOnly: true,
                                  decoration: InputDecoration(
                                    hintText: "hh/bb/tttt",
                                    isDense: true,
                                    suffixIcon: const Icon(FontAwesomeIcons.calendar),
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10)
                                    ),
                                  ),
                                  onTap: () => _selectDate(context),
                                )
                              ],
                            ),
                          ],
                        ),
                      )
                    ),

                    const SizedBox(height: 20),

                    // Informasi Fisik
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SizedBox.square(
                                  dimension: 40,
                                  child: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Color(0xff9810fa),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      FontAwesomeIcons.ruler,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Text(
                                  "Informasi Fisik",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Tinggi Badan (cm)",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      TextField(
                                        controller: _heightController,
                                        decoration: InputDecoration(
                                            hintText: "170",
                                            isDense: true,
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            )
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Berat Badan (kg)",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      TextField(
                                        controller: _heightController,
                                        decoration: InputDecoration(
                                            hintText: "65",
                                            isDense: true,
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            )
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Target Kesehatan
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SizedBox.square(
                                  dimension: 40,
                                  child: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.green,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      FontAwesomeIcons.bullseye,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Text(
                                  "Target Kesehatan",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Target Berat (kg)",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      TextField(
                                        controller: _heightController,
                                        decoration: InputDecoration(
                                            hintText: "170",
                                            isDense: true,
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            )
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Target Kalori/Hari",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      TextField(
                                        controller: _heightController,
                                        decoration: InputDecoration(
                                            hintText: "65",
                                            isDense: true,
                                            border: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(10),
                                            )
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Tipe Diet",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      DropdownButtonFormField<String>(
                                        value: selectedDietType,
                                        hint: const Text("Pilih"),
                                        isExpanded: true,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.all(10),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: const BorderSide(color: Colors.grey),
                                          ),
                                        ),
                                        items: const [
                                          DropdownMenuItem(
                                            value: "",
                                            child: Text("Pilih"),
                                          ),
                                          DropdownMenuItem(
                                            value: "Regular",
                                            child: Text("Regular"),
                                          ),
                                          DropdownMenuItem(
                                            value: "Vegetarian",
                                            child: Text("Vegetarian"),
                                          ),
                                          DropdownMenuItem(
                                            value: "Vegan",
                                            child: Text("Vegan"),
                                          ),
                                          DropdownMenuItem(
                                            value: "Pescatarian",
                                            child: Text("Pescatarian"),
                                          ),
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            selectedDietType = value;
                                          });
                                        },
                                      )
                                    ],
                                  ),
                                ),
                                SizedBox(width: 16),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        "Level Aktivitas",
                                        style: TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontSize: 14,
                                        ),
                                      ),
                                      SizedBox(height: 4),
                                      DropdownButtonFormField<String>(
                                        value: selectedDietType,
                                        hint: const Text("Pilih"),
                                        isExpanded: true,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.all(10),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: const BorderSide(color: Colors.grey),
                                          ),
                                        ),
                                        items: const [
                                          DropdownMenuItem(
                                            value: "",
                                            child: Text("Pilih"),
                                          ),
                                          DropdownMenuItem(
                                            value: "Sedentary",
                                            child: Text("Sedentary (Jarang)"),
                                          ),
                                          DropdownMenuItem(
                                            value: "Light",
                                            child: Text("Light (1-3x/minggu)"),
                                          ),
                                          DropdownMenuItem(
                                            value: "Moderate",
                                            child: Text("Moderate (3-5x/minggu)"),
                                          ),
                                          DropdownMenuItem(
                                            value: "Active",
                                            child: Text("Active (6-7x/minggu)"),
                                          ),
                                          DropdownMenuItem(
                                            value: "Very Active",
                                            child: Text("Very Active (2x/hari)"),
                                          ),
                                        ],
                                        onChanged: (value) {
                                          setState(() {
                                            selectedDietType = value;
                                          });
                                        },
                                      )
                                    ],
                                  ),
                                ),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Informasi Pekerjaan
                    // Container(
                    //   width: double.infinity,
                    //   decoration: BoxDecoration(
                    //     color: Colors.white,
                    //     borderRadius: BorderRadius.circular(20),
                    //   ),
                    //   child: Container(
                    //     padding: EdgeInsets.all(20),
                    //     child: Column(
                    //       mainAxisSize: MainAxisSize.min,
                    //       mainAxisAlignment: MainAxisAlignment.start,
                    //       crossAxisAlignment: CrossAxisAlignment.start,
                    //       children: [
                    //         Row(
                    //           children: [
                    //             SizedBox.square(
                    //               dimension: 40,
                    //               child: Container(
                    //                 padding: EdgeInsets.all(8),
                    //                 decoration: BoxDecoration(
                    //                   color: Colors.blue,
                    //                   borderRadius: BorderRadius.circular(12),
                    //                 ),
                    //                 child: Icon(
                    //                   FontAwesomeIcons.building,
                    //                   size: 20,
                    //                   color: Colors.white,
                    //                 ),
                    //               ),
                    //             ),
                    //             const SizedBox(width: 20),
                    //             Text(
                    //               "Informasi Pekerjaan",
                    //               style: TextStyle(
                    //                 fontSize: 16,
                    //                 fontWeight: FontWeight.w500,
                    //               ),
                    //             ),
                    //           ],
                    //         ),
                    //         const SizedBox(height: 20),
                    //         Column(
                    //           mainAxisAlignment: MainAxisAlignment.start,
                    //           crossAxisAlignment: CrossAxisAlignment.start,
                    //           children: [
                    //             Text(
                    //               "Divisi",
                    //               style: TextStyle(
                    //                 fontSize: 14,
                    //                 fontWeight: FontWeight.w500,
                    //               ),
                    //             ),
                    //             const SizedBox(height: 4),
                    //             TextField(
                    //               decoration: InputDecoration(
                    //                 hintText: "Masukan divisi",
                    //                 isDense: true,
                    //                 border: OutlineInputBorder(
                    //                     borderRadius: BorderRadius.circular(10)
                    //                 ),
                    //               ),
                    //             )
                    //           ],
                    //         ),
                    //         const SizedBox(height: 20),
                    //         Column(
                    //           mainAxisAlignment: MainAxisAlignment.start,
                    //           crossAxisAlignment: CrossAxisAlignment.start,
                    //           children: [
                    //             Text(
                    //               "Jabatan",
                    //               style: TextStyle(
                    //                 fontSize: 14,
                    //                 fontWeight: FontWeight.w500,
                    //               ),
                    //             ),
                    //             const SizedBox(height: 4),
                    //             TextField(
                    //               decoration: InputDecoration(
                    //                 hintText: "Masukan jabatan",
                    //                 isDense: true,
                    //                 border: OutlineInputBorder(
                    //                     borderRadius: BorderRadius.circular(10)
                    //                 ),
                    //               ),
                    //             )
                    //           ],
                    //         ),
                    //       ],
                    //     ),
                    //   ),
                    // ),

                    const SizedBox(height: 20),

                    // Kondisi Kesehatan Dasar
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SizedBox.square(
                                  dimension: 40,
                                  child: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        colors: [
                                          Color(0xFFb749f6),
                                          Color(0xFFec3ca9),
                                        ],
                                        begin: Alignment.topLeft,
                                        end: Alignment.bottomRight,
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      FontAwesomeIcons.heart,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Text(
                                  "Kondisi Kesehatan Dasar",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 20),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Alergi",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _allergyController,
                                        onSubmitted: (_) => _addAllergy(),
                                        decoration: InputDecoration(
                                          hintText: "Tambah alergi (tekan Enter)",
                                          filled: true,
                                          fillColor: Colors.grey.shade200,
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10,),
                                    SizedBox(
                                      height: 48,
                                      width: 48,
                                      child: ElevatedButton(
                                        onPressed: _addAllergy,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          padding: EdgeInsets.zero,
                                        ),
                                        child: const Icon(Icons.add, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12,),
                                if (_allergyList.isEmpty)
                                  Text(
                                    "Tidak ada alergi yang tercatat",
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey,
                                    ),
                                  )
                                else
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _allergyList.map((item) {
                                      return Chip(
                                        label: Text(item),
                                        deleteIcon: const Icon(Icons.close, size: 18),
                                        onDeleted: () => _removeAllergy(item),
                                        backgroundColor: Colors.blue.shade50,
                                      );
                                    }).toList(),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Kondisi Medis",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _medicalConditionController,
                                        onSubmitted: (_) => _addMedicalCondition(),
                                        decoration: InputDecoration(
                                          hintText: "Tambah kondisi medis (tekan Enter)",
                                          filled: true,
                                          fillColor: Colors.grey.shade200,
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10,),
                                    SizedBox(
                                      height: 48,
                                      width: 48,
                                      child: ElevatedButton(
                                        onPressed: _addMedicalCondition,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          padding: EdgeInsets.zero,
                                        ),
                                        child: const Icon(Icons.add, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12,),
                                if (_medicalConditionList.isEmpty)
                                  Text(
                                    "Tidak ada kondisi medis yang tercatat",
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey,
                                    ),
                                  )
                                else
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _medicalConditionList.map((item) {
                                      return Chip(
                                        label: Text(item),
                                        deleteIcon: const Icon(Icons.close, size: 18),
                                        onDeleted: () => _removeMedicalCondition(item),
                                        backgroundColor: Colors.blue.shade50,
                                      );
                                    }).toList(),
                                  ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Obat yang Dikonsumsi",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextField(
                                        controller: _drugController,
                                        onSubmitted: (_) => _addDrug(),
                                        decoration: InputDecoration(
                                          hintText: "Tambah obat (tekan Enter)",
                                          filled: true,
                                          fillColor: Colors.grey.shade200,
                                          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide: BorderSide.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(width: 10,),
                                    SizedBox(
                                      height: 48,
                                      width: 48,
                                      child: ElevatedButton(
                                        onPressed: _addDrug,
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: Colors.blue,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(12),
                                          ),
                                          padding: EdgeInsets.zero,
                                        ),
                                        child: const Icon(Icons.add, color: Colors.white),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 12,),
                                if (_drugList.isEmpty)
                                  Text(
                                    "Tidak ada obat yang tercatat",
                                    style: TextStyle(
                                      fontStyle: FontStyle.italic,
                                      color: Colors.grey,
                                    ),
                                  )
                                else
                                  Wrap(
                                    spacing: 8,
                                    runSpacing: 8,
                                    children: _drugList.map((item) {
                                      return Chip(
                                        label: Text(item),
                                        deleteIcon: const Icon(Icons.close, size: 18),
                                        onDeleted: () => _removeDrug(item),
                                        backgroundColor: Colors.blue.shade50,
                                      );
                                    }).toList(),
                                  ),
                              ],
                            ),
                            // Column(
                            //   children: options.map((item) {
                            //     return CheckboxListTile(
                            //       title: Text(item["label"]),
                            //       value: item["checked"],
                            //       onChanged: (value) {
                            //         setState(() {
                            //           item["checked"] = value ?? false;
                            //         });
                            //       },
                            //     );
                            //   }).toList(),
                            // ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 20,),

                    // Kontak Darurat
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                SizedBox.square(
                                  dimension: 40,
                                  child: Container(
                                    padding: EdgeInsets.all(8),
                                    decoration: BoxDecoration(
                                      color: Colors.red,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Icon(
                                      FontAwesomeIcons.phone,
                                      size: 20,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 20),
                                Text(
                                  "Kontak Darurat",
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Nama Kontak Darurat",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                TextField(
                                  decoration: InputDecoration(
                                    hintText: "Nama keluarga/teman",
                                    isDense: true,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10)
                                    ),
                                  ),
                                )
                              ],
                            ),
                            const SizedBox(height: 20),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Nomor Telepon",
                                  style: TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                TextField(
                                  decoration: InputDecoration(
                                    hintText: "+62 812 3456 7890",
                                    isDense: true,
                                    border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(10)
                                    ),
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      )
                    ),

                    const SizedBox(height: 20),

                    // Note
                    Container(
                      width: double.infinity,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20),
                        color: Color(0xffecfafe),
                      ),
                      child: Container(
                        padding: EdgeInsets.all(20),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              margin: EdgeInsets.only(top: 4),
                              child: Icon(
                                FontAwesomeIcons.circleInfo,
                                size: 16,
                              ),
                            ),
                            SizedBox(width: 16,),
                            Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Privasi Anda Terjamin",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                    Text(
                                      "Semua data kesehatan disimpan secara lokal di perangkat Anda dan tidak dikirim ke server manapun.",
                                      style: TextStyle(
                                        fontSize: 16,
                                      ),
                                    ),
                                  ],
                                )
                            )
                          ],
                        ),
                      ),
                    ),

                    const SizedBox(height: 20),

                    // Save Button
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton(
                        onPressed: () {},
                        style: ElevatedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          backgroundColor: Colors.blue,
                        ),
                        child: Text(
                          "Simpan Profil Kesehatan",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
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
