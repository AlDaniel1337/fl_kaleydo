class FolderOption {
  final String name;
  bool isSelected;
  bool hasMultipleContents;

  FolderOption({
    required this.name, 
    this.isSelected          = false, 
    this.hasMultipleContents = false,
  });
}

enum FolderNames {
  // Opciones disponibles
  anime   (name: 'Anime',),
  animeH  (name: 'Anime H',),
  manga   (name: 'Manga',),
  mangaH  (name: 'Manga H',),
  novelaVisual (name: 'Novela visual',),
  manwha  (name: 'Manwha',),
  resumen (name: 'Resumen',),
  juego   (name: 'Juego',);

  // Constructor
  const FolderNames({ 
    required this._name,
    this._isSelected = false,
  });

  // Propiedades
  final String _name;
  String get name => _name;

  final bool _isSelected;
  bool get isSelected => _isSelected;
}

enum ExtraFolderNames {
  // Opciones disponibles
  info   (name: 'Info', isSelected: true),
  imagenes (name: 'Imagenes',),
  cgs (name: 'CGs',),
  guia (name: 'Guia',);

  // Constructor
  const ExtraFolderNames({ 
    required this._name,
    this._isSelected = false,
  });

  // Propiedades
  final String _name;
  String get name => _name;

  final bool _isSelected;
  bool get isSelected => _isSelected;
}