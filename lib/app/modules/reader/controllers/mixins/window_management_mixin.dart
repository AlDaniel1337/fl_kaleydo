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

    final Display primaryDisplay = await screenRetriever.getPrimaryDisplay();
    final Size workArea = primaryDisplay.visibleSize ?? primaryDisplay.size;

    final double validWidth = targetWidth.clamp(500.0, workArea.width);
    final double centerX = (workArea.width - validWidth) / 2;

    await windowManager.setBounds(
      Rect.fromLTWH(centerX, 0, validWidth, workArea.height),
    );
  }

  /// Guarda los límites actuales de la ventana en plataformas de escritorio.
  Future<void> _saveCurrentWindowBounds() async {
    if (GetPlatform.isDesktop) {
      _previousWindowBounds = await windowManager.getBounds();
    }
  }
}