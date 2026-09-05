import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/data/services/local_storage_service/library_state_service.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';

/// Botones reutilizables para gestionar el estado de Favoritos y En Proceso de un elemento.
class MediaActionButtons extends StatelessWidget {
  final String itemPath;
  final double iconSize;
  final Color activeColor;
  final Color inactiveColor;

  const MediaActionButtons({
    super.key,
    required this.itemPath,
    this.iconSize = 24.0,
    this.activeColor = AppColors.primaryAccent, // Sustituir por AppColors.primaryAccent si está en scope
    this.inactiveColor = Colors.white54,
  });

  @override
  Widget build(BuildContext context) {
    final libraryState = Get.find<LibraryStateService>();

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Botón Favoritos
        Obx(() {
          final isFav = libraryState.isFavorite(itemPath);
          return IconButton(
            iconSize: iconSize,
            icon: Icon(
              isFav ? Icons.favorite_rounded : Icons.favorite_border_rounded,
              color: isFav ? activeColor : inactiveColor,
            ),
            onPressed: () => libraryState.toggleFavorite(itemPath),
          );
        }),

        // Botón En Proceso
        Obx(() {
          final inProc = libraryState.isInProcess(itemPath);
          return IconButton(
            iconSize: iconSize,
            icon: Icon(
              inProc ? Icons.play_circle_fill_rounded : Icons.play_circle_outline_rounded,
              color: inProc ? activeColor : inactiveColor,
            ),
            onPressed: () => libraryState.toggleInProcess(itemPath),
          );
        }),
      ],
    );
  }
}