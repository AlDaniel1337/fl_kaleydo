import 'dart:io';
import '../../data/models/models.index.dart';


class CoursesScannerService {

  //: Extensiones permitidas para clasificar archivos
  final List<String> _videoExts = ['.mp4', '.mkv', '.avi', '.webm'];
  final List<String> _imageExts = ['.jpg', '.jpeg', '.png', '.webp'];


  /// Escanea el directorio raíz de cursos y devuelve la lista completa de categorías estructuradas
  Future<List<CourseCategoryModel>> scanCoursesDirectory(String rootPath) async {
    final rootDir = Directory(rootPath);
    if (!await rootDir.exists()) return [];

    List<CourseCategoryModel> categories = [];

    // 1. NIVEL: CATEGORÍAS (Ej. Flutter, Blender)
    final catDirs = rootDir.listSync().whereType<Directory>().toList()
      ..sort((a, b) => _naturalSort(a.path, b.path));

    for (var catDir in catDirs) {
      final catCover = _findCover(catDir);
      List<CourseModel> courses = [];

      // 2. NIVEL: CURSOS (Ej. Curso 1, Curso 2)
      final courseDirs = catDir.listSync().whereType<Directory>().toList()
        ..sort((a, b) => _naturalSort(a.path, b.path));

      for (var courseDir in courseDirs) {
        final courseCover = _findCover(courseDir);
        List<CourseSectionModel> sections = [];

        // 3. NIVEL: SECCIONES (Ej. 01 - Intro, 02 - Conceptos Básicos)
        final sectionDirs = courseDir.listSync().whereType<Directory>().toList()
          ..sort((a, b) => _naturalSort(a.path, b.path));

        for (var sectionDir in sectionDirs) {
          List<CourseLessonModel> lessons = [];
          List<CourseResourceModel> sectionResources = [];

          // 4. NIVEL: ARCHIVOS (Videos y Recursos)
          final files = sectionDir.listSync().whereType<File>().toList()
            ..sort((a, b) => _naturalSort(a.path, b.path));

          for (var file in files) {
            final ext = _getExtension(file.path);
            final fileName = file.uri.pathSegments.last;

            if (_videoExts.contains(ext)) {
              // Es una lección en video
              lessons.add(CourseLessonModel(
                id: file.path, // Usamos la ruta exacta como ID único en la BD
                title: fileName.replaceAll(RegExp(r'\.[^$]*$'), ''), // Quitamos la extensión del nombre
                videoPath: file.path,
                resources: [], // Llenaremos esto enseguida
              ));
            } else if (!_imageExts.contains(ext)) {
              // Cualquier archivo que no sea video ni imagen se considera recurso de apoyo (pdf, zip, txt)
              sectionResources.add(CourseResourceModel(
                name: fileName,
                path: file.path,
              ));
            }
          }

          // Si la sección tiene videos, le adjuntamos los recursos encontrados en esa misma carpeta
          if (lessons.isNotEmpty) {
            for (var i = 0; i < lessons.length; i++) {
              lessons[i] = CourseLessonModel(
                id: lessons[i].id,
                title: lessons[i].title,
                videoPath: lessons[i].videoPath,
                resources: List.from(sectionResources),
              );
            }
            
            sections.add(CourseSectionModel(
              title: sectionDir.uri.pathSegments.lastWhere((e) => e.isNotEmpty),
              path: sectionDir.path,
              lessons: lessons,
            ));
          }
        }

        // Solo agregamos el curso si tiene al menos una sección con videos
        if (sections.isNotEmpty) {
          courses.add(CourseModel(
            id: courseDir.path,
            title: courseDir.uri.pathSegments.lastWhere((e) => e.isNotEmpty),
            path: courseDir.path,
            coverPath: courseCover.isNotEmpty ? courseCover : catCover, // Si no tiene portada, hereda la de categoría
            sections: sections,
          ));
        }
      }

      // Solo agregamos la categoría si tiene al menos un curso válido
      if (courses.isNotEmpty) {
        categories.add(CourseCategoryModel(
          title: catDir.uri.pathSegments.lastWhere((e) => e.isNotEmpty),
          path: catDir.path,
          coverPath: catCover,
          courses: courses,
        ));
      }
    }

    return categories;
  }

  // --- MÉTODOS AUXILIARES ---

  /// Busca un archivo que empiece con "cover" (ej. cover.jpg) dentro de una carpeta
  String _findCover(Directory dir) {
    try {
      final files = dir.listSync().whereType<File>();
      for (var file in files) {
        final name = file.uri.pathSegments.last.toLowerCase();
        if (name.startsWith('cover') && _imageExts.contains(_getExtension(name))) {
          return file.path;
        } else if (_imageExts.contains(_getExtension(name))) {
          return file.path;
        }
      }
    } catch (e) {
      // Ignorar errores si no hay permisos de lectura en alguna carpeta
    }
    return ''; // Devuelve vacío si no encuentra portada
  }

  /// Extrae la extensión de un archivo
  String _getExtension(String path) {
    final lastDot = path.lastIndexOf('.');
    if (lastDot == -1) return '';
    return path.substring(lastDot).toLowerCase();
  }

  /// Ordenamiento natural para que "Seccion 2" vaya antes que "Seccion 10"
  int _naturalSort(String a, String b) {
    final regExp = RegExp(r'(\d+)');
    final matchA = regExp.firstMatch(a);
    final matchB = regExp.firstMatch(b);
    if (matchA != null && matchB != null) {
      int numA = int.parse(matchA.group(0)!);
      int numB = int.parse(matchB.group(0)!);
      return numA.compareTo(numB);
    }
    return a.compareTo(b);
  }
}