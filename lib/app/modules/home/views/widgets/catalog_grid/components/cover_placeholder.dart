import 'package:flutter/material.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';


/// Placeholder para la imagen de portada cuando no hay una disponible.
class CoverPlaceholder extends StatelessWidget {
   
  const CoverPlaceholder({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Icon(
        Icons.image_outlined,
        size: 44,
        color: AppColors.textSecondary.withAlpha(100),
      ),
    );
  }
}