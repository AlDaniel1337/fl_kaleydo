import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';

/// Mixin que proporciona funcionalidades para manejar el modo Mini-Player de la ventana del reproductor.
mixin PlayerMiniPlayerMixin on GetxController {
  
  final RxBool isMiniPlayer = false.obs;
  Size _previousWindowSize = const Size(1280, 720);
  Offset _previousWindowPosition = Offset.zero;

  /// Alterna el modo Mini-Player de la ventana del reproductor.
  /// - Si está activado, la ventana se encoge y se coloca en la esquina inferior derecha.
  /// - Si está desactivado, la ventana vuelve a su tamaño y posición anteriores.
  Future<void> toggleMiniPlayer() async {
    isMiniPlayer.value = !isMiniPlayer.value;

    if (isMiniPlayer.value) {
      // Guardar estado actual antes de encoger
      _previousWindowSize = await windowManager.getSize();
      _previousWindowPosition = await windowManager.getPosition();

      // Desactiva la maximización para anular el doble clic
      await windowManager.setMaximizable(false);
      await windowManager.setAlwaysOnTop(true);

      await windowManager.setTitleBarStyle(TitleBarStyle.hidden); 
      await windowManager.setAspectRatio(16 / 9);
      await windowManager.setMinimumSize(const Size(320, 180));
      
      // Tamaño y posición inicial del mini-player (esquina inferior derecha)
      const miniSize = Size(400, 260);
      await windowManager.setSize(miniSize);
      await windowManager.setAlignment(Alignment.bottomRight);
    } else {
      // Restaurar modo normal
      await windowManager.setMaximizable(true);
      await windowManager.setAlwaysOnTop(false);
      await windowManager.setAspectRatio(0);
      await windowManager.setTitleBarStyle(TitleBarStyle.normal);
      await windowManager.setSize(_previousWindowSize);
      await windowManager.setPosition(_previousWindowPosition);
    }
  }

  @override
  void onClose() {
    // Asegurarse de restaurar la ventana si el usuario cierra el reproductor
    if (isMiniPlayer.value) {
      windowManager.setAlwaysOnTop(false);
      windowManager.setTitleBarStyle(TitleBarStyle.normal);
    }
    super.onClose();
  }

}