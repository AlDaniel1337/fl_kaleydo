import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/shared/shared_widgets.index.dart';
import 'package:media_kit/media_kit.dart';
import 'package:kaleydo/app/config/theme/app_colors.dart';
import 'package:kaleydo/app/modules/media_player/controllers/media_player_controller.dart';
import './components.index.dart';

class PlayerFooterControls extends GetView<MediaPlayerController> {
  const PlayerFooterControls({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [

          //: Barra de progreso del reproductor
          Obx(() => SliderTheme(
            data: SliderThemeData(
              trackHeight: 3,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              activeTrackColor: AppColors.primaryAccent,
              inactiveTrackColor: Colors.white24,
              thumbColor: AppColors.primaryAccent,
              overlayColor: AppColors.primaryAccent.withValues(alpha: 0.2),
            ),
            child: Slider(
              min: 0.0,
              max: controller.getMediaMaxDuration,
              value: controller.getPositionInMilliseconds,
              onChanged: (val) {
                controller.seekTo(Duration(milliseconds: val.toInt()));
              },
            ),
          )),
          const SizedBox(height: 4),

          // Fila Inferior de Botones
          Row(
            children: [

              //: Reproducción
              // Botón de Play / Pausa
              Obx(() => IconButton(
                icon: Icon(
                  controller.isPlaying.value 
                    ? Icons.pause_rounded 
                    : Icons.play_arrow_rounded,
                  color: Colors.white,
                  size: 26,
                ),
                onPressed: controller.togglePlayPause,
              )),



              //: Adelantar / Retroceder
              // Saltar -5s / +5s
              IconButton(
                icon: const Icon(Icons.replay_5_rounded, color: Colors.white, size: 22),
                onPressed: () => controller.seekRelative(-5),
              ),
              IconButton(
                icon: const Icon(Icons.forward_5_rounded, color: Colors.white, size: 22),
                onPressed: () => controller.seekRelative(5),
              ),
              const SizedBox(width: 12),



              //: Volumen
              // Control Rápido de Volumen              
              _buildMultiLayerVolumeSlider( controller ),
              const SizedBox(width: 12),



              //: Tiempo
              // Contador de Tiempo Transcurrido / Total
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Obx(() => Text(
                  '${_formatDuration(controller.position.value)} / ${_formatDuration(controller.duration.value)}',
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                )),
              ),
              const SizedBox(width: 12),
              


              //: Velocidad
              // Control deslizante para ajustar la velocidad de reproducción
              Obx(() => HoverCustomSlider(
                icon: Icons.speed,
                mainColor: AppColors.primaryAccent,
                sliderValue: controller.playbackSpeed.value,
                onChanged: (value) => controller.setSpeed(value),
                min: 0.1,
                max: 4.0,
                divisions: 39,
                expandedWidth: 200,
                label: '${controller.playbackSpeed.value.toStringAsFixed(1)}x',
              )),
              const Spacer(),



              //: Subtítulos
              // Manejo de Subtítulos
             Obx(() {
                final isSubActive = controller.currentSubtitle.value != SubtitleTrack.no();

                return QuickAndLongPressIconButton(
                  activeColor: AppColors.primaryAccent,
                  longPressDuration: const Duration(milliseconds: 200),
                  isActive: isSubActive,
                  onTap: () {
                    controller.toggleSubtitles(); 
                  },
                  onLongPress: () {
                    showSubtitlesMenu(context, controller);
                  },
                  icon: Icons.subtitles_rounded,
                );
              }),



              //: Ajustes
              // Menú Principal de Ajustes (Engranaje)
              Builder(
                builder: (buttonContext) {
                  return IconButton(
                    icon: const Icon(Icons.settings_rounded, color: Colors.white, size: 22),
                    tooltip: 'Ajustes',
                    onPressed: () => showSettingsMenu(buttonContext, controller),
                  );
                },
              ),



              //: Full Screen
              //Botón para Pantalla Completa
              Obx(() => FullScreenButton(
                isFullScreen: controller.isFullScreen.value, 
                toggleFullScreen: controller.toggleFullScreen,
              ),),
            ],
          ),
        ],
      ),
    );
  }



  /// Formatea una duración en un string con el formato HH:MM:SS o MM:SS si las horas son 0.
  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '${d.inHours > 0 ? '${d.inHours}:' : ''}$minutes:$seconds';
  }
}




// Widget para el Slider Multicapa de Volumen
Widget _buildMultiLayerVolumeSlider(MediaPlayerController controller) {
  return Obx(() {
    final double vol = controller.volume.value;

    // Calcular el valor del Slider relativo al tramo actual (0.0 a 100.0)
    double currentSegmentValue;
    Color activeColor;
    Color backgroundTrackColor;

    if (vol <= 100.0) {
      // Nivel Base (0% - 100%)
      currentSegmentValue = vol;
      activeColor = Colors.white;
      backgroundTrackColor = Colors.white24;
    } else if (vol <= 200.0) {
      // Nivel Boost 1 (101% - 200%)
      currentSegmentValue = vol - 100.0; // Se llena de 0 a 100 en el 2do nivel
      activeColor = AppColors.primaryAccent; // Rosa
      backgroundTrackColor = Colors.white; // Fondo es el Nivel 1 lleno
    } else {
      // Nivel Boost 2 (201% - 300%)
      currentSegmentValue = vol - 200.0; // Se llena de 0 a 100 en el 3er nivel
      activeColor = const Color(0xFFFF9800); // Naranja
      backgroundTrackColor = AppColors.primaryAccent; // Fondo es el Nivel 2 lleno
    }

    return Row(
      children: [
        // Barra Multicapa de Volumen
        HoverCustomSlider(
          icon: Icons.volume_up_rounded,
          mainColor: activeColor,
          backgroundColor: backgroundTrackColor,
          sliderValue: currentSegmentValue.clamp(0.0, 100.0),
          onChanged: (segmentValue) {

            if( !controller.isVolumeBoostEnabled.value){

              if(segmentValue > 100.0){
                segmentValue = 100.0;
              }

              controller.setVolume(segmentValue);
              return;
            }

            // Mapear el valor del segmento de vuelta al volumen global
            double globalVol;
            if (vol <= 100.0) {
              globalVol = segmentValue;
            } else if (vol <= 200.0) {
              globalVol = 100.0 + segmentValue;
            } else {
              globalVol = 200.0 + segmentValue;
            }
            controller.setVolume(globalVol);
          },
          min: 0.0,
          max: 100.0,
          expandedWidth: 85,
        ),

        // Etiqueta del Porcentaje Actual
        if (vol > 100)
          Padding(
            padding: const EdgeInsets.only(left: 4.0),
            child: Text(
              '${vol.toInt()}%',
              style: TextStyle(
                color: activeColor,
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
      ],
    );
  });
}