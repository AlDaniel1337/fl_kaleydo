import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:kaleydo/app/modules/media_player/controllers/media_player_controller.dart';
import './components/components.index.dart';

class MediaPlayerView extends GetView<MediaPlayerController> {
  static const String route = "/media-player";

  const MediaPlayerView({super.key});

  @override
  Widget build(BuildContext context) {
    return ExcludeSemantics(
      child: CallbackShortcuts(
        bindings: {

          //: Atajos de teclado para el control del reproductor de medios
          const SingleActivator(LogicalKeyboardKey.space): controller.togglePlayPause,
          const SingleActivator(LogicalKeyboardKey.arrowLeft): () => controller.seekRelative(-5),
          const SingleActivator(LogicalKeyboardKey.arrowRight): () => controller.seekRelative(5),
          const SingleActivator(LogicalKeyboardKey.arrowUp): () => controller.setVolume(controller.volume.value + 5),
          const SingleActivator(LogicalKeyboardKey.arrowDown): () => controller.setVolume(controller.volume.value - 5),
          const SingleActivator(LogicalKeyboardKey.escape): () {
            if (controller.isFullScreen.value) {
              controller.toggleFullScreen();
            } else {
              controller.exitPlayer();
            }
          },
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            backgroundColor: Colors.black,
            body: Listener(
              onPointerSignal: (pointerSignal) {
                if (pointerSignal is PointerScrollEvent) {
                  controller.handleScrollVolume(pointerSignal.scrollDelta.dy);
                }
              },
              child: MouseRegion(
                onHover: (_) => controller.onMouseMove(),
                child: Stack(
                  children: [
                    
                    //: Capa de Video con ajuste dinámico de Brillo
                    Center(
                      child: Obx(() => ColorFiltered(
                            colorFilter: ColorFilter.mode(
                              Colors.black.withValues(alpha: 1.0 - controller.brightness.value),
                              BlendMode.darken,
                            ),
                            child: Video(controller: controller.videoController),
                          )),
                    ),

                    //: OSD Overlay
                    const PlayerOsd(),

                    //: Controles
                    Obx(() => AnimatedOpacity(
                          opacity: controller.isControlsVisible.value ? 1.0 : 0.0,
                          duration: const Duration(milliseconds: 200),
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                                colors: [
                                  Colors.black38, 
                                  Colors.transparent, 
                                  Colors.black38
                                ],
                              ),
                            ),
                            child: const Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                PlayerHeaderControls(),
                                PlayerFooterControls(),
                              ],
                            ),
                          ),
                        )),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}