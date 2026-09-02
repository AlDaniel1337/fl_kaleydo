import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:kaleydo/app/modules/media_player/controllers/media_player_controller.dart';
import 'package:kaleydo/app/modules/media_player/views/components/dialogs/go_back_menu_item.dart';
import 'player_dialog_helper.dart';

/// Muestra un menú emergente con las pistas de audio disponibles para el reproductor de medios.
void showAudioTracksMenu(BuildContext context, MediaPlayerController controller) {

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
        title: 'AUDIO'
      ),
      
      ...controller.availableAudioTracks.map((track) {

        return PopupMenuItem(
          onTap: () => controller.setAudioTrack(track),
          child: Obx(() {
            final isSelected = controller.currentAudioTrack.value == track;
            final label = track.title ?? track.language ?? track.id;

            return Row(
              children: [
                //: Icono
                Icon(
                  Icons.check, 
                  color: isSelected 
                    ? AppColors.primaryAccent 
                    : Colors.transparent,
                ),
                const SizedBox(width: 8),
                
                //: Texto
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