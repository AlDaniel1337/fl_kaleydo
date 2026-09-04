import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'package:kaleydo/app/modules/media_player/controllers/media_player_controller.dart';

/// Widget que muestra el texto OSD (On-Screen Display) animado en el centro de la pantalla.
class PlayerOsd extends GetView<MediaPlayerController> {
  const PlayerOsd({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final osdText = controller.osdText.value;
      final isVisible = osdText.isNotEmpty;

      return IgnorePointer(
        child: Center(
          child: AnimatedOpacity(
            duration: const Duration(milliseconds: 200),
            curve: Curves.easeOut,
            opacity: isVisible ? 1.0 : 0.0,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.65),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: Colors.white.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: Text(
                osdText,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  shadows: [
                    Shadow(
                      offset: Offset(0, 1),
                      blurRadius: 4.0,
                      color: Colors.black87,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );
    });
  }
}