import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:kaleydo/app/modules/media_player/controllers/media_player_controller.dart';
import 'package:kaleydo/app/shared/widgets/custom_slider/hover_custom_slider.dart';

/// Control deslizante de volumen con múltiples capas que permite ajustar el volumen y el aumento de volumen.
class MultiLayerVolumeSlider extends GetView<MediaPlayerController> {
  const MultiLayerVolumeSlider({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final double vol = controller.volume.value;
      final bool isBoostEnabled = controller.isVolumeBoostEnabled.value;

      final volumeConfig = _getVolumeConfig(vol);

      return Row(
        mainAxisSize: MainAxisSize.min,
        children: [

          HoverCustomSlider(
            icon: Icons.volume_up_rounded,
            mainColor: volumeConfig.activeColor,
            backgroundColor: volumeConfig.backgroundTrackColor,
            sliderValue: volumeConfig.segmentValue,
            min: 0.0,
            max: 100.0,
            expandedWidth: 85,
            onChanged: (segmentValue) {
              _handleVolumeChange(segmentValue, vol, isBoostEnabled);
            },
          ),

          if (vol > 100)
            Padding(
              padding: const EdgeInsets.only(left: 4.0),
              child: Text(
                '${vol.toInt()}%',
                style: TextStyle(
                  color: volumeConfig.activeColor,
                  fontSize: 11,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      );
    });
  }

  void _handleVolumeChange(double segmentValue, double currentVol, bool isBoostEnabled) {
    if (!isBoostEnabled) {
      controller.setVolume(segmentValue.clamp(0.0, 100.0));
      return;
    }

    double targetBase;
    if (currentVol <= 100.0) {
      targetBase = 0.0;
    } else if (currentVol <= 200.0) {
      targetBase = 100.0;
    } else {
      targetBase = 200.0;
    }

    controller.setVolume(targetBase + segmentValue);
  }

  _VolumeConfig _getVolumeConfig(double vol) {
    if (vol <= 100.0) {
      return _VolumeConfig(
        segmentValue: vol.clamp(0.0, 100.0),
        activeColor: Colors.white,
        backgroundTrackColor: Colors.white24,
      );
    } else if (vol <= 200.0) {
      return _VolumeConfig(
        segmentValue: (vol - 100.0).clamp(0.0, 100.0),
        activeColor: AppColors.primaryAccent,
        backgroundTrackColor: Colors.white,
      );
    } else {
      return _VolumeConfig(
        segmentValue: (vol - 200.0).clamp(0.0, 100.0),
        activeColor: const Color(0xFFFF9800),
        backgroundTrackColor: AppColors.primaryAccent,
      );
    }
  }
}

class _VolumeConfig {
  final double segmentValue;
  final Color activeColor;
  final Color backgroundTrackColor;

  _VolumeConfig({
    required this.segmentValue,
    required this.activeColor,
    required this.backgroundTrackColor,
  });
}