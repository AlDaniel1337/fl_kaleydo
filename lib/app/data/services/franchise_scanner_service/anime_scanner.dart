import 'dart:io';
import 'package:kaleydo/app/core/utils/natural_sort.dart';
import 'package:kaleydo/app/data/models/franchise_model.dart';
import 'package:path/path.dart' as p;



typedef FranchiseItemModelList = List<FranchiseItemModel>;



/// Servicio para escanear archivos de anime dentro de un directorio.
class AnimeScannerService {

  static const _videoExtensions = {'.mp4', '.mkv', '.avi'};

  /// Método principal de escaneo de episodios de anime.
  static Future<FranchiseItemModelList> scanAnime(Directory animeDir) async {
    final entities = await animeDir.list().toList();
    final categorized = _categorizeEntities(entities);

    final FranchiseItemModelList episodes = [];

    //: Caso A: Episodios directos en la raíz
    episodes.addAll(_processDirectVideos(categorized.videos));

    //: Caso B: Escaneo concurrente de carpetas de temporadas
    if (categorized.seasonDirs.isNotEmpty) {
      final seasonEpisodes = await _processSeasonDirectories(categorized.seasonDirs);
      episodes.addAll(seasonEpisodes);
    }

    // Ordenamiento natural final por título
    episodes.sort((a, b) => naturalSortCompare(a.title, b.title));
    return episodes;
  }



  /// Clasifica los elementos de la raíz en videos directos y carpetas de temporadas.
  static ({List<File> videos, List<Directory> seasonDirs}) _categorizeEntities(
    List<FileSystemEntity> entities,
  ) {
    final List<File> videos = [];
    final List<Directory> seasonDirs = [];

    for (final entity in entities) {
      if (entity is File) {
        if (_isVideoFile(entity.path)) {
          videos.add(entity);
        }
      } else if (entity is Directory) {
        seasonDirs.add(entity);
      }
    }

    return (videos: videos, seasonDirs: seasonDirs);
  }



  /// Convierte los archivos de video sueltos en modelos de episodios (sin temporada).
  static List<FranchiseItemModel> _processDirectVideos(List<File> videos) {
    return videos
      .map((video) => FranchiseItemModel(
            title: p.basenameWithoutExtension(video.path),
            path: video.path,
            seasonName: null,
          ))
      .toList();
  }



  /// Procesa las carpetas de temporadas de manera concurrente.
  static Future<List<FranchiseItemModel>> _processSeasonDirectories(
    List<Directory> seasonDirs,
  ) async {
    final results = await Future.wait(
      seasonDirs.map(_parseEpisodesFromSeason),
    );
    // Aplana la lista de listas en una sola colección
    return results.expand((episodes) => episodes).toList();
  }



  /// Extrae los episodios válidos dentro de una subcarpeta de temporada.
  static Future<List<FranchiseItemModel>> _parseEpisodesFromSeason(Directory seasonDir) async {
    final seasonName = p.basename(seasonDir.path);
    final files = await seasonDir.list().toList();
    final List<FranchiseItemModel> seasonEpisodes = [];

    for (final file in files.whereType<File>()) {
      if (_isVideoFile(file.path)) {
        seasonEpisodes.add(FranchiseItemModel(
          title: p.basenameWithoutExtension(file.path),
          path: file.path,
          seasonName: seasonName,
        ));
      }
    }

    return seasonEpisodes;
  }



  /// Valida si una ruta de archivo tiene una extensión de video admitida ($O(1)$).
  static bool _isVideoFile(String filePath) {
    final ext = p.extension(filePath).toLowerCase();
    return _videoExtensions.contains(ext);
  }
}