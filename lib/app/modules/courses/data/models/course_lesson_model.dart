import 'course_resource_model.dart';

/// Representación de una lección dentro de una sección del curso.
class CourseLessonModel {
  final String id; // Recomendado: usar la ruta relativa o un hash como ID único
  final String title;
  final String videoPath;
  final List<CourseResourceModel> resources;

  CourseLessonModel({
    required this.id,
    required this.title,
    required this.videoPath,
    this.resources = const [],
  });
}