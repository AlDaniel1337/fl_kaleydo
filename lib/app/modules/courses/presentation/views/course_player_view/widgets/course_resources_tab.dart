import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:kaleydo/app/modules/courses/presentation/controllers/course_player_controller.dart';


/// Widget que muestra los recursos adjuntos de la lección actual del curso.
/// Si no hay recursos, muestra un mensaje indicando que no hay recursos disponibles.
class CourseResourcesTab extends StatelessWidget {
  final CoursePlayerController controller;

  const CourseResourcesTab({super.key, required this.controller});
  
  @override
  Widget build(BuildContext context) {
    return Obx(() {
      
      final lesson = controller.currentLesson.value;
      if (lesson == null || lesson.resources.isEmpty) {
        return const Center(
          child: Text('No hay recursos adjuntos en esta lección', 
            style: TextStyle(color: AppColors.textSecondary)
          ),
        );
      }

      return ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: lesson.resources.length,
        itemBuilder: (context, index) {
          final res = lesson.resources[index];
          return ListTile(
            leading: const Icon(Icons.insert_drive_file, color: AppColors.primaryAccent),
            title: Text(res.name, style: const TextStyle(color: AppColors.textPrimary)),
            trailing: IconButton(
              icon: const Icon(Icons.folder_open, color: AppColors.textSecondary),
              tooltip: 'Abrir ubicación',
              onPressed: () => controller.openResourceFolder(res.path),
            ),
          );
        },
      );
    });
  }
}