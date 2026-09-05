// lib/app/modules/reader/views/reader_view.dart

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:kaleydo/app/modules/reader/controllers/reader_controller.dart';

class ReaderView extends GetView<ReaderController> {
  const ReaderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Obx(() {
        if (controller.isLoading.value) {
          return const Center(
            child: CircularProgressIndicator(color: AppColors.primaryAccent),
          );
        }

        if (controller.imagePaths.isEmpty) {
          return Scaffold(
            appBar: AppBar(backgroundColor: Colors.transparent),
            body: const Center(
              child: Text(
                'No se encontraron imágenes en la carpeta del capítulo.',
                style: TextStyle(color: Colors.white54),
              ),
            ),
          );
        }

        return GestureDetector(
          onTap: controller.toggleControls,
          child: Stack(
            children: [
              // 1. ÁREA DE LECTURA (Scroll continuo vs Página a Página)
              Positioned.fill(
                child: controller.readingMode.value == ReadingMode.scroll
                    ? _buildScrollView()
                    : _buildPageView(),
              ),

              // 2. HEADER SUPERIOR FLOTANTE
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: controller.isControlsVisible.value ? 1.0 : 0.0,
                  child: IgnorePointer(
                    ignoring: !controller.isControlsVisible.value,
                    child: _buildHeader(context),
                  ),
                ),
              ),

              // 3. FOOTER INFERIOR FLOTANTE
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 200),
                  opacity: controller.isControlsVisible.value ? 1.0 : 0.0,
                  child: IgnorePointer(
                    ignoring: !controller.isControlsVisible.value,
                    child: _buildFooter(),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }

  // Modos de Lectura
  Widget _buildScrollView() {
    return ListView.builder(
      controller: controller.scrollController,
      padding: const EdgeInsets.symmetric(vertical: 60),
      itemCount: controller.imagePaths.length,
      itemBuilder: (context, index) {
        return Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 900), // Ancho máximo cómodo para PC
            child: Image.file(
              File(controller.imagePaths[index]),
              fit: BoxFit.fitWidth,
              filterQuality: FilterQuality.high,
            ),
          ),
        );
      },
    );
  }

  Widget _buildPageView() {
    return PageView.builder(
      controller: controller.pageController,
      onPageChanged: controller.onPageChanged,
      itemCount: controller.imagePaths.length,
      itemBuilder: (context, index) {
        return InteractiveViewer(
          minScale: 1.0,
          maxScale: 3.0,
          child: Center(
            child: Image.file(
              File(controller.imagePaths[index]),
              fit: BoxFit.contain,
              filterQuality: FilterQuality.high,
            ),
          ),
        );
      },
    );
  }

  // Componente Header
  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.black87, Colors.transparent],
        ),
      ),
      child: Row(
        children: [
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: () => Get.back(),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              controller.currentChapter.title,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          
          // Selector de Modo (Capsula Scroll / Página)
          Container(
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: AppColors.cardBackground.withOpacity(0.8),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.cardBorder),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildModeChip(
                  label: 'Scroll',
                  icon: Icons.unfold_more_rounded,
                  isSelected: controller.readingMode.value == ReadingMode.scroll,
                  onTap: () => controller.toggleReadingMode(ReadingMode.scroll),
                ),
                _buildModeChip(
                  label: 'Página',
                  icon: Icons.menu_book_rounded,
                  isSelected: controller.readingMode.value == ReadingMode.page,
                  onTap: () => controller.toggleReadingMode(ReadingMode.page),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModeChip({
    required String label,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.primaryAccent : Colors.transparent,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Icon(icon, size: 14, color: isSelected ? Colors.white : Colors.white54),
            const SizedBox(width: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.white54,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Componente Footer
  Widget _buildFooter() {
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
          // Cap. Anterior
          TextButton.icon(
            onPressed: hasPrevious ? controller.goToPreviousChapter : null,
            icon: Icon(
              Icons.chevron_left,
              color: hasPrevious ? Colors.white : Colors.white24,
            ),
            label: Text(
              'Cap. anterior',
              style: TextStyle(
                color: hasPrevious ? Colors.white : Colors.white24,
              ),
            ),
          ),

          // Indicador de Avance (ej. 1 / 37)
          Obx(() => Text(
                '${controller.currentPage.value} / ${controller.imagePaths.length}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              )),

          // Cap. Siguiente
          TextButton.icon(
            onPressed: hasNext ? controller.goToNextChapter : null,
            label: Text(
              'Cap. siguiente',
              style: TextStyle(
                color: hasNext ? Colors.white : Colors.white24,
              ),
            ),
            icon: Icon(
              Icons.chevron_right,
              color: hasNext ? Colors.white : Colors.white24,
            ),
          ),
        ],
      ),
    );
  }
}