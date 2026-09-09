// lib/app/modules/reader/views/widgets/reader_page_view.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:kaleydo/app/modules/reader/controllers/mixins/single_page_management_mixin.dart';
import 'package:kaleydo/app/modules/reader/controllers/reader_controller.dart';

/// Visor paginado para la lectura de cómics/mangas integrando la lógica
/// de eventos e interacción desacoplada en `SinglePageManagementMixin`.
class ReaderPageView extends StatefulWidget {
  //+ VARIABLES
  final ReaderController controller;

  const ReaderPageView({
    super.key,
    required this.controller,
  });
  //!+

  @override
  State<ReaderPageView> createState() => _ReaderPageViewState();
}

class _ReaderPageViewState extends State<ReaderPageView> with SinglePageManagementMixin {

  //+ ESTRUCTURA UI
  @override
  Widget build(BuildContext context) {
    return Focus(
      focusNode: focusNode,
      autofocus: true,
      onKeyEvent: handleKeyEvent,
      child: Listener(
        behavior: HitTestBehavior.opaque,
        onPointerDown: handlePointerDown,
        child: PageView.builder(
          physics: const ClampingScrollPhysics(),
          controller: widget.controller.pageController,
          onPageChanged: widget.controller.onPageChanged,
          itemCount: widget.controller.imagePaths.length,
          itemBuilder: (context, index) {
            final imagePath = widget.controller.imagePaths[index];

            return InteractiveViewer(
              minScale: 1.0,
              maxScale: 3.0,
              child: Center(
                child: Image.file(
                  File(imagePath),
                  key: ValueKey(imagePath),
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.medium,
                  cacheWidth: 1920,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
  //!+
}