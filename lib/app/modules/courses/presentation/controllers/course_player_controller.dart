import 'dart:async';
import 'dart:io';
import 'package:get/get.dart';
import 'package:kaleydo/app/modules/courses/data/models/course_lesson_model.dart';
import 'package:kaleydo/app/modules/courses/data/models/course_model.dart';
import 'package:kaleydo/app/modules/courses/data/services/course_storage_service.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class CoursePlayerController extends GetxController {
  
  late final CourseStorageService storage;
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

  @override
  void onInit() {
    super.onInit();
    storage = Get.find<CourseStorageService>();
    course = Get.arguments['course'] as CourseModel;
    
    _initPlayer();
    _loadInitialStates();
    
    // Autocargar la última lección vista o la primera del curso
    _loadLastOrFirstLesson();
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
    final newPosition = player.state.position - const Duration(seconds: 10);
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

  @override
  void onClose() {
    player.dispose();
    super.onClose();
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
}