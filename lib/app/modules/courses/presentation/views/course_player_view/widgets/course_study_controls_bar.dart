import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:kaleydo/app/modules/courses/presentation/controllers/course_player_controller.dart';
import 'package:kaleydo/app/modules/courses/data/models/course_model.dart';
import 'package:kaleydo/app/modules/courses/presentation/views/course_player_view/widgets/widgets.index.dart';


/// Barra de controles de estudio del curso, 
/// Incluye botones para avanzar/retroceder, cambiar velocidad y marcar lecciones.
class CourseStudyControlsBar extends StatelessWidget {
  final CoursePlayerController controller;

  const CourseStudyControlsBar({super.key, required this.controller});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      color: AppColors.cardBackground,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Obx(() {
            final lesson = controller.currentLesson.value;
            return Text(
              lesson?.title ?? 'Selecciona una lección',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
            );
          }),
          Row(
            children: [
              //: Botones de adelantar y retroceder 10 segundos
              _FastForwardAndRewindButtons(
                onRewind: controller.video.skipBackward,
                onFastForward: controller.video.skipForward,
              ),
              const SizedBox(width: 16),
              
              //: Botón de Velocidad
              ChangeVideoSpeedBtn(controller: controller),
              const SizedBox(width: 16),

              //: Botón para marcar la lección como completada / sin completar
              _ChangeLessonStatus(controller: controller),
            ],
          )
        ],
      ),
    );
  }
}



/// Botón para marcar la lección como completada o sin completar.
class _ChangeLessonStatus extends StatelessWidget {
  const _ChangeLessonStatus({
    required this.controller,
  });

  final CoursePlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {

      final lesson = controller.currentLesson.value;
      if (lesson == null) return const SizedBox.shrink();
      final state = controller.lessonStates[lesson.id] ?? LessonState.notViewed;

      return ElevatedButton.icon(
        icon: Icon(state == LessonState.viewed 
          ? Icons.check_circle 
          : Icons.check_circle_outline
        ),
        label: Text(state == LessonState.viewed 
          ? 'Completado' 
          : 'Marcar visto'
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: state == LessonState.viewed 
            ? Colors.green.shade700 
            : Colors.grey.shade800,
        ),
        onPressed: () => controller.toggleLessonStateManual(lesson),
      );
    });
  }
}



/// Fila de botones para avanzar y retroceder en la lección.
class _FastForwardAndRewindButtons extends StatelessWidget {

  final VoidCallback onRewind;
  final VoidCallback onFastForward;
   
  const _FastForwardAndRewindButtons({
    required this.onRewind, 
    required this.onFastForward
  });
  
  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        IconButton(
          icon: const Icon(Icons.replay_10, color: Colors.white),
          tooltip: 'Retroceder 10s',
          onPressed: onRewind,
        ),
        IconButton(
          icon: const Icon(Icons.forward_10, color: Colors.white),
          tooltip: 'Avanzar 10s',
          onPressed: onFastForward,
        ),
      ],
    );
  }
}