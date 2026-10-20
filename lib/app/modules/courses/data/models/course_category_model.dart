import 'course_model.dart';

/// Representación de una categoría de cursos.
class CourseCategoryModel {
  final String title;
  final String path;
  final String coverPath;
  final List<CourseModel> courses;

  CourseCategoryModel({
    required this.title,
    required this.path,
    required this.coverPath,
    required this.courses,
  });
}