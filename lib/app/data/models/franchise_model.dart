


/// Modelo que representa un ítem de franquicia en la aplicación.
enum FranchiseMediaType { 
  juegos, 
  novelasVisuales, 
  anime, animeh,
  manga, mangah, manhwa, 
  resumen, videos,
  libros, 
}



/// Modelo que representa un ítem de franquicia en la aplicación.
class FranchiseItemModel {
  
  final String title;
  final String path;
  final String? coverPath;
  final String? executablePath; // .exe o .lnk
  final String? seasonName;     // Ej: "Temp 1" (para Anime)
  final List<String> pagePaths; // Para Manga (páginas o PDF)

  FranchiseItemModel({
    required this.title,
    required this.path,
    this.coverPath,
    this.executablePath,
    this.seasonName,
    this.pagePaths = const [],
  });
}