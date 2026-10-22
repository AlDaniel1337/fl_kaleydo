import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/modules/courses/presentation/controllers/course_player_controller.dart';
import 'package:kaleydo/app/modules/courses/presentation/views/course_player_view/widgets/volume_icon_and_text.dart';


/// Widget que muestra un indicador de volumen flotante tipo TV.
class VolumeIndicator extends StatelessWidget {
  const VolumeIndicator({
    super.key,
    required this.controller,
  });

  final CoursePlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      if (!controller.video.showVolumeIndicator.value) return const SizedBox.shrink();
      
      // Cambiamos el color si supera el 100% para indicar "Boost"
      final bool isBoosted = controller.video.currentVolume.value > 100.0;
      
      return Positioned(
        top: 20,
        right: 20,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.black.withValues(alpha: 0.7),
            borderRadius: BorderRadius.circular(8),
            border: isBoosted 
              ? Border.all(color: Colors.orange, width: 1.5) 
              : null,
          ),
          child: VolumeIconAndText(
            isBoosted: isBoosted,
            isMuted: controller.video.currentVolume.value == 0,
            currentVolume: controller.video.currentVolume.value,
          ),
        ),
      );
    });
  }
}
