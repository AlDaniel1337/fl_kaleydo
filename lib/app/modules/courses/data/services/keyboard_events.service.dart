import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../presentation/controllers/course_player_controller.dart';

/// Servicio para manejar eventos de teclado en el reproductor de cursos.
class KeyboardEventsService {

  static KeyEventResult playerEventHandler({
    required FocusNode node, 
    required KeyEvent event, 
    required CoursePlayerController controller
  }) {
    // Solo escuchamos cuando la tecla se presiona hacia abajo (KeyDownEvent)
    if (event is KeyDownEvent) {
      if (event.logicalKey == LogicalKeyboardKey.space) {
        controller.video.togglePlayPause();
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowRight) {
        controller.video.skipForward();
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowLeft) {
        controller.video.skipBackward();
        return KeyEventResult.handled;
      }
      // Puedes agregar atajos para el volumen con Flecha Arriba/Abajo si lo deseas
      else if (event.logicalKey == LogicalKeyboardKey.arrowUp) {
        controller.video.changeVolume(10.0);
        return KeyEventResult.handled;
      } else if (event.logicalKey == LogicalKeyboardKey.arrowDown) {
        controller.video.changeVolume(-10.0);
        return KeyEventResult.handled;
      }
    }

    return KeyEventResult.ignored;
  }
}