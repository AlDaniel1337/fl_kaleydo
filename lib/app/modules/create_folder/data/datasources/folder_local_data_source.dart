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
}