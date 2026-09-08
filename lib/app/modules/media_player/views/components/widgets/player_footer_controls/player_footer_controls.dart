import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/modules/media_player/views/components/components.index.dart';
import 'package:kaleydo/app/modules/media_player/views/components/widgets/player_footer_controls/components/media_duration_badge.dart';
import 'package:kaleydo/app/modules/media_player/views/components/widgets/player_footer_controls/components/multi_layer_volume_slider.dart';
import 'package:kaleydo/app/modules/media_player/views/components/widgets/player_footer_controls/components/player_progress_bar.dart';
import 'package:kaleydo/app/shared/widgets/custom_slider/hover_custom_slider.dart';
import 'package:media_kit/media_kit.dart';

import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:kaleydo/app/modules/media_player/controllers/media_player_controller.dart';
import 'package:kaleydo/app/shared/shared_widgets.index.dart';


class PlayerFooterControls extends GetView<MediaPlayerController> {
  const PlayerFooterControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          //: Barra de progreso del reproductor
          const PlayerProgressBar(),
          const SizedBox(height: 16),

          Row(
            children: [
              //: Reproducción
              Obx(() => IconButton(
                    icon: Icon(
                      controller.isPlaying.value
                          ? Icons.pause_rounded
                          : Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: 26,
                    ),
                    onPressed: controller.togglePlayPause,
                  )),

              //: Salto de Tiempo (-10s / +10s)
              IconButton(
                icon: const Icon(Icons.replay_10_rounded, color: Colors.white, size: 22),
                onPressed: () => controller.seekRelative(-10),
              ),
              IconButton(
                icon: const Icon(Icons.forward_10_rounded, color: Colors.white, size: 22),
                onPressed: () => controller.seekRelative(10),
              ),
              const SizedBox(width: 12),

              //: Controles de Audio
              const MultiLayerVolumeSlider(),
              const SizedBox(width: 12),
              
              //: Duración del Video
              const MediaDurationBadge(),
              const SizedBox(width: 12),

              //: Control de Velocidad
              Obx(() => Row(
                children: [
                  HoverCustomSlider(
                    icon: Icons.speed,
                    mainColor: AppColors.primaryAccent,
                    sliderValue: controller.playbackSpeed.value,
                    onChanged: controller.setSpeed,
                    min: 0.1,
                    max: 4.0,
                    divisions: 39,
                    expandedWidth: 200,
                    label: '${controller.playbackSpeed.value.toStringAsFixed(1)}x',
                  ),
                  Text(
                    '${controller.playbackSpeed.value.toStringAsFixed(1)}x',
                    style: const TextStyle(color: Colors.white, fontSize: 12),
                  ),
                ],
              )),
              const Spacer(),

              //: Subtítulos
              Obx(() {
                final isSubActive = controller.currentSubtitle.value != SubtitleTrack.no();
                return QuickAndLongPressIconButton(
                  activeColor: AppColors.primaryAccent,
                  longPressDuration: const Duration(milliseconds: 200),
                  isActive: isSubActive,
                  onTap: controller.toggleSubtitles,
                  onLongPress: () => showSubtitlesMenu(context, controller),
                  icon: Icons.subtitles_rounded,
                );
              }),

              //: Ajustes
              IconButton(
                icon: const Icon(Icons.settings_rounded, color: Colors.white, size: 22),
                tooltip: 'Ajustes',
                onPressed: () => showSettingsMenu(context, controller),
              ),

              //: Pantalla Completa
              Obx(() => FullScreenButton(
                isFullScreen: controller.isFullScreen.value,
                toggleFullScreen: controller.toggleFullScreen,
              )),
            ],
          ),
        ],
      ),
    );
  }
}