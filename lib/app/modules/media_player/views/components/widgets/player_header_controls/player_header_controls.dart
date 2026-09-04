import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:kaleydo/app/modules/media_player/controllers/media_player_controller.dart';
import 'package:kaleydo/app/shared/shared_widgets.index.dart';

/// Presets predeterminados para la velocidad de reproducción.
const List<double> _kSpeedPresets = [1.0, 2.0, 3.0];

/// Controles del encabezado del reproductor: botón de retroceso y presets de velocidad.
class PlayerHeaderControls extends GetView<MediaPlayerController> {
  const PlayerHeaderControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Botón de retroceso
          GoBackBtn(onPressed: controller.exitPlayer),

          const Spacer(),

          //: Presets de velocidad
          Obx(() {
            final currentSpeed = controller.playbackSpeed.value;

            return Row(
              mainAxisSize: MainAxisSize.min,
              children: _kSpeedPresets.map((speed) {
                final isSelected = (currentSpeed - speed).abs() < 0.05;
                final speedLabel = speed % 1 == 0 
                    ? '${speed.toInt()}x' 
                    : '${speed.toStringAsFixed(1)}x';

                return Padding(
                  padding: const EdgeInsets.only(left: 6.0),
                  child: TextButtonWithColoredContainer(
                    isSelected: isSelected,
                    text: speedLabel,
                    onTap: () => controller.setSpeed(speed),
                  ),
                );
              }).toList(),
            );
          }),
        ],
      ),
    );
  }
}