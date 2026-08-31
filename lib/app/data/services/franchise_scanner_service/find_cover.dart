import 'dart:io';
import 'package:path/path.dart' as p;
import 'package:get/get.dart';


/// Busca un archivo de portada (cover) en el directorio especificado.
Future<String?> findCover(Directory dir) async {
  final entities = await dir.list().toList();
  final cover = entities.firstWhereOrNull( (e) => e is File && 
    p.basenameWithoutExtension(e.path).toLowerCase() == 'cover',
  );
  return cover?.path;
}