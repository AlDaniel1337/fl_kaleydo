import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:kaleydo/app/modules/media_player/controllers/media_player_controller.dart';

class PlayerProgressBar extends GetView<MediaPlayerController> {
  const PlayerProgressBar({super.key});

  @override
  Widget build(BuildContext context) {
    // Control de arrastre y temporizador para debounce
    final RxBool isDragging = false.obs;
    final RxDouble dragValue = 0.0.obs;
    Timer? debounceTimer;

    return Obx(() {
      final double maxDuration = controller.getMediaMaxDuration;
      final double actualPosition = controller.getPositionInMilliseconds.clamp(0.0, maxDuration);

      // Mientras se arrastra la barra, la interfaz usa la posición de tu dedo.
      // Cuando no se arrastra, sigue la reproducción normal.
      final double displayValue = isDragging.value 
          ? dragValue.value.clamp(0.0, maxDuration) 
          : actualPosition;

      return SliderTheme(
        data: SliderThemeData(
          trackHeight: 2,
          thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
          activeTrackColor: AppColors.primaryAccent,
          inactiveTrackColor: Colors.white24,
          thumbColor: AppColors.primaryAccent,
          overlayColor: AppColors.primaryAccent.withValues(alpha: 0.2),
          overlayShape: const RoundSliderOverlayShape(overlayRadius: 12),
        ),
        child: Slider(
          min: 0.0,
          max: maxDuration > 0 ? maxDuration : 1.0,
          value: displayValue,
          onChangeStart: (val) {
            isDragging.value = true;
            dragValue.value = val;
          },
          onChanged: (val) {
            dragValue.value = val; // Mantiene la bolita exactamente en tu dedo

            // DEBOUNCE: Cancela búsquedas previas y envía una sola cada 15ms
            debounceTimer?.cancel();
            debounceTimer = Timer(const Duration(milliseconds: 15), () {
              controller.seekTo(Duration(milliseconds: val.toInt()));
            });
            controller.startHideControlsTimer();
          },
          onChangeEnd: (val) {
            debounceTimer?.cancel();
            
            // Le da un pequeño margen al reproductor para estabilizarse antes de devolverle el control
            Future.delayed(const Duration(milliseconds: 150), () {
              isDragging.value = false;
            });
          },
        ),
      );
    });
  }
}