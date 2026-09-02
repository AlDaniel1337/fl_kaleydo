import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/modules/media_player/controllers/media_player_controller.dart';
import 'package:kaleydo/app/shared/shared_widgets.index.dart';


/// Widget que muestra los controles de encabezado del reproductor, incluyendo el botón de retroceso, los presets de velocidad y el control rápido de brillo.
class PlayerHeaderControls extends GetView<MediaPlayerController> {
  const PlayerHeaderControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [

          //: Botón de retroceso (Back)
          GoBackBtn(onPressed: controller.exitPlayer),
          const Spacer(),

          //: Presets de Velocidad (x1, x2, x3)
          Obx(() => Row(
            children: [1.0, 2.0, 3.0].map((speed) {
              
              final isSelected = controller.playbackSpeed.value == speed;

              return TextButtonWithColoredContainer(
                isSelected: isSelected,
                text: '${speed.toInt()}x',
                onTap: () => controller.setSpeed(speed),
              );

            }).toList(),
          )),
              
          const SizedBox(width: 24),
        ],
      ),
    );
  }
}