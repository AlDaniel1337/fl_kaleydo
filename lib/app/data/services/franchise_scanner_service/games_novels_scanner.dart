import 'dart:io';
import 'package:kaleydo/app/core/utils/natural_sort.dart';
import 'package:kaleydo/app/data/models/franchise_model.dart';
import 'package:path/path.dart' as p;
import 'find_cover.dart';

/// Servicio para escanear juegos o novelas dentro de un directorio.
class GamesNovelsScannerService {

  static const _validExtensions = {'.exe', '.lnk', '.url'};

  /// Escaneo de un único juego o novela en el directorio raíz.
  static Future<List<FranchiseItemModel>> scanForSingleGamesOrNovels(
    Directory dir,
    FranchiseMediaType type,
    String defaultCoverPath,
  ) async {
    final item = await _parseItemFromDirectory(dir, defaultCoverPath);
    return [item];
  }



  /// Escaneo de múltiples juegos o novelas dentro de subcarpetas en paralelo.
  static Future<List<FranchiseItemModel>> scanForMultipleGamesOrNovels(
    Directory dir,
    FranchiseMediaType type,
    String defaultCoverPath,
  ) async {

    final entities = await dir.list().toList();
    final subDirs = entities.whereType<Directory>();

    //: Procesamiento concurrente de subcarpetas
    final items = await Future.wait(
      subDirs.map((subDir) => _parseItemFromDirectory(subDir, defaultCoverPath)),
    );

    //: Ordenamiento natural por título
    items.sort((a, b) => naturalSortCompare(a.title, b.title));
    return items;
  }



  /// Método auxiliar para extraer los metadatos de un directorio.
  static Future<FranchiseItemModel> _parseItemFromDirectory(
    Directory dir,
    String defaultCoverPath,
  ) async {
    
    //: Ejecutar la búsqueda de cover y el listado de archivos simultáneamente
    final results = await Future.wait([
      findCover(dir),
      dir.list().toList(),
    ]);

    final coverPath = results[0] as String?;
    final entities = results[1] as List<FileSystemEntity>;

    String? executablePath;
    String? guidePath;
    String? cgsFolderPath;

    //+: Iterar sobre los archivos y carpetas para identificar ejecutables, guías y carpetas de CGs
    for (final entity in entities) {
      final nameLower = p.basename(entity.path).toLowerCase();

      if (entity is File) {
        final ext = p.extension(entity.path).toLowerCase();
        if (_validExtensions.contains(ext) && executablePath == null) {
          executablePath = entity.path;
        } else if (nameLower == 'guia.md') {
          guidePath = entity.path;
        }
      } else if (entity is Directory && nameLower == 'cgs') {
        cgsFolderPath = entity.path;
      }
    }

    return FranchiseItemModel(
      title: p.basename(dir.path),
      path: dir.path,
      coverPath: coverPath ?? defaultCoverPath,
      executablePath: executablePath,
      guidePath: guidePath,
      cgsFolderPath: cgsFolderPath,
    );
  }
}