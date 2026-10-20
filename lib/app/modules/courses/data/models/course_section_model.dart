import 'package:kaleydo/app/modules/courses/data/models/course_lesson_model.dart';

/// Representación de una sección dentro de un curso.
class CourseSectionModel {
  final String title;
  final String path;
  final List<CourseLessonModel> lessons;

  CourseSectionModel({
    required this.title,
    required this.path,
    required this.lessons,
  });
}