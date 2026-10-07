import 'dart:io';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/core/utils/natural_sort.dart';
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
 
  final RxInt currentMangaPageIndex = 0.obs;
  final int _comicsPerPageSize = 25;
  int get comicsPerPageSize => _comicsPerPageSize;

  // Variable para controlar si el manga se muestra en Grid o Lista
  final RxBool isMangaGridView = false.obs;

  void toggleMangaView() {
    isMangaGridView.value = !isMangaGridView.value;
  }
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

  List<FranchiseItemModel> get mangaHChapters =>
      mediaContent[FranchiseMediaType.mangah] ?? [];

  List<FranchiseItemModel> get bookItems =>
      mediaContent[FranchiseMediaType.libros] ?? [];

  /// Genera una lista paginada de capítulos de manga según el índice de página y el tamaño de página.
  List<FranchiseItemModel> paginatedMangaChapters({
    required int pageIndex, 
    bool getAll = false,
    bool getAllH = false,
  }) {

    final allChapters = getAllH ? mangaHChapters : mangaChapters;

    if (getAll || getAllH || allChapters.length <= _comicsPerPageSize) return allChapters;
    final startIndex = pageIndex * _comicsPerPageSize;
    final endIndex = ((pageIndex + 1) * _comicsPerPageSize).clamp(0, allChapters.length);
    return allChapters.sublist(startIndex, endIndex);
  }

  /// Cambia la página actual de manga y desplaza la vista al inicio.
  void changeMangaPage(int pageIndex) {
    currentMangaPageIndex.value = pageIndex;
    moveScrollToTop();
  }
  //!+


  //+ JUEGO / NOVELAS VISUALES
  FranchiseItemModel? selectedGameItem;
  final RxString selectedGameItemInfo = ''.obs;
  final RxList<String> selectedGameItemTags = <String>[].obs;
  final RxBool hasCGsGallery = false.obs;
  final RxList<String> selectedGameItemImages = <String>[].obs;
  final RxList<String> randomSelectedGameItemImages = <String>[].obs;

  Future<void> setSelectedGameItem(FranchiseItemModel? item) async {
    _clearSelectedGameItem();
    selectedGameItem = item;

    if (item == null) return;

    final basePath = item.path;
    final extraDir = Directory('$basePath/extra');

    // I/O Asíncrono para evitar congelar la interfaz
    if (await extraDir.exists()) {
      await Future.wait([
        _getInfoForSelectedGameItem(extraDir.path),
        _getImagesForSelectedGameItem(extraDir.path),
      ]);
    }
  }

  /// Obtiene la información del juego de forma asíncrona.
  Future<void> _getInfoForSelectedGameItem(String extraPath) async {
    final infoFile = File('$extraPath/info.txt');
    if (await infoFile.exists()) {
      final rowInfo = await infoFile.readAsString();

      final sections = rowInfo.split('---');
      if (sections.isNotEmpty) {
        selectedGameItemInfo.value = sections[0].trim();
        if (sections.length > 1) {
          final tags = sections[1]
              .split(',')
              .map((tag) => tag.trim())
              .where((tag) => tag.isNotEmpty)
              .toList();
              
          selectedGameItemTags.assignAll(tags);
        }
      }
    }
  }

  /// Obtiene las imágenes escaneando los directorios asíncronamente.
  Future<void> _getImagesForSelectedGameItem(String extraPath) async {
    final cgDir = Directory('$extraPath/CGs');
    final imagesDir = Directory('$extraPath/Images');

    Directory? targetDir;

    if (await cgDir.exists()) {
      targetDir = cgDir;
      hasCGsGallery.value = true;
    } else if (await imagesDir.exists()) {
      targetDir = imagesDir;
    }

    if (targetDir != null) {
      final paths = <String>[];
      
      // Escaneo asíncrono vía Stream
      await for (final entity in targetDir.list()) {
        if (entity is File) {
          paths.add(entity.path);
        }
      }

      selectedGameItemImages.assignAll(naturalSort<String>(paths));

      _generateRandomImages();
    }
  }

  /// Selecciona hasta 4 imágenes aleatorias sin reordenar toda la lista.
  void _generateRandomImages() {
    if (selectedGameItemImages.isEmpty) return;

    final totalImages = selectedGameItemImages.length;
    final count = min(4, totalImages);
    
    if (count == totalImages) {
      randomSelectedGameItemImages.assignAll(selectedGameItemImages);
      return;
    }

    final random = Random();
    final selectedIndices = <int>{};

    while (selectedIndices.length < count) {
      selectedIndices.add(random.nextInt(totalImages));
    }

    final randomImages = selectedIndices
        .map((index) => selectedGameItemImages[index])
        .toList();

    randomSelectedGameItemImages.assignAll(randomImages);
  }

  /// Limpia las referencias y limpia los reactivos de GetX.
  void _clearSelectedGameItem() {
    selectedGameItem = null;
    selectedGameItemInfo.value = '';
    hasCGsGallery.value = false;
    
    selectedGameItemTags.clear();
    selectedGameItemImages.clear();
    randomSelectedGameItemImages.clear();
  }



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
  Future<void> resumeLastProgress() async {
    final progress = latestProgress.value;

    if (progress == null) return;

    final String mediaType = progress['mediaType'] ?? '';
    
    if (mediaType.contains('comic')) {
      int index = mangaChapters.indexWhere((chapter) => chapter.path == progress['lastChapterPath']);
      if (index != -1) {
        openReaderForChapter(mangaChapters, index);
      }
      else {
        Get.snackbar('Error', 'No se encontró el capítulo guardado en la lista de manga.');
      }
    } 

    else if (mediaType.contains('video')) {
      int index = filteredAnimeEpisodes.indexWhere((episode) => episode.path == progress['lastVideoPath']);
      if (index != -1) {
        openPlayerForEpisode(
          filteredAnimeEpisodes, 
          index,
        );
      }
      else {
        Get.snackbar('Error', 'No se encontró el episodio guardado en la lista de anime.');
      }

    }

    await Future.delayed(const Duration(milliseconds: 150));
    checkProgressForCurrentTab();
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


  /// Vuelve a escanear el directorio de la franquicia actual para reflejar nuevos archivos
  Future<void> refreshFranchiseContent() async {
    isLoading.value = true;
    try {
      // Vuelve a ejecutar la lógica de escaneo/carga que usas en el onInit
      await loadFranchiseDetails(); 
    } finally {
      isLoading.value = false;
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

  /// Abre el lector de manga/libros y actualiza el progreso al volver
  Future<void> openReaderForChapter(List<FranchiseItemModel> chapterList, int index) async {
    await Get.toNamed(
      ReaderView.route, 
      arguments: {
        'chapterList': chapterList,
        'currentIndex': index,
      },
    );
    await Future.delayed(const Duration(milliseconds: 100));
    checkProgressForCurrentTab();
  }

  /// Abre el reproductor de anime y actualiza el progreso al volver
  Future<void> openPlayerForEpisode(List<FranchiseItemModel> playlist, int index) async {
    FocusManager.instance.primaryFocus?.unfocus();
    await Get.toNamed(
      MediaPlayerView.route,
      arguments: {
        'playlist': playlist,
        'currentIndex': index,
      },
    );
    await Future.delayed(const Duration(milliseconds: 150));
    checkProgressForCurrentTab();
  }

  void openFranchiseFolder(String folderPath) async {
    try {
      if (Platform.isWindows) {
        await Process.run('explorer.exe', [folderPath]);
      } else if (Platform.isMacOS) {
        await Process.run('open', [folderPath]);
      } else if (Platform.isLinux) {
        await Process.run('xdg-open', [folderPath]);
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'No se pudo abrir la ubicación del archivo.',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.redAccent,
        colorText: Colors.white,
      );
    }
  }
}