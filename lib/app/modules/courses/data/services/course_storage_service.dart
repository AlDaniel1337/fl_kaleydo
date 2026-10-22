import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import '../models/models.index.dart';

class CourseStorageService {

  late File _storageFile;
  int _lastSaveTime = 0;
  
  // Mapa en memoria para acceso rápido. Estructura:
  // {
  //   "last_viewed_course": "curso_id",
  //   "last_viewed_lesson": "leccion_id",
  //   "lessons": {
  //      "leccion_id": { "state": "viewed", "position": 125.5, "duration": 600.0 }
  //   }
  // }
  Map<String, dynamic> _data = {
    'lessons': {},
  };


  /// Inicializa el servicio de almacenamiento de progreso de cursos. 
  /// - Carga los datos desde el archivo de almacenamiento.
  Future<CourseStorageService> init() async {
    final directory = await getApplicationSupportDirectory();
    // Archivo completamente independiente del reader/player actual
    _storageFile = File('${directory.path}/courses_progress.json');
    await _loadData();
    return this;
  }


  /// Carga los datos desde el archivo de almacenamiento en memoria.
  Future<void> _loadData() async {
    if (await _storageFile.exists()) {
      try {
        final String content = await _storageFile.readAsString();
        _data = json.decode(content);
        if (!_data.containsKey('lessons')) _data['lessons'] = {};
        if (!_data.containsKey('courses')) _data['courses'] = {}; 
      } catch (e) {
        print('Error leyendo BD: $e');
        _data = {'lessons': {}, 'courses': {}};
      }
    } else {
      _data = {'lessons': {}, 'courses': {}};
    }
  }


  /// Guarda los datos en el archivo de almacenamiento.
  Future<void> _saveData() async {
    try {
      await _storageFile.writeAsString(json.encode(_data));
    } catch (e) {
      print('Error guardando base de datos de cursos: $e');
    }
  }
  //!+




  //+ GESTIÓN DE PROGRESO DE LECCIONES

  /// Actualiza la posición del video y calcula si debe marcarse como completado
  Future<void> updateLessonProgress({
    required String lessonId,
    required String courseId,
    required double positionSeconds,
    required double durationSeconds,
    bool forceComplete = false,
  }) async {
    Map<String, dynamic> lessons = _data['lessons'];
    Map<String, dynamic> lessonData = lessons[lessonId] ?? {};

    bool isCompleted = forceComplete || (durationSeconds > 0 && (positionSeconds / durationSeconds) >= 0.90);
    
    String currentStateStr = lessonData['state'] ?? LessonState.notViewed.name;
    LessonState currentState = LessonState.values.firstWhere((e) => e.name == currentStateStr);

    LessonState newState = isCompleted 
        ? LessonState.viewed 
        : (positionSeconds > 0 ? LessonState.inProgress : LessonState.notViewed);

    if (currentState == LessonState.viewed && !forceComplete) {
      newState = LessonState.viewed;
    }

    // Actualizamos siempre en memoria (RAM)
    lessonData['state'] = newState.name;
    lessonData['position'] = positionSeconds;
    lessonData['duration'] = durationSeconds;
    
    lessons[lessonId] = lessonData;
    _data['courses'][courseId] ??= {}; // Asegurar que exista el objeto del curso
    _data['courses'][courseId]['last_lesson'] = lessonId;

    // Solo escribimos en el disco físico cada 3 segundos o si se fuerza el completado
    final int now = DateTime.now().millisecondsSinceEpoch;
    if (forceComplete || (now - _lastSaveTime > 3000)) {
      _lastSaveTime = now;
      await _saveData();
    }
  }
  

  /// Cambia manualmente el estado de una lección
  Future<void> toggleLessonStateManual(String lessonId, LessonState state) async {
    Map<dynamic, dynamic> lessons = _data['lessons'];
    Map<dynamic, dynamic> lessonData = lessons[lessonId] ?? {};
    
    lessonData['state'] = state.name;
    lessons[lessonId] = lessonData;
    await _saveData();
  }
  //!+




  //+ LECTURA DE DATOS
  /// Obtiene el estado actual de una lección.
  LessonState getLessonState(String lessonId) {
    Map<dynamic, dynamic> lessons = _data['lessons'];
    if (lessons.containsKey(lessonId)) {
      String stateStr = lessons[lessonId]['state'];
      return LessonState.values.firstWhere((e) => e.name == stateStr, orElse: () => LessonState.notViewed);
    }
    return LessonState.notViewed;
  }


  /// Obtiene la posición guardada de una lección en segundos.
  double getLessonSavedPosition(String lessonId) {
    Map<dynamic, dynamic> lessons = _data['lessons'];
    if (lessons.containsKey(lessonId)) {
      return (lessons[lessonId]['position'] ?? 0.0).toDouble();
    }
    return 0.0;
  }


  /// Calcula el porcentaje de avance de un curso (0.0 a 1.0)
  double getCourseProgress(CourseModel course) {
    if (course.totalLessons == 0) return 0.0;
    
    int viewedCount = 0;
    for (var section in course.sections) {
      for (var lesson in section.lessons) {
        if (getLessonState(lesson.id) == LessonState.viewed) {
          viewedCount++;
        }
      }
    }
    return viewedCount / course.totalLessons;
  }


  /// Reinicia todo el progreso de un curso específico
  Future<void> resetCourseProgress(CourseModel course) async {
    Map<dynamic, dynamic> lessons = _data['lessons'];
    for (var section in course.sections) {
      for (var lesson in section.lessons) {
        lessons.remove(lesson.id);
      }
    }
    await _saveData();
  }
  //!+



  //+ GESTIÓN DE HISTORIAL POR CURSO

  /// Establece la última lección vista para un curso específico y 
  /// Actualiza la lista de lecciones recientes.
  void setLastLessonForCourse(String courseId, String lessonId) {
    Map<dynamic, dynamic> courses = _data['courses'];
    if (!courses.containsKey(courseId)) courses[courseId] = {};
    
    courses[courseId]['last_lesson'] = lessonId;

    // Gestionar la lista de los últimos 3 videos
    List<dynamic> recent = courses[courseId]['recent_lessons'] ?? [];
    recent.remove(lessonId); // Si ya estaba, lo quitamos para ponerlo al principio
    recent.insert(0, lessonId); // Lo ponemos de primero

    // Si supera los 3, eliminamos el más antiguo y borramos su posición guardada
    if (recent.length > 3) {
      String removedId = recent.removeLast();
      if (_data['lessons'].containsKey(removedId)) {
        _data['lessons'][removedId]['position'] = 0.0;
      }
    }
    
    courses[courseId]['recent_lessons'] = recent;
    _saveData();
  }


  /// Obtiene la última lección vista para un curso específico.
  String? getLastLessonForCourse(String courseId) {
    Map<dynamic, dynamic> courses = _data['courses'];
    if (courses.containsKey(courseId)) {
      return courses[courseId]['last_lesson'];
    }
    return null;
  }


  /// Limpia la caché de posiciones de las lecciones recientes para un curso específico.
  Future<void> clearCoursePositionCache(String courseId) async {
    Map<dynamic, dynamic> courses = _data['courses'];
    if (courses.containsKey(courseId)) {
      List<dynamic> recent = courses[courseId]['recent_lessons'] ?? [];
      
      // Reiniciar las posiciones de los recientes a 0.0
      for (String id in recent) {
        if (_data['lessons'].containsKey(id)) {
          _data['lessons'][id]['position'] = 0.0;
        }
      }
      
      courses[courseId]['recent_lessons'] = [];
      courses[courseId]['last_lesson'] = null;
      await _saveData();
    }
  }
  //!+
}