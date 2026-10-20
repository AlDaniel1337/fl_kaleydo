import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:kaleydo/app/modules/courses/presentation/controllers/course_player_controller.dart';
import 'package:kaleydo/app/modules/courses/data/models/course_model.dart';


/// Widget que muestra el índice de lecciones de un curso, 
/// Permitiendo expandir secciones y seleccionar lecciones.
class CourseLessonsIndex extends StatelessWidget {

  final CoursePlayerController controller;
   
  const CourseLessonsIndex({super.key, required this.controller});
  
  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      itemCount: controller.course.sections.length,
      
      itemBuilder: (context, sectionIndex) {

        final section = controller.course.sections[sectionIndex];
        
        return Theme(
          data: Theme.of(context).copyWith(dividerColor: Colors.transparent),
          child: ExpansionTile(
            initiallyExpanded: sectionIndex == 0, // La primera sección inicia abierta
            title: Text(
              section.title,
              style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            ),
            children: section.lessons.map((lesson) {
              return Obx(() {
                final isSelected = controller.currentLesson.value?.id == lesson.id;
                final state = controller.lessonStates[lesson.id] ?? LessonState.notViewed;

                // Definimos el ícono según el estado
                IconData stateIcon = Icons.check_circle;
                Color stateColor = Colors.green;
                switch (state) {
                  case LessonState.viewed:
                    stateIcon = Icons.check_circle;
                    stateColor = Colors.green;
                    break;
                  case LessonState.inProgress:
                    stateIcon = Icons.incomplete_circle;
                    stateColor = Colors.orange;
                    break;
                  case LessonState.notViewed:
                    stateIcon = Icons.radio_button_unchecked;
                    stateColor = Colors.grey;
                    break;
                }

                return ListTile(
                  selected: isSelected,
                  // Color de fondo cuando está seleccionado
                  selectedTileColor: Colors.grey.withValues(alpha: 0.2), 
                  leading: Icon(stateIcon, color: stateColor, size: 20),
                  title: Text(
                    lesson.title,
                    style: TextStyle(
                      color: isSelected ? AppColors.primaryAccent : AppColors.textSecondary,
                      fontSize: 14,
                    ),
                  ),
                  onTap: () => controller.playLesson(lesson),
                );
                
              });
            }).toList(),
          ),
        );
      },
    );
  }
}