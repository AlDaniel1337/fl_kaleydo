import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/modules/reader/presentation/controllers/reader_controller.dart';
import 'package:kaleydo/app/modules/reader/presentation/views/widgets/reader_footer/components/expanded_view_controls.dart';
import 'package:kaleydo/app/modules/reader/presentation/views/widgets/reader_footer/components/compact_view_controls.dart';

/// Footer del lector que muestra información y controles de navegación.
class ReaderFooter extends StatelessWidget {
  final ReaderController controller;

  const ReaderFooter({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.bottomCenter,
          end: Alignment.topCenter,
          colors: [Colors.black87, Colors.transparent],
        ),
      ),
      child: Obx(() {

        final hasPrevious = controller.currentChapterIndex - 1 >= 0;
        final hasNext = controller.currentChapterIndex + 1 < controller.chapterList.length;

        //: Vista compacta (Pantalla pequeña)
        if (controller.isTooSmallValue) {
          return CompactViewControls(
            onPreviousChapter: hasPrevious 
              ? controller.goToPreviousChapter 
              : null,
            onNextChapter: hasNext 
              ? controller.goToNextChapter 
              : null,
            currentPageIndicator: '${controller.currentPage.value} / ${controller.imagePaths.length}',
            onScrollToTop: controller.scrollToTop,
          );
        }

        //: Vista extendida (Pantalla normal/grande)
        return ExpandedViewControls(
          onPreviousChapter: hasPrevious 
            ? controller.goToPreviousChapter 
            : null,
          onNextChapter: hasNext 
            ? controller.goToNextChapter 
            : null,
          currentPageIndicator: '${controller.currentPage.value} / ${controller.imagePaths.length}',
          onScrollToTop: controller.scrollToTop,
        );
          
      }),
    );
  }
}