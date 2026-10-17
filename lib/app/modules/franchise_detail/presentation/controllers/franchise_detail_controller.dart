import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/data/data.models.index.dart';
import 'package:kaleydo/app/modules/franchise_detail/data/services/open_folder_service.dart';
import 'package:kaleydo/app/modules/franchise_detail/utils/franchise_tab_sorter.dart';
import 'package:kaleydo/app/modules/media_player/views/media_player_view.dart';
import 'package:kaleydo/app/modules/reader/presentation/views/reader_view.dart';

import 'anime_tab_controller.dart';
import 'game_tab_controller.dart';
import 'manga_tab_controller.dart';


class FranchiseDetailController extends GetxController {
  
  //: Servicios
  final FranchiseScannerService _scannerService = FranchiseScannerService();

  //: Sub-controllers 
  // mediante Lazy Find (Solo se inicializan al accederse)
  AnimeTabController get animeController => Get.find<AnimeTabController>();
  MangaTabController get mangaController => Get.find<MangaTabController>();
  GameTabController  get gameController => Get.find<GameTabController>();

  late final MediaItemModel mediaItem;
  bool _isMediaItemInitialized = false;

  final RxList<FranchiseMediaType> availableMediaCategories = <FranchiseMediaType>[].obs;
  final Rx<FranchiseMediaType> selectedCategory = FranchiseMediaType.juegos.obs;

  final RxMap<FranchiseMediaType, List<FranchiseItemModel>> mediaContent = <FranchiseMediaType, List<FranchiseItemModel>>{}.obs;

  final RxBool isLoading = true.obs;
  final Rxn<Map<String, dynamic>> latestProgress = Rxn<Map<String, dynamic>>();

  @override
  void onInit() {
    super.onInit();
    _initializeArguments();

    if (_isMediaItemInitialized) {
      checkProgressForCurrentTab();
      
      // Listener para manejar cambios de tab y preparar datos de forma diferida
      ever(selectedCategory, (tab) {
        checkProgressForCurrentTab();
        _onTabChanged(tab);
      });
    }
  }


  /// Inicialización bajo demanda según el tab seleccionado
  void _onTabChanged(FranchiseMediaType tab) {
    if (tab == FranchiseMediaType.juegos || tab == FranchiseMediaType.novelasVisuales) {
      final items = mediaContent[tab] ?? [];
      if (gameController.selectedGameItem == null && items.isNotEmpty) {
        gameController.setSelectedGameItem(items.first, 0);
      }
    }
  }


  //: Getters delegados
  List<FranchiseItemModel> get filteredAnimeEpisodes =>
    animeController.getFilteredEpisodes(mediaContent[FranchiseMediaType.anime] ?? []);

  List<FranchiseItemModel> get mangaChapters =>
    mediaContent[FranchiseMediaType.manga] ?? [];

  List<FranchiseItemModel> get mangaHChapters =>
    mediaContent[FranchiseMediaType.mangah] ?? [];

  List<FranchiseItemModel> get bookItems =>
    mediaContent[FranchiseMediaType.libros] ?? [];


  /// Comprueba si se deben mostrar las pestañas de temporadas de anime
  bool showAnimeSeasonTabs() {
    return selectedCategory.value == FranchiseMediaType.anime &&
      animeController.animeSeasons.length > 1;
  }


  /// Carga de Datos y Navegación
  Future<void> loadFranchiseDetails() async {
    if (!_isMediaItemInitialized) return;

    isLoading.value = true;
    try {
      final franchiseDir = Directory(mediaItem.path);
      if (!await franchiseDir.exists()) return;

      final scannedContent = await _scannerService.scanFranchiseDirectory(
        franchiseDir,
        mediaItem.coverPath ?? '',
      );

      _updateMediaState(scannedContent);
    } catch (e) {
      Get.snackbar('Error de lectura', 'No se pudieron cargar los datos: $e');
    } finally {
      isLoading.value = false;
    }
  }


  /// Actualiza el estado de los medios después de escanear el directorio de la franquicia
  void _updateMediaState(Map<FranchiseMediaType, List<FranchiseItemModel>> scannedContent) {
    mediaContent.assignAll(scannedContent);

    // Ordena y asigna las pestañas disponibles según el contenido escaneado
    List<FranchiseMediaType> tabs = _sortTabs(scannedContent.keys.toList());
    availableMediaCategories.assignAll(tabs);

    if (tabs.isNotEmpty) {
      selectedCategory.value = tabs.first;
      _onTabChanged(tabs.first);
    }

    // Configura temporadas únicamente si existe contenido de Anime
    if (scannedContent.containsKey(FranchiseMediaType.anime)) {
      animeController.setupSeasons(scannedContent[FranchiseMediaType.anime]);
    }
  }


  /// Reanuda el progreso más reciente del usuario en la franquicia
  Future<void> resumeLastProgress() async {
    final progress = latestProgress.value;
    if (progress == null) return;

    final String mediaType = progress['mediaType'] ?? '';

    //* Contenido de cómic (manga, manhwa, etc.)
    if (mediaType.contains('comic')) {
      int index = mangaChapters.indexWhere((ch) => ch.path == progress['lastChapterPath']);
      if (index != -1) {
        openReaderForChapter(mangaChapters, index);
      } else {
        Get.snackbar('Error', 'No se encontró el capítulo guardado en la lista de manga.');
      }
    } 
    
    //* Contenido de video (anime, películas, etc.)
    else if (mediaType.contains('video')) {
      int index = filteredAnimeEpisodes.indexWhere((ep) => ep.path == progress['lastVideoPath']);
      if (index != -1) {
        openPlayerForEpisode(filteredAnimeEpisodes, index);
      } else {
        Get.snackbar('Error', 'No se encontró el episodio guardado en la lista de anime.');
      }
    }

    await Future.delayed(const Duration(milliseconds: 150));
    checkProgressForCurrentTab();
  }


  /// Comprueba el progreso del usuario para la pestaña de medios actualmente seleccionada
  void checkProgressForCurrentTab() {
    if (!_isMediaItemInitialized) return;

    final currentTab = selectedCategory.value;
    final path = mediaItem.path;

    if (_isMediaAReadItem(currentTab)) {
      final storage = Get.isRegistered<ReaderStorageService>()
          ? Get.find<ReaderStorageService>()
          : null;
      latestProgress.value = storage?.getLatestChapterForFranchise(path);
    } else if (_isMediaAWatchItem(currentTab)) {
      final storage = Get.isRegistered<PlayerStorageService>()
          ? Get.find<PlayerStorageService>()
          : null;
      latestProgress.value = storage?.getLatestVideoForFranchise(path);
    } else {
      latestProgress.value = null;
    }
  }


  /// Abre el lector para un capítulo específico de la lista de capítulos proporcionada.
  Future<void> openReaderForChapter(List<FranchiseItemModel> chapterList, int index) async {
    await Get.toNamed(
      ReaderView.route,
      arguments: {'chapterList': chapterList, 'currentIndex': index},
    );
    await Future.delayed(const Duration(milliseconds: 100));
    checkProgressForCurrentTab();
  }


  /// Abre el reproductor para un episodio específico de la lista de reproducción proporcionada.
  Future<void> openPlayerForEpisode(List<FranchiseItemModel> playlist, int index) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await Get.toNamed(
      MediaPlayerView.route,
      arguments: {'playlist': playlist, 'currentIndex': index},
    );
    await Future.delayed(const Duration(milliseconds: 150));
    checkProgressForCurrentTab();
  }


  /// Abre la carpeta de la franquicia en una ventana del explorador de archivos del sistema operativo
  void openFranchiseFolder(String folderPath) => OpenFolderService.openFolder(folderPath);


  /// Refresca el contenido de la franquicia cargando nuevamente los detalles.
  Future<void> refreshFranchiseContent() async {
    isLoading.value = true;
    try {
      await loadFranchiseDetails();
    } finally {
      isLoading.value = false;
    }
  }


  /// Inicializa los argumentos recibidos al abrir la vista de detalles de la franquicia.
  void _initializeArguments() {
    if (Get.arguments is MediaItemModel) {
      mediaItem = Get.arguments as MediaItemModel;
      _isMediaItemInitialized = true;
      loadFranchiseDetails();
    } else {
      _isMediaItemInitialized = false;
      Get.snackbar('Error', 'No se especificó un elemento de medios válido.');
    }
  }


  /// Determina si un tipo de medio es un elemento de lectura
  bool _isMediaAReadItem(FranchiseMediaType type) =>
      type == FranchiseMediaType.manga || type == FranchiseMediaType.libros;
  

  /// Determina si un tipo de medio es un elemento de visualización
  bool _isMediaAWatchItem(FranchiseMediaType type) =>
      type == FranchiseMediaType.anime;


  /// Ordena las pestañas de medios según un orden predefinido
  List<FranchiseMediaType> _sortTabs(List<FranchiseMediaType> tabs) =>
      FranchiseTabSorter.sort(tabs);
}