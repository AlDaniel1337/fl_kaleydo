import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../controllers/media_player_controller.dart';

abstract class PlayerShortcuts {
  /// Retorna la lista de atajos de teclado vinculados a las acciones del controlador.
  static Map<ShortcutActivator, VoidCallback> getBindings(MediaPlayerController controller) {
    return {
      // 1. Reproducción y Pausa
      const SingleActivator(LogicalKeyboardKey.space): controller.togglePlayPause,
      const SingleActivator(LogicalKeyboardKey.keyK): controller.togglePlayPause,

      // 2. Saltos de Tiempo (10s con Flechas / J / L)
      const SingleActivator(LogicalKeyboardKey.arrowLeft): () => controller.seekRelative(-10),
      const SingleActivator(LogicalKeyboardKey.arrowRight): () => controller.seekRelative(10),
      const SingleActivator(LogicalKeyboardKey.keyJ): () => controller.seekRelative(-10),
      const SingleActivator(LogicalKeyboardKey.keyL): () => controller.seekRelative(10),

      // 3. Saltos por Porcentaje de Video (Teclas 0 a 9)
      const SingleActivator(LogicalKeyboardKey.digit0): () => controller.seekToPercentage(0),
      const SingleActivator(LogicalKeyboardKey.digit1): () => controller.seekToPercentage(10),
      const SingleActivator(LogicalKeyboardKey.digit2): () => controller.seekToPercentage(20),
      const SingleActivator(LogicalKeyboardKey.digit3): () => controller.seekToPercentage(30),
      const SingleActivator(LogicalKeyboardKey.digit4): () => controller.seekToPercentage(40),
      const SingleActivator(LogicalKeyboardKey.digit5): () => controller.seekToPercentage(50),
      const SingleActivator(LogicalKeyboardKey.digit6): () => controller.seekToPercentage(60),
      const SingleActivator(LogicalKeyboardKey.digit7): () => controller.seekToPercentage(70),
      const SingleActivator(LogicalKeyboardKey.digit8): () => controller.seekToPercentage(80),
      const SingleActivator(LogicalKeyboardKey.digit9): () => controller.seekToPercentage(90),

      // 4. Control de Volumen
      const SingleActivator(LogicalKeyboardKey.arrowUp): () => controller.setVolume(controller.volume.value + 5),
      const SingleActivator(LogicalKeyboardKey.arrowDown): () => controller.setVolume(controller.volume.value - 5),
      const SingleActivator(LogicalKeyboardKey.keyM): controller.toggleMute,

      // 5. Salida
      const SingleActivator(LogicalKeyboardKey.escape): () {
        if (controller.isFullScreen.value) {
          controller.toggleFullScreen();
        } else {
          controller.exitPlayer();
        }
      },
    };
  }
}