import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class CourseNotesService {

  late File _storageFile;
  
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
  Future<CourseNotesService> init() async {
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
        if (!_data.containsKey('lessons')) {
          _data['lessons'] = {};
        }
      } catch (e) {
        print('Error leyendo base de datos de cursos: $e');
        _data = {'lessons': {}};
      }
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


  /// Guarda las notas de una lección específica.
  Future<void> saveLessonNotes(String lessonId, String notes) async {
    Map<String, dynamic> lessons = _data['lessons'];
    Map<String, dynamic> lessonData = lessons[lessonId] ?? {};
    
    lessonData['notes'] = notes;
    lessons[lessonId] = lessonData;
    await _saveData();
  }


  /// Obtiene las notas de una lección específica.
  String getLessonNotes(String lessonId) {
    Map<String, dynamic> lessons = _data['lessons'];
    if (lessons.containsKey(lessonId)) {
      return lessons[lessonId]['notes'] ?? '';
    }
    return '';
  }

}