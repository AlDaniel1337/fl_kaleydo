import 'package:get/get.dart';
import 'package:kaleydo/app/data/data.models.index.dart';

class MangaTabController extends GetxController {

  final RxInt currentPageIndex = 0.obs;
  final RxBool isGridView = false.obs;
  final int pageSize = 25;

  /// Alterna entre la vista de cuadrícula y la vista de lista.
  void toggleViewMode() {
    isGridView.value = !isGridView.value;
  }


  /// Obtiene los capítulos paginados según el índice de página y el tamaño de página.
  List<FranchiseItemModel> getPaginatedChapters({
    required List<FranchiseItemModel> chapters,
    required int pageIndex,
    bool getAll = false,
  }) {
    if (getAll || chapters.length <= pageSize) return chapters;

    final startIndex = pageIndex * pageSize;
    final endIndex = ((pageIndex + 1) * pageSize).clamp(0, chapters.length);
    return chapters.sublist(startIndex, endIndex);
  }



  /// Cambia la página actual y ejecuta la función de devolución de llamada proporcionada.
  void changePage(int pageIndex, Function() onPageChanged) {
    currentPageIndex.value = pageIndex;
    onPageChanged();
  }
}