import 'package:flutter/material.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';

/// Divisor personalizado con padding vertical.
class CustomDivider extends StatelessWidget {
   
  const CustomDivider({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.symmetric(vertical: 8.0),
      child: Divider(
        color: AppColors.cardBorder, 
        height: 1
      ),
    );
  }
}