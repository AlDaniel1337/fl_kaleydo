import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit_video/media_kit_video.dart';

import 'package:kaleydo/app/modules/media_player/controllers/media_player_controller.dart';
import 'package:kaleydo/app/modules/media_player/utils/player_shortcuts.dart';
import './components/components.index.dart';

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
                child: Stack(
                  children: [
                    // 1. Capa de Video
                    Center(
                      child: Video(controller: controller.videoController),
                    ),

                    // 2. Capa Interactiva Base (Play/Pause + Overlay de Brillo)
                    _BrightnessOverlay(controller: controller),

                    // 3. OSD Overlay
                    const PlayerOsd(),

                    // 4. Controles principales (HUD Header & Footer)
                    _VideoPlayerControls(controller: controller),

                    // 5. Banners de Navegación de Episodios
                    _EpisodeBanner(controller: controller, isNext: false),
                    _EpisodeBanner(controller: controller, isNext: true),
                  ],
                ),
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

/// Capa interactiva que maneja el tap global para Play/Pause y aplica el filtro de brillo.
class _BrightnessOverlay extends StatelessWidget {
  const _BrightnessOverlay({required this.controller});

  final MediaPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: controller.togglePlayPause,
      child: Obx(() {
        final darkness = (1.0 - controller.brightness.value).clamp(0.0, 1.0);
        if (darkness <= 0.0) return const SizedBox.expand();

        return Container(
          color: Colors.black.withValues(alpha: darkness),
        );
      }),
    );
  }
}



/// Controles principales del reproductor de medios (Header y Footer con gradiente).
class _VideoPlayerControls extends StatelessWidget {
  const _VideoPlayerControls({required this.controller});

  final MediaPlayerController controller;

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      final areVisible = controller.isControlsVisible.value;

      return IgnorePointer(
        ignoring: !areVisible,
        child: AnimatedOpacity(
          opacity: areVisible ? 1.0 : 0.0,
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
                
                const PlayerHeaderControls(),

                // Área central vacía que retransmite el tap para Play/Pause
                Expanded(
                  child: GestureDetector(
                    behavior: HitTestBehavior.translucent,
                    onTap: controller.togglePlayPause,
                    child: const SizedBox.expand(),
                  ),
                ),

                const PlayerFooterControls(),
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
            ? controller.playNextEpisode
            : controller.playPreviousEpisode,
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