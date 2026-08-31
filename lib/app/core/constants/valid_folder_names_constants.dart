
///: Constantes que representan los nombres válidos de las subcarpetas para cada tipo de medio.
abstract class ValidFolderNamesConstants {

  // Privatizar el constructor evita instanciar la clase innecesariamente
  ValidFolderNamesConstants._();

  //: Nombres válidos de las subcarpetas del tipo Anime
  static const List<String> validAnimeFolders = [
    'anime', 'animes', 'video', 'videos', 'a', 'h',
  ];

  //: Nombres válidos de las subcarpetas del tipo Manga
  static const List<String> validMangaFolders = [
    'manga', 'mangas', 'comic', 'comics', 'manhwa', 'webtoon', 'm',
  ];

  //: Nombres válidos de las subcarpetas del tipo Juegos
  static const List<String> validGamesFolders = [
    'juegos', 'juego', 'game', 'games', 'j',
  ];

  //: Nombres válidos de las subcarpetas del tipo Novelas Visuales
  static const List<String> validVisualNovelsFolders = [
    'novela visual', 'novelas visuales', 'visual novels', 'vn', 'n',
  ];

  //: Nombres válidos de las subcarpetas del tipo Libros
  static const List<String> validBooksFolders = [
    'libro', 'libros', 'book', 'books', 'b', 'novela', 'novelas',
  ];
}