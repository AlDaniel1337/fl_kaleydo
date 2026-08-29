import 'package:flutter/material.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';


/// Widget que muestra un indicador de carga centrado.
class LoadingWidget extends StatelessWidget {
   
  const LoadingWidget({super.key});
  
  @override
  Widget build(BuildContext context) {
    return Center(
      child: CircularProgressIndicator(color: AppColors.primaryAccent),
    );
  }
}