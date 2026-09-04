import 'dart:async';
import 'package:get/get.dart';
import 'package:window_manager/window_manager.dart';

/// Mixin que proporciona funcionalidades relacionadas con la interfaz de usuario del reproductor, como pantalla completa, OSD y temporizadores.
mixin PlayerUIMixin on GetxController {
  
  //: Referencias necesarias
  RxBool get isPlaying;

  //: Estados de configuración y UI (OSD / controles)
  final RxBool isFullScreen = false.obs;
  final RxBool isControlsVisible = true.obs;
  final RxString osdText = ''.obs;

  //: Temporizadores de UI (OSD / controles)
  Timer? osdTimer;
  Timer? hideTimer;



  //+ Gestión de UI (pantalla completa, OSD y temporizadores)
  /// Alterna el estado de pantalla completa del reproductor.
  Future<void> toggleFullScreen() async {
    isFullScreen.value = !isFullScreen.value;
    await windowManager.setFullScreen(isFullScreen.value);
  }

  /// Muestra los controles del reproductor cuando se detecta movimiento del ratón.
  void onMouseMove() {
    isControlsVisible.value = true;
    startHideControlsTimer();
  }

  /// Inicia un temporizador para ocultar los controles del reproductor después de un período de inactividad del ratón.
  void startHideControlsTimer() {
    hideTimer?.cancel();
    hideTimer = Timer(const Duration(milliseconds: 2000), () {
      if (isPlaying.value) {
        isControlsVisible.value = false;
      }
    });
  }

  /// Muestra un mensaje en la pantalla de visualización en pantalla (OSD) durante un breve período.
  void showOSD(String text) {
    osdText.value = text;
    osdTimer?.cancel();
    osdTimer = Timer(const Duration(milliseconds: 600), () {
      osdText.value = '';
    });
  }

  void cancelUITimers() {
    osdTimer?.cancel();
    hideTimer?.cancel();
  }
  //!+
}