import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:kaleydo/app/modules/reader/controllers/reader_controller.dart';
import 'mode_chip.dart';
import 'custom_popup_menu.dart';

class HeaderMainMenu extends StatelessWidget {
  
  const HeaderMainMenu({
    super.key,
    required this.controller,
  });

  final ReaderController controller;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AppColors.cardBorder),
      ),
      child: Obx(
        () => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            //: Modo de lectura: Scroll
            ModeChip(
              label: 'Scroll',
              icon: Icons.unfold_more_rounded,
              isSelected: controller.readingMode.value == ReadingMode.scroll,
              onTap: () => controller.toggleReadingMode(ReadingMode.scroll),
            ),
    
            //: Modo de lectura: Página
            ModeChip(
              label: 'Página',
              icon: Icons.menu_book_rounded,
              isSelected: controller.readingMode.value == ReadingMode.page,
              onTap: () => controller.toggleReadingMode(ReadingMode.page),
            ),
    
            //: Menu desplegable para cambiar el ancho de la ventana
            CustomPopupMenu(controller: controller),
    
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