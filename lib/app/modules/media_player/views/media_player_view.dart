import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kaleydo/app/shared/widgets/fps_monitor_overlay/fps_monitor_overlay.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'package:kaleydo/app/modules/media_player/controllers/media_player_controller.dart';
import 'package:kaleydo/app/modules/media_player/utils/player_shortcuts.dart';
import './components/components.index.dart';

import 'package:window_manager/window_manager.dart';

class MediaPlayerView extends GetView<MediaPlayerController> {
  static const String route = "/media-player";

  const MediaPlayerView({super.key});

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CallbackShortcuts(
        bindings: PlayerShortcuts.getBindings(controller),
        child: Focus(
          autofocus: true,
          child: Scaffold(
            backgroundColor: Colors.black,
            body: Listener(
              onPointerSignal: _handlePointerSignal,
              child: MouseRegion(
                onHover: (_) => controller.onMouseMove(),
                onExit: (event) => controller.onMouseExit(),
                child: Obx(() {

                  if (!controller.isPlayerReady.value) {
                    return const Center(child: CircularProgressIndicator());
                  }

                  if (controller.isMiniPlayer.value) {
                    return DragToMoveArea(
                      child: _VideoPlayer(controller: controller, isMiniPlayer: true),
                    );
                  }

                  return _VideoPlayer(controller: controller);
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _handlePointerSignal(PointerSignalEvent pointerSignal) {
    if (pointerSignal is PointerScrollEvent) {
      controller.handleScrollVolume(pointerSignal.scrollDelta.dy);
    }
  }
}

class _VideoPlayer extends StatelessWidget {
  const _VideoPlayer({
    required this.controller,
    this.isMiniPlayer = false,
  });

  final MediaPlayerController controller;
  final bool isMiniPlayer;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        //: Capa de Video (Rep)
        Center(
          child: Video(controller: controller.videoController),
        ),

        //: OSD Overlay
        const PlayerOsd(),
            
        //: Controles principales (HUD Header & Footer)
        _VideoPlayerControls(
          controller: controller,
          isMiniPlayer: isMiniPlayer,
        ),
    
        //: Banners de Navegación de Episodios
        if(!isMiniPlayer) ...[
          _EpisodeBanner(controller: controller, isNext: false),
          _EpisodeBanner(controller: controller, isNext: true),
        ],

      ],
    );
  }
}



/// Controles principales del reproductor de medios (Header y Footer con gradiente).
class _VideoPlayerControls extends StatelessWidget {

  const _VideoPlayerControls({
    required this.controller, 
    this.isMiniPlayer = false
  });

  final MediaPlayerController controller;
  final bool isMiniPlayer;

  @override
  Widget build(BuildContext context) {

    return Obx(() {

      // Determina si los controles deben ser visibles y los valores de opacidad correspondientes.
      final areTheControlsVisible = controller.isImmerseModeEnabled.value
        ? controller.isPlaying.value
        : controller.isControlsVisible.value;
      final values = [[1.0, 0.0], [0.0, 1.0]];
      final opacityValues = !controller.isImmerseModeEnabled.value ? values[0] : values[1];
      
      return MouseRegion(
        cursor: controller.isImmerseModeEnabled.value
        ? !areTheControlsVisible 
          ? SystemMouseCursors.basic 
          : SystemMouseCursors.none
        : SystemMouseCursors.basic,
        child: AnimatedOpacity(
          opacity: areTheControlsVisible ? opacityValues[0] : opacityValues[1],
          duration: const Duration(milliseconds: 200),
          child: Container(
        
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black38,
                  Colors.transparent,
                  Colors.black38,
                ],
              ),
            ),
        
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                
                PlayerHeaderControls(
                  videoTitle: controller.currentEpisodeTitle.value,
                  trailing: FpsMonitorOverlay(
                    player: controller.player,
                  ),
                ),
        
                // Área central vacía que retransmite el tap para Play/Pause
                Expanded(
                  child: Row(
                    children: [
                      
                      // Espacio para retroceder 10 segundos
                      FastForwardOrRewindSpace(
                        isOnRight: false,
                        onTap: () => controller.seekRelative(-10),
                        shouldShowCursor: !controller.isImmerseModeEnabled.value,
                      ),
        
                      // Área central que captura el tap para Play/Pause
                      Expanded(
                        child: GestureDetector(
                          behavior: HitTestBehavior.translucent,
                          onTap: controller.togglePlayPause,
                          onVerticalDragUpdate: controller.isImmerseModeEnabled.value
                            ? (details) {
                              if (details.delta.dy > 0) {
                                controller.setVolume(controller.volume.value - 1);
                              } else if (details.delta.dy < 0) {
                                controller.setVolume(controller.volume.value + 1);
                              }
                            }
                            : null,
                          child: const SizedBox.expand(),
                        ),
                      ),
        
                      // Espacio para avanzar 10 segundos
                      FastForwardOrRewindSpace(
                        isOnRight: true,
                        onTap: () => controller.seekRelative(10),
                        shouldShowCursor: !controller.isImmerseModeEnabled.value
                      ),
        
                    ],
                  ),
                ),
        
                PlayerFooterControls(isMiniPlayer: isMiniPlayer),
              ],
            ),
          ),
        ),
      );
    });
  }
}



/// Componente unificado para los banners de Episodio Previo y Siguiente.
class _EpisodeBanner extends StatelessWidget {
  const _EpisodeBanner({
    required this.controller,
    required this.isNext,
  });

  final MediaPlayerController controller;
  final bool isNext;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final currentIndex = controller.currentIndex;
      final playlist = controller.playlist;

      final targetIndex = isNext ? currentIndex + 1 : currentIndex - 1;
      final hasTarget = targetIndex >= 0 && targetIndex < playlist.length;

      final isBannerVisible = isNext
        ? controller.showNextEpisodeBanner.value
        : controller.showPreviousEpisodeBanner.value;

      final isVisible = isBannerVisible && hasTarget;
      final targetEpisode = hasTarget ? playlist[targetIndex] : null;

      return EpisodeNavigationBanner(
        isNext: isNext,
        isVisible: isVisible,
        episodeTitle: targetEpisode?.title ?? '',
        onTap: isNext
            ? controller.goToNextEpisode
            : controller.goToPreviousEpisode,
        onHoverChanged: (hovering) {
          if (isNext) {
            controller.showNextEpisodeBanner.value = hovering;
          } else {
            controller.showPreviousEpisodeBanner.value = hovering;
          }
        },
      );
    });
  }
}
