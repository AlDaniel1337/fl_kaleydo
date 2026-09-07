import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:kaleydo/app/data/data.models.index.dart';

import 'mixins/chapter_scanner_mixin.dart';
import 'mixins/window_management_mixin.dart';

enum ReadingMode { scroll, page }

/// Controlador para gestionar la lectura de capítulos (manga/novelas),
/// controlando modos de visualización, guardado de progreso y navegación.
class ReaderController extends GetxController with WindowManagementMixin, ChapterScannerMixin {
  
  //+ VARIABLES
  // Servicios
  @override
  late final ReaderStorageService storage;

  // Controladores de UI
  final ScrollController scrollController = ScrollController();
  final PageController pageController = PageController();

  // Modelos y Estados de Navegación
  late FranchiseItemModel currentChapter;
  bool _isChapterInitialized = false;

  List<FranchiseItemModel> chapterList = [];
  int currentChapterIndex = 0;

  final RxList<String> imagePaths = <String>[].obs;

  // Estados Observables
  final RxBool isLoading = true.obs;
  final RxBool isControlsVisible = true.obs;
  final RxBool isFullScreen = false.obs;
  final RxBool isChapterReady = false.obs;

  final Rx<ReadingMode> readingMode = ReadingMode.scroll.obs;
  final RxInt currentPage = 1.obs;
  //!+



  //+ CICLO DE VIDA
  @override
  void onInit() {
    super.onInit();
    _initializeServices();
    initWindowSettings();
    _loadArguments();

    if (Get.isRegistered<ReaderStorageService>()) {
      readingMode.value = storage.readingMode == 'page'
          ? ReadingMode.page
          : ReadingMode.scroll;
    }

    scrollController.addListener(_onScrollPositionChanged);
  }

  @override
  void onClose() {
    restoreWindowBounds();
    scrollController.removeListener(_onScrollPositionChanged);
    scrollController.dispose();
    pageController.dispose();
    super.onClose();
  }
  //!+



  //+ GETTERS Y CONTROLES DE VISTA
  /// Retorna el nombre del archivo de la página actualmente visible.
  String get currentFileName {
    if (imagePaths.isEmpty) return '';
    final index = (currentPage.value - 1).clamp(0, imagePaths.length - 1);
    return imagePaths[index].split(RegExp(r'[/\\]')).last;
  }

  /// Alterna entre el modo continuo (scroll) y paginado.
  void toggleReadingMode(ReadingMode mode) {
    readingMode.value = mode;
    if (Get.isRegistered<ReaderStorageService>()) {
      storage.setReadingMode(mode == ReadingMode.page ? 'page' : 'scroll');
    }
  }

  /// Visibilidad de la barra de controles y superposiciones.
  void toggleControls() {
    isControlsVisible.value = !isControlsVisible.value;
  }
  //!+



  //+ MANEJO DE LECTURA Y PÁGINAS
  /// Salta directamente a una página específica del capítulo.
  void jumpToPage(int pageNumber) {
    if (pageNumber < 1 || pageNumber > imagePaths.length) return;
    currentPage.value = pageNumber;
    _registerCurrentReadProgress();

    final targetIndex = pageNumber - 1;

    if (readingMode.value == ReadingMode.scroll && scrollController.hasClients) {
      final maxScroll = scrollController.position.maxScrollExtent;
      if (maxScroll > 0 && imagePaths.length > 1) {
        final double targetOffset =
            (maxScroll / (imagePaths.length - 1)) * targetIndex;
        scrollController.jumpTo(targetOffset.clamp(0.0, maxScroll));
      }
    } else if (readingMode.value == ReadingMode.page &&
        pageController.hasClients) {
      pageController.jumpToPage(targetIndex);
    }
  }

  /// Callback invocado al cambiar de página en modo paginado.
  void onPageChanged(int index) {
    currentPage.value = index + 1;
    _registerCurrentReadProgress();
  }

  /// Vuelve a escanear las imágenes del capítulo actual.
  void reloadChapter() {
    _scanChapterImages();
    Get.snackbar(
      'Capítulo recargado',
      'Se actualizó el contenido del capítulo.',
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: AppColors.cardBackground,
      colorText: Colors.white,
      duration: const Duration(seconds: 2),
    );
  }

  /// Desplaza la vista al inicio del capítulo o primera página.
  void scrollToTop() {
    if (readingMode.value == ReadingMode.scroll && scrollController.hasClients) {
      scrollController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    } else if (readingMode.value == ReadingMode.page &&
        pageController.hasClients) {
      pageController.animateToPage(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
  //!+



  //+ NAVEGACIÓN
  /// Avanza al siguiente capítulo en la lista si existe.
  void goToNextChapter() {
    if (currentChapterIndex + 1 < chapterList.length) {
      currentChapterIndex++;
      currentChapter = chapterList[currentChapterIndex];
      _scanChapterImages();
    }
  }

  /// Retrocede al capítulo anterior en la lista si existe.
  void goToPreviousChapter() {
    if (currentChapterIndex - 1 >= 0) {
      currentChapterIndex--;
      currentChapter = chapterList[currentChapterIndex];
      _scanChapterImages();
    }
  }

  /// Cierra el lector, restableciendo el estado de la ventana y liberando caché.
  Future<void> exitReader() async {
    PaintingBinding.instance.imageCache.clear();
    PaintingBinding.instance.imageCache.clearLiveImages();
    await restoreWindowBounds();
    Get.back();
  }
  //!+



  //+ CARGA Y GESTIÓN DE DATOS
  /// Escanea y carga las imágenes desde el sistema de archivos para el capítulo actual.
  Future<void> _scanChapterImages() async {
    if (!_isChapterInitialized) return;

    isLoading.value = true;
    isChapterReady.value = false;
    imagePaths.clear();

    final files = await scanChapterDirectory(currentChapter.path);
    imagePaths.assignAll(files);

    _initializeChapterState();
    isLoading.value = false;
  }

  /// Restablece la posición de lectura guardada e inicializa los visores.
  void _initializeChapterState() {
    final savedPage = Get.isRegistered<ReaderStorageService>()
        ? storage.getPagePosition(currentChapter.path)
        : 1;

    currentPage.value =
        (savedPage > 0 && savedPage <= imagePaths.length) ? savedPage : 1;

    isChapterReady.value = true;
    _registerCurrentReadProgress();

    if (currentPage.value > 1) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        jumpToPage(currentPage.value);
      });
    }
  }

  /// Registra en almacenamiento local la última posición leída.
  void _registerCurrentReadProgress() {
    if (!_isChapterInitialized || !Get.isRegistered<ReaderStorageService>()) {
      return;
    }

    final pathSegments = currentChapter.path.split(RegExp(r'[/\\]'));
    String detectedMediaType = 'manga';

    for (final segment in pathSegments) {
      if (segment.startsWith('_')) {
        detectedMediaType = segment;
        break;
      }
    }

    String franchiseName = 'Desconocida';
    if (pathSegments.length >= 3) {
      franchiseName = pathSegments[pathSegments.length - 3];
    }

    storage.saveRecentMedia(
      mediaType: detectedMediaType,
      franchiseName: franchiseName,
      franchisePath: currentChapter.path.substring(
        0,
        currentChapter.path.lastIndexOf(Platform.pathSeparator),
      ),
      chapterPath: currentChapter.path,
      chapterTitle: currentChapter.title,
      pageIndex: currentPage.value,
    );
  }
  //!+



  //+ MÉTODOS AUXILIARES
  /// Garantiza la inicialización segura del servicio de almacenamiento.
  void _initializeServices() {
    if (Get.isRegistered<ReaderStorageService>()) {
      storage = Get.find<ReaderStorageService>();
    }
  }

  /// Valida e inicializa los argumentos pasados a la vista.
  void _loadArguments() {
    final args = Get.arguments;

    if (args is Map<String, dynamic>) {
      chapterList =
          (args['chapterList'] as List?)?.cast<FranchiseItemModel>() ?? [];
      currentChapterIndex = args['currentIndex'] as int? ?? 0;

      if (chapterList.isNotEmpty &&
          currentChapterIndex < chapterList.length) {
        currentChapter = chapterList[currentChapterIndex];
        _isChapterInitialized = true;
      }
    }

    if (_isChapterInitialized) {
      _scanChapterImages();
    } else {
      Get.snackbar('Error', 'No se pudo cargar la lista de capítulos.');
    }
  }

  /// Sincroniza la página activa con la posición actual del scroll.
  void _onScrollPositionChanged() {
    if (!scrollController.hasClients || imagePaths.isEmpty) return;

    final double currentScroll = scrollController.position.pixels;
    final double maxScroll = scrollController.position.maxScrollExtent;

    if (maxScroll <= 0) return;

    final double viewportHeight =
        scrollController.position.viewportDimension;
    final double totalContentHeight = maxScroll + viewportHeight;
    final double estimatedPageHeight = totalContentHeight / imagePaths.length;

    if (estimatedPageHeight > 0) {
      final int calculatedPage =
          ((currentScroll + (viewportHeight / 3)) / estimatedPageHeight)
                  .floor()
                  .clamp(0, imagePaths.length - 1) +
              1;

      if (currentPage.value != calculatedPage) {
        currentPage.value = calculatedPage;
        _registerCurrentReadProgress();
      }
    }
  }
  //!+
}