// lib/app/modules/reader/controllers/reader_controller.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/data/data.models.index.dart';
import 'package:kaleydo/app/data/models/franchise_model.dart';

enum ReadingMode { scroll, page }

class ReaderController extends GetxController {
  final ReaderStorageService storage = Get.find<ReaderStorageService>();

  late FranchiseItemModel currentChapter;
  List<FranchiseItemModel> chapterList = [];
  int currentChapterIndex = 0;

  final RxList<String> imagePaths = <String>[].obs;
  final RxBool isLoading = true.obs;
  final RxBool isControlsVisible = true.obs;
  final RxBool isFullScreen = false.obs;

  // Estado del lector
  final Rx<ReadingMode> readingMode = ReadingMode.scroll.obs;
  final RxInt currentPage = 1.obs;

  // Controladores de Scroll y PageView
  final ScrollController scrollController = ScrollController();
  final PageController pageController = PageController();

  @override
  void onInit() {
    super.onInit();
    _loadArguments();

    // Cargar modo de lectura guardado
    readingMode.value = storage.readingMode == 'page' 
        ? ReadingMode.page 
        : ReadingMode.scroll;

    // Listener para actualizar la página actual según el Scroll continuo
    scrollController.addListener(_onScrollPositionChanged);
  }

  @override
  void onClose() {
    scrollController.dispose();
    pageController.dispose();
    super.onClose();
  }

  void _loadArguments() {
    final args = Get.arguments;

    if (args is Map<String, dynamic>) {
      chapterList = args['chapterList'] as List<FranchiseItemModel>? ?? [];
      currentChapterIndex = args['currentIndex'] as int? ?? 0;
      
      if (chapterList.isNotEmpty) {
        currentChapter = chapterList[currentChapterIndex];
      }
    }

    _scanChapterImages();
  }

  void _scanChapterImages() {
    isLoading.value = true;
    imagePaths.clear();

    final Directory dir = Directory(currentChapter.path);

    if (dir.existsSync()) {
      final List<FileSystemEntity> entities = dir.listSync();
      final List<String> files = entities
          .whereType<File>()
          .map((e) => e.path)
          .where((path) {
            final ext = path.toLowerCase();
            return ext.endsWith('.png') ||
                  ext.endsWith('.jpg') ||
                  ext.endsWith('.jpeg') ||
                  ext.endsWith('.webp');
          })
          .toList();

      // ORDENAMIENTO NATURAL CORREGIDO
      files.sort(_naturalCompare);
      imagePaths.assignAll(files);
    }

    // Cargar posición guardada
    final savedPage = storage.getPagePosition(currentChapter.path);
    if (savedPage > 0 && savedPage <= imagePaths.length) {
      currentPage.value = savedPage;
    } else {
      currentPage.value = 1;
    }

    isLoading.value = false;

    // Reiniciar la posición de scroll/pageview a la página correspondiente
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _resetViewPosition();
    });
  }

  void _resetViewPosition() {
    final targetIndex = currentPage.value - 1;

    if (readingMode.value == ReadingMode.scroll && scrollController.hasClients) {
      if (targetIndex == 0) {
        scrollController.jumpTo(0.0);
      }
    } else if (readingMode.value == ReadingMode.page && pageController.hasClients) {
      pageController.jumpToPage(targetIndex);
    }
  }

  void toggleReadingMode(ReadingMode mode) {
    readingMode.value = mode;
    storage.setReadingMode(mode == ReadingMode.page ? 'page' : 'scroll');
  }

  void toggleControls() {
    isControlsVisible.value = !isControlsVisible.value;
  }

  void _onScrollPositionChanged() {
    if (!scrollController.hasClients || imagePaths.isEmpty) return;

    final maxScroll = scrollController.position.maxScrollExtent;
    final currentScroll = scrollController.position.pixels;

    if (maxScroll > 0) {
      final double progress = (currentScroll / maxScroll).clamp(0.0, 1.0);
      final int calculatedPage = ((progress * (imagePaths.length - 1)) + 1).round();
      
      if (currentPage.value != calculatedPage) {
        currentPage.value = calculatedPage;
        storage.savePagePosition(currentChapter.path, calculatedPage);
      }
    }
  }

  void onPageChanged(int index) {
    currentPage.value = index + 1;
    storage.savePagePosition(currentChapter.path, currentPage.value);
  }

  void goToNextChapter() {
    if (currentChapterIndex + 1 < chapterList.length) {
      currentChapterIndex++;
      currentChapter = chapterList[currentChapterIndex];
      _scanChapterImages();
    }
  }

  void goToPreviousChapter() {
    if (currentChapterIndex - 1 >= 0) {
      currentChapterIndex--;
      currentChapter = chapterList[currentChapterIndex];
      _scanChapterImages();
    }
  }

  int _naturalCompare(String a, String b) {
    // Extraer solo el nombre de archivo sin la ruta completa (ej: "01.jpeg" o "10.jpg")
    final String fileNameA = a.split(RegExp(r'[/\\]')).last;
    final String fileNameB = b.split(RegExp(r'[/\\]')).last;

    final RegExp regExp = RegExp(r'(\d+|\D+)');
    final Iterable<Match> matchesA = regExp.allMatches(fileNameA);
    final Iterable<Match> matchesB = regExp.allMatches(fileNameB);

    final Iterator<Match> itA = matchesA.iterator;
    final Iterator<Match> itB = matchesB.iterator;

    while (itA.moveNext() && itB.moveNext()) {
      final String tokenA = itA.current.group(0)!;
      final String tokenB = itB.current.group(0)!;

      final int? numA = int.tryParse(tokenA);
      final int? numB = int.tryParse(tokenB);

      if (numA != null && numB != null) {
        final int numCompare = numA.compareTo(numB);
        if (numCompare != 0) return numCompare;
      } else {
        final int strCompare = tokenA.toLowerCase().compareTo(tokenB.toLowerCase());
        if (strCompare != 0) return strCompare;
      }
    }

    return fileNameA.length.compareTo(fileNameB.length);
  }
}