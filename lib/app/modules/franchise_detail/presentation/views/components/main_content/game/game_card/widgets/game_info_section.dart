import 'package:flutter/material.dart';

class GameInfoSection extends StatelessWidget {
  final String info;

  const GameInfoSection({super.key, required this.info});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 60,
      child: SingleChildScrollView(
        child: Text(
          info,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }
}