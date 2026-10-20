import 'package:flutter/material.dart';
import 'package:kaleydo/app/modules/courses/presentation/controllers/course_player_controller.dart';
import 'widgets.index.dart';

class RightPanelForLessonsAndResources extends StatelessWidget {
  const RightPanelForLessonsAndResources({
    super.key,
    required this.controller,
  });

  final CoursePlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          'Índice de Lecciones',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        Divider(color: Colors.grey.shade800),
        SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.5,
          child: CourseLessonsIndex(controller: controller)
        ),
        SizedBox(height: 6),
    
        Text(
          'Recursos de la sección',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        Divider(color: Colors.grey.shade800),
        SizedBox(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.3,
          child: CourseResourcesTab(controller: controller),
        ),
    
      ],
    );
  }
}