import 'dart:io';
import 'package:kaleydo/app/core/utils/natural_sort.dart';
import 'package:kaleydo/app/data/models/franchise_model.dart';
import 'package:path/path.dart' as p;



/// Servicio para escanear mangas dentro de un directorio.
class MangaScannerService {
  static const _validImageExtensions = {'.jpg', '.jpeg', '.png', '.webp'};

  /// Método principal de escaneo de mangas.
  static Future<List<FranchiseItemModel>> scanManga(Directory mangaDir) async {
    final entities = await mangaDir.list().toList();
    final categorized = _categorizeEntities(entities);

    final List<FranchiseItemModel> chapters = [];

    //: Caso A: PDFs directos
    chapters.addAll(_processPdfFiles(categorized.pdfs));

    //: Caso B: Imágenes directas en el directorio raíz
    final directChapter = _processDirectImages(mangaDir, categorized.images);
    if (directChapter != null) {
      chapters.add(directChapter);
    }

    //: Caso C: Escaneo concurrente de subcarpetas
    if (categorized.subDirs.isNotEmpty) {
      final subDirChapters = await _processSubDirectories(categorized.subDirs);
      chapters.addAll(subDirChapters);
    }

    // Ordenamiento natural final por título
    chapters.sort((a, b) => naturalSortCompare(a.title, b.title));
    return chapters;
  }



  /// Clasifica los elementos del directorio raíz en PDFs, imágenes directas y subcarpetas.
  static ({List<File> pdfs, List<File> images, List<Directory> subDirs}) _categorizeEntities(
    List<FileSystemEntity> entities,
  ) {
    final List<File> pdfs = [];
    final List<File> images = [];
    final List<Directory> subDirs = [];

    for (final entity in entities) {
      if (entity is File) {
        final ext = p.extension(entity.path).toLowerCase();
        final nameWithoutExt = p.basenameWithoutExtension(entity.path).toLowerCase();

        if (ext == '.pdf') {
          pdfs.add(entity);
        } else if (_isValidPageImage(ext, nameWithoutExt, isDirect: true)) {
          images.add(entity);
        }
      } else if (entity is Directory) {
        subDirs.add(entity);
      }
    }

    return (pdfs: pdfs, images: images, subDirs: subDirs);
  }



  /// Transforma los archivos PDF encontrados en capítulos individuales.
  static List<FranchiseItemModel> _processPdfFiles(List<File> pdfs) {
    return pdfs
      .map((pdf) => FranchiseItemModel(
            title: p.basenameWithoutExtension(pdf.path),
            path: pdf.path,
            pagePaths: [pdf.path],
          ))
      .toList();
  }



  /// Convierte un grupo de imágenes sueltas en la raíz en un único capítulo.
  static FranchiseItemModel? _processDirectImages(Directory mangaDir, List<File> images) {
    if (images.isEmpty) return null;

    images.sort((a, b) => naturalSortCompare(a.path, b.path));

    return FranchiseItemModel(
      title: p.basename(mangaDir.path),
      path: mangaDir.path,
      pagePaths: images.map((e) => e.path).toList(),
    );
  }



  /// Procesa una lista de subcarpetas en paralelo.
  static Future<List<FranchiseItemModel>> _processSubDirectories(
    List<Directory> subDirs,
  ) async {
    final results = await Future.wait(
      subDirs.map(_parseChapterFromDirectory),
    );
    return results.whereType<FranchiseItemModel>().toList();
  }



  /// Extrae las páginas de una subcarpeta específica y retorna su modelo de capítulo.
  static Future<FranchiseItemModel?> _parseChapterFromDirectory(Directory subDir) async {
    final subEntities = await subDir.list().toList();
    final pages = <String>[];

    for (final entity in subEntities) {
      if (entity is File) {
        final ext = p.extension(entity.path).toLowerCase();
        final nameWithoutExt = p.basenameWithoutExtension(entity.path).toLowerCase();

        if (_isValidPageImage(ext, nameWithoutExt, isDirect: false)) {
          pages.add(entity.path);
        }
      }
    }

    if (pages.isEmpty) return null;

    pages.sort(naturalSortCompare);
    return FranchiseItemModel(
      title: p.basename(subDir.path),
      path: subDir.path,
      pagePaths: pages,
    );
  }



  /// Valida si una extensión y nombre de archivo forman una página legible.
  static bool _isValidPageImage(String ext, String nameWithoutExt, {required bool isDirect}) {
    if (!_validImageExtensions.contains(ext)) return false;
    return isDirect ? nameWithoutExt != 'cover' : !nameWithoutExt.contains('cover');
  }
}