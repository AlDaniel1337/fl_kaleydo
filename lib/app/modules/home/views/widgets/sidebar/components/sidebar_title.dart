import 'package:flutter/material.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';

/// Widget que representa el título de la barra lateral de la aplicación Kaleydo.
class SidebarTitle extends StatelessWidget {
   
  const SidebarTitle({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.only(left: 12.0, bottom: 28.0),
      child: Text(
        'Multimedia',
        style: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 20,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}