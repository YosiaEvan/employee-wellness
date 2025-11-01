import 'package:employee_wellness/components/header.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class UdaraSegar extends StatefulWidget {
  const UdaraSegar({super.key});

  @override
  State<UdaraSegar> createState() => _UdaraSegarState();
}

class _UdaraSegarState extends State<UdaraSegar> {
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
            Container(
              padding: EdgeInsets.all(20),
              width: double.infinity,
              decoration: BoxDecoration(
                  color: Color(0xff009bf4),
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
                            "Udara Segar",
                            style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                          Text(
                            "Teknik Pernapasan",
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
                          Column(
                            children: [
                              Text(
                                "🧘‍♂️",
                                style: TextStyle(
                                  fontSize: 52,
                                ),
                              ),
                              SizedBox(height: 8,),
                              Text(
                                "Siap Memulai",
                                style: TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                "Tekan tombol mulai",
                                style: TextStyle(
                                  fontSize: 16,
                                ),
                              )
                            ],
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
                          Container(
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
                                          "0%",
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
                                        "0g",
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
                                          "0%",
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
                                        "0g",
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
                                          "0%",
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
                                        "0g",
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
                                                            value: false,
                                                            onChanged: (_) {}
                                                        ),
                                                        CheckboxListTile(
                                                            title: Text("Mengandung gula tambahan"),
                                                            value: false,
                                                            onChanged: (_) {}
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
                                                            // aksi tambah
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
                          // if (foods.isNotEmpty)
                          //   ListView.separated(
                          //     itemCount: foods.length,
                          //     separatorBuilder: (context, index) => SizedBox(height: 12),
                          //     shrinkWrap: true,
                          //     physics: NeverScrollableScrollPhysics(),
                          //     itemBuilder: (context, index) {
                          //       final food = foods[index];
                          //
                          //       return Container(
                          //           width: double.infinity,
                          //           padding: EdgeInsets.all(16),
                          //           decoration: BoxDecoration(
                          //               borderRadius: BorderRadius.circular(20),
                          //               color: Color(0xffedfdf5),
                          //               border: Border.all(
                          //                 color: Color(0xffb9f8cf),
                          //                 width: 2,
                          //                 style: BorderStyle.solid,
                          //               )
                          //           ),
                          //           child: Column(
                          //             children: [
                          //               Row(
                          //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //                 children: [
                          //                   Text(
                          //                     food["name"],
                          //                     style: TextStyle(
                          //                       fontSize: 20,
                          //                       fontWeight: FontWeight.bold,
                          //                     ),
                          //                   ),
                          //                   Text(
                          //                     food["time"].toString(),
                          //                     style: TextStyle(
                          //                       fontSize: 12,
                          //                       fontWeight: FontWeight.bold,
                          //                     ),
                          //                   ),
                          //                 ],
                          //               ),
                          //               SizedBox(height: 8,),
                          //               Row(
                          //                 mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //                 children: [
                          //                   Row(
                          //                     children: [
                          //                       if (food["addOil"] == 1)
                          //                         Container(
                          //                           padding: EdgeInsets.all(4),
                          //                           decoration: BoxDecoration(
                          //                             borderRadius: BorderRadius.circular(8),
                          //                             color: Color(0xfffff085),
                          //                           ),
                          //                           child: Text(
                          //                             "🛢️ Minyak",
                          //                           ),
                          //                         ),
                          //                       if (food["addOil"] == 1)
                          //                         SizedBox(width: 4,),
                          //                       if (food["addSugar"] == 1)
                          //                         Container(
                          //                           padding: EdgeInsets.all(4),
                          //                           decoration: BoxDecoration(
                          //                             borderRadius: BorderRadius.circular(8),
                          //                             color: Color(0xfffccee8),
                          //                           ),
                          //                           child: Text(
                          //                             "🍬 Gula",
                          //                           ),
                          //                         )
                          //                     ],
                          //                   ),
                          //                   Text(
                          //                     "${food["calories"]} kkal",
                          //                     style: TextStyle(
                          //                       color: Colors.red,
                          //                       fontWeight: FontWeight.bold,
                          //                       fontSize: 16,
                          //                     ),
                          //                   )
                          //                 ],
                          //               ),
                          //               SizedBox(height: 8,),
                          //               Row(
                          //                 children: [
                          //                   Container(
                          //                     padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          //                     decoration: BoxDecoration(
                          //                       color: Color(0xffffe2e2),
                          //                       borderRadius: BorderRadius.circular(4),
                          //                     ),
                          //                     child: Text(
                          //                       "P: ${food["proteins"]}g",
                          //                     ),
                          //                   ),
                          //                   SizedBox(width: 4,),
                          //                   Container(
                          //                     padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          //                     decoration: BoxDecoration(
                          //                       color: Color(0xffdbeafe),
                          //                       borderRadius: BorderRadius.circular(4),
                          //                     ),
                          //                     child: Text(
                          //                       "K: ${food["carbs"]}g",
                          //                     ),
                          //                   ),
                          //                   SizedBox(width: 4,),
                          //                   Container(
                          //                     padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          //                     decoration: BoxDecoration(
                          //                       color: Color(0xffdbfce7),
                          //                       borderRadius: BorderRadius.circular(4),
                          //                     ),
                          //                     child: Text(
                          //                       "S: ${food["fibers"]}g",
                          //                     ),
                          //                   )
                          //                 ],
                          //               )
                          //             ],
                          //           )
                          //       );
                          //     },
                          //   )
                          // else
                          //   Container(
                          //     width: double.infinity,
                          //     height: 200,
                          //     alignment: Alignment.center,
                          //     padding: EdgeInsets.all(20),
                          //     decoration: BoxDecoration(
                          //         color: Color(0xfff9fafb),
                          //         borderRadius: BorderRadius.circular(20)
                          //     ),
                          //     child: Column(
                          //       mainAxisAlignment: MainAxisAlignment.center,
                          //       children: [
                          //         Icon(
                          //           FontAwesomeIcons.appleWhole,
                          //           color: Color(0xff99a1af),
                          //           size: 40,
                          //         ),
                          //         SizedBox(height: 12,),
                          //         Text(
                          //           "Belum ada makanan tercatat hari ini",
                          //           style: TextStyle(
                          //               color: Color(0xff99a1af),
                          //               fontSize: 16,
                          //               fontWeight: FontWeight.w500
                          //           ),
                          //         ),
                          //         Text(
                          //           'Klik "Tambah" untuk mencatat makanan',
                          //           style: TextStyle(
                          //             color: Color(0xff99a1af),
                          //             fontSize: 12,
                          //           ),
                          //         )
                          //       ],
                          //     ),
                          //   )
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
