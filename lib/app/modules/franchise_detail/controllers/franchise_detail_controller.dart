import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/data/data.models.index.dart';
import 'package:kaleydo/app/modules/media_player/views/media_player_view.dart';
import 'package:kaleydo/app/modules/reader/views/reader_view.dart';
import 'package:process_run/shell.dart';

/// Controlador para gestionar el detalle y la navegación de contenidos de una franquicia.
class FranchiseDetailController extends GetxController {
  
  //+ VARIABLES
  // Servicios
  final FranchiseScannerService _scannerService = FranchiseScannerService();

  // Controladores de UI
  final ScrollController animeScrollController = ScrollController();

  late final MediaItemModel mediaItem;
  bool _isMediaItemInitialized = false;

  final RxList<FranchiseMediaType> availableTabs = <FranchiseMediaType>[].obs;
  final Rx<FranchiseMediaType> selectedTab = FranchiseMediaType.juegos.obs;

  final RxMap<FranchiseMediaType, List<FranchiseItemModel>> mediaContent =
      <FranchiseMediaType, List<FranchiseItemModel>>{}.obs;

  final RxList<String> animeSeasons = <String>['Completo'].obs;
  final RxString selectedAnimeSeason = 'Completo'.obs;

  final RxBool isLoading = true.obs;
  final Rxn<Map<String, dynamic>> latestProgress = Rxn<Map<String, dynamic>>();
  //!+



  //+ CICLO DE VIDA
  @override
  void onInit() {
    super.onInit();
    _initializeArguments();

    if (_isMediaItemInitialized) {
      checkProgressForCurrentTab();
      ever(selectedTab, (_) => checkProgressForCurrentTab());
    }
  }

  @override
  void onClose() {
    animeScrollController.dispose();
    super.onClose();
  }
  //!+



  //+ ANIME
  /// GET: Filtra los episodios de anime según la temporada seleccionada.
  List<FranchiseItemModel> get filteredAnimeEpisodes {
    final allEpisodes = mediaContent[FranchiseMediaType.anime] ?? [];
    if (selectedAnimeSeason.value == 'Completo') return allEpisodes;

    return allEpisodes
        .where((ep) => ep.seasonName == selectedAnimeSeason.value)
        .toList();
  }


  /// Cambia la temporada de anime seleccionada y desplaza la vista al inicio.
  void changeAnimeSeason(String season) {
    selectedAnimeSeason.value = season;
    moveScrollToTop();
  }


  /// Determina si se deben mostrar las pestañas de temporada de anime.
  bool showAnimeSeasonTabs() {
    return selectedTab.value == FranchiseMediaType.anime &&
        animeSeasons.length > 1;
  }


  /// Configura las temporadas de anime basándose en los episodios escaneados.
  void _setupAnimeSeasons(List<FranchiseItemModel>? animeEpisodes) {
    if (animeEpisodes == null || animeEpisodes.isEmpty) {
      animeSeasons.assignAll(['Completo']);
      selectedAnimeSeason.value = 'Completo';
      return;
    }

    final seasons = animeEpisodes
        .map((ep) => ep.seasonName)
        .whereType<String>()
        .toSet();

    animeSeasons.assignAll(['Completo', ...seasons]);
    selectedAnimeSeason.value = 'Completo';
  }
  //!+



  //+ MANGA / LIBROS / COMICS
  List<FranchiseItemModel> get mangaChapters =>
      mediaContent[FranchiseMediaType.manga] ?? [];

  List<FranchiseItemModel> get bookItems =>
      mediaContent[FranchiseMediaType.libros] ?? [];
  //!+



  //+ EJECUCIÓN DE COMANDOS
  /// Ejecuta un comando de shell en el directorio de la franquicia.
    Future<void> launchExecutable(String path) async {
    try {
      final shell = Shell();
      await shell.run('"$path"');
    } catch (e) {
      Get.snackbar('Error al ejecutar', 'No se pudo iniciar el programa: $e');
    }
  }
  //!+
  
  

  //+ NAVEGACIÓN
  /// Desplaza la vista al inicio.
  void moveScrollToTop() {
    if (animeScrollController.hasClients) {
      animeScrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 250),
        curve: Curves.easeOut,
      );
    }
  }


  /// Navega al último progreso guardado según el tipo de contenido seleccionado (manga o anime).
  void resumeLastProgress() {
    final progress = latestProgress.value;
    if (progress == null) return;

    final currentTab = selectedTab.value;

    // Manga
    if (_isMediaAReadItem(currentTab)) {
      
      final chapterPath = progress['lastChapterPath'] as String? ?? '';
      if (chapterPath.isEmpty) return;

      // Calcula el índice del capítulo actual en la lista correspondiente
      final currentList = currentTab == FranchiseMediaType.manga ? mangaChapters : bookItems;
      final index = currentList.indexWhere((item) => item.path == chapterPath);

      Get.toNamed(
        ReaderView.route,
        arguments: {
          'chapterList': currentList,
          'currentIndex': index != -1 ? index : 0,
          'chapterPath': chapterPath,
        },
      );
    }
    
    // Anime
    else if (currentTab == FranchiseMediaType.anime) {
      final videoPath = progress['lastVideoPath'] as String? ?? '';
      if (videoPath.isNotEmpty) {
        Get.toNamed(
          MediaPlayerView.route, 
          arguments: videoPath
        );
      }
    }
  }
  //!+

  

  //+ CARGA Y GESTIÓN DE DATOS
  /// Carga los detalles de la franquicia desde el directorio especificado en `mediaItem`.
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
  

  /// Verifica y actualiza el progreso más reciente para la pestaña de contenido actualmente seleccionada.
  void checkProgressForCurrentTab() {
    if (!_isMediaItemInitialized) return;

    final currentTab = selectedTab.value;
    final path = mediaItem.path;

    // Manga
    if (_isMediaAReadItem(currentTab)) {
      
      final storage = Get.isRegistered<ReaderStorageService>()
          ? Get.find<ReaderStorageService>()
          : null;

      latestProgress.value = storage?.getLatestChapterForFranchise(path);
    } 
    
    // Anime
    else if (_isMediaAWatchItem(currentTab)) {
      final storage = Get.isRegistered<PlayerStorageService>()
          ? Get.find<PlayerStorageService>()
          : null;
      latestProgress.value = storage?.getLatestVideoForFranchise(path);
    }
    
    // Otros tipos de contenido
    else {
      latestProgress.value = null;
    }
  }
  //!+



  //+ MÉTODOS AUXILIARES
  /// Inicializa el `mediaItem` a partir de los argumentos proporcionados a la vista. Si no se proporciona un `MediaItemModel` válido, muestra un mensaje de error.
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


  /// Actualiza el estado de los medios y las pestañas disponibles basándose en el contenido escaneado.
  void _updateMediaState(Map<FranchiseMediaType, List<FranchiseItemModel>> scannedContent) {
    mediaContent.assignAll(scannedContent);

    final tabs = scannedContent.keys.toList();
    availableTabs.assignAll(tabs);

    if (tabs.isNotEmpty) {
      selectedTab.value = tabs.first;
    }

    _setupAnimeSeasons(scannedContent[FranchiseMediaType.anime]);
  }


  /// Determina si el tipo de medio proporcionado es un elemento de lectura.
  bool _isMediaAReadItem(FranchiseMediaType mediaType) {
    return mediaType == FranchiseMediaType.manga ||
        mediaType == FranchiseMediaType.libros;
  }


  /// Determina si el tipo de medio proporcionado es un elemento de reproducción.
  bool _isMediaAWatchItem(FranchiseMediaType mediaType) {
    return mediaType == FranchiseMediaType.anime;
  }
  //!+

}