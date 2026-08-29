import 'package:flutter/material.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';

/// Widget que muestra un mensaje indicando que no hay carpetas disponibles.
class NoFoldersMessage extends StatelessWidget {
   
  const NoFoldersMessage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(12.0),
      child: Text(
        'Sin carpetas',
        style: TextStyle(color: AppColors.textSecondary, fontSize: 13),
      ),
    );
  }
}