import 'dart:io';
import 'dart:math';
import 'package:kaleydo/app/core/utils/natural_sort.dart';
import 'package:kaleydo/app/modules/franchise_detail/domain/entities/game_extra_info_result.dart';

typedef InfoFileResult = Future<({String info, List<String> tags})>;
typedef ImageGalleryResult = Future<({List<String> images, List<String> randomImages, bool hasCGsGallery})>;

class GameExtraInfoService {

  /// Obtener la información extra del juego, incluyendo detalles, etiquetas e imágenes.
  Future<GameExtraInfoResult> loadExtraData(String itemBasePath) async {

    // Revisar si el directorio "extra" existe antes de intentar cargar los datos.
    final extraDir = Directory('$itemBasePath/extra');
    if (!await extraDir.exists()) {
      return GameExtraInfoResult.empty();
    }

    final infoData = await _parseInfoFile(extraDir.path);
    final imageData = await _parseImageGallery(extraDir.path);

    return GameExtraInfoResult(
      info: infoData.info,
      tags: infoData.tags,
      images: imageData.images,
      randomImages: imageData.randomImages,
      hasCGsGallery: imageData.hasCGsGallery,
    );
  }



  /// Analiza el archivo de información del juego y extrae los detalles y etiquetas.
  InfoFileResult _parseInfoFile(String extraPath) async {
    final infoFile = File('$extraPath/info.txt');
    if (!await infoFile.exists()) return (info: '', tags: <String>[]);

    final rawInfo = await infoFile.readAsString();
    final sections = rawInfo.split('---');

    String info = '';
    List<String> tags = [];

    if (sections.isNotEmpty) {
      info = sections[0].trim();
      if (sections.length > 1) {
        tags = sections[1]
            .split(',')
            .map((tag) => tag.trim())
            .where((tag) => tag.isNotEmpty)
            .toList();
      }
    }
    return (info: info, tags: tags);
  }


  /// Analiza la galería de imágenes del juego y devuelve las imágenes ordenadas, imágenes aleatorias y si tiene galería de CGs.
  ImageGalleryResult _parseImageGallery(String extraPath) async {
    final cgDir = Directory('$extraPath/CGs');
    final imagesDir = Directory('$extraPath/Images');

    Directory? targetDir;
    bool hasCGs = false;

    if (await cgDir.exists()) {
      targetDir = cgDir;
      hasCGs = true;
    } else if (await imagesDir.exists()) {
      targetDir = imagesDir;
    }

    if (targetDir == null) {
      return (images: <String>[], randomImages: <String>[], hasCGsGallery: false);
    }

    final paths = <String>[];
    await for (final entity in targetDir.list()) {
      if (entity is File) {
        paths.add(entity.path);
      }
    }

    final sortedImages = naturalSort<String>(paths);
    final randomImages = _pickRandomImages(sortedImages);

    return (images: sortedImages, randomImages: randomImages, hasCGsGallery: hasCGs);
  }


  /// Selecciona un subconjunto aleatorio de imágenes de la lista proporcionada, con un máximo de 4 imágenes.
  List<String> _pickRandomImages(List<String> images) {
    if (images.isEmpty) return [];

    final totalImages = images.length;
    final count = min(4, totalImages);

    if (count == totalImages) return List.from(images);

    final random = Random();
    final selectedIndices = <int>{};

    while (selectedIndices.length < count) {
      selectedIndices.add(random.nextInt(totalImages));
    }

    return selectedIndices.map((index) => images[index]).toList();
  }
}