import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:kaleydo/app/modules/media_player/controllers/media_player_controller.dart';

/// Barra de progreso del reproductor que muestra y permite ajustar la posición actual del medio en reproducción.
class PlayerProgressBar extends GetView<MediaPlayerController> {
  const PlayerProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return SliderTheme(
        data: SliderThemeData(
          trackHeight: 3,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
          activeTrackColor: AppColors.primaryAccent,
          inactiveTrackColor: Colors.white24,
          thumbColor: AppColors.primaryAccent,
          overlayColor: AppColors.primaryAccent.withValues(alpha: 0.2),
        ),
        child: Slider(
          min: 0.0,
          max: controller.getMediaMaxDuration,
          value: controller.getPositionInMilliseconds.clamp(0.0, controller.getMediaMaxDuration),
          onChanged: (val) {
            controller.seekTo(Duration(milliseconds: val.toInt()));
          },
        ),
      );
    });
  }
}