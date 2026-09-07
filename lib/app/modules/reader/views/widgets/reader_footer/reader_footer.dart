import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/modules/reader/controllers/reader_controller.dart';
import 'package:kaleydo/app/shared/shared_widgets.index.dart';

/// Widget que representa el footer del lector, mostrando información y controles de navegación.
class ReaderFooter extends StatelessWidget {

  final ReaderController controller;

  const ReaderFooter({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    final hasPrevious = controller.currentChapterIndex - 1 >= 0;
    final hasNext = controller.currentChapterIndex + 1 < controller.chapterList.length;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black87, Colors.transparent],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [

          //: Botón de capítulo anterior
          CustomTextIconButton(
            label: 'Cap. anterior',
            icon: Icons.chevron_left,
            onPressed: hasPrevious ? controller.goToPreviousChapter : null,
            isEnabled: hasPrevious,
            iconPosition: IconPosition.left,
            enabledCursor: SystemMouseCursors.click,
            disabledCursor: SystemMouseCursors.forbidden,
          ),
          Spacer(),

          //: Indicador de página actual
          Obx(
            () => Text(
              '${controller.currentPage.value} / ${controller.imagePaths.length}',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ),
          SizedBox(width: 16),

          //: Botón de ir al comienzo
          IconButton(
            icon: const Icon(
              Icons.upgrade_rounded, 
              color: Colors.white
            ),
            tooltip: 'Ir al comienzo',
            onPressed: controller.scrollToTop,
          ),
          Spacer(),

          
          //: Botón de capítulo siguiente
          CustomTextIconButton(
            label: 'Cap. siguiente',
            icon: Icons.chevron_right,
            onPressed: hasNext ? controller.goToNextChapter : null,
            isEnabled: hasNext,
            enabledCursor: SystemMouseCursors.click,
            disabledCursor: SystemMouseCursors.forbidden,
          ),

        ],
      ),
    );
  }
}