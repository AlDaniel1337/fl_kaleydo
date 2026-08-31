import 'dart:io';



/// Modelo que representa un ítem de franquicia en la aplicación.
enum FranchiseMediaType { juegos, novelas, libros, manga, anime, resumen }



/// Modelo que representa un ítem de franquicia en la aplicación.
class FranchiseItemModel {
  
  final String title;
  final String path;
  final String? coverPath;
  final String? executablePath; // .exe o .lnk
  final String? guidePath;      // guia.md
  final String? cgsFolderPath;  // carpeta /cgs
  final String? seasonName;     // Ej: "Temp 1" (para Anime)
  final List<String> pagePaths; // Para Manga (páginas o PDF)

  FranchiseItemModel({
    required this.title,
    required this.path,
    this.coverPath,
    this.executablePath,
    this.guidePath,
    this.cgsFolderPath,
    this.seasonName,
    this.pagePaths = const [],
  });

  /// Indica si la franquicia tiene una carpeta de CGS existente.
  bool get hasCgs => cgsFolderPath != null && Directory(cgsFolderPath!).existsSync();
  
  /// Indica si la franquicia tiene una guía existente.
  bool get hasGuide => guidePath != null && File(guidePath!).existsSync();
}