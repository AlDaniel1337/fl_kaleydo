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
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          
          //: Modo de lectura: Scroll & Página
          Obx(() {
            if (controller.isTooSmallValue) return const SizedBox.shrink();
            
            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                ModeChip(
                  label: 'Scroll',
                  icon: Icons.unfold_more_rounded,
                  isSelected: controller.readingMode.value == ReadingMode.scroll,
                  onTap: () => controller.toggleReadingMode(ReadingMode.scroll),
                ),
                ModeChip(
                  label: 'Página',
                  icon: Icons.menu_book_rounded,
                  isSelected: controller.readingMode.value == ReadingMode.page,
                  onTap: () => controller.toggleReadingMode(ReadingMode.page),
                ),
              ],
            );
          }),

          //+ Cambio de ancho de la ventana con botones, menú y etiqueta reactiva
          Stack(
            alignment: Alignment.center,
            children: [

              //: Botones de cambio de ancho de la ventana y menú desplegable
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => controller.changeWindowWidth(false),
                    icon: const Icon(Icons.arrow_left_rounded, color: Colors.white),
                  ),
                  CustomPopupMenu(controller: controller),
                  IconButton(
                    onPressed: () => controller.changeWindowWidth(true),
                    icon: const Icon(Icons.arrow_right_rounded, color: Colors.white),
                  ),
                ],
              ),

              //: Texto que muestra el ancho actual de la ventana
              Positioned(
                bottom: 0,
                child: Obx(
                  () => Text(
                    controller.currentWindowWidth.toString(),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 8,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
      //!+

    );
  }
}