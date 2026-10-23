import 'dart:async';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';

class CourseVideoController extends GetxController {

  late final Player player;
  late final VideoController videoController;

  final RxDouble playbackSpeed = 1.0.obs;
  final RxDouble currentVolume = 100.0.obs;
  final RxBool showVolumeIndicator = false.obs;
  Timer? _volumeTimer;

  @override
  void onInit() {
    super.onInit();
    player = Player(
      
    );
    videoController = VideoController(player);
    player.setVolume(100.0);
    currentVolume.value = 100.0;
  }

  @override
  void onClose() {
    _volumeTimer?.cancel();
    final playerToDispose = player;
    Future.microtask(() async {
      await playerToDispose.stop();
      await playerToDispose.dispose();
    });
    super.onClose();
  }

  /// Carga un video en el reproductor 
  /// - Lo posiciona en la posición guardada si es mayor a 2 segundos.
  Future<void> loadVideo(String videoPath, double savedPosition) async {
    await player.open(Media(videoPath), play: false);

    if (savedPosition > 2.0) {
      await Future.delayed(const Duration(milliseconds: 300));
      await player.seek(Duration(seconds: savedPosition.toInt()));
    }

    await player.play();
  }


  /// Alterna entre reproducir y pausar el video.
  void togglePlayPause() => player.playOrPause();


  /// Establece la velocidad de reproducción del video.
  void setSpeed(double speed) {
    playbackSpeed.value = speed;
    player.setRate(speed);
  }


  /// Salta 10 segundos hacia adelante en el video.
  void skipForward() {
    final newPosition = player.state.position + const Duration(seconds: 10);
    player.seek(newPosition);
  }


  /// Salta 10 segundos hacia atrás en el video.
  void skipBackward() {
    Duration newPosition = player.state.position - const Duration(seconds: 10);
    if (newPosition < Duration.zero) {
      newPosition = Duration.zero;
    }
    player.seek(newPosition);
  }


  /// Cambia el volumen del reproductor en un delta dado.
  void changeVolume(double delta) {
    double newVolume = (currentVolume.value + delta).clamp(0.0, 300.0);
    currentVolume.value = newVolume;
    player.setVolume(newVolume);

    showVolumeIndicator.value = true;
    _volumeTimer?.cancel();
    _volumeTimer = Timer(const Duration(seconds: 2), () {
      showVolumeIndicator.value = false;
    });
  }
}