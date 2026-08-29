import 'package:flutter/material.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';


/// Widget que muestra el título dinámico de la categoría seleccionada.
class DynamicCategoryTitle extends StatelessWidget {

  final String title;
   
  const DynamicCategoryTitle({super.key, required this.title});
  
  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        color: AppColors.textPrimary,
        fontSize: 24,
        fontWeight: FontWeight.bold,
      ),
    );
  }
}