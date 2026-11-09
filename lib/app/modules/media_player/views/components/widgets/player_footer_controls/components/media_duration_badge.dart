import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/modules/media_player/controllers/media_player_controller.dart';
import 'package:kaleydo/app/modules/media_player/utils/duration_formatter.dart';

/// Muestra la duración actual y total del medio en reproducción.
class MediaDurationBadge extends GetView<MediaPlayerController> {

  final bool shouldHide;
  final double whiteOpacity;

  const MediaDurationBadge({
    super.key, 
    this.shouldHide = false,
    this.whiteOpacity = 0.12
  });

  @override
  Widget build(BuildContext context) {

    return Obx(() {
      
      final isPlaying = controller.isPlaying.value;
      final isImmerseMode = controller.isImmerseModeEnabled.value;

      if (shouldHide && (!isImmerseMode || !isPlaying )) {
        return const SizedBox.shrink();
      }

      final current = DurationFormatter.format(controller.position.value);
      final total = DurationFormatter.format(controller.duration.value);
        
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color:Colors.black.withValues(alpha: whiteOpacity),
          borderRadius: BorderRadius.circular(12),
        ),

        child: Text(
          '$current / $total',
          style: const TextStyle(color: Colors.white, fontSize: 12),
        ),
      );
    });
  }
}