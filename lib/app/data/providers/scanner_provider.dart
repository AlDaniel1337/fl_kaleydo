import 'dart:io';
import 'package:kaleydo/app/config/theme/app_media_type.dart';
import 'package:kaleydo/app/core/utils/natural_sort.dart';
import 'package:path/path.dart' as p;
import 'package:kaleydo/app/data/models/config_model.dart';
import 'package:kaleydo/app/data/models/media_item_model.dart';

/// Explora el sistema de archivos buscando las carpetas con prefijo _
class ScannerProvider {

  ///+ Escanea la carpeta raíz y devuelve una lista de elementos multimedia.
  Future<List<MediaItemModel>> scanRootFolder(ConfigModel config) async {
    
    final List<MediaItemModel> items = [];
    
    //: Obtener el directorio raíz a partir de la ruta de configuración
    final rootDir = Directory(config.rootFolderPath); 

    if (!await rootDir.exists()) return items;

    //: Lista todos directorios dentro del directorio raíz
    final List<FileSystemEntity> entities = await rootDir.list().toList();
    
    //+ Iterar sobre cada directorio dentro del directorio raíz
    for (var entity in entities) {
      if (entity is Directory) {

        //: Obtener nombre de la carpeta
        final folderName = p.basename(entity.path);

        //+ Revisar si la o las carpetas tienen el prefijo "_"
        if (folderName.startsWith('_')) {
          final mediaType = getAppMediaType(folderName);
          final subItems = await _scanUniMediaCategory(entity, mediaType, config);
          items.addAll(subItems);
        } else {
          // Categoría Variados (Franquicias / Multi-medio)
          final coverPath = await _findCoverImage(entity, config.imageExtensions);
          items.add(MediaItemModel(
            id: entity.path,
            title: folderName,
            path: entity.path,
            type: AppMediaType.variado,
            coverPath: coverPath,
          ));
        }
        //!+

      }
    }
    //!+

    //: Ordenamiento natural por título
    items.sort((a, b) => naturalSortCompare(a.title, b.title));
    return items;
  }
  //!+



  ///+ Escanea una categoría de medio uni-medio y devuelve una lista de elementos multimedia.
  Future<List<MediaItemModel>> _scanUniMediaCategory(
    Directory categoryDir,
    AppMediaType type,
    ConfigModel config,
  ) async {
    final List<MediaItemModel> items = [];
    final entities = await categoryDir.list().toList();

    for (var entity in entities) {
      if (entity is Directory) {
        // Obtener el nombre de la carpeta como título del elemento multimedia.
        final title = p.basename(entity.path); 
        
        // Buscar la imagen de portada dentro del directorio.
        final coverPath = await _findCoverImage(entity, config.imageExtensions); 

        items.add(MediaItemModel(
          id: entity.path,
          title: title,
          path: entity.path,
          type: type,
          coverPath: coverPath,
        ));
      }
    }

    return items;
  }
  //!+



  ///+ Busca la imagen de portada dentro de un directorio dado.
  Future<String?> _findCoverImage(Directory dir, List<String> extensions) async {
    try {

      // Listar todos los archivos y directorios dentro del directorio dado.
      final List<FileSystemEntity> entities = await dir.list().toList();

      // Iterar sobre todos los archivos y directorios para encontrar la imagen de portada.
      for (var entity in entities) {
        if (entity is File) {
          final fileName = p.basenameWithoutExtension(entity.path).toLowerCase();
          final ext = p.extension(entity.path).toLowerCase();

          if (fileName == 'cover' && extensions.contains(ext)) {
            return entity.path;
          }
        }
      }
    } catch (_) {}
    return null;
  }
  //!+
}