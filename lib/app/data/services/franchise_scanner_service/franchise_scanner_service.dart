import 'dart:io';
import 'package:get/get.dart';
import 'package:kaleydo/app/core/constants/valid_folder_names_constants.dart';
import 'package:kaleydo/app/core/utils/natural_sort.dart';
import 'package:kaleydo/app/data/models/franchise_model.dart';
import 'package:kaleydo/app/data/services/franchise_scanner_service/anime_scanner.dart';
import 'package:kaleydo/app/data/services/franchise_scanner_service/books_scanner.dart';
import 'package:kaleydo/app/data/services/franchise_scanner_service/games_novels_scanner.dart';
import 'package:kaleydo/app/data/services/franchise_scanner_service/manga_scanner.dart';
import 'package:path/path.dart' as p;



typedef FranchiseScanResult = Map<FranchiseMediaType, List<FranchiseItemModel>>;



class FranchiseScannerService {

  /// Carga los detalles de la franquicia desde el sistema de archivos.
  Future<FranchiseScanResult> scanFranchiseDirectory( Directory franchiseDir, String defaultCoverPath ) async {

    final FranchiseScanResult result = {};

    //: Listar todas las entidades dentro del directorio de la franquicia
    final entities = await franchiseDir.list().toList();

    //+ Escanear subcarpetas internas (Anime, Manga, Juegos, Novelas)
    for (var entity in entities) {
      if (entity is Directory) {
        //: Obtener el nombre de la carpeta actual en minúsculas y sin espacios al inicio o final
        final folderName = p.basename(entity.path).toLowerCase().trim();

        //+ Determinar el tipo de medio según el nombre de la carpeta y escanear en consecuencia
        //: Juegos
        if (ValidFolderNamesConstants.validGamesFolders.contains(folderName)) {
          result[FranchiseMediaType.juegos] = await scanGamesOrNovels(
            entity, 
            FranchiseMediaType.juegos, 
            defaultCoverPath
          );
        } 
        
        //: Novelas visuales
        else if (ValidFolderNamesConstants.validVisualNovelsFolders.contains(folderName)) {
          result[FranchiseMediaType.novelas] = await scanGamesOrNovels(
            entity, 
            FranchiseMediaType.novelas, 
            defaultCoverPath
          );
        } 
        
        //: Libros
        else if (ValidFolderNamesConstants.validBooksFolders.contains(folderName)) {
          result[FranchiseMediaType.libros] = await scanBooks(entity);
        } 
        
        //: Manga
        else if (ValidFolderNamesConstants.validMangaFolders.contains(folderName)) {
          result[FranchiseMediaType.manga] = await scanManga(entity);
        } 
        
        //: Anime
        else if (ValidFolderNamesConstants.validAnimeFolders.contains(folderName)) {
          result[FranchiseMediaType.anime] = await scanAnime(entity);
        }
        //!+

      } else if (entity is File && p.basename(entity.path).toLowerCase() == 'resumen.md') {
        result[FranchiseMediaType.resumen] = [];
      }
    }
    //!+

    return result;
  }


  //+ = JUEGOS / NOVELAS =
  /// Escaneo generalde Juegos o Novelas (Múltiples subcarpetas o título único)
  Future<List<FranchiseItemModel>> scanGamesOrNovels(Directory dir, FranchiseMediaType type, String defaultCoverPath) async {
    final List<FranchiseItemModel> items = [];

    //: Listar todas las entidades dentro de la carpeta de juegos o novelas
    final entities = await dir.list().toList();

    //: Comprobar si es un título único (archivos .exe/.lnk directamente en la carpeta)
    final directExe = entities.firstWhereOrNull((e) => e is File && (
      e.path.endsWith('.exe') || 
      e.path.endsWith('.lnk') || 
      e.path.endsWith('.url')
    ));

    //: Comprobar si es un título único o múltiples subcarpetas
    if (directExe != null) {
      items.addAll(
        await GamesNovelsScannerService.scanForSingleGamesOrNovels(dir, type, defaultCoverPath));
    } else {
      items.addAll(
        await GamesNovelsScannerService.scanForMultipleGamesOrNovels(dir, type, defaultCoverPath)
      );
    }

    //: Ordenar los items por título de manera natural antes de retornarlos
    items.sort((a, b) => naturalSortCompare(a.title, b.title));
    return items;
  }
  //!+

  

  //+ = MANGA / COMICS =
  // Escaneo Híbrido de Manga (Archivos directos o Subcarpetas de capítulos)
  Future<List<FranchiseItemModel>> scanManga(Directory mangaDir) async {
    final chapters = await MangaScannerService.scanManga(mangaDir);
    return chapters;
  }
  //!+



  //+ = ANIME =
  ///: Escaneo Híbrido de Anime (Episodios directos o Estructura por Temporadas)
  Future<FranchiseItemModelList> scanAnime(Directory animeDir) async {
    final episodes = await AnimeScannerService.scanAnime(animeDir);
    return episodes;
  }
  //!+


  //+ LIBROS =
  ///: Escaneo de Libros (Archivos directos o Subcarpetas)
  Future<List<FranchiseItemModel>> scanBooks(Directory booksDir) async {
    return await BooksScannerService.scanBooks(booksDir);
  }
  //!+
}