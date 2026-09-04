import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/modules/media_player/controllers/media_player_controller.dart';
import 'package:kaleydo/app/modules/media_player/utils/duration_formatter.dart';

/// Muestra la duración actual y total del medio en reproducción.
class MediaDurationBadge extends GetView<MediaPlayerController> {
  const MediaDurationBadge({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Obx(() {
        final current = DurationFormatter.format(controller.position.value);
        final total = DurationFormatter.format(controller.duration.value);
        
        return Text(
          '$current / $total',
          style: const TextStyle(color: Colors.white, fontSize: 12),
        );
      }),
    );
  }
}