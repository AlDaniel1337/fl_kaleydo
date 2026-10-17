import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/data/data.models.index.dart';


class AnimeTabController extends GetxController {
  
  //: Variables para contenido de video
  final ScrollController animeScrollController = ScrollController();
  final RxList<String> animeSeasons = <String>['Completo'].obs;
  final RxString selectedAnimeSeason = 'Completo'.obs;

  @override
  void onClose() {
    animeScrollController.dispose();
    super.onClose();
  }


  /// Filtra los episodios de anime según la temporada seleccionada. 
  /// - Si la temporada seleccionada es "Completo", devuelve todos los episodios.
  List<FranchiseItemModel> getFilteredEpisodes(List<FranchiseItemModel> allEpisodes) {

    if (selectedAnimeSeason.value == 'Completo') return allEpisodes;

    return allEpisodes
      .where((ep) => ep.seasonName == selectedAnimeSeason.value)
      .toList();
  }


  /// Configura las temporadas de anime disponibles a partir de la lista de episodios proporcionada. 
  /// - Siempre incluye "Completo" como la primera opción.
  void setupSeasons(List<FranchiseItemModel>? animeEpisodes) {

    // Si no hay episodios de anime, se establece solo la opción "Completo".
    if (animeEpisodes == null || animeEpisodes.isEmpty) {
      animeSeasons.assignAll(['Completo']);
      selectedAnimeSeason.value = 'Completo';
      return;
    }

    // Extraer las temporadas únicas de los episodios de anime.
    final seasons = animeEpisodes
      .map((ep) => ep.seasonName)
      .whereType<String>()
      .toSet();

    animeSeasons.assignAll(['Completo', ...seasons]);
    selectedAnimeSeason.value = 'Completo';
  }


  /// Cambia la temporada seleccionada y desplaza la lista de episodios hacia arriba.
  void changeSeason(String season) {
    selectedAnimeSeason.value = season;
    moveScrollToTop();
  }


  /// Desplaza la lista de episodios de anime hacia arriba.
  void moveScrollToTop() {
    if (animeScrollController.hasClients) {
      animeScrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }
}