import 'package:flutter/material.dart';
import 'package:kaleydo/app/core/utils/clean_text.dart';

/// Enumeración de los íconos disponibles en la barra lateral de la aplicación.
enum AppMediaType {
  // Opciones disponibles
  unknownCategoryIcon (icon: Icons.folder_special_rounded),

  anime (icon: Icons.live_tv_rounded),
  animes (icon: Icons.live_tv_rounded),
  animeHentai (icon: Icons.tv_off_rounded),
  animesHentai (icon: Icons.tv_off_rounded),

  manga (icon: Icons.menu_book_rounded),
  mangas (icon: Icons.menu_book_rounded),
  mangaHentai (icon: Icons.bookmark_add_rounded),
  mangasHentai (icon: Icons.bookmark_add_rounded),

  hentai (icon: Icons.explicit_rounded),

  juego (icon: Icons.sports_esports_rounded),
  juegos (icon: Icons.sports_esports_rounded),

  novela (icon: Icons.book_rounded),
  novelas (icon: Icons.book_rounded),

  novelasVisuales (icon: Icons.my_library_books_rounded),

  musica (icon: Icons.library_music_rounded),

  curso (icon: Icons.school_rounded),
  cursos (icon: Icons.school_rounded),

  variado (icon: Icons.auto_awesome_mosaic_rounded),
  variadoHentai (icon: Icons.auto_awesome_mosaic_rounded),
  ;

  // Constructor
  const AppMediaType({ 
    required this._icon 
  });

  // Propiedades
  final IconData _icon;
  IconData get icon => _icon;
  
}




/// Obtiene el ícono apartir de un String que representa el tipo de medio.
IconData getAppMediaTypeIconOrIcon(String mediaType) {
  mediaType = cleanText(mediaType);
  return getAppMediaType(mediaType).icon;
}



/// Obtiene el tipo de medio apartir de un String que representa el tipo de medio.
AppMediaType getAppMediaType(String mediaType) {

  mediaType = cleanText(mediaType);
  
  // Retornar el tipo de medio correspondiente según el string
  final type = AppMediaType.values.firstWhere(
    (e) => e.name.toLowerCase() == mediaType,
    orElse: () => AppMediaType.unknownCategoryIcon,
  );
  
  return type;
}
