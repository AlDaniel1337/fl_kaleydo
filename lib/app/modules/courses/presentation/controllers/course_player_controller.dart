import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/modules/courses/data/models/course_lesson_model.dart';
import 'package:kaleydo/app/modules/courses/data/models/course_model.dart';
import 'package:kaleydo/app/modules/courses/data/services/course_storage_service.dart';

import 'course_notes_controller.dart';
import 'course_video_controller.dart';

class CoursePlayerController extends GetxController {
  late final CourseStorageService storage;
  late final CourseModel course;

  // Sub-controladores delegados
  late final CourseVideoController video;
  late final CourseNotesController notes;

  // Estado global de lecciones del curso
  final Rx<CourseLessonModel?> currentLesson = Rx<CourseLessonModel?>(null);
  final RxMap<String, LessonState> lessonStates = <String, LessonState>{}.obs;

  @override
  void onInit() {
    super.onInit();
    storage = Get.find<CourseStorageService>();
    course = Get.arguments['course'] as CourseModel;

    // Inicializar sub-controladores vinculados al lifecycle
    video = Get.put(CourseVideoController());
    notes = Get.put(CourseNotesController());

    _setupPlayerListeners();
    _loadInitialStates();
    _loadLastOrFirstLesson();
  }


  @override
  void onClose() {
    Get.delete<CourseVideoController>();
    Get.delete<CourseNotesController>();
    super.onClose();
  }


  /// Configura los listeners del reproductor de video para actualizar el progreso y manejar la finalización del video.
  void _setupPlayerListeners() {
    video.player.stream.position.listen((position) {
      final duration = video.player.state.duration;
      final lesson = currentLesson.value;

      if (lesson != null && duration.inSeconds > 0) {
        storage
            .updateLessonProgress(
          lessonId: lesson.id,
          courseId: course.id,
          positionSeconds: position.inSeconds.toDouble(),
          durationSeconds: duration.inSeconds.toDouble(),
        )
            .then((_) {
          lessonStates[lesson.id] = storage.getLessonState(lesson.id);
        });
      }
    });

    video.player.stream.completed.listen((completed) {
      if (completed) {
        video.player.pause();
      }
    });
  }


  /// Carga los estados iniciales de todas las lecciones del curso desde el almacenamiento.
  void _loadInitialStates() {
    for (var section in course.sections) {
      for (var lesson in section.lessons) {
        lessonStates[lesson.id] = storage.getLessonState(lesson.id);
      }
    }
  }



  /// Carga la última lección vista o la primera lección del curso si no hay historial.
  void _loadLastOrFirstLesson() {
    final lastLessonId = storage.getLastLessonForCourse(course.id);
    CourseLessonModel? lessonToPlay;

    if (lastLessonId != null) {
      for (var section in course.sections) {
        for (var lesson in section.lessons) {
          if (lesson.id == lastLessonId) {
            lessonToPlay = lesson;
            break;
          }
        }
        if (lessonToPlay != null) break;
      }
    }

    if (lessonToPlay == null && course.sections.isNotEmpty && course.sections.first.lessons.isNotEmpty) {
      lessonToPlay = course.sections.first.lessons.first;
    }

    if (lessonToPlay != null) {
      playLesson(lessonToPlay);
    }
  }


  /// Reproduce la lección especificada y carga su progreso y notas.
  void playLesson(CourseLessonModel lesson) async {
    currentLesson.value = lesson;
    storage.setLastLessonForCourse(course.id, lesson.id);

    // Cargar notas de la lección seleccionada
    notes.loadNotesForLesson(lesson.id);

    final savedPosition = storage.getLessonSavedPosition(lesson.id);
    await video.loadVideo(lesson.videoPath, savedPosition);
  }


  /// Alterna manualmente el estado de visualización de una lección.
  void toggleLessonStateManual(CourseLessonModel lesson) {
    final currentState = lessonStates[lesson.id] ?? LessonState.notViewed;
    final newState = currentState == LessonState.viewed ? LessonState.notViewed : LessonState.viewed;

    storage.toggleLessonStateManual(lesson.id, newState).then((_) {
      lessonStates[lesson.id] = newState;
    });
  }


  /// Guarda las notas actuales de la lección en curso.
  void saveCurrentNotes(String text) {
    final lesson = currentLesson.value;
    if (lesson != null) {
      notes.saveLessonNotes(lesson.id, text);
    }
  }


  /// Exporta todas las notas del curso a un archivo Markdown.
  Future<void> exportCourseNotes() async {
    await notes.exportCourseNotes(course, openResourceFolder);
  }


  /// Abre la carpeta de recursos del curso en el explorador de archivos del sistema.
  void openResourceFolder(String path) async {
    try {
      final directory = File(path).parent.path;
      if (Platform.isWindows) {
        await Process.run('explorer.exe', [directory]);
      }
    } catch (e) {
      Get.snackbar('Error', 'No se pudo abrir la ubicación.');
    }
  }


  /// Limpia la caché de posiciones de video del curso y restablece el reproductor.
  void clearCache() {
    storage.clearCoursePositionCache(course.id);
    video.player.seek(Duration.zero);

    Get.snackbar(
      'Caché Limpio',
      'Se han restablecido las posiciones de los videos de este curso.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: Colors.grey.shade900,
      colorText: Colors.white,
    );
  }
}