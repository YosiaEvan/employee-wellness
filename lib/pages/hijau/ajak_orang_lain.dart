import 'package:employee_wellness/components/bottom_header.dart';
import 'package:employee_wellness/components/header.dart';
import 'package:employee_wellness/components/responsive_container.dart';
import 'package:employee_wellness/pages/hijau_homepage.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

class AjakOrangLain extends StatefulWidget {
  const AjakOrangLain({super.key});

  @override
  State<AjakOrangLain> createState() => _AjakOrangLainState();
}

class _AjakOrangLainState extends State<AjakOrangLain> {
  bool _sudahMengajak = false;
  final int _jumlahDiundang = 12;
  final int _jumlahBergabung = 5;
  final int _jumlahAktif = 3;

  void _shareToWhatsApp() async {
    const message = "Halo! Mari bergabung di Employee Wellness dan jalani gaya hidup sehat serta ramah lingkungan bersama saya. Gunakan kode referral saya: WELLNESS2026";
    final url = Uri.parse("whatsapp://send?text=${Uri.encodeComponent(message)}");
    
    if (await canLaunchUrl(url)) {
      await launchUrl(url);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("WhatsApp tidak terpasang di perangkat ini")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withValues(alpha: 0.98),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Header(),
            BottomHeader(
              color: const Color(0xfff59e0b),
              heading: "Ajak Orang Lain",
              subHeading: "Kolaborasi untuk Bumi",
              destination: const HijauHomepage(),
            ),
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: ResponsiveContainer(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Referral Statistics Card
                      Container(
                        padding: const EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.05),
                              blurRadius: 10,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            const Row(
                              children: [
                                FaIcon(FontAwesomeIcons.users, color: Color(0xfff59e0b), size: 24),
                                SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    "Status Referral Anda",
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                Expanded(child: _buildStatItem("Diundang", _jumlahDiundang.toString(), Colors.blue)),
                                Expanded(child: _buildStatItem("Bergabung", _jumlahBergabung.toString(), Colors.green)),
                                Expanded(child: _buildStatItem("Aktif", _jumlahAktif.toString(), Colors.orange)),
                              ],
                            ),
                            const Divider(height: 32),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                const FaIcon(FontAwesomeIcons.coins, color: Colors.amber, size: 20),
                                const SizedBox(width: 8),
                                const Flexible(
                                  child: Text(
                                    "+75 Poin per teman",
                                    style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber, fontSize: 16),
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 24),

                      // WhatsApp Share Section
                      const Text(
                        "Bagikan ke Teman",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: _shareToWhatsApp,
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: const Color(0xff25D366),
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              FaIcon(FontAwesomeIcons.whatsapp, color: Colors.white, size: 24),
                              SizedBox(width: 12),
                              Flexible(
                                child: Text(
                                  "Ajak lewat WhatsApp",
                                  style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Invitation Status Section
                      const Text(
                        "Status Ajakan",
                        style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(height: 12),
                      GestureDetector(
                        onTap: () {
                          setState(() {
                            _sudahMengajak = !_sudahMengajak;
                          });
                        },
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          padding: const EdgeInsets.all(20),
                          decoration: BoxDecoration(
                            color: _sudahMengajak ? const Color(0xffecfdf5) : const Color(0xfffff7ed),
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(
                              color: _sudahMengajak ? const Color(0xff10b981) : const Color(0xfff59e0b),
                              width: 2,
                            ),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  FaIcon(
                                    _sudahMengajak ? FontAwesomeIcons.solidCircleCheck : FontAwesomeIcons.circleExclamation,
                                    color: _sudahMengajak ? const Color(0xff10b981) : const Color(0xfff59e0b),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      _sudahMengajak ? "Sudah Mengajak Teman" : "Belum Mengajak Teman",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                        color: _sudahMengajak ? const Color(0xff065f46) : const Color(0xff92400e),
                                      ),
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _sudahMengajak
                                    ? "Luar biasa! Anda telah berkontribusi menyebarkan gaya hidup sehat ke lingkaran sosial Anda. Terus ajak lebih banyak teman!"
                                    : "Jangan biarkan teman Anda ketinggalan! Ajak mereka sekarang untuk bersama-sama membangun kebiasaan hidup yang lebih baik dan kumpulkan poin ekstra.",
                                style: TextStyle(
                                  color: _sudahMengajak ? const Color(0xff065f46).withOpacity(0.8) : const Color(0xff92400e).withOpacity(0.8),
                                ),
                                softWrap: true,
                              ),
                              const SizedBox(height: 16),
                              Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  _sudahMengajak ? "Status: Selesai" : "Klik jika sudah mengajak",
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: color),
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(fontSize: 12, color: Colors.grey, fontWeight: FontWeight.w500),
        ),
      ],
    );
  }
}
