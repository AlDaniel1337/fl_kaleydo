import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kaleydo/app/modules/courses/data/services/course_notes_service.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/modules/courses/data/models/course_lesson_model.dart';
import 'package:kaleydo/app/modules/courses/data/models/course_model.dart';
import 'package:kaleydo/app/modules/courses/data/services/course_storage_service.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class CoursePlayerController extends GetxController {
  
  late final CourseStorageService storage;
  late final CourseNotesService notesService;
  late final CourseModel course;

  // media_kit
  late final Player player;
  late final VideoController videoController;

  // Estados Reactivos
  final Rx<CourseLessonModel?> currentLesson = Rx<CourseLessonModel?>(null);
  final RxDouble playbackSpeed = 1.0.obs;
  final RxMap<String, LessonState> lessonStates = <String, LessonState>{}.obs;

  // Variables para el volumen
  final RxDouble currentVolume = 100.0.obs;
  final RxBool showVolumeIndicator = false.obs;
  Timer? _volumeTimer;

  // Controles de notas y recursos del curso
  final RxInt selectedTabIndex = 0.obs; // 0 = Recursos, 1 = Notas
  final RxBool isPreviewMode = false.obs; // Modo edición vs vista previa
  final TextEditingController notesController = TextEditingController();

  @override
  void onInit() {
    super.onInit();
    storage = Get.find<CourseStorageService>();
    course = Get.arguments['course'] as CourseModel;

    notesService = Get.find<CourseNotesService>();

    _initPlayer();
    _loadInitialStates();
    
    // Autocargar la última lección vista o la primera del curso
    _loadLastOrFirstLesson();
  }


  @override
  void onClose() {
    player.dispose();
    notesController.dispose();
    super.onClose();
  }


  void _initPlayer() {
    player = Player();
    videoController = VideoController(player);

    player.setVolume(100.0);
    currentVolume.value = 100.0;

    // Escuchar la posición para guardar el progreso y marcar como visto al 90%
    player.stream.position.listen((position) {
      final duration = player.state.duration;
      final lesson = currentLesson.value;
      
      if (lesson != null && duration.inSeconds > 0) {
        storage.updateLessonProgress(
          lessonId: lesson.id,
          courseId: course.id,
          positionSeconds: position.inSeconds.toDouble(),
          durationSeconds: duration.inSeconds.toDouble(),
        ).then((_) {
          // Actualizamos el estado local para que la UI cambie el ícono
          lessonStates[lesson.id] = storage.getLessonState(lesson.id);
        });
      }
    });

    // Detener al finalizar
    player.stream.completed.listen((completed) {
      if (completed) {
        player.pause();
      }
    });
  }

  void _loadInitialStates() {
    for (var section in course.sections) {
      for (var lesson in section.lessons) {
        lessonStates[lesson.id] = storage.getLessonState(lesson.id);
      }
    }
  }

  void _loadLastOrFirstLesson() {
    // Si la BD guardara la última lección del curso, la buscaríamos aquí.
    // Por ahora, cargamos la primera por defecto.
    if (course.sections.isNotEmpty && course.sections.first.lessons.isNotEmpty) {
      playLesson(course.sections.first.lessons.first);
    }
  }

  //+ CONTROLES DEL REPRODUCTOR DE ESTUDIO
  void playLesson(CourseLessonModel lesson) async {
    currentLesson.value = lesson;
    
    // Cargamos el video en el reproductor
    await player.open(Media(lesson.videoPath), play: true);
    
    // Restauramos la posición guardada (si estaba en progreso)
    final savedPosition = storage.getLessonSavedPosition(lesson.id);
    if (savedPosition > 0) {
      await player.seek(Duration(seconds: savedPosition.toInt()));
    }

    // Cargar notas al cambiar de lección
    notesController.text = notesService.getLessonNotes(lesson.id);
  }

  void setSpeed(double speed) {
    playbackSpeed.value = speed;
    player.setRate(speed);
  }

  void skipForward() {
    final newPosition = player.state.position + const Duration(seconds: 10);
    player.seek(newPosition);
  }

  void skipBackward() {
    Duration newPosition = player.state.position - const Duration(seconds: 10);
    // Comprobamos que la nueva posición no sea negativa
    if (newPosition < Duration.zero) {
      newPosition = Duration.zero;
    }
    player.seek(newPosition);
  }

  //+ GESTIÓN DE ESTADOS Y RECURSOS
  void toggleLessonStateManual(CourseLessonModel lesson) {
    final currentState = lessonStates[lesson.id] ?? LessonState.notViewed;
    
    // Si estaba visto, lo pasamos a no visto, y viceversa
    final newState = currentState == LessonState.viewed 
        ? LessonState.notViewed 
        : LessonState.viewed;

    storage.toggleLessonStateManual(lesson.id, newState).then((_) {
      lessonStates[lesson.id] = newState;
    });
  }

  void openResourceFolder(String path) async {
    try {
      final directory = File(path).parent.path;
      if (Platform.isWindows) {
        await Process.run('explorer.exe', [directory]);
      }
      // Agrega macOS o Linux si lo llegas a compilar para ellos
    } catch (e) {
      Get.snackbar('Error', 'No se pudo abrir la ubicación.');
    }
  }

  void togglePlayPause() {
    player.playOrPause();
  }

  void changeVolume(double delta) {
    // Calculamos y limitamos el volumen entre 0 y 300
    double newVolume = currentVolume.value + delta;
    newVolume = newVolume.clamp(0.0, 300.0);
    
    currentVolume.value = newVolume;
    player.setVolume(newVolume);
    
    // Mostramos el indicador visual en pantalla
    showVolumeIndicator.value = true;
    _volumeTimer?.cancel();
    _volumeTimer = Timer(const Duration(seconds: 2), () {
      showVolumeIndicator.value = false;
    });
  }

  //+ MÉTODOS DE NOTAS
  void saveCurrentNotes(String text) {
    final lesson = currentLesson.value;
    if (lesson != null) {
      notesService.saveLessonNotes(lesson.id, text);
    }
  }

  Future<void> exportCourseNotes() async {
    StringBuffer buffer = StringBuffer();
    
    // Formato personalizado de cabecera
    buffer.writeln('# 📘 Curso: ${course.title}');
    buffer.writeln('---');
    
    bool hasAnyNotes = false;

    for (var section in course.sections) {
      bool sectionHasNotes = false;
      StringBuffer sectionBuffer = StringBuffer();
      sectionBuffer.writeln('\n## 📂 ${section.title}');

      for (var lesson in section.lessons) {
        String note = notesService.getLessonNotes(lesson.id).trim();
        if (note.isNotEmpty) {
          sectionHasNotes = true;
          hasAnyNotes = true;
          sectionBuffer.writeln('\n### 📝 ${lesson.title}');
          sectionBuffer.writeln(note);
          sectionBuffer.writeln('\n---'); // Separador de lección
        }
      }

      // Solo agregamos la sección si tiene al menos una lección con apuntes
      if (sectionHasNotes) {
        buffer.write(sectionBuffer.toString());
      }
    }

    if (!hasAnyNotes) {
      Get.snackbar('Aviso', 'No hay apuntes en este curso para exportar.', 
          backgroundColor: Colors.orange, colorText: Colors.white);
      return;
    }

    try {
      // Guardamos el archivo .md directamente en la carpeta raíz del curso
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
      
      // Abre la carpeta automáticamente para que veas el archivo
      openResourceFolder(exportPath);
      
    } catch (e) {
      Get.snackbar('Error', 'No se pudieron exportar los apuntes.', 
          backgroundColor: Colors.redAccent, colorText: Colors.white);
    }
  }
}