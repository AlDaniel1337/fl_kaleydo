import 'package:flutter/material.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';


/// Widget que representa el título del encabezado "Kaleydo".
class HeaderTitle extends StatelessWidget {
   
  const HeaderTitle({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Text(
      'Kaleydo',
      style: TextStyle(
        color: AppColors.primaryAccent,
        fontSize: 22,
        fontWeight: FontWeight.bold,
        letterSpacing: 0.5,
      ),
    );
  }
}