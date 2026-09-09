// lib/app/modules/reader/views/widgets/reader_page_view/mixins/single_page_management_mixin.dart

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:kaleydo/app/modules/reader/views/widgets/reader_page_view/reader_page_view.dart';

/// Mixin para encapsular la gestión de foco, controles de teclado y mouse
/// para la navegación página a página en visores de lectura.
mixin SinglePageManagementMixin on State<ReaderPageView> {
  
  //+ VARIABLES
  final FocusNode focusNode = FocusNode();
  //!+

  //+ CICLO DE VIDA
  @override
  void dispose() {
    focusNode.dispose();
    super.dispose();
  }
  //!+

  //+ NAVEGACIÓN Y EVENTOS
  /// Navega a la siguiente página si no es la última.
  void nextPage() {
    final pageController = widget.controller.pageController;
    if (pageController.hasClients) {
      final currentPage = pageController.page?.round() ?? 0;
      if (currentPage < widget.controller.imagePaths.length - 1) {
        pageController.nextPage(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  /// Navega a la página anterior si no es la primera.
  void previousPage() {
    final pageController = widget.controller.pageController;
    if (pageController.hasClients) {
      final currentPage = pageController.page?.round() ?? 0;
      if (currentPage > 0) {
        pageController.previousPage(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeInOut,
        );
      }
    }
  }

  /// Maneja eventos de teclado para la navegación de páginas (Flecha Izquierda / Derecha).
  KeyEventResult handleKeyEvent(FocusNode node, KeyEvent event) {
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        nextPage();
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        previousPage();
        return KeyEventResult.handled;
      }
    }
    return KeyEventResult.ignored;
  }

  /// Maneja eventos de puntero para la navegación con botones laterales del mouse.
  void handlePointerDown(PointerDownEvent event) {
    if (!focusNode.hasFocus) {
      focusNode.requestFocus();
    }

    if (event.buttons == kBackMouseButton) {
      previousPage();
    } else if (event.buttons == kForwardMouseButton) {
      nextPage();
    }
  }
  //!+
}