import 'package:flutter/material.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';


/// Widget que muestra un mensaje indicando que no se encontró contenido multimedia.
class NoMultimediaMessage extends StatelessWidget {
   
  const NoMultimediaMessage({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: const [
          Icon(Icons.folder_off_outlined, 
            size: 48, 
            color: AppColors.textSecondary
          ),
          SizedBox(height: 12),
          Text(
            'No se encontro contenido',
            style: TextStyle(color: AppColors.textSecondary, fontSize: 16),
          ),
        ],
      ),
    );
  }
}