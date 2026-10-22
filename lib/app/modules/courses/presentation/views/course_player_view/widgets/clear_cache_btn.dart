import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:kaleydo/app/modules/courses/presentation/controllers/course_player_controller.dart';


/// Botón para limpiar el caché de posiciones de las lecciones del curso
class ClearCacheBtn extends StatelessWidget {

  final CoursePlayerController controller;
   
  const ClearCacheBtn({super.key, required this.controller});
  
  @override
  Widget build(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.cleaning_services, color: AppColors.textSecondary),
      tooltip: 'Limpiar caché de posiciones',
      onPressed: () {
        // Diálogo de confirmación rápido
        Get.defaultDialog(
          title: 'Limpiar Caché',
          middleText: '¿Deseas reiniciar las posiciones guardadas de este curso? \n(No afectará las lecciones marcadas como vistas)',
          textConfirm: 'Limpiar',
          textCancel: 'Cancelar',
          confirmTextColor: Colors.white,
          buttonColor: AppColors.primaryAccent,
          onConfirm: () {
            controller.clearCache();
            Get.back();
          },
        );
      },
    );
  }
}