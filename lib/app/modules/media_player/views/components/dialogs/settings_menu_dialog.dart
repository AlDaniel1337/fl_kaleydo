import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:kaleydo/app/modules/media_player/controllers/media_player_controller.dart';
import 'package:kaleydo/app/shared/shared_widgets.index.dart';
import 'package:media_kit/media_kit.dart';
import 'player_dialog_helper.dart';
import 'speed_menu_dialog.dart';
import 'audio_tracks_menu_dialog.dart';
import 'subtitles_menu_dialog.dart';
import 'improvements_menu_dialog.dart';


/// Muestra un menú emergente con las opciones de configuración del reproductor de medios.
void showSettingsMenu(BuildContext context, MediaPlayerController controller) {
  
  final position = PlayerDialogHelper.getButtonPosition(context);

  showMenu(
    context: context,
    position: position,
    color: AppColors.cardBackground.withValues(alpha: 0.80),
    elevation: 8,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.only(
        topLeft: Radius.circular(16),
        topRight: Radius.circular(16),
        bottomLeft: Radius.circular(16),
      ),
      side: BorderSide(color: AppColors.cardBorder.withValues(alpha: 0.80)),
    ),
    items: [

      //: Brillo
      PopupMenuItem(
        enabled: false,
        child: Row(
          children: [
            const Icon(Icons.brightness_6_rounded, color: Colors.white),
            const SizedBox(width: 8),
            const Text('Brillo', style: TextStyle(color: Colors.white, fontSize: 14)),
            const Spacer(),
            SizedBox(
              width: 100,
              child: Obx(() => Slider(
                value: controller.brightness.value,
                min: 0.1,
                max: 1.0,
                activeColor: AppColors.primaryAccent,
                onChanged: controller.setBrightness,
              )),
            ),
          ],
        ),
      ),



      //: Mejoras
      PopupMenuItem(
        onTap: () => Future.microtask(() {
          if (context.mounted) {
            showImprovementsMenu(context, controller);
          }
        }),
        child: SettingsTile(
          icon: Icons.tune_rounded,
          title: 'Mejoras',
        ),
      ),



      //: Velocidad de reproducción
      PopupMenuItem(
        onTap: () => Future.microtask(() {
          if (context.mounted) {
            showSpeedSubMenu(context, controller);
          }
        }),
        child: SettingsTile(
          icon: Icons.speed_rounded,
          title: 'Velocidad',
          trailing: Obx(() => Text(
            '${controller.playbackSpeed.value.toStringAsFixed(2)}x',
            style: const TextStyle(color: AppColors.textSecondary, fontSize: 13),
          )),
        ),
      ),



      //: Pistas de audio
      PopupMenuItem(
        onTap: () => Future.microtask(() {
          if (context.mounted) {
            showAudioTracksMenu(context, controller);
          }
        }),
        child: SettingsTile(
          icon: Icons.audiotrack_rounded,
          title: 'Audio',
          trailing: Obx(() => Text(
            controller.currentAudioTrack.value.title 
              ?? controller.currentAudioTrack.value.language 
              ?? "Predeterminado",
            textAlign: TextAlign.end,
            style: const TextStyle(
              color: AppColors.textSecondary, 
              fontSize: 13,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          )),
        ),
      ),



      //: Subtítulos
      PopupMenuItem(
        onTap: () => Future.microtask(() {
          if (context.mounted) {
            showSubtitlesMenu(context, controller);
          }
        }),
        child: SettingsTile(
          icon: Icons.subtitles_rounded,
          title: 'Subtítulos',
          trailing: Obx(() {
            final isSub = controller.currentSubtitle.value != SubtitleTrack.no();
            return Text( isSub
                ? controller.currentSubtitle.value.title 
                  ?? controller.currentSubtitle.value.language 
                  ?? "On"
                : 'Off',
              textAlign: TextAlign.end,
              style: const TextStyle(
                color: AppColors.textSecondary, 
                fontSize: 13
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            );
          }),
        ),
      ),
    ],
  );
}