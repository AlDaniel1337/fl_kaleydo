// lib/app/modules/reader/views/widgets/reader_header.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:kaleydo/app/modules/reader/controllers/reader_controller.dart';

import 'chapter_grid_dialog/chapter_grid_dialog.dart';

class ReaderHeader extends StatelessWidget {
  
  final ReaderController controller;

  const ReaderHeader({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
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

          //: Botón de retroceso
          IconButton(
            icon: const Icon(Icons.arrow_back, color: Colors.white),
            onPressed: controller.exitReader,
          ),
          const SizedBox(width: 8),
          
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [

                //: Título del capítulo
                Text(
                  controller.currentChapter.title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),

                //: Nombre del archivo actual
                Obx(
                  () => Text(
                    controller.currentFileName,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: 11,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),

              ],
            ),
          ),

          //: Cuadrícula y botón de ir al comienzo
          IconButton(
            icon: const Icon(Icons.grid_view_rounded, color: Colors.white),
            tooltip: 'Vista de cuadrícula',
            onPressed: () => ChapterGridDialog.show(context, controller),
          ),

          //: Botón de ir al comienzo
          IconButton(
            icon: const Icon(
              Icons.upgrade_rounded, 
              color: Colors.white
            ),
            tooltip: 'Ir al comienzo',
            onPressed: controller.scrollToTop,
          ),

          _buildModeSelector(),
        ],
      ),
    );
  }

  Widget _buildModeSelector() {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withOpacity(0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Obx(
        () => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            //: Modo de lectura: Scroll
            _ModeChip(
              label: 'Scroll',
              icon: Icons.unfold_more_rounded,
              isSelected: controller.readingMode.value == ReadingMode.scroll,
              onTap: () => controller.toggleReadingMode(ReadingMode.scroll),
            ),

            //: Modo de lectura: Página
            _ModeChip(
              label: 'Página',
              icon: Icons.menu_book_rounded,
              isSelected: controller.readingMode.value == ReadingMode.page,
              onTap: () => controller.toggleReadingMode(ReadingMode.page),
            ),

            //: Menu desplegable para cambiar el ancho de la ventana
            PopupMenuButton<double>(
              icon: const Icon(Icons.aspect_ratio_rounded, color: Colors.white),
              tooltip: 'Ancho de la ventana',
              color: AppColors.cardBackground,
              onSelected: controller.setWindowWidth,
              itemBuilder: (context) => controller.windowWidthOptions.entries.map((entry) {
                final isSelected = controller.currentWindowWidth.value == entry.key;
                return PopupMenuItem<double>(
                  value: entry.key,
                  child: Row(
                    children: [
                      Icon(
                        Icons.check,
                        color: isSelected ? AppColors.primaryAccent : Colors.transparent,
                        size: 18,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        entry.value,
                        style: TextStyle(
                          color: isSelected ? AppColors.primaryAccent : Colors.white,
                          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),

            //: Botón de recarga del capítulo
            IconButton(
              icon: const Icon(Icons.refresh_rounded, color: Colors.white),
              tooltip: 'Recargar capítulo',
              onPressed: controller.reloadChapter,
            ),
          ],
        ),
      ),
    );
  }
}

class _ModeChip extends StatelessWidget {
  final String label;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeChip({
    required this.label,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
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
}