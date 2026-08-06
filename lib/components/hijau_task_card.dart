import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HijauTaskCard extends StatelessWidget {
  final FaIconData icon;
  final String title;
  final String difficulty;
  final String description;
  final int points;
  final String? benefit;
  final bool isCompleted;
  final VoidCallback onSelesai;
  final Color sectionColor;

  const HijauTaskCard({
    super.key,
    required this.icon,
    required this.title,
    required this.difficulty,
    required this.description,
    required this.points,
    this.benefit,
    required this.isCompleted,
    required this.onSelesai,
    this.sectionColor = const Color(0xff059669),
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            spreadRadius: 0,
            offset: const Offset(0, 4),
          ),
        ],
        border: isCompleted 
          ? Border.all(color: sectionColor.withOpacity(0.5), width: 2)
          : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox.square(
                dimension: 50,
                child: Container(
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: sectionColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: FaIcon(icon, size: 24, color: sectionColor),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.orange.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        difficulty,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Colors.orange,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (isCompleted)
                const FaIcon(
                  FontAwesomeIcons.solidCircleCheck,
                  color: Color(0xff059669),
                  size: 24,
                ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            description,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[700],
            ),
          ),
          const SizedBox(height: 16),
          if (benefit != null) ...[
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.05),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.withOpacity(0.1)),
              ),
              child: Row(
                children: [
                  const FaIcon(FontAwesomeIcons.bolt, size: 14, color: Colors.blue),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      "Keuntungan: $benefit",
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.blue,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
          ],
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const FaIcon(FontAwesomeIcons.coins, size: 16, color: Colors.amber),
                  const SizedBox(width: 6),
                  Text(
                    "+$points Poin",
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: Colors.amber,
                    ),
                  ),
                ],
              ),
              if (!isCompleted)
                ElevatedButton(
                  onPressed: onSelesai,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: sectionColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                    elevation: 0,
                  ),
                  child: const Text(
                    "Selesai",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                )
              else
                Text(
                  "Selesai",
                  style: TextStyle(
                    color: sectionColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
