import 'package:kaleydo/app/data/data.models.index.dart';

abstract class FranchiseTabSorter {
  static const List<FranchiseMediaType> _defaultOrder = [
    FranchiseMediaType.juegos,
    FranchiseMediaType.novelasVisuales,
    FranchiseMediaType.anime,
    FranchiseMediaType.manga,
    FranchiseMediaType.mangah,
    FranchiseMediaType.manhwa,
    FranchiseMediaType.libros,
    FranchiseMediaType.videos,
    FranchiseMediaType.resumen,
  ];

  /// Recibe una lista de pestañas y devuelve una nueva lista ordenada según la prioridad de la app.
  static List<FranchiseMediaType> sort(List<FranchiseMediaType> tabs) {
    final sortedList = List<FranchiseMediaType>.from(tabs);
    sortedList.sort((a, b) {
      final indexA = _defaultOrder.indexOf(a);
      final indexB = _defaultOrder.indexOf(b);

      // Si algún elemento no está en la lista de orden predefinido, lo manda al final
      final weightA = indexA != -1 ? indexA : 999;
      final weightB = indexB != -1 ? indexB : 999;

      return weightA.compareTo(weightB);
    });
    return sortedList;
  }
}