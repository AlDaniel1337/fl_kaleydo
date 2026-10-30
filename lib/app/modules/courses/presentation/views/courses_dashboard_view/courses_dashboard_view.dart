import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:kaleydo/app/modules/courses/data/models/course_category_model.dart';
import 'package:kaleydo/app/modules/courses/presentation/views/courses_dashboard_view/widgets/course_card.dart';
import 'package:kaleydo/app/modules/courses/presentation/views/courses_dashboard_view/widgets/courses_grid.dart';
import 'package:kaleydo/app/modules/courses/presentation/views/courses_dashboard_view/widgets/show_folder_structure.dart';
import '../../controllers/courses_controller.dart';

class CoursesDashboardView extends GetView<CoursesController> {

  static const int coursesColumns = 7;
  static const String route = "/courses";

  const CoursesDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,

      appBar: AppBar(
        backgroundColor: AppColors.background,
        title: Obx(() => Text(
          controller.selectedCategory.value == null 
              ? 'Mis Categorías de Estudio' 
              : 'Cursos de ${controller.selectedCategory.value!.title}',
          style: const TextStyle(color: AppColors.textPrimary),
        )),

        leading: Obx(() {
          if (controller.selectedCategory.value != null) {
            return IconButton(
              icon: const Icon(Icons.arrow_back, color: AppColors.primaryAccent),
              onPressed: controller.backToCategories,
            );
          }
          // Si estamos en la raíz, el botón de retroceder cierra el módulo
          return IconButton(
            icon: const Icon(Icons.close, color: AppColors.textSecondary),
            onPressed: () => Get.back(),
          );
        }),

        actions: [
          IconButton(
            icon: const Icon(Icons.help_outline, color: AppColors.textSecondary),
            tooltip: 'Estructura de carpetas',
            onPressed: () => showFolderStructureDialog(context),
          ),
        ],
      ),

      body: Obx(() {
        
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryAccent),
          );
        }

        if (controller.categories.isEmpty) {
          return const Center(
            child: Text(
              'No se encontraron cursos en la ruta especificada.',
              style: TextStyle(color: AppColors.textSecondary),
            ),
          );
        }

        // Alternar vista basado en si hay una categoría seleccionada
        if (controller.selectedCategory.value == null) {
          return _buildCategoriesGrid();
        } else {
          return _buildCoursesGrid(controller.selectedCategory.value!);
        }
      }),
    );
  }


  /// Construye la cuadrícula de categorías de cursos.
  Widget _buildCategoriesGrid() {
    return CoursesGrid(
      itemBuilder: (context, index) {
        final category = controller.categories[index];
        return CourseCard(
          title: category.title,
          subtitle: '${category.courses.length} Cursos',
          coverPath: category.coverPath,
          onTap: () => controller.selectCategory(category),
        );
      },
      itemCount: controller.categories.length,
      crossAxisCount: coursesColumns,
    );
  }


  /// Construye la cuadrícula de cursos dentro de una categoría.
  Widget _buildCoursesGrid(CourseCategoryModel category) {
    return CoursesGrid(
      itemBuilder: (context, index) {
        final course = category.courses[index];
        final progress = controller.getCourseProgress(course);

        return CourseCard(
          title: course.title,
          subtitle: '${course.totalLessons} Lecciones',
          coverPath: course.coverPath,
          progress: progress, // Le pasamos el progreso para la barra
          onTap: () => controller.openCourse(course),
        );
      },
      itemCount: category.courses.length,
      crossAxisCount: coursesColumns,
    );
  }

}
