import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';

/// Mixin que proporciona funcionalidades relacionadas con la configuración del reproductor, como velocidad de reproducción, brillo y ajustes avanzados de MPV.
mixin PlayerSettingsMixin on GetxController {

  //: Referencias necesarias
  Player get player;
  void showOSD(String text);
  void saveAllSettings();

  //: Variables reactivas de configuración
  // Estados de ajustes de velocidad y brillo
  final RxDouble playbackSpeed = 1.0.obs;
  final RxDouble brightness = 1.0.obs;

  // Estados de configuración avanzada MPV
  final RxBool isFastSeekingEnabled = true.obs;

  // Estado del Filtro de Nitidez / Escalado HD
  final RxBool isHdEnhancerEnabled = false.obs;



  //+ Velocidad de reproducción
  /// Establece la velocidad de reproducción del video.
  void setSpeed(double speed) {
    playbackSpeed.value = speed;
    player.setRate(speed);
    saveAllSettings();
    showOSD('Velocidad: ${speed.toStringAsFixed(1)}x');
  }
  //!+



  //+ Brillo del reproductor
  /// Establece el brillo del reproductor.
  void setBrightness(double val) {
    brightness.value = val.clamp(0.2, 1.0);
    saveAllSettings();
    showOSD('Brillo: ${(brightness.value * 100).toInt()}%');
  }

  /// Ajusta el brillo en función del delta proporcionado.
  void adjustBrightness(double delta) {
    setBrightness(brightness.value + delta);
  }
  //!+



  //+ Configuración avanzada y nativa de MPV
  /// Alterna entre el modo de búsqueda rápida y la búsqueda exacta.
  void toggleFastSeeking() {
    isFastSeekingEnabled.value = !isFastSeekingEnabled.value;
    applySeekingMode(isFastSeekingEnabled.value);
    saveAllSettings();
    showOSD(
      isFastSeekingEnabled.value
          ? 'Búsqueda Rápida (Keyframe + Buffer Alto)'
          : 'Búsqueda Exacta (Bajo Consumo)',
    );
  }

  /// Aplica el modo de búsqueda rápida o exacta al reproductor nativo.
  void applySeekingMode(bool fast) {
    if (player.platform is NativePlayer) {
      final nativePlayer = player.platform as NativePlayer;

      if (fast) {
        nativePlayer.setProperty('hr-seek', 'no');
        nativePlayer.setProperty('cache', 'yes');
        nativePlayer.setProperty('demuxer-max-bytes', '64MiB');
      } else {
        nativePlayer.setProperty('hr-seek', 'absolute');
        nativePlayer.setProperty('cache', 'auto');
        nativePlayer.setProperty('demuxer-max-bytes', '8MiB');
      }
    }
  }

  /// Alterna la mejora de imagen del reproductor.
  void toggleHdEnhancer() {
    isHdEnhancerEnabled.value = !isHdEnhancerEnabled.value;
    applyHdEnhancer(isHdEnhancerEnabled.value);
    showOSD(isHdEnhancerEnabled.value 
      ? 'Mejora HD / Enfoque Activado' 
      : 'Mejora HD Desactivada');
  }

  /// Aplica la mejora de imagen HD al reproductor nativo según el valor de `enable`.
  void applyHdEnhancer(bool enable) {
    if (player.platform is NativePlayer) {
      final nativePlayer = player.platform as NativePlayer;

      if (enable) {
        // Aplica algoritmo Spline36 + Filtro de Enfoque (Sharpen)
        nativePlayer.setProperty('scale', 'spline36');
        nativePlayer.setProperty('cscale', 'spline36');
        nativePlayer.setProperty('vf', 'sharpen=0.6');
      } else {
        // Restaura el renderizado bilineal estándar y remueve filtros de video
        nativePlayer.setProperty('scale', 'bilinear');
        nativePlayer.setProperty('cscale', 'bilinear');
        nativePlayer.setProperty('vf', '');
      }
    }
  }
  //!+
}