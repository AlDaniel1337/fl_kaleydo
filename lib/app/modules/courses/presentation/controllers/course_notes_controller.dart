import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/modules/courses/data/models/course_model.dart';
import 'package:kaleydo/app/modules/courses/data/services/course_notes_service.dart';

class CourseNotesController extends GetxController {
  late final CourseNotesService _notesService;

  final RxInt selectedTabIndex = 0.obs; // 0 = Recursos, 1 = Notas
  final RxBool isPreviewMode = false.obs;
  final TextEditingController notesController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    _notesService = Get.find<CourseNotesService>();
  }

  @override
  void onClose() {
    notesController.dispose();
    super.onClose();
  }


  /// Guarda las notas de una lección específica.
  void saveLessonNotes(String lessonId, String text) {
    _notesService.saveLessonNotes(lessonId, text);
  }


  /// Carga las notas de una lección específica en el controlador de texto.
  void loadNotesForLesson(String lessonId) {
    notesController.text = _notesService.getLessonNotes(lessonId);
  }


  /// Exporta todas las notas del curso a un archivo Markdown en la carpeta del curso.
  Future<void> exportCourseNotes(CourseModel course, Function(String) openFolderCallback) async {
    final buffer = StringBuffer();
    buffer.writeln('# 📘 Curso: ${course.title}');
    buffer.writeln('---');

    bool hasAnyNotes = false;

    for (var section in course.sections) {
      bool sectionHasNotes = false;
      final sectionBuffer = StringBuffer();
      sectionBuffer.writeln('\n## 📂 ${section.title}');

      for (var lesson in section.lessons) {
        String note = _notesService.getLessonNotes(lesson.id).trim();
        if (note.isNotEmpty) {
          sectionHasNotes = true;
          hasAnyNotes = true;
          sectionBuffer.writeln('\n### 📝 ${lesson.title}');
          sectionBuffer.writeln(note);
          sectionBuffer.writeln('\n---');
        }
      }

      if (sectionHasNotes) {
        buffer.write(sectionBuffer.toString());
      }
    }

    if (!hasAnyNotes) {
      Get.snackbar(
        'Aviso',
        'No hay apuntes en este curso para exportar.',
        backgroundColor: Colors.orange,
        colorText: Colors.white,
      );
      return;
    }

    try {
      final cleanTitle = course.title.replaceAll(RegExp(r'[<>:"/\\|?*]'), '_');
      final exportPath = '${course.path}${Platform.pathSeparator}Apuntes_$cleanTitle.md';

      final file = File(exportPath);
      await file.writeAsString(buffer.toString());

      Get.snackbar(
        'Exportación Exitosa',
        'Apuntes guardados en la carpeta del curso.',
        backgroundColor: Colors.green.shade800,
        colorText: Colors.white,
      );

      openFolderCallback(exportPath);
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudieron exportar los apuntes.',
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }
}