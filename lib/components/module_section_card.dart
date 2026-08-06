import 'package:employee_wellness/services/app_localizations.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class ModuleSectionCard extends StatelessWidget {
  final Widget? destination;
  final Color backgroundColor;
  final Color sectionColor;
  final FaIconData icon;
  final String heading;
  final String subHeading;
  final String description;
  final String targetText;
  final bool? isCompleted;

  const ModuleSectionCard({
    super.key,
    required this.destination,
    required this.backgroundColor,
    required this.sectionColor,
    required this.icon,
    required this.heading,
    required this.subHeading,
    required this.description,
    required this.targetText,
    this.isCompleted,
  });

  @override
  Widget build(BuildContext context) {
    final loc = AppLocalizations.of(context)!;
    return GestureDetector(
      onTap: () => {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => destination!),
        ),
      },
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.08),
              blurRadius: 12,
              spreadRadius: 2,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: Stack(
          children: [
            Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                SizedBox.square(
                  dimension: 60,
                  child: Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: sectionColor,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: FaIcon( // 🔥 sudah benar
                      icon,
                      size: 36,
                      color: Colors.white,
                    ),
                  ),
                ),
                const SizedBox(width: 20,),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        heading,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      Text(
                        subHeading,
                        style: const TextStyle(
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12,),
            Text(
              description,
              textAlign: TextAlign.left,
            ),
            const SizedBox(height: 12,),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      SizedBox.square(
                        dimension: 10,
                        child: Container(
                          alignment: Alignment.center,
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: sectionColor,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Text(""),
                        ),
                      ),
                      const SizedBox(width: 8,),
                      Text(loc.translate('target_label'))
                    ],
                  ),
                  Text(
                    targetText,
                    style: const TextStyle(
                      fontWeight: FontWeight.w500,
                    ),
                  )
                ],
              ),
            )
          ],
        ),
        if (isCompleted == true)
          Positioned(
            top: -4,
            right: -4,
            child: Container(
              alignment: Alignment.center,
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: const Color(0xFF00C368),
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
              child: const Icon(Icons.check, size: 16, color: Colors.white),
            ),
          ),
      ],
    ),
      ),
    );
  }
}
