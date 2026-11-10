// data/datasources/folder_local_data_source.dart
import 'dart:io';

class FolderLocalDataSource {

  // Crea un directorio en la ruta especificada si no existe.
  Future<void> createDirectory(String path) async {
    final dir = Directory(path);
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
  }

  // Verifica si un directorio existe en la ruta especificada.
  Future<bool> directoryExists(String path) async {
    return await Directory(path).exists();
  }

  // Crea un archivo en la ruta especificada si no existe.
  Future<void> createFile(String path) async {
    final file = File(path);
    if (!await file.exists()) {
      await file.create(recursive: true);
    }
  }

  // Verifica si un archivo existe en la ruta especificada.
  Future<bool> fileExists(String path) async {
    return await File(path).exists();
  }
}