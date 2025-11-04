import 'package:employee_wellness/components/bottom_header.dart';
import 'package:employee_wellness/components/header.dart';
import 'package:employee_wellness/pages/sehat/udara_segar.dart';
import 'package:employee_wellness/pages/sehat_homepage.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class PolaMakanSehat extends StatefulWidget {
  const PolaMakanSehat({super.key});

  @override
  State<PolaMakanSehat> createState() => _PolaMakanSehatState();
}

class _PolaMakanSehatState extends State<PolaMakanSehat> {
  double get totalCalories {
    return foods.fold(0, (sum, item) => sum + (item['calories'] ?? 0));
  }
  double targetCalories = 2000;
  double get progress {
    if (targetCalories == 0) return 0;
    return ((totalCalories / targetCalories) * 100).clamp(0, 100);
  }
  double get remainingCalories {
    return (targetCalories - totalCalories).clamp(0, targetCalories);
  }
  double get totalProtein => foods.fold(0, (sum, food) => sum + (food["proteins"] ?? 0));
  double get totalCarb => foods.fold(0, (sum, food) => sum + (food["carbs"] ?? 0));
  double get totalFiber => foods.fold(0, (sum, food) => sum + (food["fibers"] ?? 0));
  double get totalAll => totalProtein + totalCarb + totalFiber;
  final TextEditingController nameController = TextEditingController();
  final TextEditingController calorieController = TextEditingController();
  final TextEditingController proteinController = TextEditingController();
  final TextEditingController carbController = TextEditingController();
  final TextEditingController fiberController = TextEditingController();
  final TextEditingController fatController = TextEditingController();
  bool containsSugar = false;
  bool containsOil = false;
  List<Map<String, dynamic>> foods = [];

  void addFood() {
    if (nameController.text.isEmpty || calorieController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Nama dan Kalori wajib diisi!")),
      );
      return;
    }

    setState(() {
      foods.add({
        "name": nameController.text,
        "calories": double.tryParse(calorieController.text) ?? 0,
        "proteins": double.tryParse(proteinController.text) ?? 0,
        "carbs": double.tryParse(carbController.text) ?? 0,
        "fibers": double.tryParse(fiberController.text) ?? 0,
        "fat": double.tryParse(fatController.text) ?? 0,
        "addOil": containsOil,
        "addSugar": containsSugar,
        "time": DateFormat('HH:mm').format(DateTime.now()),
      });
    });

    nameController.clear();
    calorieController.clear();
    proteinController.clear();
    carbController.clear();
    fiberController.clear();
    fatController.clear();
    setState(() {
      containsOil = false;
      containsSugar = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Makanan berhasil ditambahkan!")),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    calorieController.dispose();
    proteinController.dispose();
    carbController.dispose();
    fiberController.dispose();
    fatController.dispose();
    super.dispose();
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
                                        showModalBottomSheet(
                                          context: context,
                                          isScrollControlled: true,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
                                          ),
                                          builder: (context) {
                                            return StatefulBuilder(
                                              builder: (context, setModalState) {
                                                return Padding(
                                                  padding: EdgeInsets.all(20),
                                                  child: Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    children: [
                                                      Text(
                                                        "Tambah Makanan",
                                                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                                      ),
                                                      SizedBox(height: 12),
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            "Nama Makanan",
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight: FontWeight.w500,
                                                            ),
                                                          ),
                                                          SizedBox(height: 4,),
                                                          TextField(
                                                            controller: nameController,
                                                            decoration: InputDecoration(
                                                              labelText: "Nama makanan",
                                                              border: OutlineInputBorder(),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 12),
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            "Kalori (kkal)",
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight: FontWeight.w500,
                                                            ),
                                                          ),
                                                          SizedBox(height: 4,),
                                                          TextField(
                                                            controller: calorieController,
                                                            decoration: InputDecoration(
                                                              labelText: "Jumlah Kalori",
                                                              border: OutlineInputBorder(),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 12),
                                                      Row(
                                                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                        children: [
                                                          Expanded(
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Text(
                                                                    "Protein (g)",
                                                                    style: TextStyle(
                                                                      fontSize: 16,
                                                                      fontWeight: FontWeight.w500,
                                                                    ),
                                                                  ),
                                                                  SizedBox(height: 4,),
                                                                  TextField(
                                                                    controller: proteinController,
                                                                    decoration: InputDecoration(
                                                                      labelText: "Jumlah Protein",
                                                                      border: OutlineInputBorder(),
                                                                    ),
                                                                  ),
                                                                ],
                                                              )
                                                          ),
                                                          SizedBox(width: 8,),
                                                          Expanded(
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Text(
                                                                    "Karbohidrat (g)",
                                                                    style: TextStyle(
                                                                      fontSize: 16,
                                                                      fontWeight: FontWeight.w500,
                                                                    ),
                                                                  ),
                                                                  SizedBox(height: 4,),
                                                                  TextField(
                                                                    controller: carbController,
                                                                    decoration: InputDecoration(
                                                                      labelText: "Jumlah Karbohidrat",
                                                                      border: OutlineInputBorder(),
                                                                    ),
                                                                  ),
                                                                ],
                                                              )
                                                          ),
                                                          SizedBox(width: 8,),
                                                          Expanded(
                                                              child: Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  Text(
                                                                    "Serat (g)",
                                                                    style: TextStyle(
                                                                      fontSize: 16,
                                                                      fontWeight: FontWeight.w500,
                                                                    ),
                                                                  ),
                                                                  SizedBox(height: 4,),
                                                                  TextField(
                                                                    controller: fiberController,
                                                                    decoration: InputDecoration(
                                                                      labelText: "Jumlah Serat",
                                                                      border: OutlineInputBorder(),
                                                                    ),
                                                                  ),
                                                                ],
                                                              )
                                                          )
                                                        ],
                                                      ),
                                                      SizedBox(height: 12),
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            "Lemak (g)",
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              fontWeight: FontWeight.w500,
                                                            ),
                                                          ),
                                                          SizedBox(height: 4,),
                                                          TextField(
                                                            controller: fatController,
                                                            decoration: InputDecoration(
                                                              labelText: "Jumlah Lemak",
                                                              border: OutlineInputBorder(),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 12),
                                                      Column(
                                                        children: [
                                                          CheckboxListTile(
                                                            title: Text("Mengandung minyak goreng"),
                                                            value: containsOil,
                                                            onChanged: (value) => setModalState(() => containsOil = value ?? false),
                                                          ),
                                                          CheckboxListTile(
                                                            title: Text("Mengandung gula tambahan"),
                                                            value: containsSugar,
                                                            onChanged: (value) => setModalState(() => containsSugar = value ?? false),
                                                          ),
                                                        ],
                                                      ),
                                                      SizedBox(height: 12),
                                                      Container(
                                                          decoration: BoxDecoration(
                                                            color: Color(0xff00bd7b),
                                                            borderRadius: BorderRadius.circular(8),
                                                          ),
                                                          child: ElevatedButton(
                                                            onPressed: () {
                                                              addFood();
                                                              Navigator.pop(context);
                                                            },
                                                            style: ElevatedButton.styleFrom(
                                                              backgroundColor: Colors.transparent,
                                                              shadowColor: Colors.transparent,
                                                            ),
                                                            child: Text(
                                                              "Simpan",
                                                              style: TextStyle(
                                                                color: Colors.white,
                                                                fontSize: 16,
                                                              ),
                                                            ),
                                                          )
                                                      )
                                                    ],
                                                  ),
                                                );
                                              }
                                            );
                                          },
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
                          if (foods.isNotEmpty)
                            ListView.separated(
                            itemCount: foods.length,
                            separatorBuilder: (context, index) => SizedBox(height: 12),
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              final food = foods[index];

                              return Container(
                                width: double.infinity,
                                padding: EdgeInsets.all(16),
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(20),
                                    color: Color(0xffedfdf5),
                                    border: Border.all(
                                      color: Color(0xffb9f8cf),
                                      width: 2,
                                      style: BorderStyle.solid,
                                    )
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          food["name"],
                                          style: TextStyle(
                                            fontSize: 20,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                        Text(
                                          food["time"].toString(),
                                          style: TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 8,),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            if (food["addOil"])
                                              Container(
                                                padding: EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(8),
                                                  color: Color(0xfffff085),
                                                ),
                                                child: Text(
                                                  "🛢️ Minyak",
                                                ),
                                              ),
                                            if (food["addOil"])
                                              SizedBox(width: 4,),
                                            if (food["addSugar"])
                                              Container(
                                                padding: EdgeInsets.all(4),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(8),
                                                  color: Color(0xfffccee8),
                                                ),
                                                child: Text(
                                                  "🍬 Gula",
                                                ),
                                              )
                                          ],
                                        ),
                                        Text(
                                          "${food["calories"]} kkal",
                                          style: TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),
                                        )
                                      ],
                                    ),
                                    SizedBox(height: 8,),
                                    Row(
                                      children: [
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Color(0xffffe2e2),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            "P: ${food["proteins"]}g",
                                          ),
                                        ),
                                        SizedBox(width: 4,),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Color(0xffdbeafe),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            "K: ${food["carbs"]}g",
                                          ),
                                        ),
                                        SizedBox(width: 4,),
                                        Container(
                                          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                          decoration: BoxDecoration(
                                            color: Color(0xffdbfce7),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            "S: ${food["fibers"]}g",
                                          ),
                                        )
                                      ],
                                    )
                                  ],
                                )
                              );
                            },
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
                            colors: [Color(0xffdbeafe), Color(0xffcffafe)],
                            begin: Alignment.centerLeft,
                            end: Alignment.centerRight,
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
                                    "Tantangan Sehat",
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
                                    color: Color(0xffecfcff),
                                    borderRadius: BorderRadius.circular(20)
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "🎯 Target 2 Hari Tanpa Minyak",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff193cb8),
                                      ),
                                    ),
                                    SizedBox(height: 12,),
                                    Text(
                                      "Kurangi gorengan dan masakan berminyak untuk kesehatan jantung",
                                      style: TextStyle(
                                        color: Color(0xff4772ec),
                                      ),
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
                                    Text(
                                      "🎯 Target 2 Hari Tanpa Gula",
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                        color: Color(0xff193cb8),
                                      ),
                                    ),
                                    SizedBox(height: 12,),
                                    Text(
                                      "Hindari gula tambahan untuk kontrol gula darah yang lebih baik",
                                      style: TextStyle(
                                        color: Color(0xff4772ec),
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
}
