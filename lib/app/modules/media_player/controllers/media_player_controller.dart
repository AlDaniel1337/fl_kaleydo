import 'dart:async';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart';
import 'package:window_manager/window_manager.dart';

class MediaPlayerController extends GetxController {

  //: Intancias
  // Instancias y propiedades de media_kit
  late final Player player;
  late final VideoController videoController;


  //: Estados reactivos 
  // Estados de reproducción y tiempo
  final RxBool isPlaying = false.obs;
  final Rx<Duration> position = Duration.zero.obs;
  final Rx<Duration> duration = Duration.zero.obs;
  
  // Estados de ajustes de audio, velocidad y brillo
  final RxDouble playbackSpeed = 1.0.obs;
  final RxDouble volume = 100.0.obs;
  double _previousVolume = 0.0;
  final RxDouble brightness = 1.0.obs;

  // Estados de subtítulos
  final RxList<SubtitleTrack> availableSubtitles = <SubtitleTrack>[].obs;
  final Rx<SubtitleTrack> currentSubtitle = SubtitleTrack.no().obs;
  SubtitleTrack _lastSelectedSubtitle = SubtitleTrack.no();

  // Estados de pistas de audio
  final RxList<AudioTrack> availableAudioTracks = <AudioTrack>[].obs;
  final Rx<AudioTrack> currentAudioTrack = AudioTrack.auto().obs;


  // Estados de configuración y UI (OSD / controles)
  final RxBool isFullScreen = false.obs;
  final RxBool isControlsVisible = true.obs;
  final RxBool isFastSeeking = true.obs; // Por defecto en modo Rápido
  final RxString osdText = ''.obs;

  Timer? _osdTimer;
  Timer? _hideTimer;



  @override
  void onInit() {
    super.onInit();
    final String videoPath = Get.arguments as String;

    player = Player();
    videoController = VideoController(player);

    _listenToStreams();

    player.open(Media(videoPath)).then((_) {
      _applySeekingMode(isFastSeeking.value);
    });

    _startHideControlsTimer();
  }



  //: Key Listeners (Streams del reproductor)
  /// Escucha los streams del reproductor para actualizar los estados reactivos.
  void _listenToStreams() {
    // Escuchar estado de reproducción y tiempo
    player.stream.playing.listen((val) => isPlaying.value = val);
    player.stream.position.listen((val) => position.value = val);
    player.stream.duration.listen((val) => duration.value = val);
    player.stream.volume.listen((val) => volume.value = val);
    player.stream.rate.listen((val) => playbackSpeed.value = val);

    // Escuchar pistas disponibles y seleccionadas
    player.stream.tracks.listen((tracks) {
      availableSubtitles.assignAll(tracks.subtitle);
      availableAudioTracks.assignAll(tracks.audio);
    });

    player.stream.track.listen((track) {
      currentSubtitle.value = track.subtitle;
      currentAudioTrack.value = track.audio;
    });
  }



  @override
  void onClose() {
    _osdTimer?.cancel();
    _hideTimer?.cancel();

    final playerToDispose = player;
    Future.microtask(() async {
      await playerToDispose.stop();
      await playerToDispose.dispose();
    });

    super.onClose();
  }


  //+ Reproducción
  /// Alterna entre reproducir y pausar el video.
  void togglePlayPause() {
    player.playOrPause();
    _startHideControlsTimer();
  }

  /// Salta a una posición específica en el video.
  void seekTo(Duration pos) => player.seek(pos);

  /// Salta hacia adelante o hacia atrás en el video en función de los segundos proporcionados.
  void seekRelative(int seconds) {
    final newPos = position.value + Duration(seconds: seconds);
    final clampedPos = Duration(
      milliseconds: newPos.inMilliseconds.clamp(0, duration.value.inMilliseconds),
    );
    player.seek(clampedPos);
    _showOSD(seconds > 0 ? '+${seconds}s' : '${seconds}s');
  }
  //!+



  //+ Navegación
  /// Salir del reproductor, deteniendo la reproducción y cerrando la pantalla.
  Future<void> exitPlayer() async {
    FocusManager.instance.primaryFocus?.unfocus();

    if (isFullScreen.value) {
      isFullScreen.value = false;
      await windowManager.setFullScreen(false);
    }

    await player.pause();
    Get.back();
  }
  //!+



  //+ Velocidad de reproducción
  /// Establece la velocidad de reproducción del video.
  void setSpeed(double speed) {
    playbackSpeed.value = speed;
    player.setRate(speed);
    _showOSD('Velocidad: ${speed.toStringAsFixed(1)}x');
  }
  //!+



  //+ Volumen del reproductor
  /// Establece el volumen del reproductor.
  void setVolume(double val, {bool shouldMute = false}) {
    if (shouldMute) {
      _previousVolume = volume.value;
      player.setVolume(0.0);
      return;
    }

    final clamped = val.clamp(0.0, 100.0);
    volume.value = clamped;
    player.setVolume(clamped);
    _showOSD('Volumen: ${clamped.toInt()}%');
  }

  /// Ajusta el volumen en función del desplazamiento del scroll.
  void handleScrollVolume(double delta) {
    final newVol = delta < 0 ? volume.value + 5.0 : volume.value - 5.0;
    setVolume(newVol);
  }

  /// Alterna el estado de silencio del reproductor.
  void toggleMute() {
    bool isMuted = volume.value == 0;
    setVolume(
      isMuted ? _previousVolume : 0,
      shouldMute: !isMuted,
    );
  }
  //!+



  //+ Brillo del reproductor
  /// Establece el brillo del reproductor.
  void setBrightness(double val) {
    brightness.value = val.clamp(0.2, 1.0);
    _showOSD('Brillo: ${(brightness.value * 100).toInt()}%');
  }

  /// Ajusta el brillo en función del delta proporcionado.
  void adjustBrightness(double delta) {
    setBrightness(brightness.value + delta);
  }
  //!+



  //+ Audio del reproductor
  /// Establece la pista de subtítulos activa.
  void setSubtitleTrack(SubtitleTrack track) {
  if (track != SubtitleTrack.no()) {
    _lastSelectedSubtitle = track;
  }
  player.setSubtitleTrack(track);
}

  /// Establece la pista de audio activa.
  void setAudioTrack(AudioTrack track) {
    player.setAudioTrack(track);
  }
  //!+



  //+ Subtítulos del reproductor
  /// Alterna entre activar y desactivar los subtítulos.
  void toggleSubtitles() {
    if (availableSubtitles.isEmpty) {
      _showOSD('Sin subtítulos disponibles');
      return;
    }

    final bool isOff = currentSubtitle.value == SubtitleTrack.no();

    if (isOff) {
      // Prioriza el último subtítulo que el usuario seleccionó
      // Si aún existe en la lista actual, usa ese. Si no, usa el 1ro por defecto.
      final SubtitleTrack trackToSelect = ( availableSubtitles.any((t) => t.id == _lastSelectedSubtitle.id))
        ? _lastSelectedSubtitle
        : availableSubtitles.first;

      setSubtitleTrack(trackToSelect);

      final String label = trackToSelect.title ?? trackToSelect.language ?? 'Activados';
      _showOSD('Subtítulos: $label');
    } else {
      _lastSelectedSubtitle = currentSubtitle.value;
      player.setSubtitleTrack(SubtitleTrack.no());
      _showOSD('Subtítulos: Desactivados');
    }
  }
  //!+



  //+ Configuración avanzada y nativa de MPV
  /// Alterna entre el modo de búsqueda rápida y la búsqueda exacta.
  void toggleFastSeeking() {
    isFastSeeking.value = !isFastSeeking.value;
    _applySeekingMode(isFastSeeking.value);
    _showOSD(
      isFastSeeking.value
          ? 'Búsqueda Rápida (Keyframe + Buffer Alto)'
          : 'Búsqueda Exacta (Bajo Consumo)',
    );
  }

  /// Aplica el modo de búsqueda rápida o exacta al reproductor nativo.
  void _applySeekingMode(bool fast) {
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
  //!+



  //+ Gestión de UI (pantalla completa, OSD y temporizadores)
  /// Alterna el estado de pantalla completa del reproductor.
  Future<void> toggleFullScreen() async {
    isFullScreen.value = !isFullScreen.value;
    await windowManager.setFullScreen(isFullScreen.value);
  }

  /// Muestra los controles del reproductor cuando se detecta movimiento del ratón.
  void onMouseMove() {
    isControlsVisible.value = true;
    _startHideControlsTimer();
  }

  /// Inicia un temporizador para ocultar los controles del reproductor después de un período de inactividad del ratón.
  void _startHideControlsTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(milliseconds: 2000), () {
      if (isPlaying.value) {
        isControlsVisible.value = false;
      }
    });
  }

  /// Muestra un mensaje en la pantalla de visualización en pantalla (OSD) durante un breve período.
  void _showOSD(String text) {
    osdText.value = text;
    _osdTimer?.cancel();
    _osdTimer = Timer(const Duration(milliseconds: 1200), () {
      osdText.value = '';
    });
  }
  //!+



  //+ Getters para widgets de UI
  double get getMediaMaxDuration {
    return duration.value.inMilliseconds.toDouble() > 0
      ? duration.value.inMilliseconds.toDouble()
      : 1.0;
  }

  double get getPositionInMilliseconds {
    return position.value.inMilliseconds
      .toDouble()
      .clamp(0.0, duration.value.inMilliseconds.toDouble());
  }
  //!+
}