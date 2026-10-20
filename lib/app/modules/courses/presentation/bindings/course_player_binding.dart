import 'package:get/get.dart';
import 'package:kaleydo/app/modules/courses/presentation/controllers/course_player_controller.dart';

/// Clase que define las dependencias para el módulo Courses.
class CoursePlayerBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<CoursePlayerController>(() => CoursePlayerController());
  }
}