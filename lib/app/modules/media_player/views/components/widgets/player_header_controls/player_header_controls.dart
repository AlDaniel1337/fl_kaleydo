import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:kaleydo/app/modules/media_player/controllers/media_player_controller.dart';
import 'package:kaleydo/app/shared/shared_widgets.index.dart';

/// Controles del encabezado del reproductor: botón de retroceso y presets de velocidad.
class PlayerHeaderControls extends GetView<MediaPlayerController> {

  final String videoTitle;
  
  const PlayerHeaderControls({super.key, required this.videoTitle});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Row(
        children: [
          // Botón de retroceso
          GoBackBtn(onPressed: controller.exitPlayer),
          const SizedBox(width: 16), 

          Text(
            videoTitle,
            style: Theme.of(context).textTheme.bodyMedium,
          ),    
        ],
      ),
    );
  }
}