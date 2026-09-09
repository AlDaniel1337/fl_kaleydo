import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:screen_retriever/screen_retriever.dart';
import 'package:window_manager/window_manager.dart';
import 'package:kaleydo/app/data/data.models.index.dart';

mixin WindowManagementMixin on GetxController {
  
  //+ VARIABLES
  ReaderStorageService get storage;

  final Map<double, String> windowWidthOptions = [500,600,700,800,900].asMap().map((index, width) => MapEntry(width.toDouble(), '${width.toInt()} px'));

  final RxDouble currentWindowWidth = 1000.0.obs;
  Rect? _previousWindowBounds;
  //!+


  /// Inicializa la configuración de la ventana del lector, guardando los límites actuales y aplicando el ancho de ventana almacenado.
  void initWindowSettings() {
    _saveCurrentWindowBounds();
    currentWindowWidth.value = storage.readerWidth;
    _applyWindowSize(currentWindowWidth.value);
  }

  /// Restaura los límites de la ventana previamente guardados en plataformas de escritorio.
  Future<void> restoreWindowBounds() async {
    if (GetPlatform.isDesktop && _previousWindowBounds != null) {
      await windowManager.setBounds(_previousWindowBounds!);
    }
  }

  /// Establece el ancho de la ventana del lector y lo guarda en el almacenamiento local.
  Future<void> setWindowWidth(double width) async {
    currentWindowWidth.value = width;
    storage.setReaderWidth(width);
    await _applyWindowSize(width);
  }

  /// Aplica el tamaño de ventana especificado en plataformas de escritorio, centrando la ventana y limitando su ancho al área de trabajo disponible.
  Future<void> _applyWindowSize(double targetWidth) async {
    if (!GetPlatform.isDesktop) return;

    final Rect currentBounds = await windowManager.getBounds();

    // Obtenemos la pantalla principal como respaldo y la lista de pantallas
    final Display primaryDisplay = await screenRetriever.getPrimaryDisplay();
    final List<Display> displays = await screenRetriever.getAllDisplays();
    
    Display currentDisplay = primaryDisplay;

    // Identificamos en qué pantalla se encuentra el centro actual de la ventana
    for (final display in displays) {
      final Offset visiblePos = display.visiblePosition ?? Offset.zero;
      final Size size = display.size;
      
      final Rect screenRect = Rect.fromLTWH(
        visiblePos.dx,
        visiblePos.dy,
        size.width,
        size.height,
      );
      
      if (screenRect.contains(currentBounds.center)) {
        currentDisplay = display;
        break;
      }
    }

    final Size workArea = currentDisplay.visibleSize ?? currentDisplay.size;
    final Offset screenPosition = currentDisplay.visiblePosition ?? Offset.zero;

    final double validWidth = targetWidth.clamp(500.0, workArea.width);

    // Calculamos la nueva posición X centrada respecto a la posición actual de la ventana
    double newX = currentBounds.center.dx - (validWidth / 2);

    // Delimitadores basados en el área visible de la pantalla actual
    final double minX = screenPosition.dx;
    final double maxX = minX + workArea.width;

    // Evitamos que la ventana se desborde fuera de los límites de este monitor
    if (newX < minX) {
      newX = minX;
    } else if (newX + validWidth > maxX) {
      newX = maxX - validWidth;
    }

    await windowManager.setBounds(
      Rect.fromLTWH(
        newX,
        currentBounds.top, // Conserva la posición vertical exacta donde está
        validWidth,
        currentBounds.height, // Conserva la altura actual de la ventana
      ),
    );
  }

  /// Guarda los límites actuales de la ventana en plataformas de escritorio.
  Future<void> _saveCurrentWindowBounds() async {
    if (GetPlatform.isDesktop) {
      _previousWindowBounds = await windowManager.getBounds();
    }
  }

  /// Cambia el ancho de la ventana del lector en función del valor actual y las opciones disponibles.
  void changeWindowWidth(bool increase) {

    final currentIndex = windowWidthOptions.keys.toList().indexOf(currentWindowWidth.value);

    if (currentIndex == -1) return;

    if (currentIndex == 0 && !increase) return;
    if (currentIndex == windowWidthOptions.length - 1 && increase) return;

    final newIndex = increase ? currentIndex + 1 : currentIndex - 1;
    
    if (newIndex >= 0 && newIndex < windowWidthOptions.length) {
      setWindowWidth(windowWidthOptions.keys.toList()[newIndex]);
    }
  }
}