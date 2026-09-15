import 'package:flutter/material.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';

class GameTitle extends StatelessWidget {

  final String title;
   
  const GameTitle({super.key, required this.title});
  
  @override
  Widget build(BuildContext context) {
    return  Text(
      title,
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 14,
        letterSpacing: 0.5,
      ),
    );
  }
}