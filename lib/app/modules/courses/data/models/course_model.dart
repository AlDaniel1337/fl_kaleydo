import 'course_section_model.dart';

/// Estado de una lección dentro de un curso.
enum LessonState { notViewed, inProgress, viewed }



/// Representación de un curso.
class CourseModel {
  final String id;
  final String title;
  final String path;
  final String coverPath;
  final List<CourseSectionModel> sections;

  CourseModel({
    required this.id,
    required this.title,
    required this.path,
    required this.coverPath,
    required this.sections,
  });

  /// Calcula el total de lecciones en el curso
  int get totalLessons => sections.fold(0, (sum, section) => sum + section.lessons.length);
}