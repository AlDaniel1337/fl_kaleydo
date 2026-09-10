// lib/app/modules/reader/views/widgets/reader_header.dart

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:kaleydo/app/modules/reader/controllers/reader_controller.dart';
import 'package:kaleydo/app/modules/reader/views/widgets/reader_header/components/components.index.dart';
import '../chapter_grid_dialog/chapter_grid_dialog.dart';

/// Widget que representa el header del lector, mostrando el título del capítulo, nombre del archivo actual y controles de navegación.
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
          Obx(() {
            if (controller.isTooSmallValue) {
              return const SizedBox.shrink(); // Retorna un widget vacío si es pequeño
            }

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Vista de cuadrícula
                IconButton(
                  icon: const Icon(Icons.grid_view_rounded, color: Colors.white),
                  tooltip: 'Vista de cuadrícula',
                  onPressed: () => ChapterGridDialog.show(context, controller),
                ),

                // Botón de ir al comienzo
                IconButton(
                  icon: const Icon(
                    Icons.arrow_upward_rounded, 
                    color: Colors.white,
                  ),
                  tooltip: 'Ir al comienzo',
                  onPressed: controller.scrollToTop,
                ),
              ],
            );
          }),

          //: Menú principal del lector
          HeaderMainMenu(controller: controller)
          
        ],
      ),
    );
  }

}
