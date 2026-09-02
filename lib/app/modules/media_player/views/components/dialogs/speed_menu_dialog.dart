import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:kaleydo/app/modules/media_player/controllers/media_player_controller.dart';
import 'package:kaleydo/app/modules/media_player/views/components/dialogs/go_back_menu_item.dart';
import 'player_dialog_helper.dart';

/// Muestra un submenú emergente con las opciones de velocidad de reproducción del reproductor de medios.
void showSpeedSubMenu(BuildContext context, MediaPlayerController controller) {

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
        title: 'VELOCIDAD'
      ),

      PopupMenuItem(
        enabled: false,
        child: SizedBox(
          width: 260,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [             

              //: Velocidad actual
              // Muestra la velocidad de reproducción actual
              Obx(() => Text(
                '${controller.playbackSpeed.value.toStringAsFixed(2)}x',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
              )),
              SizedBox(height: 16),      



              //: Velocidades
              // Opciones de velocidad rápidas
              Obx(() => Wrap(
                spacing: 4,
                children: [1.0, 1.25, 1.5, 1.75].map((speed) {
                  final isSelected = (controller.playbackSpeed.value - speed).abs() < 0.01;
                  return ChoiceChip(
                    label: Text('$speed'),
                    selected: isSelected,
                    selectedColor: AppColors.primaryAccent,
                    onSelected: (_) => controller.setSpeed(speed),
                  );
                }).toList(),
              )),

              SizedBox(height: 60),

            ],
          ),
        ),
      ),

    ],
  );
}