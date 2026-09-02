import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:kaleydo/app/modules/media_player/controllers/media_player_controller.dart';
import 'player_dialog_helper.dart';
import 'go_back_menu_item.dart';


/// Muestra un menú emergente con las pistas de subtítulos disponibles para el reproductor de medios.
void showSubtitlesMenu(BuildContext context, MediaPlayerController controller) {

  final position = PlayerDialogHelper.getButtonPosition(context);

  showMenu(
    context: context,
    position: position,
    color: AppColors.cardBackground.withValues(alpha: 0.80),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(16),
      side: BorderSide(color: AppColors.cardBorder.withValues(alpha: 0.80)),
    ),
    items: [

      //: Encabezado
      goBackMenuItem(
        context: context,
        controller: controller, 
        title: 'SUBTÍTULOS'
      ),



      //: Desactivados
      // Opción para desactivar los subtítulos
      PopupMenuItem(
        onTap: () => controller.setSubtitleTrack(SubtitleTrack.no()),
        child: Obx(() {
          final isSubActive = controller.currentSubtitle.value != SubtitleTrack.no();
          return Row(
            children: [
              Icon(Icons.check, color: !isSubActive ? AppColors.primaryAccent : Colors.transparent),
              const SizedBox(width: 8),
              const Text('Desactivados', style: TextStyle(color: Colors.white, fontSize: 13)),
            ],
          );
        }),
      ),



      //: Subtítulos
      // Muestra las pistas de subtítulos disponibles para seleccionar
      ...controller.availableSubtitles.where((t) => t != SubtitleTrack.no()).map((track) {
        return PopupMenuItem(
          onTap: () => controller.setSubtitleTrack(track),
          child: Obx(() {
            final isSelected = controller.currentSubtitle.value == track;
            final label = track.title ?? track.language ?? track.id;
            return Row(
              children: [
                
                Icon(Icons.check, 
                  color: isSelected 
                    ? AppColors.primaryAccent 
                    : Colors.transparent
                ),
                const SizedBox(width: 8),
                
                // Texto
                Expanded(
                  child: Text(
                    label.toUpperCase(), 
                    style: const TextStyle(color: Colors.white, fontSize: 13),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),              
              ],
            );
          }),
        );
      }),
    ],
  );
}