import 'package:flutter/material.dart';

class MainFeature extends StatelessWidget {
  final Color color;
  final String text;

  const MainFeature({
    super.key,
    required this.color,
    required this.text
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          text,
          style: TextStyle(
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.left,
        )
      ],
    );
  }
}
