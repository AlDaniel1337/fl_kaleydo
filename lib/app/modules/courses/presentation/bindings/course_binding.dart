import 'package:get/get.dart';
import 'package:kaleydo/app/modules/courses/presentation/controllers/courses_controller.dart';

/// Clase que define las dependencias para el módulo Courses.
class CourseBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CoursesController>(() => CoursesController());
  }
}