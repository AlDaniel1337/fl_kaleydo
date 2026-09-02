import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/modules/media_player/controllers/media_player_controller.dart';



/// Widget que muestra el texto OSD (On-Screen Display) en el centro de la pantalla.
class PlayerOsd extends GetView<MediaPlayerController> {
  
  const PlayerOsd({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {

      if (controller.osdText.value.isEmpty) return const SizedBox.shrink();

      return Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.10),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text(
            controller.osdText.value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      );
    });
  }
}