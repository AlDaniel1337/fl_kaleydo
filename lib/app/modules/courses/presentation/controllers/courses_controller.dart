// lib/app/modules/courses/controllers/courses_controller.dart

import 'package:get/get.dart';
import 'package:kaleydo/app/modules/courses/data/services/course_storage_service.dart';
import 'package:kaleydo/app/modules/courses/data/services/courses_scanner_service.dart';
import '../../data/models/models.index.dart';
import 'package:kaleydo/app/modules/courses/presentation/views/course_player_view/course_player_view.dart';

class CoursesController extends GetxController {

  final CoursesScannerService scanner = CoursesScannerService();
  //TODO Ajustar la ruta base según la ubicación de los cursos en tu sistema
  final String coursesRootPath = 'H:\\_kaleydo\\cursos';

  final RxBool isLoading = true.obs;
  final RxList<CourseCategoryModel> categories = <CourseCategoryModel>[].obs;
  final Rx<CourseCategoryModel?> selectedCategory = Rx<CourseCategoryModel?>(null);

  late final CourseStorageService storage;

  @override
  void onInit() {
    super.onInit();
    storage = Get.find<CourseStorageService>();
    _loadCoursesData();
  }


  /// Carga los datos de los cursos desde el directorio especificado y actualiza la lista de categorías.
  Future<void> _loadCoursesData() async {
    isLoading.value = true;
    try {
      final scannedCategories = await scanner.scanCoursesDirectory(coursesRootPath);
      categories.assignAll(scannedCategories);
    } catch (e) {
      Get.snackbar('Error', 'No se pudieron cargar los cursos: $e');
    } finally {
      isLoading.value = false;
    }
  }



  //+ NAVEGACIÓN DE LA INTERFAZ

  /// Selecciona una categoría específica para mostrar sus cursos.
  void selectCategory(CourseCategoryModel category) {
    selectedCategory.value = category;
  }


  /// Vuelve a la vista de categorías desde la vista de cursos.
  void backToCategories() {
    selectedCategory.value = null;
  }


  /// Abre la vista del reproductor para un curso específico.
  void openCourse(CourseModel course) {
    // Aquí navegaremos a la vista del reproductor (Udemy Style) que crearemos después
    Get.toNamed(CoursePlayerView.route, arguments: {'course': course});
  }
  //!+ 



  //+ DATOS DE PROGRESO
  /// Obtiene el progreso de un curso específico como un valor entre 0.0 y 1.0.
  double getCourseProgress(CourseModel course) {
    return storage.getCourseProgress(course);
  }
  //!+
}