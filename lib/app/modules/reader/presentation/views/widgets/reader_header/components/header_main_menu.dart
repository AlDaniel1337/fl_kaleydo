import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:kaleydo/app/modules/reader/presentation/controllers/reader_controller.dart';
import '../../../../../../../shared/widgets/buttons/chip_btn.dart';
import 'custom_popup_size_menu.dart';

/// Menú principal del header del lector que incluye:
/// - Selección del modo de lectura (Scroll o Página)
/// - Ajuste del ancho de la ventana del lector con botones y menú emergente
/// - Visualización del ancho actual de la ventana
class HeaderMainMenu extends StatelessWidget {
  const HeaderMainMenu({
    super.key,
    required this.controller,
  });

  final ReaderController controller;

  @override
  Widget build(BuildContext context) {

    final double colorAlpha = 0.4;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.cardBackground.withValues(alpha: colorAlpha),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          
          //: Modo de lectura
          // Scroll & Página
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

          Stack(
            alignment: Alignment.center,
            children: [

              //: Cambio de ancho de la ventana
              // Botones de cambio de ancho de la ventana y menú desplegable
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => controller.changeWindowWidth(false),
                    icon: const Icon(Icons.arrow_left_rounded, color: Colors.white),
                    tooltip: 'Disminuir ancho de la ventana',
                  ),
                  CustomPopupSizeMenu(controller: controller),
                  IconButton(
                    onPressed: () => controller.changeWindowWidth(true),
                    icon: const Icon(Icons.arrow_right_rounded, color: Colors.white),
                    tooltip: 'Aumentar ancho de la ventana',
                  ),
                ],
              ),

              //: Ancho actual de la ventana
              // Texto que muestra el ancho actual de la ventana
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

    );
  }
}