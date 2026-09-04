import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:kaleydo/app/modules/media_player/controllers/media_player_controller.dart';
import 'package:kaleydo/app/modules/media_player/views/components/dialogs/go_back_menu_item.dart';
import 'package:kaleydo/app/shared/shared_widgets.index.dart';
import 'player_dialog_helper.dart';

/// Muestra un menú emergente con las opciones de mejoras disponibles para el reproductor de medios.
void showImprovementsMenu(BuildContext context, MediaPlayerController controller) {

  final position = PlayerDialogHelper.getButtonPosition(context, verticalOffset: 150);

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
        title: 'MEJORAS'
      ),


      //: Boost de Volumen
      PopupMenuItem(
        enabled: false,
        child: SettingsTile(
          icon: Icons.volume_up_rounded,
          title: 'Boost de Volumen',
          trailing: Obx(() => _buildStatusChip(
            value: controller.isVolumeBoostEnabled.value,
            onTap: () => controller.toggleVolumeBoost(),
          )),
          showArrow: false,
        ),
      ),


      //: Mejora de imagen
      PopupMenuItem(
        enabled: false,
        child: SettingsTile(
          icon: Icons.image_rounded,
          title: 'Mejora de imagen',
          trailing: Obx(() => _buildStatusChip(
            value: controller.isHdEnhancerEnabled.value,
            onTap: () => controller.toggleHdEnhancer(),
          )),
          showArrow: false,
        ),
      ),


      //: Mejora de reproducción
      PopupMenuItem(
        enabled: false,
        child: SettingsTile(
          icon: Icons.flash_on_rounded,
          title: 'Mejora de reproducción',
          trailing: Obx(() => _buildStatusChip(
            value: controller.isFastSeekingEnabled.value,
            onTap: () => controller.toggleFastSeeking(),
          )),
          showArrow: false,
        ),
      ),

    ],
  );
}



/// Sub-widget auxiliar Chip
Widget _buildStatusChip({required bool value, required VoidCallback onTap}) {
  return InkWell(
    onTap: onTap,
    borderRadius: BorderRadius.circular(20),
    child: AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: value 
            ? AppColors.primaryAccent.withValues(alpha: 0.25)
            : Colors.white.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: value 
              ? AppColors.primaryAccent 
              : Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Text(
        value ? 'ON' : 'OFF',
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.bold,
          color: value ? AppColors.primaryAccent : Colors.white54,
        ),
      ),
    ),
  );
}