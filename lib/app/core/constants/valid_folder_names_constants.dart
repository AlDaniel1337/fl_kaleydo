
///: Constantes que representan los nombres válidos de las subcarpetas para cada tipo de medio.
abstract class ValidFolderNamesConstants {

  // Privatizar el constructor evita instanciar la clase innecesariamente
  ValidFolderNamesConstants._();

  //: Anime
  static const List<String> validAnimeFolders = [
    'anime', 'animes', 'video', 'videos', 'a', 'h',
  ];

  //: Manga
  static const List<String> validMangaFolders = [
    'manga', 'mangas', 'comic', 'comics', 'manhwa', 'webtoon', 'm',
  ];

  //: Juegos
  static const List<String> validGamesFolders = [
    'juegos', 'juego', 'game', 'games', 'j',
  ];

  //: Novelas Visuales
  static const List<String> validVisualNovelsFolders = [
    'novela visual', 'novelas visuales', 'visual novels', 'vn', 'n', 'nv',
  ];

  //: Libros
  static const List<String> validBooksFolders = [
    'libro', 'libros', 'book', 'books', 'b', 'novela', 'novelas',
  ];
}